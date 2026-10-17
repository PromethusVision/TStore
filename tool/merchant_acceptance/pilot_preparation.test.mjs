import test from 'node:test';
import assert from 'node:assert/strict';
import { fileURLToPath } from 'node:url';
import { readFile } from 'node:fs/promises';
import { baselineLedger,projectRef,projectUrl,checkTarget,loadDelta,schemaPlan,categoryPlan,authPlan,cohortPlan,validateBaseline,digest } from './pilot_preparation_contract.mjs';
import {validateObservedFunction,mirrorHostedProfile} from './pilot_hosted_profile.mjs';

test('hosted mirror refuses unknown executable changes and hostile identifiers',()=>{
  validateObservedFunction('example()', 'definition\r\n', 'definition\n');
  assert.throws(()=>validateObservedFunction('example()', 'changed\n', 'definition\n'));
  assert.throws(()=>validateObservedFunction('example();drop table x', 'same','same'));
  assert.throws(()=>validateObservedFunction('unknown()', 'anything', undefined));
  assert.throws(()=>validateObservedFunction('rls_auto_enable()', 'changed managed code',undefined));
  validateObservedFunction('create_chat_message_notification()', 'Yeni mesajÄ±n var','Yeni mesajın var');
  assert.throws(()=>validateObservedFunction('example()', 'Yeni mesajÄ±n var','Yeni mesajın var'));
});
test('hosted mirror cannot use a remote or alternate-port database connection',async()=>{
  for(const connectionParameters of [{host:projectRef+'.supabase.co',port:55432},{host:'127.0.0.1',port:5432}]) await assert.rejects(mirrorHostedProfile({connectionParameters,query:()=>{throw Error('must not query');}}));
});

const target={project_ref:projectRef,project_url:projectUrl};
const root=fileURLToPath(new URL('../../',import.meta.url));
const parent='00000000-0000-4000-8000-000000000001',leaf='00000000-0000-4000-8000-000000000002',sibling='00000000-0000-4000-8000-000000000003';
const taxonomy=()=>[parent,leaf,sibling].map((id,index)=>({id,parent_id:index?parent:null,name:index?'Leaf '+index:'Root',level:index?2:1,is_active:false,is_assignable:false,lifecycle_state:'staged',policy_class:'NORMAL',professional_review_status:'not_required',taxonomy_version:'canonical-v1.0.0'}));
const baseline=()=>({ledger:structuredClone(baselineLedger),tables:['profiles','shops','shop_products','notifications','products','categories','taxonomy_contract_config'].map(n=>({name:'public.'+n,rls:true})).concat({name:'storage.objects',rls:true}),buckets:[],triggers:[{name:'prevent_profile_role_client_escalation',enabled:'O'}],indexes:[{indexname:'shops_owner_user_id_unique_idx',indexdef:'UNIQUE'}],constraints:[{name:'shop_products_shop_product_key',definition:'UNIQUE (shop_id, product_id)'}],policies:['profiles_insert_own','profiles_update_own','shops_owner_create_role_gated','shops_owner_update_role_gated','shop_products_owner_create_role_gated','shop_products_owner_update_role_gated','notifications_select_own','notifications_update_own'].map(policyname=>({policyname}))});

