import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtemp,writeFile,readFile,mkdir,symlink,rm,realpath} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {resolve} from 'node:path';
import {applications,capabilities,endpoint,project,rehearsalKey,ownerCertificate,json,sha,parseInput,pairDefines,inspectMetadata,fieldTemplate,assessField,scanPayload,parseRecord} from './contract.mjs';
import {newOutput,testResult,run,compatibilityTests,sourceSnapshot} from './build_pair.mjs';
import {verifyBundle,validateBundle,reviewMain} from './review_pair.mjs';
const input=()=>({MERCHANT_PILOT_ENABLED:'true',MERCHANT_PILOT_URL:endpoint,MERCHANT_PILOT_ANON_KEY:rehearsalKey});
const mutate=(change)=>({...input(),...change});

test('one client input creates exact same backend/key and all business flags OFF',()=>{
  const pair=pairDefines(input());assert.equal(pair.customer.SUPABASE_DEVELOPMENT_URL,pair.merchant.MERCHANT_PILOT_URL);
  assert.equal(pair.customer.SUPABASE_DEVELOPMENT_ANON_KEY,pair.merchant.MERCHANT_PILOT_ANON_KEY);
  for(const flag of capabilities){assert.equal(pair.customer[flag],'false');assert.equal(pair.merchant[flag],'false');}
  assert.equal(pair.customer.ESNAFTAVAR_DEVELOPMENT_CANONICAL_TAXONOMY,'false');
});
test('payload scan binds required literals without claiming behavior or secret absence',()=>{
  const payload=Buffer.from(endpoint+'\0'+rehearsalKey+'\0_catalog_price_contract');
  assert.deepEqual(scanPayload(payload,rehearsalKey),{backend_url_present:true,supplied_client_key_present:true,catalog_price_marker_present:true,scan_scope:'REQUIRED_LITERALS_ONLY_NOT_BEHAVIOR_OR_SECRET_PROOF'});
  assert.equal(scanPayload(payload,'sb_publishable_differentClient12345').supplied_client_key_present,false);
  assert.equal(scanPayload(Buffer.from('listing_only_v1'),rehearsalKey).catalog_price_marker_present,false);
  assert(!JSON.stringify(scanPayload(payload,rehearsalKey)).includes(rehearsalKey));
});
for(const wrong of [null,[],{},42,{...input(),EXTRA:'true'},mutate({MERCHANT_PILOT_ENABLED:'false'}),
  mutate({MERCHANT_PILOT_URL:'https://other.supabase.co'}),mutate({MERCHANT_PILOT_URL:endpoint+'/'}),
  mutate({MERCHANT_PILOT_ANON_KEY:'sb_secret_syntheticNeverUse12345'}),mutate({MERCHANT_PILOT_ANON_KEY:rehearsalKey+' '})]) {
  test('invalid config shape, target or credential is rejected '+sha(json(wrong)).slice(0,8),()=>assert.throws(()=>parseInput(json(wrong))));
}
test('duplicate and escaped duplicate keys cannot be silently overwritten',()=>{
  for(const name of ['MERCHANT_PILOT_URL','MERCHANT_PILOT_UR\\u004c'])assert.throws(()=>parseInput(json(input()).replace('{',`{"${name}":"forbidden",`)));
  assert.throws(()=>parseInput(json(input()).replace(/}\s*$/,',}')));
  assert.throws(()=>parseInput(json(input()).replace('"true"','true')));
});
test('legacy anonymous JWT must belong to exact project; role and ref are checked',()=>{
  const jwt=claims=>'e30.'+Buffer.from(JSON.stringify(claims)).toString('base64url')+'.signature';
  assert(parseInput(json(mutate({MERCHANT_PILOT_ANON_KEY:jwt({role:'anon',ref:project})}))));
  for(const claims of [{role:'service_role',ref:project},{role:'anon',ref:'other'},{role:'anon'}])
    assert.throws(()=>parseInput(json(mutate({MERCHANT_PILOT_ANON_KEY:jwt(claims)}))));
});

