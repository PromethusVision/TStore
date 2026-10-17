import test from 'node:test';
import assert from 'node:assert/strict';
import {readFile,writeFile,mkdir,copyFile,mkdtemp,rm,realpath,readdir} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {prepareLaunch} from './prepare_pilot_launch.mjs';
import {intakeTemplate,repairFile,lf} from './pilot_launch_contract.mjs';
import {digest} from './pilot_preparation_contract.mjs';
const source=fileURLToPath(new URL('../../',import.meta.url));
async function fixture(t){
  const prefix=resolve(tmpdir(),'esnaftavar-pilot-launch-'),repo=await mkdtemp(prefix);
  t.after(async()=>{assert(repo.startsWith(prefix));assert.equal(await realpath(repo),repo);await rm(repo,{recursive:true});});
  const proof=JSON.parse(await readFile(resolve(source,'docs/data/merchant_pilot_launch_acceptance.json'),'utf8'));
  const files=new Set(['docs/data/merchant_pilot_test_installation.json','docs/data/merchant_pilot_preparation_baseline.json','docs/data/merchant_pilot_preparation_acceptance.json','docs/data/merchant_pilot_hosted_profile.json','docs/data/merchant_pilot_launch_acceptance.json','supabase/migrations/20260812000600_0006_chat_notifications_account.sql',...proof.sources.map(s=>s.path)]);
  for(const file of files){await mkdir(dirname(resolve(repo,file)),{recursive:true});await copyFile(resolve(source,file),resolve(repo,file));}
  return repo;
}
test('launch bundle has hashed E/C reviews, empty intake and no A replay or provisioning SQL',async t=>{
  const repo=await fixture(t),{directory,manifest}=await prepareLaunch(repo,'review-test');
  assert.equal(manifest.remote_authorized,false);assert.equal(manifest.distribution_ready,false);assert.equal(manifest.category_B,'NOT_SELECTED');
  const files=await readdir(directory);for(const name of ['schema.review.sql','category.review.sql','provision.sql'])assert(!files.includes(name));
  for(const item of manifest.files)assert.equal(digest(lf(await readFile(resolve(directory,item.path),'utf8'))),item.sha256_lf);
  const intake=JSON.parse(await readFile(resolve(directory,'intake.assessment.json'),'utf8'));assert.equal(intake.assessment,'INCOMPLETE');
  const before=await readFile(resolve(directory,'bundle.json'),'utf8');await assert.rejects(prepareLaunch(repo,'review-test'));assert.equal(await readFile(resolve(directory,'bundle.json'),'utf8'),before);
});
test('launch output rejects escapes, unknown inputs and private intake details',async t=>{
  const repo=await fixture(t);
  for(const name of ['../escape','/tmp/elsewhere','C:\\elsewhere','--apply','--token','ab'])await assert.rejects(prepareLaunch(repo,name));
  await assert.rejects(prepareLaunch(repo,'private-input',{...intakeTemplate(),email:'private@example.invalid'}));
  await assert.rejects(readdir(resolve(repo,'.buildlog/pilot-launch-review')));
});
test('changed source or incomplete evidence cannot generate a review bundle',async t=>{
  const repo=await fixture(t),path=resolve(repo,repairFile),original=await readFile(path,'utf8');
  await writeFile(path,original+'\n-- changed');await assert.rejects(prepareLaunch(repo,'changed-source'));await writeFile(path,original);
  const proofPath=resolve(repo,'docs/data/merchant_pilot_launch_acceptance.json'),proof=JSON.parse(await readFile(proofPath,'utf8'));
  proof.checks.pop();await writeFile(proofPath,JSON.stringify(proof));await assert.rejects(prepareLaunch(repo,'partial-proof'));
  proof.checks.push({name:'restored',result:'PASS'});await writeFile(proofPath,JSON.stringify(proof));
  const runtime=resolve(repo,'tool/merchant_acceptance/pilot_launch.mjs');await writeFile(runtime,(await readFile(runtime,'utf8'))+'\n// changed');await assert.rejects(prepareLaunch(repo,'stale-proof'));
});