test('only the exact nonproduction target, without credentials or extra overrides',()=>{
  checkTarget(target);
  for(const changed of [{...target,project_ref:'another-project'},{...target,project_url:'http://'+projectRef+'.supabase.co'},{...target,project_url:projectUrl+'/'},{...target,token:'secret'}]) assert.throws(()=>checkTarget(changed));
});
test('historical migration identities cannot be rewritten to repository timestamps',()=>{
  validateBaseline(JSON.stringify(baseline()));
  for(const change of [s=>s.ledger[0].version='20260812000100',s=>s.ledger.pop(),s=>s.ledger.push({version:'99999999999999',name:'future'})]) {
    const s=baseline();change(s);assert.throws(()=>validateBaseline(JSON.stringify(s)));
  }
});
test('partial deployments, extended features, missing RLS/guard/owner policy fail closed',()=>{
  for(const change of [s=>s.tables[0].rls=false,s=>s.tables.push({name:'public.product_identity',rls:true}),s=>s.tables.push({name:'public.push_devices',rls:true}),s=>s.buckets.push({id:'listing-media'}),s=>s.triggers[0].enabled='D',s=>s.policies.pop(),s=>s.indexes=[],s=>s.constraints=[]]) {
    const s=baseline();change(s);assert.throws(()=>validateBaseline(JSON.stringify(s)));
  }
});
test('schema candidate preserves reviewed bodies and records both ledger entries atomically',async()=>{
  const sources=await loadDelta(root), result=schemaPlan(target,JSON.stringify(baseline()),sources);
  for(const s of sources) assert(result.sql.includes(s.body));
  // Original BEGIN/COMMIT text is also retained inside the ledger SQL literal.
  // Real transaction atomicity is checked by the PostgreSQL rehearsal.
  assert(result.sql.endsWith('COMMIT;\n'));
  assert.equal((result.sql.match(/INSERT INTO supabase_migrations.schema_migrations/g)||[]).length,2);
  assert(result.sql.includes('PILOT_BASELINE_DRIFT')); assert(result.sql.includes('PILOT_REVIEW_NOT_APPROVED'));
  assert(result.preflight.includes('BEGIN READ ONLY;')); assert(result.preflight.endsWith('ROLLBACK;\n'));
  assert.equal(result.plan.remote_authorized,false);
});
test('tampered source, body, migration identity or ordering cannot be packed',async()=>{
  const sources=await loadDelta(root);
  for(const change of [s=>s.reverse(),s=>s[0].sql+='\n--changed',s=>s[0].body+='\nSELECT 1;',s=>s[0].name='replacement',s=>s[0].version='99999999999999']) {
    const altered=structuredClone(sources);change(altered);assert.throws(()=>schemaPlan(target,JSON.stringify(baseline()),altered));
  }
});
test('schema approval fingerprint changes with baseline drift and stays target bound',async()=>{
  const sources=await loadDelta(root),s=baseline();
  const a=schemaPlan(target,JSON.stringify(s),sources);
  s.extra='changed';const b=schemaPlan(target,JSON.stringify(s),sources);
  assert.notEqual(a.plan.sha256,b.plan.sha256);assert(!b.sql.includes("IS DISTINCT FROM '"+a.plan.sha256+"'"));
});
test('category candidate activates exact leaves and required ancestry, not siblings',()=>{
  const result=categoryPlan(target,JSON.stringify(taxonomy()),[leaf]);
  assert.deepEqual(result.plan.changes.map(c=>c.id),[parent,leaf]);
  assert.equal(result.plan.changes[0].to.is_assignable,false);
  assert.equal(result.plan.changes[1].to.is_assignable,true);
  assert(!result.sql.includes(sibling)); assert(!result.sql.includes("SET policy_class"));
  assert(!result.sql.includes("SET professional_review_status"));
  assert.equal(result.plan.remote_authorized,false);
});
test('empty, unknown, duplicate and non-leaf selections require review',()=>{
  for(const ids of [[],[parent],[leaf,leaf],['invalid'],['00000000-0000-4000-8000-000000000099']]) assert.throws(()=>categoryPlan(target,JSON.stringify(taxonomy()),ids));
});
test('policy or professional review on any ancestor cannot be bypassed',()=>{
  for(const index of [0,1]) for(const [field,value] of [['policy_class','EXCLUDED'],['policy_class','PROFESSIONAL'],['professional_review_status','pending'],['professional_review_status','rejected']]) {
    const nodes=taxonomy();nodes[index][field]=value;assert.throws(()=>categoryPlan(target,JSON.stringify(nodes),[leaf]));
  }
});
test('missing parent, hierarchy drift and previously active categories cannot be republished',()=>{
  for(const change of [n=>n[1].parent_id=sibling,n=>n[0].parent_id=leaf,n=>n[0].level=2,n=>n[1].is_active=true,n=>n[1].is_assignable=true,n=>n[1].taxonomy_version='other',n=>n.push({...n[1]})]) {
    const nodes=taxonomy();change(nodes);assert.throws(()=>categoryPlan(target,JSON.stringify(nodes),[leaf]));
  }
});
test('category approval cannot be reused for broader selection or changed taxonomy',()=>{
  const first=categoryPlan(target,JSON.stringify(taxonomy()),[leaf]);
  assert.notEqual(first.plan.sha256,categoryPlan(target,JSON.stringify(taxonomy()),[leaf,sibling]).plan.sha256);
  const changed=taxonomy();changed[2].name='renamed';assert.notEqual(first.plan.sha256,categoryPlan(target,JSON.stringify(changed),[leaf]).plan.sha256);
});
test('Auth preparation adds exact callbacks and preserves existing shared settings',()=>{
  const before={site_url:'http://localhost:3000',redirect_urls:['https://existing.example/callback'],confirm_email:false,smtp_enabled:false};
  const p=authPlan(target,before);
  assert.equal(p.additions.length,4);assert(p.proposed.redirect_urls.includes(before.redirect_urls[0]));
  assert.equal(p.proposed.site_url,before.site_url);assert.equal(p.proposed.confirm_email,false);assert.equal(p.proposed.smtp_enabled,false);
  assert(p.additions.every(s=>!s.includes('*')));
  const replay=authPlan(target,p.proposed);assert.deepEqual(replay.additions,[]);
});
test('cohort preparation does not manufacture identities or permit admin/duplicate accounts',()=>{
  const slots=[{slot:'merchant-01',role:'merchant',user_id:null},{slot:'customer-01',role:'customer',user_id:null}];
  assert.equal(cohortPlan(target,slots).ready_for_provision_approval,false);
  for(const changed of [[{...slots[0],role:'admin'}],[{...slots[0],password:'secret'}],[{...slots[0],user_id:leaf},{...slots[1],user_id:leaf}],[slots[0],slots[0]]]) assert.throws(()=>cohortPlan(target,changed));
});
test('preparation module has no network, process execution or remote credential entry point',async()=>{
  const code=await readFile(new URL('./pilot_preparation_contract.mjs',import.meta.url),'utf8');
  assert(!/from ['"](?:pg|node:(?:http|https|net|child_process))['"]|\bfetch\(/.test(code));
  assert.equal(typeof digest('evidence'),'string');
});
