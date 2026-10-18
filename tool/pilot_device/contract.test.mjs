import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtemp,writeFile,readFile,mkdir,symlink,rm,realpath} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {resolve} from 'node:path';
import {applications,capabilities,endpoint,project,rehearsalKey,ownerCertificate,json,sha,parseInput,pairDefines,inspectMetadata,fieldTemplate,assessField,scanPayload} from './contract.mjs';
import {newOutput,testResult,run} from './build_pair.mjs';
import {verifyBundle} from './review_pair.mjs';
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
const bundle=()=>({bundle_id:'b'.repeat(64),created_at:'2026-01-01T00:00:00.000Z',purpose:'compile-rehearsal',mode:'debug',artifacts:[{role:'customer',sha256:'a'.repeat(64)},{role:'merchant',sha256:'c'.repeat(64)}]});
test('field template is empty, binds exact pair, and cannot become pilot authorization',()=>{
  const b=bundle(),form=fieldTemplate(b),result=assessField(b,form);assert.equal(result.observed_open,12);assert.equal(result.pilot_ready,false);
  form.device_aliases={customer:'customer-device-1',merchant:'merchant-device-1'};
  for(const c of form.cases){c.result='PASS';c.observed_at='2026-01-02T00:00:00.000Z';c.evidence_sha256='e'.repeat(64);}
  const reviewed=assessField(b,form);assert.equal(reviewed.observed_pass,12);assert.equal(reviewed.pilot_ready,false);assert.equal(reviewed.owner_opening,'OPEN');
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
test('pair verifier hashes actual APK bytes and source manifest, not filename or unchecked PASS',async t=>{
  const dir=await temporary(t),source={files:[{path:'a',sha256:sha('source')}]};source.sha256=sha(json(source.files));
  const b={...bundle(),kind:'esnaftavar-pilot-device-pair-v1',project_ref:project,pilot_ready:false,remote_authorized:false,
    tests:{result:'PASS',passed:70,failed:0,skipped:0},source_sha256:source.sha256};
  b.artifacts=[];
  for(const role of Object.keys(applications)){const bytes=Buffer.from(role);await writeFile(resolve(dir,role+'.apk'),bytes);b.artifacts.push({role,file:role+'.apk',application_id:applications[role].id,sha256:sha(bytes),bytes:bytes.length});}
  delete b.bundle_id;b.bundle_id=sha(json(b));await writeFile(resolve(dir,'pair.json'),json(b));await writeFile(resolve(dir,'sources.json'),json(source));
  assert.equal((await verifyBundle(dir,{currentSources:false})).bundle_id,b.bundle_id);
  await writeFile(resolve(dir,'merchant.apk'),'changed');await assert.rejects(verifyBundle(dir,{currentSources:false}));
});
