import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFile,writeFile,mkdir,mkdtemp,realpath,copyFile,rm,access,symlink} from 'node:fs/promises';
import {resolve,dirname,sep} from 'node:path';
import {tmpdir} from 'node:os';
import {fileURLToPath} from 'node:url';
import {randomUUID} from 'node:crypto';
import {captureIntegratedSources,readIntegratedContracts,verifyIntegratedReadiness,verifyIntegratedProof,
  validateIntegratedResult,integratedProofs,integratedBaseline,integratedSessionChecks} from './pilot_integrated_contract.mjs';
import {prepareIntegratedPilot} from './prepare_integrated_pilot.mjs';
import {readHistoricalContracts,verifyCurrentReadiness,historicalReadinessSha} from './pilot_current_contract.mjs';
import {installedProofPath,installedTemplate,installedReviewFiles} from './pilot_installed_contract.mjs';
import {fixtureBaselineCommit,uiChecks,databaseChecks} from './pilot_ui_contract.mjs';
import {installedSchemaMd5} from './pilot_installed_profile.mjs';
import {digest} from './pilot_preparation_contract.mjs';
import {categoryInventory} from './prepare_pilot.mjs';
import {restoreHistoricalTestSources} from './historical_test_fixture.mjs';
const root=fileURLToPath(new URL('../../',import.meta.url));
const json=x=>JSON.stringify(x,null,2)+'\n';

async function fixture(t){
  const parent=await realpath(tmpdir()),base=await mkdtemp(resolve(parent,'merchant-integrated-test-'));
  t.after(async()=>{
    assert.equal(await realpath(base),base);assert(base.startsWith(parent+sep));
    await rm(base,{recursive:true});
  });
  for(const s of await captureIntegratedSources(root)){
    await mkdir(dirname(resolve(base,s.path)),{recursive:true});await copyFile(resolve(root,s.path),resolve(base,s.path));
  }
  await records(base);return base;
}
// Shape fixtures only, never saved as real acceptance or used by a live runner.
async function records(base){
  const h=await readIntegratedContracts(base),sources=await captureIntegratedSources(base);
  for(const mode of ['ui','repositories']){
    const p={kind:'merchant-pilot-integrated-'+mode+'-local-v1',result:'PASS',remote_access:'NONE',production_writes:'NONE',
      physical_two_device:'OPEN',distribution_ready:false,integrated_baseline_commit:integratedBaseline,
      fixture_baseline_commit:fixtureBaselineCommit,installed_schema_md5:installedSchemaMd5,
      historical_readiness_sha256_lf:historicalReadinessSha,renewed_sources:h.renewed,
      run_id:'ev-merchant-ab-'+(mode==='ui'?'a':'b').repeat(12),nonce_sha256:(mode==='ui'?'a':'b').repeat(64),sources,
      checks:mode==='ui'?[...uiChecks,...integratedSessionChecks].map(name=>({name,result:'PASS'})):h.proof.client_checks,
      database_postchecks:databaseChecks.map(x=>mode==='repositories'&&x==='no verified sale invented'?'one synthetic legacy QR purchase; physical acceptance OPEN':x)};
    await writeFile(resolve(base,integratedProofs[mode]),json(p));
  }
}
async function mutate(base,mode,fn){const path=resolve(base,integratedProofs[mode]);const p=JSON.parse(await readFile(path,'utf8'));fn(p);await writeFile(path,json(p));}

