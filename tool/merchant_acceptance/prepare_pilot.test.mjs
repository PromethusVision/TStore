import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtemp,mkdir,copyFile,readFile,writeFile,readdir,rm,realpath} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {prepareBundle,categoryInventory} from './prepare_pilot.mjs';
import {delta,digest} from './pilot_preparation_contract.mjs';

const source=fileURLToPath(new URL('../../',import.meta.url));
async function fixture(t) {
  const prefix=resolve(tmpdir(),'esnaftavar-pilot-prep-'),repo=await mkdtemp(prefix);
  t.after(async()=>{assert(repo.startsWith(prefix));assert.equal(await realpath(repo),repo);await rm(repo,{recursive:true});});
  const evidence=JSON.parse(await readFile(resolve(source,'docs/data/merchant_pilot_preparation_acceptance.json'),'utf8'));
  const files=['docs/data/merchant_pilot_preparation_baseline.json','docs/data/merchant_pilot_preparation_acceptance.json','docs/data/merchant_pilot_hosted_profile.json',...evidence.sources.map(s=>s.path),...delta.map(s=>'supabase/migrations/'+s.file)];
  for(const path of files) {const dest=resolve(repo,path);await mkdir(dirname(dest),{recursive:true});await copyFile(resolve(source,path),dest);}
  return repo;
}
test('offline bundle has hashed artifacts, no default category activation and no credentials',async t=>{
  const repo=await fixture(t),{directory,manifest}=await prepareBundle(repo,'review-test');
  assert.equal(manifest.remote_authorized,false);assert.equal(manifest.category_selection,'NOT_SELECTED');
  assert(!(await readdir(directory)).includes('category.review.sql'));
  for(const file of manifest.files) assert.equal(digest(await readFile(resolve(directory,file.path))),file.sha256);
  const cohort=JSON.parse(await readFile(resolve(directory,'cohort.example.json'),'utf8'));
  assert(cohort.slots.every(s=>s.user_id===null));assert.equal(cohort.ready_for_provision_approval,false);
  const before=await readFile(resolve(directory,'bundle.json'),'utf8');
  await assert.rejects(prepareBundle(repo,'review-test'));assert.equal(await readFile(resolve(directory,'bundle.json'),'utf8'),before);
});
test('path escapes and execution/credential flags are rejected before output',async t=>{
  const repo=await fixture(t);
  for(const name of ['../escape','C:\\elsewhere','/tmp/other','--apply','--project','--token','aa','review/name']) await assert.rejects(prepareBundle(repo,name));
  await assert.rejects(readdir(resolve(repo,'.buildlog/pilot-review')));
});
test('changed migration or baseline cannot produce a review package',async t=>{
  const repo=await fixture(t),path=resolve(repo,'supabase/migrations',delta[0].file),original=await readFile(path);
  await writeFile(path,Buffer.concat([original,Buffer.from('\n-- changed\n')]));await assert.rejects(prepareBundle(repo,'changed-migration'));
  await writeFile(path,original);
  const base=resolve(repo,'docs/data/merchant_pilot_preparation_baseline.json'),b=JSON.parse(await readFile(base,'utf8'));
  b.schema_text+=' ';await writeFile(base,JSON.stringify(b));await assert.rejects(prepareBundle(repo,'changed-baseline'));
});
test('stale proof, altered target and unreviewed category arguments are refused',async t=>{
  const repo=await fixture(t),path=resolve(repo,'docs/data/merchant_pilot_preparation_baseline.json'),before=await readFile(path,'utf8'),base=JSON.parse(before);
  base.target.project_ref='production';await writeFile(path,JSON.stringify(base));await assert.rejects(prepareBundle(repo,'wrong-target'));
  await writeFile(path,before);await assert.rejects(prepareBundle(repo,'invalid-leaves',['all']));
  const src=resolve(repo,'tool/merchant_acceptance/fixture.mjs');await writeFile(src,(await readFile(src,'utf8'))+'\n// changed\n');await assert.rejects(prepareBundle(repo,'stale-proof'));
});
test('explicit eligible leaves generate a separate proposed-only category plan',async t=>{
  const repo=await fixture(t),base=JSON.parse(await readFile(resolve(repo,'docs/data/merchant_pilot_preparation_baseline.json'),'utf8'));
  const inventory=categoryInventory(base.target,base.taxonomy_text),leaf=inventory.find(x=>x.eligible);
  assert(leaf && inventory.some(x=>!x.eligible));
  const {directory,manifest}=await prepareBundle(repo,'explicit-proposal',[leaf.id]);
  assert.equal(manifest.category_selection,'PROPOSED_ONLY');
  const plan=JSON.parse(await readFile(resolve(directory,'category.plan.json'),'utf8'));assert.deepEqual(plan.leaves,[leaf.id]);assert.equal(plan.remote_authorized,false);
  const blocked=inventory.find(x=>!x.eligible);await assert.rejects(prepareBundle(repo,'blocked-proposal',[blocked.id]));
});
