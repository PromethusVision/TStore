// Compile-only, synthetic client keys, never installs/runs an APK or contacts a backend.
import assert from 'node:assert/strict';
import {mkdtemp,writeFile,copyFile,unlink,rmdir} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {resolve,dirname} from 'node:path';
import {root,run,newOutput,sourceSnapshot,inspectApk} from '../pilot_device/build_pair.mjs';
import {applications,endpoint,rehearsalKey,pairDefines,json} from '../pilot_device/contract.mjs';

const [name,flutter,sdk,java]=process.argv.slice(2);
assert.equal(process.argv.length,6);
const before=await sourceSnapshot();
const output=await newOutput(root,name);
const temp=await mkdtemp(resolve(tmpdir(),'esnaftavar-public-firebase-rehearsal-'));
const inputs=[];
try {
  const identities={customer:'1:1003286439273:android:9c71a17085ffd1ada2c9f8',
    merchant:'1:1003286439273:android:012b10fb018d88e1a2c9f8'};
  const env={...process.env,JAVA_HOME:dirname(dirname(java)),CI:'true',FLUTTER_SUPPRESS_ANALYTICS:'true'};
  for(const key of ['DART_DEFINES','DART_FLAGS','JAVA_TOOL_OPTIONS','_JAVA_OPTIONS','JDK_JAVA_OPTIONS',
    'GRADLE_OPTS','FLUTTER_TOOL_ARGS','ESNAFTAVAR_SIGNING_PROPERTIES']) delete env[key];
  for(const [role,app] of Object.entries(applications)) {
    const path=resolve(temp,role+'.json');inputs.push(path);
    await writeFile(path,json({project_info:{project_id:'esnaftavar-development',project_number:'1003286439273'},
      client:[{client_info:{mobilesdk_app_id:identities[role],android_client_info:{package_name:app.id}},
        api_key:[{current_key:'synthetic_public_client_fixture_12345'}]}]}),{flag:'wx'});
    env['ESNAFTAVAR_FIREBASE_'+role.toUpperCase()+'_CONFIG']=path;
  }
  const pair=pairDefines({MERCHANT_PILOT_ENABLED:'true',MERCHANT_PILOT_URL:endpoint,MERCHANT_PILOT_ANON_KEY:rehearsalKey});
  for(const role of Object.keys(pair)) {
    const file=resolve(temp,role+'-defines.json');inputs.push(file);
    await writeFile(file,json({...pair[role],ESNAFTAVAR_DEVELOPMENT_PUSH_ENABLED:'true'}),{flag:'wx'});
  }
  const artifacts=[];
  for(const [role,app] of Object.entries(applications)) {
    console.log('FIREBASE_COMPILE: '+role);
    await run(resolve(flutter,'bin/cache/dart-sdk/bin/dart.exe'),[
      resolve(flutter,'bin/cache/flutter_tools.snapshot'),'--no-version-check','--suppress-analytics',
      'build','apk','--debug','--no-pub','--target-platform','android-arm64','--flavor',app.flavor,
      '--target',app.target,'--dart-define-from-file',resolve(temp,role+'-defines.json')],
      {env,log:resolve(output,role+'.build.log'),redact:[rehearsalKey]});
    const apk=resolve(output,role+'.apk');
    await copyFile(resolve(root,`build/app/outputs/flutter-apk/app-${app.flavor.toLowerCase()}-debug.apk`),apk,1);
    const metadata=await inspectApk(apk,role,'debug',{sdk,java,env,repo:root,configuration:resolve(temp,'merchant-defines.json')});
    const resources=await run(resolve(sdk,'build-tools/35.0.0/aapt.exe'),['dump','--values','resources',apk],{env});
    assert(resources.includes(identities[role]));assert(resources.includes('1003286439273'));
    assert(resources.includes('synthetic_public_client_fixture_12345'));
    artifacts.push({...metadata,firebase_app_id:identities[role],synthetic_client_config:true});
  }
  assert.equal((await sourceSnapshot()).sha256,before.sha256);
  await writeFile(resolve(output,'result.json'),json({result:'PASS',purpose:'COMPILE_ONLY_NOT_DISTRIBUTABLE',
    push_flag:true,source_sha256:before.sha256,artifacts,remote_calls:'NONE',physical_delivery:'OPEN'}),{flag:'wx'});
  console.log('FIREBASE_ENABLED_PAIR_PASS: synthetic resources verified; no real send or install.');
} finally {
  for(const file of inputs)await unlink(file);
  await rmdir(temp); // Empty task-created directory only; no recursive deletion.
}
