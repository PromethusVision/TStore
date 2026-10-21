import assert from 'node:assert/strict';
import {readFile,readdir,realpath} from 'node:fs/promises';
import {resolve} from 'node:path';
import {digest,projectRef,projectUrl} from './pilot_preparation_contract.mjs';
import {lf} from './pilot_publication_contract.mjs';
import {installedSources,installedProofPath} from './pilot_installed_contract.mjs';
import {installedSchemaMd5,installedReceipt,installedReceiptSha} from './pilot_installed_profile.mjs';
import {captureUiSources,uiChecks,databaseChecks,fixtureBaselineCommit} from './pilot_ui_contract.mjs';
import {historicalReadinessSha} from './pilot_current_contract.mjs';

// A distinct qualification profile. J7/J9/J12 entrypoints and evidence retain
// their original source restrictions. No flag can opt them into this profile.
export const integratedBaseline='50f750f2e18debab64e38315f8a66ba097b6b87b';
export const integratedProofs={
  ui:'docs/data/merchant_pilot_integrated_ui_acceptance.json',
  repositories:'docs/data/merchant_pilot_integrated_repository_acceptance.json',
};
export const reviewedClientDeltas=Object.freeze({
  'lib/features/merchant/runtime/merchant_runtime.dart':'8e98dd26dfad99b46072547b771dd5f0ef76cdbe40bb70a6f537f3461f0bcafa',
  'lib/features/merchant/data/supabase_merchant_repository.dart':'999c1ff344685ff048ab76615b90e46e541f31722b9cae0ad826fede3f025bea',
  'lib/features/merchant/data/supabase_catalog_media_repository.dart':'95504c42353374235a815124921cf72a9ce29df0eca2332a73261c0fe87eda76',
  'lib/features/merchant/data/supabase_merchant_operations_repository.dart':'083795b8be06d3f52f9ca7972e7b3e211ad0d0af8ddc5ea98121e5e7d29f9e6c',
  'lib/features/notifications/data/repositories/notification_repository_impl.dart':'22fe3dcda90d6a620683228ac5ab79f076c5cc7feaca98682baee8192530a1c2',
  'lib/features/cart/data/repositories/qr_session_repository_impl.dart':'ef684f85aefbb4e5b69735f90fd45dbcb6ed3bb3b56f8972a674e85fc6449525',
});
// Only fixture setup changed in this historical test; production SQL/preparers
// remain exact. The old J9 positive case now uses its own pinned source bytes.
const reviewedTestDeltas=Object.freeze({
  'tool/merchant_acceptance/pilot_installed.test.mjs':'d8af76c955e989573aebc7702b45bce9ce473a48655cf9aae0b4cab505696bae',
});
export const integratedSessionChecks=Object.freeze([
  'ordinary token renewal preserves the open listing draft',
  'same-account new session retires the open listing draft',
  'new session reloads persisted listing instead of the old draft',
]);

export async function readIntegratedContracts(repo){
  const raw=lf(await readFile(resolve(repo,installedProofPath),'utf8'));
  assert.equal(digest(raw),historicalReadinessSha,'Pinned J9 evidence changed');
  const proof=JSON.parse(raw);
  assert.deepEqual(proof.sources.map(s=>s.path),installedSources);
  const renewed=[];
  for(const s of proof.sources){
    const current=digest(lf(await readFile(resolve(repo,s.path),'utf8')));
    const expected=reviewedClientDeltas[s.path]??reviewedTestDeltas[s.path]??s.sha256_lf;
    assert.equal(current,expected,'Unreviewed integrated contract drift: '+s.path);
    if(current!==s.sha256_lf)renewed.push({path:s.path,previous_sha256_lf:s.sha256_lf,current_sha256_lf:current});
  }
  assert.deepEqual(renewed.map(s=>s.path).sort(),Object.keys({...reviewedClientDeltas,...reviewedTestDeltas}).sort());
  const receipt=lf(await readFile(resolve(repo,installedReceipt),'utf8'));
  assert.equal(digest(receipt),installedReceiptSha);
  const target={project_ref:projectRef,project_url:projectUrl};
  assert.deepEqual(JSON.parse(receipt).target,target);
  return {proof,renewed,target};
}

