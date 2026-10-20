import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFile,writeFile,copyFile,mkdir,mkdtemp,realpath,access,rm,symlink} from 'node:fs/promises';
import {resolve,dirname,sep} from 'node:path';
import {tmpdir} from 'node:os';
import {randomUUID} from 'node:crypto';
import {fileURLToPath} from 'node:url';
import {readHistoricalContracts,verifyCurrentReadiness,validateRepositoryResult,repositoryProofPath,historicalReadinessSha} from './pilot_current_contract.mjs';
import {captureUiSources,uiChecks,uiProofPath,fixtureBaselineCommit,databaseChecks} from './pilot_ui_contract.mjs';
import {prepareCurrentPilot} from './prepare_current_pilot.mjs';
import {installedTemplate,installedReviewFiles,installedProofPath} from './pilot_installed_contract.mjs';
import {installedSchemaMd5} from './pilot_installed_profile.mjs';
import {categoryInventory} from './prepare_pilot.mjs';
import {digest} from './pilot_preparation_contract.mjs';
import {lf} from './pilot_publication_contract.mjs';

const root=fileURLToPath(new URL('../../',import.meta.url));
const baseObservation=JSON.parse(await readFile(resolve(root,'docs/data/merchant_pilot_preparation_baseline.json'),'utf8'));
async function fixture(t){
  const parent=await realpath(tmpdir()),base=await mkdtemp(resolve(parent,'merchant-current-proof-'));
  t.after(async()=>{assert.equal(await realpath(base),base);assert(base.startsWith(parent+sep));await rm(base,{recursive:true});});
  for(const source of await captureUiSources(root)){
    await mkdir(dirname(resolve(base,source.path)),{recursive:true});
    await copyFile(resolve(root,source.path),resolve(base,source.path));
  }
  await records(base);
  return base;
}
// Test-only proof fixtures. Never write these synthetic records to the repo.
async function records(base){
  const original=JSON.parse(await readFile(resolve(base,installedProofPath),'utf8'));
  const common={result:'PASS',remote_access:'NONE',production_writes:'NONE',physical_two_device:'OPEN',
    distribution_ready:false,fixture_baseline_commit:fixtureBaselineCommit,installed_schema_md5:installedSchemaMd5,
    sources:await captureUiSources(base)};
  await writeFile(resolve(base,uiProofPath),JSON.stringify({...common,kind:'merchant-pilot-ui-local-only-v1',
    checks:uiChecks.map(name=>({name,result:'PASS'})),database_postchecks:databaseChecks}));
  await writeFile(resolve(base,repositoryProofPath),JSON.stringify({...common,kind:'merchant-pilot-current-repositories-local-v1',
    historical_readiness_sha256_lf:historicalReadinessSha,checks:original.client_checks,
    database_postchecks:databaseChecks.map(x=>x==='no verified sale invented'?'one synthetic legacy QR purchase; physical acceptance OPEN':x)}));
}
test('current UI and repositories renew only the observed wiring source; defaults emit no mutations',async t=>{
  const base=await fixture(t),evidence=await verifyCurrentReadiness(base);
  assert.deepEqual(evidence.renewed.map(x=>x.path),['lib/features/merchant/runtime/merchant_runtime.dart']);
  for(const mode of ['cohort','publication']){
    const r=await prepareCurrentPilot(base,mode,'empty-'+mode);
    assert.equal(r.report.status,'INCOMPLETE_NO_MUTATION');assert.equal(r.manifest.remote_authorized,false);
    assert.equal(r.manifest.contains_private_ids,false);
    assert(!r.manifest.files.some(f=>f.path.endsWith('.review.sql')));
    assert.deepEqual(r.manifest.proofs,evidence.proofs);
    for(const f of r.manifest.files)assert.equal(digest(lf(await readFile(resolve(r.directory,f.path),'utf8'))),f.sha256_lf);
  }
});
test('source drift refuses preparation before creating an output directory',async t=>{
  const base=await fixture(t);
  await writeFile(resolve(base,'lib/features/auth/data/repositories/auth_repository_impl.dart'),'// changed\n',{flag:'a'});
  await assert.rejects(prepareCurrentPilot(base,'cohort','must-not-exist'),/stale/);
  await assert.rejects(access(resolve(base,'.buildlog/pilot-current-review/must-not-exist')));
});
test('even fresh client records cannot admit a different runtime wiring delta',async t=>{
  const base=await fixture(t);
  await writeFile(resolve(base,'lib/features/merchant/runtime/merchant_runtime.dart'),'// another delta\n',{flag:'a'});
  await records(base);
  await assert.rejects(verifyCurrentReadiness(base),/Only the integrated same-session runtime composition delta/);
});
test('new passing client records cannot authorize a changed historical SQL contract',async t=>{
  const base=await fixture(t);
  await writeFile(resolve(base,'supabase/proposals/pilot_catalog_publication_v1.sql'),'\n-- changed contract\n',{flag:'a'});
  await records(base);
  await assert.rejects(verifyCurrentReadiness(base),/Historical server\/preparation contract changed/);
});
test('historical proof tampering is refused even if current source hashes are refreshed',async t=>{
  const base=await fixture(t),path=resolve(base,installedProofPath);
  await writeFile(path,(await readFile(path,'utf8'))+'\n');await records(base);
  await assert.rejects(verifyCurrentReadiness(base),/Pinned J9 evidence changed/);
});
test('missing or incomplete repository pass cannot be replaced by screen pass',async t=>{
  const base=await fixture(t),path=resolve(base,repositoryProofPath);
  const record=JSON.parse(await readFile(path,'utf8'));record.checks.pop();
  await writeFile(path,JSON.stringify(record));await assert.rejects(verifyCurrentReadiness(base));
  await rm(path);await assert.rejects(verifyCurrentReadiness(base));
});
test('repository result must bind this process and all original checkpoints',async()=>{
  const h=await readHistoricalContracts(root),nonce='a'.repeat(48);
  const result={result:'PASS',nonce,checks:h.proof.client_checks};
  assert.equal(validateRepositoryResult(result,nonce,h.proof.client_checks).length,18);
  assert.throws(()=>validateRepositoryResult(result,'b'.repeat(48),h.proof.client_checks));
  assert.throws(()=>validateRepositoryResult({...result,checks:result.checks.slice(1)},nonce,h.proof.client_checks));
});
test('complete reviewed cohort emits exactly the unchanged category and role candidates',async t=>{
  const base=await fixture(t),h=await readHistoricalContracts(base),input=installedTemplate('cohort');
  const taxonomy=baseObservation.taxonomy_text;
  input.category_leaf_ids=[categoryInventory(h.target,taxonomy).find(c=>c.eligible).id];
  input.accounts.forEach(a=>{a.user_id=randomUUID();a.identity_review_ref='synthetic-reviewed-identity';});
  const observation={schema_md5:installedSchemaMd5,taxonomy_md5:digest(taxonomy,'md5'),catalog_md5:'a'.repeat(32),
    decisions_enabled:false,product_count:0,catalog:[],accounts:input.accounts.map(a=>({id:a.user_id,role:'customer',
      profile_md5:'b'.repeat(32),auth_created_at:'2026-10-18T00:00:00Z',email_confirmed:true,email_matches:true,
      banned:null,deleted:false,anonymous:false,owned_shops:0}))};
  const original=installedReviewFiles(h.target,'cohort',input,observation,taxonomy);
  const result=await prepareCurrentPilot(base,'cohort','reviewed-cohort',input,observation,taxonomy);
  assert.equal(result.report.status,'REVIEW_CANDIDATES_ONLY');assert.equal(result.manifest.contains_private_ids,true);
  for(const [path,text] of Object.entries(original.files))assert.equal(await readFile(resolve(result.directory,path),'utf8'),text);
  assert.notEqual(JSON.parse(original.files['roles.plan.json']).sha256,JSON.parse(original.files['categories.plan.json']).sha256);
});
test('unknown private fields and bad names do not create review output',async t=>{
  const base=await fixture(t),input=installedTemplate('cohort');input.password='forbidden';
  await assert.rejects(prepareCurrentPilot(base,'cohort','invalid-private',input));
  for(const name of ['../escape','C:/escape','--apply','https://remote'])await assert.rejects(prepareCurrentPilot(base,'cohort',name));
  await assert.rejects(access(resolve(base,'.buildlog/pilot-current-review')));
});
test('existing output and directory junctions are refused without overwriting',async t=>{
  const base=await fixture(t),outside=await fixture(t);
  const r=await prepareCurrentPilot(base,'cohort','already-prepared');
  const before=await readFile(resolve(r.directory,'bundle.json'),'utf8');
  await assert.rejects(prepareCurrentPilot(base,'cohort','already-prepared'));
  assert.equal(await readFile(resolve(r.directory,'bundle.json'),'utf8'),before);
  await mkdir(resolve(outside,'.buildlog'));
  await symlink(base,resolve(outside,'.buildlog/pilot-current-review'),process.platform==='win32'?'junction':'dir');
  await assert.rejects(prepareCurrentPilot(outside,'cohort','escape-review'),/reparse/);
});
