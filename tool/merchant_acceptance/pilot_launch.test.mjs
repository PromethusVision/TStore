import test from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {loadRepair,repairPlan,repairedSource,intakeTemplate,assessIntake,reviewCallbacks,installedSchemaMd5} from './pilot_launch_contract.mjs';
import {digest,authPlan,categoryPlan} from './pilot_preparation_contract.mjs';
import {observedLineEndings,mirrorPostAProfile} from './pilot_launch_profile.mjs';
const root=fileURLToPath(new URL('../../',import.meta.url));
const read=name=>readFile(new URL('../../'+name,import.meta.url),'utf8');
const receipt=JSON.parse(await read('docs/data/merchant_pilot_test_installation.json'));
const baseline=JSON.parse(await read('docs/data/merchant_pilot_preparation_baseline.json'));
const profile=JSON.parse(await read('docs/data/merchant_pilot_hosted_profile.json'));
const canonical=await read('supabase/migrations/20260812000600_0006_chat_notifications_account.sql');
const source=await loadRepair(root),target=receipt.target;

test('repair contains only canonical function bodies and expected six literal changes',()=>{
  const fixed=repairedSource(profile,canonical);assert.deepEqual(source.definitions,fixed.definitions);
  assert.equal((source.sql.match(/CREATE OR REPLACE FUNCTION/g)||[]).length,2);
  for(const forbidden of ['DROP ','GRANT ','REVOKE ','ALTER ','UPDATE public.','DELETE FROM public.'])assert(!source.sql.includes(forbidden));
});
test('unknown body changes, missing literals and canonical drift are rejected',()=>{
  for(const mutation of [s=>s.replace('NEW.receiver_id','NEW.sender_id'),s=>s.replace('Yeni mesajÄ±n var','Yeni mesajın var')]){
    const p=structuredClone(profile),sig='create_chat_message_notification()';p.function_definitions[sig]=mutation(p.function_definitions[sig]);
    p.schema.functions.find(f=>f.signature===sig).definition_md5=digest(p.function_definitions[sig],'md5');
    assert.throws(()=>repairedSource(p,canonical));
  }
  assert.throws(()=>repairedSource(profile,canonical.replace('Bir kullanıcı','Başka kullanıcı')));
});
test('only the installed Development target and captured A receipt can produce E',()=>{
  const plan=repairPlan(target,receipt,source);assert.equal(plan.plan.baseline_md5,installedSchemaMd5);assert.equal(plan.plan.remote_authorized,false);
  for(const mutate of [r=>r.target.project_ref='other',r=>r.result='FAIL',r=>r.postcheck.schema_md5='different',r=>r.postcheck.core.ledger.pop()]){
    const r=structuredClone(receipt);mutate(r);assert.throws(()=>repairPlan(target,r,source));
  }
  assert.throws(()=>repairPlan({...target,token:'secret'},receipt,source));
});
test('source substitution cannot be hidden behind a recomputed source digest',()=>{
  const s=structuredClone(source);s.sql+='DROP TABLE public.notifications;';s.sha256_lf=digest(s.sql);assert.throws(()=>repairPlan(target,receipt,s));
  const altered=structuredClone(source);altered.definitions[0].definition=altered.definitions[0].definition.replace('NEW.receiver_id','NEW.sender_id');
  altered.definitions[0].after_md5=digest(altered.definitions[0].definition,'md5');assert.throws(()=>repairPlan(target,receipt,altered));
});
test('atomic candidate keeps distinct approval, drift, authority, rollback and replay boundaries',()=>{
  const r=repairPlan(target,receipt,source);
  for(const guard of ['PILOT_REVIEW_NOT_APPROVED','PILOT_BASELINE_DRIFT','PILOT_COMPETING_WRITER','PILOT_FUNCTION_AUTHORITY_CHANGED','PILOT_TEXT_POSTCHECK','PILOT_UNRELATED_SCHEMA_CHANGE'])assert(r.sql.includes(guard));
  assert(r.sql.includes('IN SHARE ROW EXCLUSIVE MODE'));assert(r.sql.endsWith('COMMIT;\n'));assert(r.preflight.startsWith('BEGIN READ ONLY;'));assert(r.postcheck.startsWith('BEGIN READ ONLY;'));
});
test('empty intake keeps pilot closed instead of manufacturing participants or categories',()=>{
  const report=assessIntake(target,baseline.taxonomy_text,intakeTemplate());
  assert.equal(report.distribution_ready,false);assert.equal(report.remote_authorized,false);assert.equal(report.category_selection,'NOT_SELECTED');
  assert(report.missing.includes('catalog_items_verified'));assert(report.missing.includes('participants_selected'));assert.equal(report.categories,null);
});
test('intake rejects private fields, malformed booleans and implied identity permission',()=>{
  for(const mutate of [x=>x.password='secret',x=>x.email='private@example.invalid',x=>x.participants_selected='true',x=>x.account_identity_reviewed=true,x=>x.account_role_reviewed=true,x=>x.catalog_items_verified=true]){
    const intake=intakeTemplate();mutate(intake);assert.throws(()=>assessIntake(target,baseline.taxonomy_text,intake));
  }
});
let eligible;for(const n of JSON.parse(baseline.taxonomy_text)){try{categoryPlan(target,baseline.taxonomy_text,[n.id]);eligible=n.id;break;}catch{}}
test('explicit category choice remains proposed only and cannot bypass review',()=>{
  const intake=intakeTemplate();intake.product_leaf_ids=[eligible];const report=assessIntake(target,baseline.taxonomy_text,intake);
  assert.equal(report.category_selection,'PROPOSED_ONLY');assert.equal(report.categories.plan.remote_authorized,false);
  for(const ids of [['all'],[eligible,eligible],['00000000-0000-0000-0000-000000000000']])assert.throws(()=>assessIntake(target,baseline.taxonomy_text,{...intake,product_leaf_ids:ids}));
});
test('even all claimed checkpoints cannot auto-authorize release',()=>{
  const intake=intakeTemplate();for(const key of Object.keys(intake))if(typeof intake[key]==='boolean')intake[key]=true;
  intake.product_leaf_ids=[eligible];const report=assessIntake(target,baseline.taxonomy_text,intake);
  assert.equal(report.assessment,'CLAIMED_COMPLETE_REQUIRES_INDEPENDENT_EVIDENCE');assert.equal(report.distribution_ready,false);assert.equal(report.remote_authorized,false);
});
const before={site_url:'http://localhost:3000',redirect_urls:['existing://callback/'],confirm_email:false,smtp_enabled:false};
test('callback review preserves existing URLs and shared Auth settings',()=>{
  const plan=authPlan(target,before);assert.equal(plan.additions.length,4);
  const result=reviewCallbacks(target,before,plan.proposed);assert.equal(result.result,'CONFIGURATION_MATCH_ONLY');assert.equal(result.mail_delivered,false);assert.equal(result.physical_callback_accepted,false);
});
test('callback review rejects wildcard, wrong app, removed entries and unrelated setting changes',()=>{
  const proposed=authPlan(target,before).proposed;
  for(const mutate of [x=>x.redirect_urls.push('**'),x=>x.redirect_urls.push('com.other://login-callback/'),x=>x.redirect_urls.shift(),x=>x.site_url='https://example.com',x=>x.confirm_email=true,x=>x.smtp_enabled=true]){
    const after=structuredClone(proposed);mutate(after);assert.throws(()=>reviewCallbacks(target,before,after));
  }
});
test('new review utilities have no remote transport or apply entry point',async()=>{
  for(const name of ['pilot_launch_contract.mjs','prepare_pilot_launch.mjs']){
    const text=await read('tool/merchant_acceptance/'+name);
    assert(!/from ['"](?:pg|https?|node:https?|node:child_process|@supabase)/.test(text));assert(!/\bfetch\s*\(/.test(text));
  }
});
test('post-A mirror accepts only equivalent observed body newlines',()=>{
  const local="CREATE OR REPLACE FUNCTION public.f()\n RETURNS integer\n LANGUAGE sql\nAS $function$\nSELECT 1;\n$function$\n";
  const observed=local.replace('$function$\nSELECT 1;\n','$function$\r\nSELECT 1;\r\n');
  const hashes={lf_md5:digest(local,'md5'),md5:digest(observed,'md5')};
  assert.equal(observedLineEndings(local,hashes),observed);
  assert.throws(()=>observedLineEndings(local.replace('SELECT 1','SELECT 2'),hashes));
  assert.throws(()=>observedLineEndings(local,{...hashes,md5:'wrong'}));
});
test('post-A mirror cannot touch hosted or alternate local databases',async()=>{
  for(const connectionParameters of [{host:'example.supabase.co',port:55432},{host:'127.0.0.1',port:5432}])
    await assert.rejects(mirrorPostAProfile({connectionParameters,query(){throw Error('must not query');}}));
});
