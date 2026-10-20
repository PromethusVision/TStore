import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFile,writeFile,mkdir,mkdtemp,realpath,rm,symlink} from 'node:fs/promises';
import {resolve,dirname,sep} from 'node:path';
import {tmpdir} from 'node:os';
import {uiChecks,validateUiResult,captureUiSources,verifyUiProof,uiSourceFiles,uiSourceRoots,
  uiProofPath,fixtureBaselineCommit,databaseChecks} from './pilot_ui_contract.mjs';
import {installedSchemaMd5} from './pilot_installed_profile.mjs';

const nonce = 'a'.repeat(48);
const proof = () => ({kind:'merchant-pilot-ui-client-local-v1',nonce,result:'PASS',
  checks:uiChecks.map(name=>({name,result:'PASS'}))});
test('accepts only complete ordered screen checks from this execution',()=>{
  assert.equal(validateUiResult(proof(),nonce).length,15);
});
test('rejects old, missing or malformed process identity',()=>{
  for(const changed of [undefined,'b'.repeat(48),'a']){
    const p=proof();p.nonce=changed;assert.throws(()=>validateUiResult(p,nonce));
  }
  assert.throws(()=>validateUiResult(proof(),'a'));
});
test('partial, duplicate, reordered, failed or skipped checks cannot claim acceptance',()=>{
  for(const mutate of [p=>p.checks.pop(),p=>p.checks.push(p.checks[0]),
    p=>p.checks.reverse(),p=>p.checks[0].result='SKIP',p=>p.checks[0].result='FAIL',
    p=>p.result='FAIL',p=>p.kind='repository-only']){
    const p=proof();mutate(p);assert.throws(()=>validateUiResult(p,nonce));
  }
});

async function fixture(t){
  const parent=await realpath(tmpdir()),base=await mkdtemp(resolve(parent,'merchant-ui-proof-'));
  t.after(async()=>{
    const actual=await realpath(base);
    assert(actual.startsWith(parent+sep)&&actual===base);
    await rm(base,{recursive:true});
  });
  for(const path of uiSourceFiles){await mkdir(dirname(resolve(base,path)),{recursive:true});await writeFile(resolve(base,path),'original\n');}
  for(const dir of uiSourceRoots)await mkdir(resolve(base,dir),{recursive:true});
  await writeFile(resolve(base,'lib/features/merchant/local.dart'),'original\n');
  await mkdir(dirname(resolve(base,uiProofPath)),{recursive:true});
  const record={kind:'merchant-pilot-ui-local-only-v1',result:'PASS',remote_access:'NONE',production_writes:'NONE',
    physical_two_device:'OPEN',distribution_ready:false,fixture_baseline_commit:fixtureBaselineCommit,
    installed_schema_md5:installedSchemaMd5,checks:proof().checks,database_postchecks:databaseChecks,
    sources:await captureUiSources(base)};
  await writeFile(resolve(base,uiProofPath),JSON.stringify(record));
  return base;
}
test('proof verifier rejects changed source while allowing equivalent Windows newlines',async t=>{
  const base=await fixture(t);await verifyUiProof(base);
  const file=resolve(base,'lib/features/merchant/local.dart');
  await writeFile(file,'original\r\n');await verifyUiProof(base);
  await writeFile(file,'changed\n');await assert.rejects(verifyUiProof(base),/stale or incomplete/);
});
test('new runtime file or omitted source cannot reuse a prior successful record',async t=>{
  const base=await fixture(t);
  const newFile=resolve(base,'lib/core/ui/new_flow.dart');
  await mkdir(dirname(newFile),{recursive:true});await writeFile(newFile,'new');
  await assert.rejects(verifyUiProof(base),/stale or incomplete/);
  const path=resolve(base,uiProofPath),record=JSON.parse(await readFile(path,'utf8'));
  record.sources.pop();await writeFile(path,JSON.stringify(record));
  await assert.rejects(verifyUiProof(base),/stale or incomplete/);
});
test('local proof cannot silently close device/distribution gates or omit DB checks',async t=>{
  const base=await fixture(t),path=resolve(base,uiProofPath),record=JSON.parse(await readFile(path,'utf8'));
  for(const mutate of [p=>p.physical_two_device='PASS',p=>p.distribution_ready=true,
    p=>p.remote_access='HOSTED',p=>p.database_postchecks.pop(),p=>p.checks.pop()]){
    const changed=structuredClone(record);mutate(changed);await writeFile(path,JSON.stringify(changed));
    await assert.rejects(verifyUiProof(base));
  }
});
test('runtime directory junction cannot draw proof inputs from outside the source',async t=>{
  const base=await fixture(t),outside=await fixture(t);
  await symlink(outside,resolve(base,'lib/features/merchant/escape'),process.platform==='win32'?'junction':'dir');
  await assert.rejects(captureUiSources(base),/symlink|reparse/);
});