// Bind the complete current lib plus every local acceptance executable, test,
// SQL source and dependency lock. Output records and ignored credentials are
// deliberately excluded; missing/added sources still invalidate a prior record.
export async function captureIntegratedSources(repo){
  const base=await realpath(repo),sources=new Map((await captureUiSources(base)).map(s=>[s.path,s]));
  async function collect(dir){
    assert.equal(await realpath(resolve(base,dir)),resolve(base,dir),'No source reparse path');
    for(const entry of await readdir(resolve(base,dir),{withFileTypes:true})){
      if(entry.name==='node_modules')continue;
      assert(!entry.isSymbolicLink(),'No source symlink');
      const path=dir+'/'+entry.name;
      if(entry.isDirectory())await collect(path);
      else if(/\.(mjs|dart|sql|json)$/.test(path)){
        assert.equal(await realpath(resolve(base,path)),resolve(base,path),'No source reparse path');
        sources.set(path,{path,sha256_lf:digest(lf(await readFile(resolve(base,path),'utf8')))});
      }
    }
  }
  for(const dir of ['tool/merchant_acceptance','supabase/migrations','supabase/proposals'])await collect(dir);
  return [...sources.values()].sort((a,b)=>a.path<b.path?-1:a.path>b.path?1:0);
}

export function validateIntegratedResult(result,nonce,mode,historicalChecks){
  assert(['ui','repositories'].includes(mode));
  assert.match(nonce,/^[a-f0-9]{48}$/);assert.equal(result.nonce,nonce);
  assert.equal(result.result,'PASS');
  const checks=mode==='ui'?[...uiChecks,...integratedSessionChecks].map(name=>({name,result:'PASS'})):historicalChecks;
  assert.equal(checks.length,18);
  if(mode==='ui')assert.equal(result.kind,'merchant-pilot-ui-client-local-v1');
  assert.deepEqual(result.checks,checks,'Complete current-run checkpoints required');
  return result.checks;
}

export async function verifyIntegratedProof(repo,mode){
  assert(['ui','repositories'].includes(mode));
  const historical=await readIntegratedContracts(repo);
  const raw=lf(await readFile(resolve(repo,integratedProofs[mode]),'utf8')),p=JSON.parse(raw);
  assert.equal(p.kind,'merchant-pilot-integrated-'+mode+'-local-v1');
  assert.equal(p.result,'PASS');assert.equal(p.remote_access,'NONE');assert.equal(p.production_writes,'NONE');
  assert.equal(p.physical_two_device,'OPEN');assert.equal(p.distribution_ready,false);
  assert.equal(p.integrated_baseline_commit,integratedBaseline);
  assert.equal(p.fixture_baseline_commit,fixtureBaselineCommit);
  assert.equal(p.installed_schema_md5,installedSchemaMd5);
  assert.equal(p.historical_readiness_sha256_lf,historicalReadinessSha);
  assert.deepEqual(p.renewed_sources,historical.renewed);
  assert.match(p.run_id,/^ev-merchant-ab-[a-f0-9]{12}$/);
  assert.match(p.nonce_sha256,/^[a-f0-9]{64}$/);
  const expected=mode==='ui'?[...uiChecks,...integratedSessionChecks].map(name=>({name,result:'PASS'})):historical.proof.client_checks;
  assert.deepEqual(p.checks,expected);
  assert.deepEqual(p.database_postchecks,databaseChecks.map(x=>mode==='repositories'&&x==='no verified sale invented'
    ?'one synthetic legacy QR purchase; physical acceptance OPEN':x));
  assert.deepEqual(p.sources,await captureIntegratedSources(repo),'Integrated proof stale or incomplete');
  return {proof:p,sha256_lf:digest(raw),historical};
}

export async function verifyIntegratedReadiness(repo){
  const ui=await verifyIntegratedProof(repo,'ui'),repositories=await verifyIntegratedProof(repo,'repositories');
  assert.notEqual(ui.proof.run_id,repositories.proof.run_id,'Separate fresh fixtures required');
  assert.notEqual(ui.proof.nonce_sha256,repositories.proof.nonce_sha256,'Separate executions required');
  assert.deepEqual(ui.proof.sources,repositories.proof.sources);
  return {target:ui.historical.target,renewed:ui.historical.renewed,proofs:{
    historical_sha256_lf:historicalReadinessSha,ui_sha256_lf:ui.sha256_lf,
    repository_sha256_lf:repositories.sha256_lf,sources_sha256:digest(JSON.stringify(ui.proof.sources))}};
}