function metadata(role='merchant',mode='debug') {
  const app=applications[role];return {
    badge:`package: name='${app.id}' versionCode='5' versionName='1.0.0'\napplication-label:'${app.label}'\nnative-code: 'arm64-v8a'\n`,
    signing:`Verifies\nSigner #1 certificate SHA-256 digest: ${mode==='release'?ownerCertificate:'a'.repeat(64)}\n`,
    tree:`E: manifest (line=1)\n  A: package="${app.id}" (Raw: "${app.id}")
  E: uses-permission\n    A: android:name="android.permission.INTERNET"
  E: uses-permission\n    A: android:name="android.permission.CAMERA"
  E: uses-permission\n    A: android:name="android.permission.ACCESS_COARSE_LOCATION"
  E: uses-permission\n    A: android:name="android.permission.ACCESS_FINE_LOCATION"
  E: application
    A: android:allowBackup(0x01010280)=(type 0x12)0x0
    A: android:usesCleartextTraffic(0x010104ec)=(type 0x12)0x0
    A: android:debuggable(0x0101000f)=(type 0x12)0x${mode==='debug'?'ffffffff':'0'}
    E: activity
      A: android:name="com.esnaftavar.app.MainActivity"
      A: android:exported=(type 0x12)0xffffffff
      E: meta-data
        A: android:name="flutter_deeplinking_enabled"
        A: android:value=(type 0x12)0x0
      E: intent-filter
        E: action\n          A: android:name="android.intent.action.VIEW"
        E: category\n          A: android:name="android.intent.category.DEFAULT"
        E: category\n          A: android:name="android.intent.category.BROWSABLE"
        E: data
          A: android:scheme="${app.callback}"
          A: android:host="login-callback"
`};
}
for(const role of Object.keys(applications))for(const mode of ['debug','release'])test(`${role} packaged identity/callback/signature ${mode}`,()=>{
  const m=metadata(role,mode);const result=inspectMetadata(role,mode,m.badge,m.tree,m.signing);
  assert.equal(result.application_id,applications[role].id);assert.equal(result.debuggable,mode==='debug');
});
test('actual Windows SDK CRLF output is accepted without normalizing body values',()=>{
  const m=metadata();assert(inspectMetadata('merchant','debug',m.badge.replaceAll('\n','\r\n'),m.tree.replaceAll('\n','\r\n'),m.signing.replaceAll('\n','\r\n')));
});
test('wrong app, cross-app callback, missing permission, backup and extra callback are refused',()=>{
  const m=metadata();
  for(const tree of [m.tree.replace(applications.merchant.callback,applications.customer.callback),
    m.tree.replace('login-callback','evil-host'),m.tree.replace('android.permission.CAMERA','android.permission.RECORD_AUDIO'),
    m.tree.replace('android:allowBackup(0x01010280)=(type 0x12)0x0','android:allowBackup(0x01010280)=(type 0x12)0xffffffff'),
    m.tree+'          A: android:pathPrefix="/"\n',m.tree+m.tree.slice(m.tree.indexOf('      E: intent-filter'))])
    assert.throws(()=>inspectMetadata('merchant','debug',m.badge,tree,m.signing));
  assert.throws(()=>inspectMetadata('customer','debug',m.badge,m.tree,m.signing));
});
test('unsigned, extra signer, wrong release key and debuggable release rejected',()=>{
  const m=metadata('merchant','release');
  for(const signing of ['',m.signing.replace(ownerCertificate,'b'.repeat(64)),m.signing+`Signer #2 certificate SHA-256 digest: ${ownerCertificate}\n`])
    assert.throws(()=>inspectMetadata('merchant','release',m.badge,m.tree,signing));
  assert.throws(()=>inspectMetadata('merchant','release',m.badge,m.tree.replace('android:debuggable(0x0101000f)=(type 0x12)0x0','android:debuggable(0x0101000f)=(type 0x12)0xffffffff'),m.signing));
});
test('tests require completed green run with no skips; partial output cannot claim success',()=>{
  const rows=Array.from({length:70},()=>({type:'testDone',result:'success',hidden:false,skipped:false}));
  const good=rows.concat({type:'done',success:true}).map(JSON.stringify).join('\n');assert.equal(testResult(good).passed,70);
  assert.throws(()=>testResult(rows.map(JSON.stringify).join('\n')));
  assert.throws(()=>testResult(good.replace('"skipped":false','"skipped":true')));
  assert.throws(()=>testResult(good.replace('"result":"success"','"result":"error"')));
});
test('command output keeps diagnostics separate from JSON and binary payload',async()=>{
  const args=['-e','process.stdout.write("{\\"pass\\":true}");process.stderr.write("diagnostic");'];
  assert.deepEqual(JSON.parse(await run(process.execPath,args)),{pass:true});
  assert.equal((await run(process.execPath,args,{binary:true})).toString(),'{"pass":true}');
  await assert.rejects(run(process.execPath,['-e','process.stdout.write("partial");process.exit(2);']));
});
const bundle=()=>({bundle_id:'b'.repeat(64),created_at:'2026-01-01T00:00:00.000Z',purpose:'device-candidate',mode:'debug',artifacts:[{role:'customer',sha256:'a'.repeat(64)},{role:'merchant',sha256:'c'.repeat(64)}]});
test('field template is empty, binds exact pair, and cannot become pilot authorization',()=>{
  const b=bundle(),form=fieldTemplate(b),result=assessField(b,form);assert.equal(result.observed_open,12);assert.equal(result.pilot_ready,false);
  form.device_aliases={customer:'customer-device-1',merchant:'merchant-device-1'};
  for(const c of form.cases){c.result='PASS';c.observed_at='2026-01-02T00:00:00.000Z';c.evidence_sha256='e'.repeat(64);}
  const reviewed=assessField(b,form);assert.equal(reviewed.observed_pass,12);assert.equal(reviewed.pilot_ready,false);assert.equal(reviewed.owner_opening,'OPEN');
  assert.equal(reviewed.status,'FIELD_REPORTED_COMPLETE_REQUIRES_OWNER_REVIEW');
});
test('field review rejects wrong bundle, duplicate/missing cases, early evidence, PII and asserted authorization',()=>{
  const b=bundle();const changes=[f=>f.bundle_id='a'.repeat(64),f=>f.artifacts.customer='c'.repeat(64),f=>f.cases.pop(),
    f=>f.cases[1]=f.cases[0],f=>f.email='private@example.invalid',f=>f.device_aliases.customer='personal-device-imei',
    f=>f.owner_opening='PASS',f=>f.cases[0].result='PASS',f=>f.cases[0].evidence_sha256='x'];
  for(const change of changes){const form=fieldTemplate(b);change(form);assert.throws(()=>assessField(b,form));}
});

