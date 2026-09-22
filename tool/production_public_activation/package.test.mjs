import test from 'node:test';
import assert from 'node:assert/strict';
import {publicationPlan} from './policy.mjs';
import {parseCsv} from '../taxonomy_migration/lib.mjs';
import {read,hash,manifest,body,directory,stable} from './common.mjs';
import {verify,measure} from './seal.mjs';
import {activate,rollback} from './executor.mjs';
const seal=hash(read(`${directory}/seal.json`));

test('publication plan retains exactly all 24 roots and only qualified terminal leaves',()=>{
 const plan=publicationPlan(),nodes=parseCsv(read('docs/TAXONOMY_W36_CATEGORY_IMPORT.csv')).rows;
 const active=new Map(plan.active.map(n=>[n.id,n.assignable]));
 assert.equal(nodes.filter(n=>!n.PARENT_ID).every(n=>active.get(n.ID)===false),true);
 assert.equal(plan.active.length,325);assert.equal(plan.active.filter(n=>n.assignable).length,247);
 for(const n of nodes.filter(n=>active.has(n.ID))){
  if(n.PARENT_ID)assert.equal(active.has(n.PARENT_ID),true);
  if(active.get(n.ID))assert.equal(nodes.some(c=>c.PARENT_ID===n.ID),false);
 }
});
test('all 20 owner mappings retain their 14 eligible and 6 blocked classifications',()=>{
 const plan=publicationPlan(),active=new Map(plan.active.map(n=>[n.id,n.assignable]));
 const mapping=parseCsv(read('docs/data/production_20_product_canonical_mapping.csv')).rows;
 assert.equal(mapping.length,20);assert.equal(mapping.filter(m=>active.get(m.PROPOSED_CANONICAL_UUID)).length,14);
 assert.equal(mapping.filter(m=>!active.get(m.PROPOSED_CANONICAL_UUID)).length,6);
});
test('every fail-closed qualification remains unpublished',()=>{
 const plan=publicationPlan(),ids=new Set(plan.active.map(n=>n.id));
 for(const q of plan.qualification)if(q.EFFECTIVE_POLICY_GATE!=='PASS'||q.EFFECTIVE_PROFESSIONAL_REVIEW_GATE!=='PASS')assert.equal(ids.has(q.DEVELOPMENT_UUID),false);
});
test('sealed runtime inventory verifies and excludes test/proof/report inputs',()=>{
 assert.equal(verify(seal).result,'PASS');const inputs=measure().map(f=>f.path);
 for(const file of ['executor.mjs','validators.mjs','compatibility.mjs','policy.mjs','activate.sql','rollback.sql','runtime-manifest.json','state-oracle.json'])assert(inputs.includes(`${directory}/${file}`));
 assert.equal(inputs.some(f=>/rehearse|failure-tests|package.test|local-http|local-support|prepare-local|RELEASE_W52L|w52l_a_public_activation_validation/.test(f)),false);
});
test('wrong externally supplied seal rejects before database work',async()=>{
 const db={get transport(){throw Error('DATABASE_MUST_NOT_BE_TOUCHED');}};
 await assert.rejects(activate(db,'0'.repeat(64)),/W52LA_SEAL_HASH/);
 await assert.rejects(rollback(db,'0'.repeat(64)),/W52LA_SEAL_HASH/);
});
test('readiness package refuses a real Production write transport',async()=>{
 const db={transport:{verified:true,kind:'LIVE_PRODUCTION',project_ref:'mefhfvrgkwciubeajjeb'},exec(){throw Error('NO_DB_ACCESS_EXPECTED');}};
 await assert.rejects(activate(db,seal),/W52LA_READINESS_PACKAGE_LOCAL_WRITE_ONLY/);
 await assert.rejects(rollback(db,seal),/W52LA_READINESS_PACKAGE_LOCAL_WRITE_ONLY/);
 assert.equal(manifest().live_write_enabled,false);
});
test('0012 and 0013 remain exactly immutable',()=>{
 assert.equal(hash(read('supabase/migrations/20260916001200_0012_production_canonical_side_by_side.sql')),'a72332213046505047e3e01d0d3795343b4e0d0eff8567388db464536ddc4834');
 assert.equal(hash(read('supabase/migrations/20260919001300_0013_production_canonical_private_preview.sql')),'9b56e249a6e3054b8303742ca4bcc41d40e216de9c1a62a72193e4bae81091a4');
});
test('current client absence is recorded rather than inventing a usable build flag',()=>{
 const m=manifest();assert.equal(m.client_discovery.production_public_runtime_exists,false);assert.equal(m.client_discovery.exact_public_build_recipe_ready,false);
 const main=read('lib/main_production.dart'),adapter=read('lib/features/shop/data/services/supabase_canonical_taxonomy_rpc_adapter.dart');
 assert(main.includes('TaxonomyDependencyConfiguration.legacy('));assert(main.includes('productionPreviewApplication(supabaseConfig)'));
 assert(adapter.includes("static const capabilitiesRpc = 'taxonomy_capabilities_v2'"));
 assert.equal(main.includes('production_taxonomy_roots_v1'),false);
});
