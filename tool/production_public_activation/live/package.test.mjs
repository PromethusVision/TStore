import test from 'node:test';
import assert from 'node:assert/strict';
import {randomBytes} from 'node:crypto';
import {read,hash,json,directory,authority,project,payload,manifest,writeIntent} from './common.mjs';
import {verify,measure} from './seal.mjs';
import {parse,run} from './cli.mjs';
import {readState,activate,rollback} from './engine.mjs';
import {artifactGate,physicalGate} from './artifact.mjs';
import {connectionFactory} from './production.mjs';
import {issueBackup,requireBackup} from '../../production_public_client/live/backup.mjs';
const seal=hash(read(directory+'/seal.json'));
const transport={verified:true,kind:'TLS_VERIFY_FULL_EXACT_PRODUCTION_HOST',project_ref:project,hostname:`db.${project}.supabase.co`,sslmode:'verify-full',database:'postgres',username:'postgres',port:5432};
const options={production_authorized:true,sql_sha256:manifest().activation_sql_sha256,seal_sha256:seal};
const unreachable=t=>({transport:t,exec(){assert.fail('Unexpected database access');},query(){assert.fail('Unexpected database access');}});
test('seal pins current main, exact reviewed SQL and complete execution closure',()=>{
 assert.equal(authority,'c75c17c6ebe8683b1d652a2fab05ed7700739453');assert.equal(verify(seal).result,'PASS');
 const inventory=measure().map(r=>r.path);
 for(const f of ['cli.mjs','production.mjs','engine.mjs','validators.mjs','artifact.mjs','runtime-manifest.json','artifact-contract.json','physical-public-off.json'])assert.ok(inventory.includes(directory+'/'+f));
 for(const f of ['activate.sql','rollback.sql','policy.mjs','compatibility.mjs'])assert.ok(inventory.includes('tool/production_public_activation/'+f));
 assert.ok(inventory.includes('tool/production_public_client/executor.mjs'));
 assert.ok(inventory.includes('tool/production_public_client/live/backup.mjs'));
 assert.ok(!inventory.some(p=>p.endsWith('.md')||/rehearse|failure-tests|package\.test|flutter_integration/.test(p)));
 assert.equal(hash(payload()),manifest().activation_sql_sha256);assert.equal(hash(payload(true)),manifest().rollback_sql_sha256);
});
test('reviewed SQL touches publication flags only and preserves 0015',()=>{
 for(const sql of [payload(),payload(true)]){
  assert.doesNotMatch(sql,/\b(?:CREATE|ALTER|DROP|TRUNCATE|GRANT|REVOKE)\s+(?:TABLE|FUNCTION|SCHEMA|POLICY)\b/i);
  const mutations=[...sql.matchAll(/UPDATE public\.(\w+)/g)].map(m=>m[1]).sort();
  assert.deepEqual(mutations,['canonical_categories','production_taxonomy_config','taxonomy_aliases']);
  assert.doesNotMatch(sql,/UPDATE public\.(?:products|shop_products|shops|canonical_category_qualification|product_canonical_assignments)\b/);
 }
});
test('wrong seal, target, SQL or absent authority stops without any DB request',async()=>{
 assert.throws(()=>verify('0'.repeat(64)),/W52LE_PACKAGE_HASH/);
 await assert.rejects(readState(unreachable({...transport,project_ref:'wrong'}),options),/W52LC_TARGET_IDENTITY/);
 await assert.rejects(activate(unreachable(transport),{...options,production_authorized:false},null),/W52LE_EXPLICIT_ACTIVATION_AUTHORIZATION_REQUIRED/);
 for(const fn of [activate,rollback])await assert.rejects(fn(unreachable(transport),{...options,sql_sha256:'0'.repeat(64)},null),/W52LE_EXPECTED_SQL_HASH/);
});
test('frozen final public artifact identity is immutable and missing bytes fail closed',()=>{
 const a=json(directory+'/artifact-contract.json');
 assert.equal(a.apk.sha256,'04d71bfd25920c171fd25f27416ee22f74f851608bb3c79b1561dc4966827f64');
 assert.equal(a.aab.sha256,'17e361684eab4aea6432bfa47a00af543777107c8bf7d0ccd472341b9e77cc79');
 assert.equal(a.version_code,3);assert.equal(a.runtime,'PRODUCTION_PUBLIC_CANONICAL');assert.equal(a.preview_define,false);
 assert.throws(()=>artifactGate({}),/W52LE_FROZEN_ARTIFACT_PATH_REQUIRED/);
});
test('live activation requires sealed physical OFF proof for the same APK',()=>{
 const proof=json(directory+'/physical-public-off.json');assert.equal(proof.result,'PASS');
 assert.equal(physicalGate({transport}).result,'PASS');
 assert.equal(physicalGate({transport:{kind:'ISOLATED_REAL_BACKUP_RESTORE'}}).result,'LOCAL_REHEARSAL_ONLY');
 assert.equal(proof.serial_recorded,false);assert.equal(proof.rebuild,false);
});
test('CLI exposes only preflight, activate, postflight and rollback with strict options',()=>{
 assert.deepEqual(manifest().operations,['preflight','activate','postflight','rollback']);
 for(const op of ['deploy','db-push','apply-sql',''])assert.throws(()=>parse([op,'--production-authorized']),/W52LE_OPERATION_REQUIRED/);
 for(const flag of ['--password','--sql-file','--host','--tester','--skip-backup','--skip-artifact'])assert.throws(()=>parse(['activate','--production-authorized',flag,'x']),/W52LE_UNKNOWN_OR_DUPLICATE_OPTION/);
 assert.throws(()=>parse(['activate','--production-authorized','--production-authorized']),/W52LE_UNKNOWN_OR_DUPLICATE_OPTION/);
 assert.throws(()=>parse(['activate']),/W52LE_EXPLICIT_LIVE_AUTHORIZATION_REQUIRED/);
 assert.equal(parse(['preflight','--production-authorized','--apk','external.apk']).apk,'external.apk');
});
test('backup receipt rejects forged, corrupt, stale and changed-baseline evidence',()=>{
 const bytes=Buffer.concat([Buffer.from('PGDMP'),randomBytes(16)]),fingerprint='b'.repeat(64);
 const data={bytes,tocVerified:true,metadata:{project_ref:project,database:'postgres',source_pg_version:'17.6',format:'CUSTOM',tool_version:'17.6',completed_at_utc:new Date().toISOString(),sha256:hash(bytes),size_bytes:bytes.length}};
 const receipt=issueBackup(data,fingerprint);assert.ok(Object.isFrozen(receipt));
 assert.equal(requireBackup(receipt,fingerprint).baseline_fingerprint,fingerprint);
 assert.throws(()=>requireBackup({...receipt},fingerprint),/VERIFIED_FRESH_BACKUP_REQUIRED/);
 assert.throws(()=>requireBackup(receipt,'c'.repeat(64)),/BACKUP_BASELINE_CHANGED/);
 assert.throws(()=>requireBackup(receipt,fingerprint,Date.parse(receipt.completed_at_utc)+900001),/BACKUP_EXPIRED/);
 bytes[6]^=255;assert.throws(()=>issueBackup(data,fingerprint),/BACKUP_HASH/);
});
test('credential is consumed only from process environment and cleared on refusal',()=>{
 const saved=process.env.PGPASSWORD;try{
  process.env.PGPASSWORD=randomBytes(24).toString('hex');
  assert.throws(()=>connectionFactory({production_authorized:true,project_ref:'wrong'}),/W52LE_TARGET_IDENTITY/);
  assert.equal(process.env.PGPASSWORD,undefined);
 }finally{if(saved!==undefined)process.env.PGPASSWORD=saved;}
});
test('safe CLI rejection precedes connection and clears environment without raw output',async()=>{
 const saved=process.env.PGPASSWORD;try{
  process.env.PGPASSWORD=randomBytes(24).toString('hex');
  const result=await run(['activate','--production-authorized','--seal-sha256','0'.repeat(64)]);
  assert.equal(result.result,'STOPPED_BEFORE_WRITE');assert.equal(result.safe_error,'W52LE_PACKAGE_HASH');
  assert.equal(result.production_write_attempted,false);assert.equal(result.child_pgpassword_cleared,true);assert.equal(process.env.PGPASSWORD,undefined);
 }finally{if(saved!==undefined)process.env.PGPASSWORD=saved;}
});