async function temporary(t) {
  const directory=await mkdtemp(resolve(tmpdir(),'ev-pilot-pair-'));
  t.after(async()=>{assert(resolve(directory).startsWith(resolve(tmpdir(),'ev-pilot-pair-')));await rm(directory,{recursive:true,force:true});});
  return realpath(directory);
}
test('output refuses traversal and existing bundle, preserving previous files',async t=>{
  const root=await temporary(t);const dir=await newOutput(root,'valid-pair');await writeFile(resolve(dir,'keep.txt'),'preserved');
  await assert.rejects(newOutput(root,'valid-pair'));for(const name of ['../escape','a/b','C:\\outside','--apply'])await assert.rejects(newOutput(root,name));
  assert.equal(await readFile(resolve(dir,'keep.txt'),'utf8'),'preserved');
});
test('output refuses directory junction escape',async t=>{
  const root=await temporary(t),outside=await temporary(t);await symlink(outside,resolve(root,'.buildlog'),'junction');
  await assert.rejects(newOutput(root,'valid-pair'));
});
function seal(b) {
  const {bundle_id,...body}=b;return {...body,bundle_id:sha(json(body))};
}
function manifest(sourceSha=sha('source')) {
  return seal({...bundle(),kind:'esnaftavar-pilot-device-pair-v1',project_ref:project,pilot_ready:false,remote_authorized:false,
    status:'ARTIFACT_CANDIDATE_REQUIRES_FIELD_REVIEW',source_commit:'a'.repeat(40),uncommitted_sources:false,
    production_access:'NONE',remote_access:'NONE',physical_two_device:'OPEN',provider_delivery:'OPEN',
    canonical_taxonomy:false,catalog_price_contract:'listing_only_v1',
    capabilities:Object.fromEntries(capabilities.map(k=>[k,false])),config_sha256:{customer:sha('config-c'),merchant:sha('config-m')},
    tests:{result:'PASS',passed:70,failed:0,skipped:0,paths:compatibilityTests},source_sha256:sourceSha,
    artifacts:Object.entries(applications).map(([role,app])=>{
      const m=metadata(role),bytes=Buffer.from(role);
      return {...inspectMetadata(role,'debug',m.badge,m.tree,m.signing),file:role+'.apk',
        flavor:app.flavor,target:app.target,sha256:sha(bytes),bytes:bytes.length,
        payload_scan:{...scanPayload(Buffer.from(endpoint+rehearsalKey+'_catalog_price_contract'),rehearsalKey),payload:'assets/flutter_assets/kernel_blob.bin'}};
    }),
  });
}
function completed(b,result='PASS') {
  const form=fieldTemplate(b);form.device_aliases={customer:'customer-device-1',merchant:'merchant-device-1'};
  for(const c of form.cases){c.result=result;c.observed_at='2026-01-02T00:00:00.000Z';c.evidence_sha256='e'.repeat(64);}
  return form;
}

