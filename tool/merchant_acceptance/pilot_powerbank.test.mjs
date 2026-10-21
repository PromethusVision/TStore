import test from 'node:test';
import assert from 'node:assert/strict';
import {fileURLToPath} from 'node:url';
import {powerbankManifest,powerbankCategoryPlan,powerbankObservationSql,powerbankRollbackPlan} from './pilot_powerbank_contract.mjs';
import {databaseChecks,clientChecks,validatePowerbankProof} from './prepare_powerbank_pilot.mjs';
import {projectRef,projectUrl} from './pilot_preparation_contract.mjs';
import {installedSchemaMd5} from './pilot_installed_profile.mjs';
const repo=fileURLToPath(new URL('../../',import.meta.url));
const target={project_ref:projectRef,project_url:projectUrl};
const m=await powerbankManifest(repo);
const node=(id,name,parent_id,level)=>({id,name,parent_id,level,is_active:false,is_assignable:false,lifecycle_state:'staged',policy_class:'NORMAL',professional_review_status:'not_required',taxonomy_version:'canonical-v1.0.0'});
const observation=()=>({schema_md5:installedSchemaMd5,categories_md5:'a'.repeat(32),catalog_md5:'b'.repeat(32),category_count:1563,active_count:0,product_count:0,listing_count:0,root:node(m.root_id,'Elektronik',null,1),parent:node(m.parent_id,'Güç, Şarj & Bağlantı',m.root_id,2),children:0,identity_collisions:0});
test('one additive leaf, immutable existing identities and no provisioning authority',()=>{
  const p=powerbankCategoryPlan(target,observation(),m);
  assert.equal(p.plan.remote_authorized,false);
  assert.equal(p.plan.changes.insert.id,m.node.id);
  assert.deepEqual(p.plan.changes.activate_ancestors,[m.root_id,m.parent_id]);
  assert(!/INSERT INTO public\.(products|profiles|shops|shop_products)|GRANT |ALTER TABLE|DELETE FROM/i.test(p.sql));
  assert.equal(p.plan.sha256,powerbankCategoryPlan(target,observation(),m).plan.sha256);
});
test('a different project or forged schema cannot produce a plan',()=>{
  assert.throws(()=>powerbankCategoryPlan({...target,project_ref:'production'},observation(),m));
  assert.throws(()=>powerbankCategoryPlan(target,{...observation(),schema_md5:'c'.repeat(32)},m));
});
test('existing products, listings, activation, child nodes and duplicate identity require new review',()=>{
  for(const key of ['active_count','product_count','listing_count','children','identity_collisions']){
    assert.throws(()=>powerbankCategoryPlan(target,{...observation(),[key]:1},m),undefined,key);
  }
  assert.throws(()=>powerbankCategoryPlan(target,{...observation(),category_count:1564},m));
});
test('parent movement, policy downgrade and pending review are rejected',()=>{
  for(const [key,value] of [['parent_id',null],['policy_class','REGULATED'],['professional_review_status','pending'],['is_assignable',true],['name','Other']]){
    const o=observation();o.parent[key]=value;assert.throws(()=>powerbankCategoryPlan(target,o,m),undefined,key);
  }
});
test('manifest cannot silently change the product decision or allocate another identity',()=>{
  for(const [key,value] of [['id',m.root_id],['name','Medicine'],['policy_class','EXCLUDED'],['level',4],['source_key','CANONICAL-000001']]){
    assert.throws(()=>powerbankCategoryPlan(target,observation(),{...m,node:{...m.node,[key]:value}}),undefined,key);
  }
  assert.throws(()=>powerbankCategoryPlan(target,observation(),{...m,remote_authorized:true}));
  assert.throws(()=>powerbankCategoryPlan(target,observation(),{...m,path:['Telefon','Powerbank']}));
});

const activated=()=>{const o=observation();return {...o,category_count:1564,active_count:3,children:1,identity_collisions:1,root:{...o.root,is_active:true,lifecycle_state:'active'},parent:{...o.parent,is_active:true,lifecycle_state:'active'}};};
test('recovery is a separate review retaining identity and immutable history',()=>{
 const p=powerbankRollbackPlan(target,activated(),m);
 assert.equal(p.plan.remote_authorized,false);assert.equal(p.plan.retained_id,m.node.id);
 assert(!/DELETE FROM|INSERT INTO|ALTER TABLE|GRANT /i.test(p.sql));
 assert.notEqual(p.plan.sha256,powerbankCategoryPlan(target,observation(),m).plan.sha256);
 assert.throws(()=>powerbankRollbackPlan(target,observation(),m));
});
test('recovery refuses product use, changed ownership of category and additional activation',()=>{
 for(const [key,value] of [['product_count',1],['listing_count',1],['children',2],['identity_collisions',2],['active_count',4]])assert.throws(()=>powerbankRollbackPlan(target,{...activated(),[key]:value},m));
 const o=activated();o.parent.parent_id=null;assert.throws(()=>powerbankRollbackPlan(target,o,m));
});
const proof=()=>({kind:'merchant-pilot-powerbank-local-v1',result:'PASS',remote_access:'NONE',production_writes:'NONE',distribution_ready:false,physical_two_device:'OPEN',synthetic_accounts:true,real_catalog_written:false,verified_purchases:0,run_id:'ev-merchant-ab-123456abcdef',nonce_sha256:'a'.repeat(64),source_commit:'b'.repeat(40),captured_at:'2026-10-22T00:00:00Z',installed_schema_md5:installedSchemaMd5,manifest_sha256_lf:'c'.repeat(64),checks:databaseChecks.map(name=>({name,result:'PASS'})),client_checks:structuredClone(clientChecks),sources:[{path:'lib/example.dart',sha256_lf:'d'.repeat(64)}]});
test('readiness binds all exact database and actual client checkpoints',()=>{
 const p=proof();validatePowerbankProof(p,p.sources,p.manifest_sha256_lf);
 for(const key of ['checks','client_checks']){const q=proof();q[key].pop();assert.throws(()=>validatePowerbankProof(q,p.sources,p.manifest_sha256_lf));}
 const q=proof();q.client_checks[0].checks[0]='fake substitute';assert.throws(()=>validatePowerbankProof(q,p.sources,p.manifest_sha256_lf));
});
test('stale code, different manifest and false physical readiness never qualify',()=>{
 const p=proof();assert.throws(()=>validatePowerbankProof(p,[],p.manifest_sha256_lf));
 assert.throws(()=>validatePowerbankProof(p,p.sources,'e'.repeat(64)));
 for(const [key,value] of [['distribution_ready',true],['physical_two_device','PASS'],['remote_access','Development'],['verified_purchases',1]])assert.throws(()=>validatePowerbankProof({...p,[key]:value},p.sources,p.manifest_sha256_lf));
});
test('changed observations bind different review tokens and private input is rejected',()=>{
  const a=powerbankCategoryPlan(target,observation(),m);
  const b=powerbankCategoryPlan(target,{...observation(),categories_md5:'c'.repeat(32)},m);
  assert.notEqual(a.plan.sha256,b.plan.sha256);
  assert.throws(()=>powerbankCategoryPlan(target,{...observation(),email:'private@example.invalid'},m));
  const sql=powerbankObservationSql();assert(sql.startsWith('BEGIN READ ONLY;'));
  assert(!sql.includes('auth.users'));assert(sql.endsWith('ROLLBACK;\n'));
});
