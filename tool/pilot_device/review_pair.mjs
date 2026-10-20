import assert from 'node:assert/strict';
import {readFile,realpath,writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {root,sourceSnapshot} from './build_pair.mjs';
import {applications,capabilities,project,ownerCertificate,json,sha,slug,digestPattern,
  assessField,parseRecord,utcInstant} from './contract.mjs';
import {compatibilityTests} from './build_pair.mjs';

async function privateFile(path) {
  assert.equal(await realpath(path),resolve(path),'Evidence reparse path refused');
  return readFile(path,'utf8');
}

export function validateBundle(bundle) {
  const {bundle_id,...body}=bundle;assert.equal(sha(json(body)),bundle_id);
  assert.equal(bundle.kind,'esnaftavar-pilot-device-pair-v1');assert.equal(bundle.project_ref,project);
  assert.equal(bundle.pilot_ready,false);assert.equal(bundle.remote_authorized,false);
  for(const key of ['production_access','remote_access'])assert.equal(bundle[key],'NONE');
  for(const key of ['physical_two_device','provider_delivery'])assert.equal(bundle[key],'OPEN');
  assert(['compile-rehearsal','device-candidate'].includes(bundle.purpose));
  assert(['debug','release'].includes(bundle.mode));assert.equal(bundle.artifacts.length,2);
  assert.equal(typeof bundle.uncommitted_sources,'boolean');
  assert.match(bundle.source_commit,/^[a-f0-9]{40}$/);
  assert(digestPattern.test(bundle.source_sha256));assert(utcInstant(bundle.created_at)<=Date.now());
  if(bundle.purpose==='compile-rehearsal'){
    assert.equal(bundle.mode,'debug');assert.equal(bundle.status,'COMPILE_REHEARSAL_PASS_NOT_DISTRIBUTABLE');
  }else{
    assert.equal(bundle.uncommitted_sources,false);
    assert.equal(bundle.status,'ARTIFACT_CANDIDATE_REQUIRES_FIELD_REVIEW');
  }
  assert.equal(bundle.canonical_taxonomy,false);assert.equal(bundle.catalog_price_contract,'listing_only_v1');
  assert.deepEqual(bundle.capabilities,Object.fromEntries(capabilities.map(k=>[k,false])));
  assert.deepEqual(Object.keys(bundle.config_sha256).sort(),['customer','merchant']);
  for(const hash of Object.values(bundle.config_sha256))assert(digestPattern.test(hash));
  assert.equal(bundle.tests.result,'PASS');assert(Number.isSafeInteger(bundle.tests.passed)&&bundle.tests.passed>=60);
  assert.equal(bundle.tests.failed,0);assert.equal(bundle.tests.skipped,0);
  assert.deepEqual(bundle.tests.paths,compatibilityTests);
  for(const [index,role] of Object.keys(applications).entries()){
    const item=bundle.artifacts[index],app=applications[role];
    assert.equal(item.role,role);assert.equal(item.application_id,app.id);assert.equal(item.label,app.label);
    assert.equal(item.flavor,app.flavor);assert.equal(item.target,app.target);
    assert.equal(item.callback,`${app.callback}://login-callback/`);
    assert.equal(item.file,role+'.apk');assert(digestPattern.test(item.sha256));
    assert(Number.isSafeInteger(item.bytes)&&item.bytes>0);
    assert.equal(item.mode,bundle.mode);assert.equal(item.debuggable,bundle.mode==='debug');
    assert.equal(item.abi,'arm64-v8a');assert(digestPattern.test(item.certificate_sha256));
    if(bundle.mode==='release')assert.equal(item.certificate_sha256,ownerCertificate);
    assert(Number.isSafeInteger(item.version_code)&&item.version_code>0);
    assert.equal(typeof item.version_name,'string');assert(item.version_name.length>0&&item.version_name.length<=100);
    assert.deepEqual(item.payload_scan,{
      backend_url_present:true,supplied_client_key_present:true,catalog_price_marker_present:true,
      scan_scope:'REQUIRED_LITERALS_ONLY_NOT_BEHAVIOR_OR_SECRET_PROOF',
      payload:bundle.mode==='debug'?'assets/flutter_assets/kernel_blob.bin':'lib/arm64-v8a/libapp.so',
    });
  }
  for(const key of ['version_code','version_name','certificate_sha256'])
    assert.equal(bundle.artifacts[0][key],bundle.artifacts[1][key]);
  return bundle;
}

export async function verifyBundle(directory,{repo=root,currentSources=true}={}) {
  assert.equal(await realpath(directory),resolve(directory));
  const bundle=validateBundle(parseRecord(await privateFile(resolve(directory,'pair.json'))));
  const source=parseRecord(await privateFile(resolve(directory,'sources.json')));
  assert.deepEqual(Object.keys(source).sort(),['files','sha256']);assert(source.files.length>100);
  const seen=new Set();let previous='';
  for(const item of source.files){
    assert.deepEqual(Object.keys(item).sort(),['path','sha256']);
    assert.equal(typeof item.path,'string');
    assert(/^[a-zA-Z0-9_./-]+$/.test(item.path));
    assert(item.path.split('/').every(p=>p&&p!=='.'&&p!=='..'));
    assert(!seen.has(item.path)&&item.path>previous);seen.add(item.path);previous=item.path;
    assert(digestPattern.test(item.sha256));
  }
  assert.equal(sha(json(source.files)),source.sha256);assert.equal(source.sha256,bundle.source_sha256);
  if(currentSources)assert.equal((await sourceSnapshot(repo)).sha256,source.sha256,'Source evidence stale; rebuild pair');
  for(const [index,role] of Object.keys(applications).entries()){
    const item=bundle.artifacts[index];assert.equal(item.role,role);assert.equal(item.application_id,applications[role].id);
    assert.equal(item.file,role+'.apk');assert(digestPattern.test(item.sha256));
    const path=resolve(directory,item.file);assert.equal(await realpath(path),path);
    const bytes=await readFile(path);assert.equal(bytes.length,item.bytes);assert.equal(sha(bytes),item.sha256,'Artifact changed');
  }
  return bundle;
}

export async function reviewMain(args,{repo=root,output=console.log,error=console.error}={}) {
  try {
    const [name,observation]=args;assert(args.length===1||args.length===2);assert(slug(name));
    const directory=resolve(repo,'.buildlog/pilot-device',name);const bundle=await verifyBundle(directory,{repo});
    if(observation) {
      assert(slug(observation));const path=resolve(repo,'.buildlog/pilot-device-input',observation+'.json');
      const text=await privateFile(path);
      const report={...assessField(bundle,parseRecord(text)),observation_sha256:sha(text)};
      await writeFile(resolve(directory,observation+'.review.json'),json(report),{flag:'wx'});
      output(`${report.status}: ${report.observed_pass} reported, ${report.observed_fail} failed, ${report.observed_open} open; pilot opening remains OPEN.`);
      return report.stop_required?2:report.observed_open?3:0;
    }
    output('PAIR_ARTIFACTS_VERIFIED: artifacts and source match; no field acceptance or distribution authority.');
    return 0;
  }catch{error('PAIR_REVIEW_REFUSED: mismatching/stale evidence, input, or existing report.');return 1;}
}

if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href) {
  process.exitCode=await reviewMain(process.argv.slice(2));
}