test('synthetic pairs allow empty preparation only, never PASS or FAIL device observations',()=>{
  const b={...bundle(),purpose:'compile-rehearsal'};
  assert.equal(assessField(b,fieldTemplate(b)).observed_open,12);
  for(const result of ['PASS','FAIL'])assert.throws(()=>assessField(b,completed(b,result)));
});
test('same, swapped or missing device aliases are refused for device evidence',()=>{
  const b=bundle();
  for(const aliases of [
    {customer:'customer-device-1',merchant:'customer-device-1'},
    {customer:'merchant-device-1',merchant:'customer-device-1'},
    {customer:null,merchant:'merchant-device-1'},
  ]){const form=completed(b);form.device_aliases=aliases;assert.throws(()=>assessField(b,form));}
});
test('field evidence rejects normalized invalid dates, future/prebuild time and invalid bundle dates',()=>{
  const b=bundle();
  for(const time of ['2026-02-30T00:00:00.000Z','2026-01-01T24:00:00.000Z','2100-01-02T00:00:00.000Z','2025-12-31T23:59:59.999Z']){
    const form=completed(b);form.cases[0].observed_at=time;assert.throws(()=>assessField(b,form));
  }
  assert.throws(()=>assessField({...b,created_at:'2026-02-30T00:00:00.000Z'},completed(b)));
});
test('failure dominates partial or completed reports and identifies exact failed/open cases',()=>{
  const b=bundle(),form=completed(b);form.cases[8].result='FAIL';
  form.cases[11]={...fieldTemplate(b).cases[11]};
  const report=assessField(b,form);assert.equal(report.status,'FIELD_BLOCKED');assert.equal(report.stop_required,true);
  assert.deepEqual(report.failed_cases,['two_device_qr']);assert.deepEqual(report.pending_cases,['private_history_and_inbox']);
  assert.equal(report.pilot_ready,false);assert.equal(report.remote_authorized,false);
});
test('evidence JSON rejects nested and escaped duplicate keys before values disappear',()=>{
  assert.deepEqual(parseRecord('{"text":"a colon : and \\"quoted\\"","array":[{"ok":true}]}'),
    {text:'a colon : and "quoted"',array:[{ok:true}]});
  for(const text of ['{"result":"FAIL","result":"PASS"}','{"a":{"id":1,"\\u0069d":2}}','{"a":[{"x":1,"x":2}]}','null','[]'])
    assert.throws(()=>parseRecord(text));
});