test('current integrated profile admits only six reviewed clients and the historical test fixture correction',async()=>{
  const h=await readIntegratedContracts(root);assert.equal(h.renewed.length,7);
  assert.equal(h.renewed.filter(s=>s.path.startsWith('lib/')).length,6);
});
test('old J12 entrypoints continue to reject current repository deltas',async()=>{
  await assert.rejects(readHistoricalContracts(root),/Historical server\/preparation contract changed/);
  await assert.rejects(verifyCurrentReadiness(root),/Historical server\/preparation contract changed/);
});
test('both default modes remain incomplete, read-only and local-only',async t=>{
  const base=await fixture(t),e=await verifyIntegratedReadiness(base);
  for(const kind of ['cohort','publication']){
    const r=await prepareIntegratedPilot(base,kind,'default-'+kind);
    assert.equal(r.report.status,'INCOMPLETE_NO_MUTATION');assert.equal(r.manifest.remote_authorized,false);
    assert.equal(r.manifest.contains_private_ids,false);assert.deepEqual(r.manifest.proofs,e.proofs);
    assert(!r.manifest.files.some(f=>f.path.endsWith('.review.sql')));
    const original=installedReviewFiles(e.target,kind,installedTemplate(kind));
    for(const [path,text] of Object.entries(original.files))assert.equal(await readFile(resolve(r.directory,path),'utf8'),text);
  }
});
for(const source of ['lib/features/merchant/data/supabase_merchant_repository.dart','supabase/proposals/pilot_catalog_publication_v1.sql',
  'tool/merchant_acceptance/pilot_installed.test.mjs','docs/data/merchant_pilot_installed_acceptance.json']){
  test('new profile rejects unreviewed pinned drift: '+source,async t=>{
    const base=await fixture(t);await writeFile(resolve(base,source),'\n// drift\n',{flag:'a'});
    await assert.rejects(verifyIntegratedReadiness(base));
    await assert.rejects(prepareIntegratedPilot(base,'cohort','no-output'));
    await assert.rejects(access(resolve(base,'.buildlog/pilot-integrated-review')));
  });
}
for(const source of ['lib/core/new_contract.dart','tool/merchant_acceptance/new_contract.mjs','supabase/proposals/new_contract.sql']){
  test('added source invalidates both prior records: '+source,async t=>{
    const base=await fixture(t);await writeFile(resolve(base,source),'// added\n');
    await assert.rejects(verifyIntegratedReadiness(base),/stale or incomplete/);
  });
}
test('missing source and incomplete manifest are refused',async t=>{
  const base=await fixture(t);await mutate(base,'ui',p=>p.sources.pop());
  await assert.rejects(verifyIntegratedReadiness(base),/stale or incomplete/);
  await rm(resolve(base,'tool/merchant_acceptance/pilot_repository_test.dart'));
  await assert.rejects(verifyIntegratedReadiness(base));
});
test('UI-only, repository-only and cross-run mixed evidence cannot unlock preparation',async t=>{
  const base=await fixture(t),repoPath=resolve(base,integratedProofs.repositories),original=await readFile(repoPath);
  await rm(repoPath);await assert.rejects(verifyIntegratedReadiness(base));await writeFile(repoPath,original);
  await mutate(base,'repositories',p=>p.run_id='ev-merchant-ab-'+'a'.repeat(12));
  await assert.rejects(verifyIntegratedReadiness(base),/Separate fresh fixtures/);
  await writeFile(repoPath,original);await mutate(base,'repositories',p=>p.nonce_sha256='a'.repeat(64));
  await assert.rejects(verifyIntegratedReadiness(base),/Separate executions/);
  await writeFile(repoPath,original);await rm(resolve(base,integratedProofs.ui));await assert.rejects(verifyIntegratedReadiness(base));
});
test('skip, failure, missing session check or database check cannot claim PASS',async t=>{
  const base=await fixture(t),path=resolve(base,integratedProofs.ui),raw=await readFile(path);
  for(const fn of [p=>p.checks.pop(),p=>p.checks[0].result='SKIP',p=>p.result='FAIL',p=>p.database_postchecks.pop(),p=>p.checks.reverse()]){
    await writeFile(path,raw);await mutate(base,'ui',fn);await assert.rejects(verifyIntegratedProof(base,'ui'));
  }
});
test('device, distribution and hosted gates cannot silently become accepted',async t=>{
  const base=await fixture(t),path=resolve(base,integratedProofs.ui),raw=await readFile(path);
  for(const fn of [p=>p.remote_access='HOSTED',p=>p.production_writes='YES',p=>p.physical_two_device='PASS',p=>p.distribution_ready=true,
    p=>p.installed_schema_md5='a'.repeat(32),p=>p.integrated_baseline_commit='0'.repeat(40)]){
    await writeFile(path,raw);await mutate(base,'ui',fn);await assert.rejects(verifyIntegratedReadiness(base));
  }
});
test('process nonce, complete ordered checkpoints and correct mode are mandatory',async()=>{
  const h=await readIntegratedContracts(root),nonce='a'.repeat(48);
  for(const mode of ['ui','repositories']){
    const p={kind:'merchant-pilot-ui-client-local-v1',result:'PASS',nonce,
      checks:mode==='ui'?[...uiChecks,...integratedSessionChecks].map(name=>({name,result:'PASS'})):h.proof.client_checks};
    assert.equal(validateIntegratedResult(p,nonce,mode,h.proof.client_checks).length,18);
    assert.throws(()=>validateIntegratedResult(p,'b'.repeat(48),mode,h.proof.client_checks));
    assert.throws(()=>validateIntegratedResult({...p,checks:p.checks.slice(1)},nonce,mode,h.proof.client_checks));
  }
  assert.throws(()=>validateIntegratedResult({},nonce,'hosted',h.proof.client_checks));
});
test('complete cohort reuses exact state-bound SQL without apply token or schema installer',async t=>{
  const base=await fixture(t),h=await readIntegratedContracts(base),input=installedTemplate('cohort');
  const taxonomy=JSON.parse(await readFile(resolve(root,'docs/data/merchant_pilot_preparation_baseline.json'),'utf8')).taxonomy_text;
  input.category_leaf_ids=[categoryInventory(h.target,taxonomy).find(c=>c.eligible).id];
  input.accounts.forEach(a=>{a.user_id=randomUUID();a.identity_review_ref='synthetic-reviewed-identity';});
  const observation={schema_md5:installedSchemaMd5,taxonomy_md5:digest(taxonomy,'md5'),catalog_md5:'a'.repeat(32),
    decisions_enabled:false,product_count:0,catalog:[],accounts:input.accounts.map(a=>({id:a.user_id,role:'customer',profile_md5:'b'.repeat(32),
      auth_created_at:'2026-10-18T00:00:00Z',email_confirmed:true,email_matches:true,banned:null,deleted:false,anonymous:false,owned_shops:0}))};
  const old=installedReviewFiles(h.target,'cohort',input,observation,taxonomy);
  const r=await prepareIntegratedPilot(base,'cohort','reviewed-cohort',input,observation,taxonomy);
  assert.equal(r.report.status,'REVIEW_CANDIDATES_ONLY');assert.equal(r.manifest.contains_private_ids,true);
  for(const [path,text] of Object.entries(old.files))assert.equal(await readFile(resolve(r.directory,path),'utf8'),text);
  assert(!Object.keys(old.files).some(p=>p.startsWith('schema.')));
});
test('private credentials, unsafe output names and overwrite are refused',async t=>{
  const base=await fixture(t),input=installedTemplate('cohort');input.password='forbidden';
  await assert.rejects(prepareIntegratedPilot(base,'cohort','bad-private',input));
  for(const name of ['../escape','C:/escape','--apply','https://remote'])await assert.rejects(prepareIntegratedPilot(base,'cohort',name));
  const r=await prepareIntegratedPilot(base,'cohort','once-only'),before=await readFile(resolve(r.directory,'bundle.json'));
  await assert.rejects(prepareIntegratedPilot(base,'cohort','once-only'));assert.deepEqual(await readFile(resolve(r.directory,'bundle.json')),before);
});
test('reviewed publication reuses atomic receipt SQL and rejects services or unverified owners',async t=>{
  const base=await fixture(t),h=await readIntegratedContracts(base),owner=randomUUID(),submission=randomUUID();
  const input={...installedTemplate('publication'),batch_id:randomUUID(),compatibility_review_ref:'reviewed-build-pair',items:[{
    submission_id:submission,product_id:randomUUID(),brand_id:null,create:true,kind:'physical_good',review_ref:'physical-evidence'}]};
  const observation={schema_md5:installedSchemaMd5,taxonomy_md5:'b'.repeat(32),catalog_md5:'c'.repeat(32),
    selected:[{submission:{id:submission,status:'pending',submitted_by:owner,name:'Synthetic physical item'},role:'merchant',owner,
      auth_ready:true,shop_active:true,category_allowed:true}],decisions_enabled:false,catalog_count:0,brand_count:0,catalog:[],brands:[]};
  const original=installedReviewFiles(h.target,'publication',input,observation);
  const r=await prepareIntegratedPilot(base,'publication','reviewed-publication',input,observation);
  assert.deepEqual(r.report.proposals,['publication']);assert.equal(r.manifest.remote_authorized,false);
  for(const [path,text] of Object.entries(original.files))assert.equal(await readFile(resolve(r.directory,path),'utf8'),text);
  observation.selected[0].auth_ready=false;
  await assert.rejects(prepareIntegratedPilot(base,'publication','unverified-owner',input,observation));
  observation.selected[0].auth_ready=true;input.items[0].kind='service';
  await assert.rejects(prepareIntegratedPilot(base,'publication','service-item',input,observation));
});
test('source and output junctions cannot escape the verified workspace',async t=>{
  const base=await fixture(t),outside=await fixture(t);
  await mkdir(resolve(base,'.buildlog'));await symlink(outside,resolve(base,'.buildlog/pilot-integrated-review'),process.platform==='win32'?'junction':'dir');
  await assert.rejects(prepareIntegratedPilot(base,'cohort','escape-output'),/reparse/);
  await symlink(outside,resolve(base,'lib/escape'),process.platform==='win32'?'junction':'dir');
  await assert.rejects(captureIntegratedSources(base),/symlink|reparse/);
});
test('historical test helper cannot rewrite the live workspace or accept wrong commit bytes',async t=>{
  const base=await fixture(t);
  await assert.rejects(restoreHistoricalTestSources(root,root,installedProofPath,fixtureBaselineCommit),/separate/);
  await assert.rejects(restoreHistoricalTestSources(root,base,installedProofPath,integratedBaseline),/does not match pinned proof/);
});
