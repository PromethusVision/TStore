import assert from 'node:assert/strict';
import {spawn} from 'node:child_process';
import {readFile,writeFile,mkdir,realpath,copyFile,open,unlink} from 'node:fs/promises';
import {resolve,dirname,join} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {applications,capabilities,project,endpoint,rehearsalKey,json,sha,slug,parseInput,pairDefines,inspectMetadata,fieldTemplate,scanPayload} from './contract.mjs';

export const root=fileURLToPath(new URL('../../',import.meta.url));
export const compatibilityTests=[
  'test/widget/shop/catalog_price_compatibility_test.dart',
  'test/unit/merchant/merchant_pilot_config_test.dart',
  'test/unit/auth/auth_callback_contract_test.dart',
  'test/unit/merchant/merchant_recovery_sdk_race_test.dart',
  'test/unit/merchant/merchant_account_recovery_test.dart',
  'test/widget/merchant/merchant_pilot_auth_test.dart',
  'tool/pilot_device/preflight_test.dart',
];
const sourceRoots=['lib','android','assets','pubspec.yaml','pubspec.lock','tool/pilot_device',...compatibilityTests];
const noValues = text => text.replace(/sb_(?:publishable|secret)_[A-Za-z0-9_-]+/g,'[CLIENT_OR_SERVER_KEY_REDACTED]')
  .replace(/[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{12,}\.[A-Za-z0-9_-]{8,}/g,'[TOKEN_REDACTED]');

export function run(executable,args,{cwd=root,env=process.env,timeout=1800000,log=null,redact=[],binary=false,maxBytes=24000000}={}) {
  return new Promise((ok,fail)=>{
    const child=spawn(executable,args,{cwd,env,windowsHide:true,stdio:['ignore','pipe','pipe']});
    let size=0;const chunks=[],diagnostics=[];let timedOut=false;
    const timer=setTimeout(()=>{
      timedOut=true;
      if(process.platform==='win32'&&child.pid)spawn('taskkill.exe',['/PID',String(child.pid),'/T','/F'],{windowsHide:true,stdio:'ignore'}).on('error',()=>child.kill());
      else child.kill();
    },timeout);
    const collect=(target,b)=>{size+=b.length;if(size<=maxBytes)target.push(b);};
    child.stdout.on('data',b=>collect(chunks,b));child.stderr.on('data',b=>collect(diagnostics,b));
    child.on('error',()=>{clearTimeout(timer);fail(new Error('LOCAL_EXECUTABLE_UNAVAILABLE'));});
    child.on('close',async code=>{
      clearTimeout(timer);const bytes=Buffer.concat(chunks);let output=binary?bytes:bytes.toString('utf8');
      try {
        if(log){assert(!binary);let safe=output+Buffer.concat(diagnostics).toString('utf8');for(const value of redact)if(value)safe=safe.split(value).join('[CLIENT_KEY_REDACTED]');await writeFile(log,noValues(safe),{flag:'wx'});}
        assert(!timedOut && code===0 && size<=maxBytes,'LOCAL_COMMAND_FAILED; inspect private log');ok(output);
      }catch{fail(new Error('LOCAL_COMMAND_FAILED; inspect private log'));}
    });
  });
}

export async function sourceSnapshot(repo=root) {
  const canonical=await realpath(repo);
  const paths=[...new Set((await run('git',['ls-files','-co','--exclude-standard','--',...sourceRoots],{cwd:repo})).trim().split(/\r?\n/))].sort();
  assert(paths.length>100 && paths.every(p=>p&&!p.includes('..')&&!p.startsWith('/')));
  const files=[];
  for(const path of paths){const absolute=resolve(canonical,path);assert.equal(await realpath(absolute),absolute,'Source reparse path refused');files.push({path,sha256:sha(await readFile(absolute))});}
  return {sha256:sha(json(files)),files};
}

export async function newOutput(repo,name) {
  assert(slug(name));const canonical=await realpath(repo),scratch=resolve(canonical,'.buildlog');
  await mkdir(scratch,{recursive:true});assert.equal(await realpath(scratch),scratch);
  const parent=resolve(scratch,'pilot-device');await mkdir(parent,{recursive:true});assert.equal(await realpath(parent),parent);
  const output=resolve(parent,name);assert.equal(dirname(output),parent);await mkdir(output);return output;
}

export function testResult(output) {
  const events=output.split(/\r?\n/).filter(l=>l.startsWith('{')).map(l=>{try{return JSON.parse(l);}catch{return {};}});
  const done=events.filter(e=>e.type==='done');assert.equal(done.length,1);assert.equal(done[0].success,true);
  const tests=events.filter(e=>e.type==='testDone'&&!e.hidden);
  assert(tests.length>=60);assert(tests.every(t=>t.result==='success'&&!t.skipped));
  return {result:'PASS',passed:tests.length,failed:0,skipped:0,paths:compatibilityTests};
}

export async function inspectApk(apk,role,mode,{sdk,java,configuration,env,repo=root}) {
  const sdkTools=resolve(sdk,'build-tools/35.0.0');
  const badge=await run(resolve(sdkTools,'aapt.exe'),['dump','badging',apk],{cwd:repo,env});
  const tree=await run(resolve(sdkTools,'aapt.exe'),['dump','xmltree',apk,'AndroidManifest.xml'],{cwd:repo,env});
  const signing=await run(java,['-jar',resolve(sdkTools,'lib/apksigner.jar'),'verify','--verbose','--print-certs',apk],{cwd:repo,env});
  const metadata=inspectMetadata(role,mode,badge,tree,signing);
  const input=JSON.parse(await readFile(configuration,'utf8'));
  const payload=mode==='debug'?'assets/flutter_assets/kernel_blob.bin':'lib/arm64-v8a/libapp.so';
  // The installed archive tool reads one entry to stdout; no scripts, execution
  // policy change, extraction paths or APK execution are involved.
  const bytesInPayload=await run(resolve(process.env.ProgramFiles??'C:/Program Files','7-Zip/7z.exe'),['x','-so',apk,payload],
    {cwd:repo,env,binary:true,maxBytes:400*1024*1024});
  const scan={...scanPayload(bytesInPayload,input.MERCHANT_PILOT_ANON_KEY),payload};
  assert.equal(scan.backend_url_present,true);assert.equal(scan.supplied_client_key_present,true);
  assert.equal(scan.catalog_price_marker_present,true);
  const bytes=await readFile(apk); return {...metadata,sha256:sha(bytes),bytes:bytes.length,payload_scan:scan};
}

export async function buildPair({name,flutter,sdk,java,purpose='compile-rehearsal',mode='debug',inputName=null,repo=root}) {
  assert(['compile-rehearsal','device-candidate'].includes(purpose));assert(['debug','release'].includes(mode));
  assert(purpose!=='compile-rehearsal'||(mode==='debug'&&inputName===null));
  const canonical=await realpath(repo); const before=await sourceSnapshot(repo);
  const commit=(await run('git',['rev-parse','HEAD'],{cwd:repo})).trim();
  const dirty=Boolean((await run('git',['status','--porcelain','--untracked-files=normal'],{cwd:repo})).trim());
  if(purpose==='device-candidate')assert(!dirty,'Candidates require a clean reviewed source commit');
  let input={MERCHANT_PILOT_ENABLED:'true',MERCHANT_PILOT_URL:endpoint,MERCHANT_PILOT_ANON_KEY:rehearsalKey};
  if(purpose==='device-candidate') {
    assert(slug(inputName));const file=resolve(canonical,'.buildlog/pilot-device-input',inputName+'.json');
    assert.equal(await realpath(file),file);input=parseInput(await readFile(file,'utf8'));
    assert.notEqual(input.MERCHANT_PILOT_ANON_KEY,rehearsalKey);
  }
  const pair=pairDefines(input),dart=resolve(flutter,'bin/cache/dart-sdk/bin/dart.exe');
  const flutterArgs=[resolve(flutter,'bin/cache/flutter_tools.snapshot'),'--no-version-check','--suppress-analytics'];
  const env={...process.env,JAVA_HOME:dirname(dirname(java)),CI:'true',FLUTTER_SUPPRESS_ANALYTICS:'true'};
  for(const key of ['DART_DEFINES','DART_FLAGS','JAVA_TOOL_OPTIONS','_JAVA_OPTIONS','JDK_JAVA_OPTIONS','GRADLE_OPTS','FLUTTER_TOOL_ARGS'])delete env[key];
  if(mode==='debug')delete env.ESNAFTAVAR_SIGNING_PROPERTIES;
  if(mode==='release')assert(env.ESNAFTAVAR_SIGNING_PROPERTIES,'Existing external signing input required');
  const output=await newOutput(repo,name);
  // One task-owned lock prevents two instances from racing over Flutter's shared
  // output directory. It never removes another process's lock or build files.
  let lock;const lockPath=resolve(canonical,'.buildlog/pilot-device/build.lock');let stage='lock';
  try {
    lock=await open(lockPath,'wx');await lock.writeFile(json({pid:process.pid,output:name}));
    const options={cwd:repo,env,redact:[input.MERCHANT_PILOT_ANON_KEY]};
    for(const [role,defines] of Object.entries(pair))await writeFile(resolve(output,role+'.config.json'),json(defines),{flag:'wx',mode:0o600});
    stage='configuration';
    await run(dart,['--packages=.dart_tool/package_config.json','tool/pilot_device/preflight.dart',resolve(output,'customer.config.json'),resolve(output,'merchant.config.json')],{...options,log:resolve(output,'preflight.log')});
    stage='compatibility-tests';
    const tests=testResult(await run(dart,[...flutterArgs,'test','--no-pub','--reporter','json',...compatibilityTests],{...options,log:resolve(output,'compatibility.log')}));
    const artifacts=[];
    for(const [role,app] of Object.entries(applications)) {
      stage='build-'+role;console.log('PAIR_PROGRESS: '+stage);
      const args=[...flutterArgs,'build','apk','--'+mode,'--no-pub','--target-platform','android-arm64','--flavor',app.flavor,
        '--target',app.target,'--dart-define-from-file',resolve(output,role+'.config.json')];
      await run(dart,args,{...options,log:resolve(output,role+'.build.log')});
      stage='inspect-'+role;
      const apk=resolve(output,role+'.apk');
      await copyFile(resolve(canonical,`build/app/outputs/flutter-apk/app-${app.flavor.toLowerCase()}-${mode}.apk`),apk,1);
      artifacts.push({...await inspectApk(apk,role,mode,{sdk,java,configuration:resolve(output,'merchant.config.json'),env,repo}),file:role+'.apk',flavor:app.flavor,target:app.target});
    }
    assert.equal(artifacts[0].version_code,artifacts[1].version_code);assert.equal(artifacts[0].version_name,artifacts[1].version_name);
    assert.equal(artifacts[0].certificate_sha256,artifacts[1].certificate_sha256);
    stage='source-recheck';assert.equal((await sourceSnapshot(repo)).sha256,before.sha256,'Sources changed during build');
    assert.equal((await run('git',['rev-parse','HEAD'],{cwd:repo})).trim(),commit);
    const sdkVersion=JSON.parse(await run(dart,[...flutterArgs,'--version','--machine'],options));
    const bundle={kind:'esnaftavar-pilot-device-pair-v1',created_at:new Date().toISOString(),purpose,mode,
      status:purpose==='compile-rehearsal'?'COMPILE_REHEARSAL_PASS_NOT_DISTRIBUTABLE':'ARTIFACT_CANDIDATE_REQUIRES_FIELD_REVIEW',
      project_ref:project,source_commit:commit,uncommitted_sources:dirty,source_sha256:before.sha256,
      config_sha256:Object.fromEntries(Object.entries(pair).map(([role,value])=>[role,sha(json(value))])),
      capabilities:Object.fromEntries(capabilities.map(k=>[k,false])),canonical_taxonomy:false,
      catalog_price_contract:'listing_only_v1',tests,artifacts,
      toolchain:{flutter:sdkVersion.frameworkVersion,framework_revision:sdkVersion.frameworkRevision,dart:sdkVersion.dartSdkVersion,android_build_tools:'35.0.0'},
      production_access:'NONE',remote_access:'NONE',remote_authorized:false,physical_two_device:'OPEN',provider_delivery:'OPEN',pilot_ready:false};
    bundle.bundle_id=sha(json(bundle));
    await writeFile(resolve(output,'sources.json'),json(before),{flag:'wx'});
    await writeFile(resolve(output,'pair.json'),json(bundle),{flag:'wx'});
    await writeFile(resolve(output,'field-observation.template.json'),json(fieldTemplate(bundle)),{flag:'wx'});
    return {output,bundle};
  } catch(error) {
    await writeFile(resolve(output,'FAILED.json'),json({stage,status:'FAIL',pilot_ready:false}),{flag:'wx'});throw error;
  } finally {
    if(lock){await lock.close();await unlink(lockPath);}
    // Configs contain client-only keys but remain private build inputs, not
    // handoff artifacts. Never retain or print the values in the receipt.
    for(const role of Object.keys(pair))await unlink(resolve(output,role+'.config.json')).catch(()=>{});
  }
}

if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href) {
  try {
    const [command,name,flutter,sdk,java,inputName,mode]=process.argv.slice(2);
    assert((command==='rehearse'&&process.argv.length===7)||(command==='candidate'&&process.argv.length===9));
    const result=await buildPair({name,flutter,sdk,java,purpose:command==='rehearse'?'compile-rehearsal':'device-candidate',inputName:inputName??null,mode:mode??'debug'});
    console.log('PAIR_ARTIFACTS_VERIFIED: '+result.output+'; pilot opening remains OPEN.');
  }catch{console.error('PAIR_BUILD_REFUSED: inspect task-local status/logs; no remote operation or distribution.');process.exitCode=1;}
}