const invalidManifests=[
  ['enabled economic flag',b=>b.capabilities.REWARD_EARNING_V1_ENABLED=true],
  ['missing flag',b=>delete b.capabilities.QR_CLAIMS_V2_ENABLED],
  ['taxonomy enabled',b=>b.canonical_taxonomy=true],
  ['incorrect catalog contract',b=>b.catalog_price_contract='legacy'],
  ['unreviewed source',b=>b.uncommitted_sources=true],
  ['remote authority',b=>b.remote_authorized=true],
  ['remote access',b=>b.remote_access='READ'],
  ['physical acceptance assertion',b=>b.physical_two_device='PASS'],
  ['wrong purpose status',b=>b.status='COMPILE_REHEARSAL_PASS_NOT_DISTRIBUTABLE'],
  ['bad source revision',b=>b.source_commit='main'],
  ['bad timestamp',b=>b.created_at='2026-02-30T00:00:00.000Z'],
  ['wrong callback',b=>b.artifacts[1].callback=b.artifacts[0].callback],
  ['wrong target',b=>b.artifacts[1].target=b.artifacts[0].target],
  ['mismatched version',b=>b.artifacts[1].version_code++],
  ['mismatched certificate',b=>b.artifacts[1].certificate_sha256='b'.repeat(64)],
  ['missing packaged key',b=>b.artifacts[1].payload_scan.supplied_client_key_present=false],
  ['release claim on debug artifact',b=>b.mode='release'],
  ['missing compatibility tests',b=>b.tests.paths=[]],
  ['partial test count',b=>b.tests.passed=60.5],
  ['missing config hash',b=>delete b.config_sha256.customer],
  ['unsafe artifact name',b=>b.artifacts[1].file='../merchant.apk'],
];
for(const [name,change] of invalidManifests)test('manifest rejects '+name+' even with recalculated checksum',()=>{
  const b=manifest();change(b);assert.throws(()=>validateBundle(seal(b)));
});
test('valid release pair must have matching owner certificates and non-debug payload metadata',()=>{
  const b=manifest();b.mode='release';
  for(const item of b.artifacts){item.mode='release';item.debuggable=false;item.certificate_sha256=ownerCertificate;item.payload_scan.payload='lib/arm64-v8a/libapp.so';}
  assert(validateBundle(seal(b)));
  for(const item of b.artifacts)item.certificate_sha256='c'.repeat(64);
  assert.throws(()=>validateBundle(seal(b)));
});

