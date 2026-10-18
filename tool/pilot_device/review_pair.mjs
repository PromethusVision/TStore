import assert from 'node:assert/strict';
import {readFile,realpath,writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {root,sourceSnapshot} from './build_pair.mjs';
import {applications,project,json,sha,slug,digestPattern,assessField} from './contract.mjs';

export async function verifyBundle(directory,{repo=root,currentSources=true}={}) {
  assert.equal(await realpath(directory),resolve(directory));
  const bundle=JSON.parse(await readFile(resolve(directory,'pair.json'),'utf8'));
  const {bundle_id,...body}=bundle;assert.equal(sha(json(body)),bundle_id);
  assert.equal(bundle.kind,'esnaftavar-pilot-device-pair-v1');assert.equal(bundle.project_ref,project);
  assert.equal(bundle.pilot_ready,false);assert.equal(bundle.remote_authorized,false);
  assert(['compile-rehearsal','device-candidate'].includes(bundle.purpose));
  assert(['debug','release'].includes(bundle.mode));assert.equal(bundle.artifacts.length,2);
  if(bundle.purpose==='compile-rehearsal')assert.equal(bundle.mode,'debug');
  assert.equal(bundle.tests.result,'PASS');assert(bundle.tests.passed>=60);assert.equal(bundle.tests.failed,0);assert.equal(bundle.tests.skipped,0);
  const source=JSON.parse(await readFile(resolve(directory,'sources.json'),'utf8'));
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

if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href) {
  try {
    const [name,observation]=process.argv.slice(2);assert(process.argv.length===3||process.argv.length===4);assert(slug(name));
    const directory=resolve(root,'.buildlog/pilot-device',name);const bundle=await verifyBundle(directory);
    if(observation) {
      assert(slug(observation));const path=resolve(root,'.buildlog/pilot-device-input',observation+'.json');assert.equal(await realpath(path),path);
      const report=assessField(bundle,JSON.parse(await readFile(path,'utf8')));
      await writeFile(resolve(directory,observation+'.review.json'),json(report),{flag:'wx'});
    }
    console.log('PAIR_REVIEW_PASS: artifacts and source match; physical acceptance and pilot opening remain separate.');
  }catch{console.error('PAIR_REVIEW_REFUSED: mismatching/stale evidence, input, or existing report.');process.exitCode=1;}
}
