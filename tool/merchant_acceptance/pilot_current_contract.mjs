import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {digest,projectRef,projectUrl} from './pilot_preparation_contract.mjs';
import {lf} from './pilot_publication_contract.mjs';
import {installedSources,installedProofPath} from './pilot_installed_contract.mjs';
import {installedSchemaMd5,installedReceipt,installedReceiptSha} from './pilot_installed_profile.mjs';
import {captureUiSources,verifyUiProof,uiProofPath,databaseChecks,fixtureBaselineCommit} from './pilot_ui_contract.mjs';

export const historicalReadinessSha='512887661f9cc4579344e5d9e3981ec0ecb80ac842f210fc7a901e711e8acf79';
export const repositoryProofPath='docs/data/merchant_pilot_current_repository_acceptance.json';
// The only changed J9-bound source in the reviewed baseline. All other J9
// contracts, SQL, repositories and historical records must remain byte-equivalent.
const renewedSource='lib/features/merchant/runtime/merchant_runtime.dart';
const renewedSourceSha='8e98dd26dfad99b46072547b771dd5f0ef76cdbe40bb70a6f537f3461f0bcafa';

export async function readHistoricalContracts(repo){
  const raw=lf(await readFile(resolve(repo,installedProofPath),'utf8'));
  assert.equal(digest(raw),historicalReadinessSha,'Pinned J9 evidence changed');
  const proof=JSON.parse(raw);
  assert.equal(proof.kind,'merchant-pilot-installed-local-only-v1');
  assert.equal(proof.result,'PASS');assert.equal(proof.installed_schema_md5,installedSchemaMd5);
  assert.deepEqual(proof.sources.map(s=>s.path),installedSources);
  const renewed=[];
  for(const source of proof.sources){
    const current=digest(lf(await readFile(resolve(repo,source.path),'utf8')));
    if(source.path===renewedSource)assert.equal(current,renewedSourceSha,
      'Only the integrated same-session runtime composition delta is admitted');
    if(current!==source.sha256_lf){
      assert.equal(source.path,renewedSource,'Historical server/preparation contract changed: '+source.path);
      renewed.push({path:source.path,previous_sha256_lf:source.sha256_lf,current_sha256_lf:current});
    }
  }
  const receipt=lf(await readFile(resolve(repo,installedReceipt),'utf8'));
  assert.equal(digest(receipt),installedReceiptSha);
  const target={project_ref:projectRef,project_url:projectUrl};
  assert.deepEqual(JSON.parse(receipt).target,target);
  return {proof,renewed,target};
}

export function validateRepositoryResult(result,nonce,expectedChecks){
  assert.match(nonce,/^[a-f0-9]{48}$/);assert.equal(result.nonce,nonce);
  assert.equal(result.result,'PASS');assert.equal(expectedChecks.length,18);
  assert.deepEqual(result.checks,expectedChecks,'All original repository checkpoints required');
  return result.checks;
}

export async function verifyCurrentReadiness(repo){
  const historical=await readHistoricalContracts(repo);
  const ui=await verifyUiProof(repo);
  const raw=lf(await readFile(resolve(repo,repositoryProofPath),'utf8'));
  const repositories=JSON.parse(raw);
  assert.equal(repositories.kind,'merchant-pilot-current-repositories-local-v1');
  assert.equal(repositories.result,'PASS');assert.equal(repositories.remote_access,'NONE');
  assert.equal(repositories.production_writes,'NONE');assert.equal(repositories.physical_two_device,'OPEN');
  assert.equal(repositories.distribution_ready,false);
  assert.equal(repositories.fixture_baseline_commit,fixtureBaselineCommit);
  assert.equal(repositories.installed_schema_md5,installedSchemaMd5);
  assert.equal(repositories.historical_readiness_sha256_lf,historicalReadinessSha);
  assert.deepEqual(repositories.checks,historical.proof.client_checks);
  assert.deepEqual(repositories.database_postchecks,databaseChecks.map(x=>x==='no verified sale invented'
    ?'one synthetic legacy QR purchase; physical acceptance OPEN':x));
  assert.deepEqual(repositories.sources,await captureUiSources(repo),'Current repository proof stale');
  assert.deepEqual(ui.sources,repositories.sources,'Screen and repository sources must match');
  return {target:historical.target,renewed:historical.renewed,proofs:{
    historical_sha256_lf:historicalReadinessSha,repository_sha256_lf:digest(raw),
    ui_sha256_lf:digest(lf(await readFile(resolve(repo,uiProofPath),'utf8'))),
    sources_sha256:digest(JSON.stringify(ui.sources))}};
}