async function fixture(t) {
  const repo=await temporary(t);await run('git',['init','--quiet'],{cwd:repo});
  await mkdir(resolve(repo,'lib'));
  await Promise.all(Array.from({length:101},(_,i)=>writeFile(resolve(repo,`lib/file${String(i).padStart(3,'0')}.dart`),'fixture')));
  const source=await sourceSnapshot(repo),b=manifest(source.sha256),dir=await newOutput(repo,'test-pair');
  await mkdir(resolve(repo,'.buildlog/pilot-device-input'));
  await writeFile(resolve(dir,'pair.json'),json(b));await writeFile(resolve(dir,'sources.json'),json(source));
  for(const role of Object.keys(applications))await writeFile(resolve(dir,role+'.apk'),role);
  return {repo,dir,b,source};
}
test('pair verifier hashes actual APK bytes and source manifest, not filename or unchecked PASS',async t=>{
  const {dir,b}=await fixture(t);
  assert.equal((await verifyBundle(dir,{currentSources:false})).bundle_id,b.bundle_id);
  await writeFile(resolve(dir,'merchant.apk'),'changed');await assert.rejects(verifyBundle(dir,{currentSources:false}));
});
test('same-checksum manifest cannot bypass source drift, duplicate paths or traversal',async t=>{
  const {repo,dir,b,source}=await fixture(t);
  await writeFile(resolve(repo,'lib/file000.dart'),'changed');
  await assert.rejects(verifyBundle(dir,{repo}));
  for(const path of ['../outside','/outside','lib/./a','lib//a','C:/outside','lib/file001.dart']){
    const changed=structuredClone(source);changed.files[0].path=path;changed.sha256=sha(json(changed.files));
    await writeFile(resolve(dir,'sources.json'),json(changed));
    await writeFile(resolve(dir,'pair.json'),json(seal({...b,source_sha256:changed.sha256})));
    await assert.rejects(verifyBundle(dir,{currentSources:false}));
  }
});
test('pair and source evidence reject reparse redirection even to byte-identical files',async t=>{
  const {dir}=await fixture(t),outside=await temporary(t);
  for(const name of ['pair.json','sources.json']){
    const data=await readFile(resolve(dir,name));await writeFile(resolve(outside,name),data);
    await rm(resolve(dir,name));await symlink(resolve(outside,name),resolve(dir,name),'file');
    await assert.rejects(verifyBundle(dir,{currentSources:false}));
    await rm(resolve(dir,name));await writeFile(resolve(dir,name),data);
  }
});
for(const scenario of [
  {name:'empty',code:3,status:'FIELD_INCOMPLETE',form:b=>fieldTemplate(b)},
  {name:'failed',code:2,status:'FIELD_BLOCKED',form:b=>{const f=completed(b);f.cases[8].result='FAIL';return f;}},
  {name:'reported',code:0,status:'FIELD_REPORTED_COMPLETE_REQUIRES_OWNER_REVIEW',form:b=>completed(b)},
])test('review entrypoint reports '+scenario.name+' accurately and preserves evidence',async t=>{
  const {repo,dir,b}=await fixture(t),form=scenario.form(b),messages=[];
  const inputText=json(form);await writeFile(resolve(repo,'.buildlog/pilot-device-input/observation.json'),inputText);
  const options={repo,output:m=>messages.push(m),error:m=>messages.push(m)};
  assert.equal(await reviewMain(['test-pair','observation'],options),scenario.code);
  assert(messages[0].startsWith(scenario.status));assert(!messages[0].includes('PAIR_REVIEW_PASS'));
  const path=resolve(dir,'observation.review.json'),text=await readFile(path,'utf8'),report=JSON.parse(text);
  assert.equal(report.observation_sha256,sha(inputText));assert.equal(report.remote_authorized,false);assert.equal(report.pilot_ready,false);
  assert.equal(await reviewMain(['test-pair','observation'],options),1);
  assert.equal(await readFile(path,'utf8'),text);
});
test('review entrypoint rejects synthetic device claims and does not write a review file',async t=>{
  const {repo,dir,b}=await fixture(t);
  const synthetic=seal({...b,purpose:'compile-rehearsal',status:'COMPILE_REHEARSAL_PASS_NOT_DISTRIBUTABLE'});
  await writeFile(resolve(dir,'pair.json'),json(synthetic));
  await writeFile(resolve(repo,'.buildlog/pilot-device-input/observation.json'),json(completed(synthetic)));
  assert.equal(await reviewMain(['test-pair','observation'],{repo,output:()=>{},error:()=>{}}),1);
  await assert.rejects(readFile(resolve(dir,'observation.review.json')));
});
test('artifact-only review has a distinct outcome and refuses stale sources',async t=>{
  const {repo}=await fixture(t),messages=[];
  const options={repo,output:m=>messages.push(m),error:m=>messages.push(m)};
  assert.equal(await reviewMain(['test-pair'],options),0);
  assert(messages[0].startsWith('PAIR_ARTIFACTS_VERIFIED'));
  await writeFile(resolve(repo,'lib/file000.dart'),'new source');
  assert.equal(await reviewMain(['test-pair'],options),1);
  assert(messages[1].startsWith('PAIR_REVIEW_REFUSED'));
});
test('review rejects duplicate input fields and redirected observation files without creating a report',async t=>{
  const {repo,dir,b}=await fixture(t),outside=await temporary(t);
  const path=resolve(repo,'.buildlog/pilot-device-input/observation.json'),form=completed(b);
  await writeFile(path,json(form).replace('{','{"owner_opening":"PASS",'));
  const options={repo,output:()=>{},error:()=>{}};
  assert.equal(await reviewMain(['test-pair','observation'],options),1);
  await assert.rejects(readFile(resolve(dir,'observation.review.json')));
  await writeFile(resolve(outside,'observation.json'),json(form));await rm(path);
  await symlink(resolve(outside,'observation.json'),path,'file');
  assert.equal(await reviewMain(['test-pair','observation'],options),1);
  await assert.rejects(readFile(resolve(dir,'observation.review.json')));
});
