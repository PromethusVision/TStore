import assert from 'node:assert/strict';
import {readFile,readdir,realpath} from 'node:fs/promises';
import {resolve} from 'node:path';
import {digest} from './pilot_preparation_contract.mjs';
import {lf} from './pilot_publication_contract.mjs';
import {installedSources} from './pilot_installed_contract.mjs';
import {installedSchemaMd5} from './pilot_installed_profile.mjs';

export const fixtureBaselineCommit='62e7ba4a4839abc190fd6bf8493c2709a333b861';
export const uiProofPath='docs/data/merchant_pilot_ui_acceptance.json';
// Shared helpers/theme and transitive feature code also affect the real host.
// A new Dart file anywhere in lib invalidates the record, not just editor files.
export const uiSourceRoots=['lib'];
export const uiSourceFiles=[...installedSources,'pubspec.yaml','pubspec.lock',
  'tool/merchant_acceptance/pilot_ui.mjs','tool/merchant_acceptance/pilot_ui_contract.mjs',
  'tool/merchant_acceptance/pilot_ui_test.dart','tool/merchant_acceptance/verify_pilot_ui.mjs'];
uiSourceFiles.push('tool/merchant_acceptance/pilot_current_contract.mjs',
  'tool/merchant_acceptance/prepare_current_pilot.mjs',
  'docs/data/merchant_pilot_installed_acceptance.json');
export const databaseChecks=Object.freeze(['exact schema unchanged','one active available listing at 234.56',
  'central price sentinel remains zero','no verified sale invented','foreign shop and notification unchanged','media decisions disabled']);

export const uiChecks = Object.freeze([
  'login and onboarding through Merchant screens',
  'profile edit persists after returning to dashboard',
  'lost profile acknowledgement exits to authoritative shop name',
  'catalog selection creates one listing at exact price',
  'price edit reaches Customer without central-price fallback',
  'lost listing acknowledgement exits to authoritative price without retry',
  'availability off is reflected in Customer offers',
  'inactive listing disappears from Customer offers',
  'reactivation and availability restore the same listing',
  'real Storage upload through merchant photo screen',
  'photo removal updates Customer hero',
  'shared inbox contains only this account notifications',
  'sign out clears private workspace and customer role is denied',
  'another merchant sees only its own empty workspace',
  'new client session reloads persisted merchant workspace',
]);

// A previous process, a partial run or a skipped check is never a fresh PASS.
export function validateUiResult(result, nonce) {
  assert.match(nonce, /^[a-f0-9]{48}$/);
  assert.equal(result?.kind, 'merchant-pilot-ui-client-local-v1');
  assert.equal(result.nonce, nonce);
  assert.equal(result.result, 'PASS');
  assert.deepEqual(result.checks, uiChecks.map(name => ({name, result: 'PASS'})));
  return result.checks;
}

export async function captureUiSources(repo) {
  const base=await realpath(repo),paths=new Set(uiSourceFiles);
  async function collect(dir){
    assert.equal(await realpath(resolve(base,dir)),resolve(base,dir),'No source reparse path');
    for(const entry of await readdir(resolve(base,dir),{withFileTypes:true})){
      assert(!entry.isSymbolicLink(),'No source symlink');
      const path=dir+'/'+entry.name;
      if(entry.isDirectory())await collect(path);
      else if(entry.isFile()&&path.endsWith('.dart'))paths.add(path);
    }
  }
  for(const dir of uiSourceRoots)await collect(dir);
  return Promise.all([...paths].sort().map(async path=>{
    const full=resolve(base,path);assert.equal(await realpath(full),full,'No source reparse path');
    return {path,sha256_lf:digest(lf(await readFile(full,'utf8')))};
  }));
}

// Freshness/shape check only: a JSON record is not a signed attestation, a device
// acceptance or permission to provision/activate hosted business features.
export async function verifyUiProof(repo) {
  const proof=JSON.parse(await readFile(resolve(repo,uiProofPath),'utf8'));
  assert.equal(proof.kind,'merchant-pilot-ui-local-only-v1');assert.equal(proof.result,'PASS');
  assert.equal(proof.remote_access,'NONE');assert.equal(proof.production_writes,'NONE');
  assert.equal(proof.physical_two_device,'OPEN');assert.equal(proof.distribution_ready,false);
  assert.equal(proof.fixture_baseline_commit,fixtureBaselineCommit);
  assert.equal(proof.installed_schema_md5,installedSchemaMd5);
  assert.deepEqual(proof.checks,uiChecks.map(name=>({name,result:'PASS'})));
  assert.deepEqual(proof.database_postchecks,databaseChecks);
  assert.deepEqual(proof.sources,await captureUiSources(repo),'UI proof stale or incomplete');
  return proof;
}
