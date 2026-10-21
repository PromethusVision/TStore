import {restoreHistoricalTestSources} from './historical_test_fixture.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import {readFile,writeFile,mkdir,mkdtemp,copyFile,readdir,rm,realpath} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {prepareCohort} from './prepare_pilot_cohort.mjs';
import {cohortTemplate,cohortSources,postCeSchemaMd5} from './pilot_cohort_contract.mjs';
import {categoryInventory} from './prepare_pilot.mjs';
import {digest} from './pilot_preparation_contract.mjs';
const source=fileURLToPath(new URL('../../',import.meta.url));
async function fixture(t){const prefix=resolve(tmpdir(),'esnaftavar-cohort-'),repo=await mkdtemp(prefix);t.after(async()=>{assert(repo.startsWith(prefix));assert.equal(await realpath(repo),repo);await rm(repo,{recursive:true});});
 const paths=[...cohortSources,'docs/data/merchant_pilot_preparation_baseline.json','docs/data/merchant_pilot_cohort_acceptance.json'];
 for(const path of paths){await mkdir(dirname(resolve(repo,path)),{recursive:true});await copyFile(resolve(source,path),resolve(repo,path));}await restoreHistoricalTestSources(source,repo,'docs/data/merchant_pilot_cohort_acceptance.json','b5607c51f7a52afaeedfd3b0e0333fda592477a9');return repo;}
test('default bundle has missing facts and no mutation or completed-installation replay',async t=>{const repo=await fixture(t);const result=await prepareCohort(repo,'empty-cohort');assert.equal(result.report.distribution_ready,false);assert.equal(result.report.remote_authorized,false);const files=await readdir(result.directory);assert.deepEqual(files.sort(),['bundle.json','category-inventory.json','intake.template.json','observation.readonly.sql','readiness.json']);for(const item of result.manifest.files)assert.equal(digest((await readFile(resolve(result.directory,item.path),'utf8')).replaceAll('\r\n','\n')),item.sha256_lf);assert.equal(result.manifest.contains_private_account_ids,false);});
test('output overwrite and path/flag injection refuse without changing prior bundle',async t=>{const repo=await fixture(t);for(const slug of ['../outside','C:\\outside','--apply','aa','folder/name'])await assert.rejects(prepareCohort(repo,slug));const result=await prepareCohort(repo,'one-cohort');const before=await readFile(resolve(result.directory,'bundle.json'),'utf8');await assert.rejects(prepareCohort(repo,'one-cohort'));assert.equal(await readFile(resolve(result.directory,'bundle.json'),'utf8'),before);});
test('source or proof drift refuses review package even with unchanged schema label',async t=>{const repo=await fixture(t),path=resolve(repo,cohortSources[0]);const original=await readFile(path,'utf8');await writeFile(path,original+'\n// changed\n');await assert.rejects(prepareCohort(repo,'changed-source'));await writeFile(path,original);const proofPath=resolve(repo,'docs/data/merchant_pilot_cohort_acceptance.json'),proof=JSON.parse(await readFile(proofPath,'utf8'));proof.checks.pop();await writeFile(proofPath,JSON.stringify(proof));await assert.rejects(prepareCohort(repo,'incomplete-proof'));});
test('foreign target, private fields and false participant completion are rejected',async t=>{const repo=await fixture(t);const input=cohortTemplate();input.accounts[0].email='private@example.invalid';await assert.rejects(prepareCohort(repo,'private-input',input));const path=resolve(repo,'docs/data/merchant_pilot_test_ce_installation.json'),receipt=JSON.parse(await readFile(path,'utf8'));receipt.target.project_ref='production';await writeFile(path,JSON.stringify(receipt));await assert.rejects(prepareCohort(repo,'wrong-target'));});
test('chosen categories without observation still produce no write plan',async t=>{const repo=await fixture(t),base=JSON.parse(await readFile(resolve(repo,'docs/data/merchant_pilot_preparation_baseline.json'),'utf8'));const input=cohortTemplate();input.category_leaf_ids=[categoryInventory(base.target,base.taxonomy_text).find(x=>x.eligible).id];const result=await prepareCohort(repo,'await-observation',input);assert(!(await readdir(result.directory)).includes('category.review.sql'));});
test('exact existing-account snapshot emits distinct guarded proposals but no catalog seed',async t=>{
 const repo=await fixture(t),base=JSON.parse(await readFile(resolve(repo,'docs/data/merchant_pilot_preparation_baseline.json'),'utf8'));
 const input=cohortTemplate();input.category_leaf_ids=[categoryInventory(base.target,base.taxonomy_text).find(x=>x.eligible).id];
 input.accounts[0].user_id='11111111-1111-4111-8111-111111111111';input.accounts[1].user_id='22222222-2222-4222-8222-222222222222';input.accounts.forEach(a=>a.identity_review_ref='synthetic-review');
 const observation={schema_md5:postCeSchemaMd5,taxonomy_md5:digest(base.taxonomy_text,'md5'),catalog_md5:'a'.repeat(32),decisions_enabled:false,product_count:0,catalog:[],accounts:input.accounts.map(a=>({id:a.user_id,role:'customer',profile_md5:'b'.repeat(32),auth_created_at:'2026-10-17T00:00:00+00:00',email_confirmed:true,email_matches:true,banned:null,deleted:false,anonymous:false,owned_shops:0}))};
 const result=await prepareCohort(repo,'synthetic-review',input,observation),files=await readdir(result.directory);
 assert(files.includes('roles.review.sql')&&files.includes('category.review.sql'));assert(!files.some(n=>n.includes('catalog.')||n.includes('schema.review')||n.includes('notification')));assert.equal(result.manifest.contains_private_account_ids,true);assert.equal(result.report.distribution_ready,false);assert.equal(result.report.catalog.publication_sql_generated,false);
 observation.accounts.pop();await assert.rejects(prepareCohort(repo,'missing-account',input,observation));
});
