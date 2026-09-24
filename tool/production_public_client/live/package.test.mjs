import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync,writeFileSync,rmSync,mkdirSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {resolve,dirname,basename} from 'node:path';
import {randomBytes} from 'node:crypto';
import {read,hash,json,root,directory,authority,project,sourceHash,payloadHash,payload,migration,target,writeIntent,functions,rollbackPath} from './common.mjs';
import {verify,measure} from './seal.mjs';
import {parse,run} from './cli.mjs';
import {issueBackup,requireBackup} from './backup.mjs';
import {externalPath,connectionFactory} from './production.mjs';
import {readState,install,rollback} from './engine.mjs';
const seal=hash(read(directory+'/seal.json'));
const transport={verified:true,kind:'TLS_VERIFY_FULL_EXACT_PRODUCTION_HOST',project_ref:project,hostname:`db.${project}.supabase.co`,sslmode:'verify-full',database:'postgres',username:'postgres',port:5432};
const options={production_authorized:true,sql_sha256:sourceHash,seal_sha256:seal};
function unreachable(transport){return {transport,exec(){assert.fail('Unexpected database access');},query(){assert.fail('Unexpected database access');}};}
function backup(){
 const bytes=Buffer.concat([Buffer.from('PGDMP'),randomBytes(16)]);
 return {bytes,tocVerified:true,metadata:{project_ref:project,database:'postgres',source_pg_version:'17.6',format:'CUSTOM',tool_version:'17.6',completed_at_utc:new Date().toISOString(),sha256:hash(bytes),size_bytes:bytes.length}};
}
const fingerprint='b'.repeat(64);

test('seal freezes the required main and complete runtime import closure',()=>{
 assert.equal(json(directory+'/seal.json').authority_main,authority);
 assert.equal(verify(seal).result,'PASS');
 const inventory=measure().map(i=>i.path);
 for(const f of ['cli.mjs','production.mjs','engine.mjs','validators.mjs','backup.mjs','runtime-manifest.json'])assert.ok(inventory.includes(directory+'/'+f));
 assert.ok(inventory.includes(migration));
 assert.ok(inventory.includes(rollbackPath));
 assert.ok(inventory.includes('tool/production_taxonomy/execution/session.mjs'));
 assert.ok(inventory.includes('tool/production_preview_bridge/live_v2/transaction.mjs'));
 for(const f of ['rehearse.mjs','failure-tests.mjs','local-support.mjs','package.test.mjs'])assert.ok(!inventory.includes(directory+'/'+f));
});
test('wrong/missing external seal and live SQL pins reject before database access',async()=>{
 for(const value of [undefined,'',seal.toUpperCase(),'0'.repeat(64)])assert.throws(()=>verify(value),/W52LC_EXTERNAL_SEAL_REQUIRED|W52LC_PACKAGE_HASH/);
 await assert.rejects(install(unreachable(transport),{...options,sql_sha256:'0'.repeat(64)},null),/W52LC_EXPECTED_SQL_HASH/);
 await assert.rejects(rollback(unreachable(transport),{...options,sql_sha256:'0'.repeat(64)}),/W52LC_EXPECTED_SQL_HASH/);
});
test('0015 source and transaction payload are exactly the reviewed artifact',()=>{
 assert.equal(hash(read(migration)),sourceHash);assert.equal(hash(payload()),payloadHash);
 assert.equal((payload().match(/CREATE FUNCTION public\./g)??[]).length,4);
 assert.deepEqual([...payload().matchAll(/CREATE FUNCTION public\.(\w+)/g)].map(m=>m[1]).sort(),[...functions].sort());
 assert.doesNotMatch(payload(),/\b(?:INSERT\s+INTO|UPDATE\s+public\.|DELETE\s+FROM|CREATE\s+POLICY|ALTER\s+TABLE)\b/i);
 assert.equal((payload().match(/SECURITY INVOKER/g)??[]).length,3);
 assert.equal((payload().match(/SECURITY DEFINER/g)??[]).length,1);
 assert.equal((payload().match(/SET search_path=pg_catalog,public/g)??[]).length,4);
});
test('rollback drops only the four pinned signatures without cascade or data mutations',()=>{
 const sql=read(rollbackPath);
 assert.deepEqual([...sql.matchAll(/DROP FUNCTION public\.(\w+)/g)].map(m=>m[1]).sort(),[...functions].sort());
 assert.doesNotMatch(sql,/\b(?:CASCADE|TRUNCATE|UPDATE|DELETE|DROP TABLE|DROP SCHEMA)\b/);
});
test('target requires exact verified transport and TLS identity',()=>{
 assert.doesNotThrow(()=>target({transport}));
 for(const change of [{project_ref:'wrong'},{verified:false},{kind:'UNTRUSTED'},{hostname:'localhost'},{sslmode:'require'},{database:'other'},{username:'other'},{port:6543}])assert.throws(()=>target({transport:{...transport,...change}}),/W52LC_(TARGET_IDENTITY|TRUSTED_TRANSPORT_REQUIRED|TLS_IDENTITY_REQUIRED)/);
});
test('write authorization and read target guards fail before database access',async()=>{
 assert.throws(()=>writeIntent({transport},{...options,production_authorized:false}),/W52LC_EXPLICIT_DEPLOY_AUTHORIZATION_REQUIRED/);
 await assert.rejects(readState(unreachable({...transport,project_ref:'wrong'}),seal),/W52LC_TARGET_IDENTITY/);
 await assert.rejects(install(unreachable(transport),{...options,production_authorized:false},null),/W52LC_EXPLICIT_DEPLOY_AUTHORIZATION_REQUIRED/);
 await assert.rejects(rollback(unreachable(transport),{...options,production_authorized:false}),/W52LC_EXPLICIT_DEPLOY_AUTHORIZATION_REQUIRED/);
});
test('CLI exposes only four operations; no activation, arbitrary SQL, db push or credential argument',()=>{
 assert.deepEqual(json(directory+'/runtime-manifest.json').operations,['preflight','deploy','postflight','rollback']);
 for(const op of ['activate','publication','db-push','apply-sql',''])assert.throws(()=>parse([op,'--production-authorized']),/W52LC_OPERATION_REQUIRED/);
 for(const arg of ['--password','--sql-file','--host','--allow-activation','--tester'])assert.throws(()=>parse(['deploy','--production-authorized',arg,'unsafe']),/W52LC_UNKNOWN_OR_DUPLICATE_OPTION/);
 assert.equal(parse(['preflight','--production-authorized','--seal-sha256',seal]).seal_sha256,seal);
 assert.throws(()=>parse(['preflight']),/W52LC_EXPLICIT_LIVE_AUTHORIZATION_REQUIRED/);
 assert.throws(()=>parse(['preflight','--production-authorized','--production-authorized']),/W52LC_UNKNOWN_OR_DUPLICATE_OPTION/);
 assert.throws(()=>parse(['preflight','--production-authorized','--seal-sha256']),/W52LC_UNKNOWN_OR_DUPLICATE_OPTION/);
});
test('backup receipts require verified bytes, TOC, provenance and unchanged baseline',()=>{
 const receipt=issueBackup(backup(),fingerprint);
 assert.ok(Object.isFrozen(receipt));assert.equal(requireBackup(receipt,fingerprint).baseline_fingerprint,fingerprint);
 for(const copy of [null,{}, {...receipt}])assert.throws(()=>requireBackup(copy,fingerprint),/W52LC_VERIFIED_FRESH_BACKUP_REQUIRED/);
 assert.throws(()=>requireBackup(receipt,'c'.repeat(64)),/W52LC_BACKUP_BASELINE_CHANGED/);
 assert.throws(()=>issueBackup({...backup(),tocVerified:false},fingerprint),/W52LC_BACKUP_TOC_REQUIRED/);
 const corrupt=backup();corrupt.bytes[6]^=255;assert.throws(()=>issueBackup(corrupt,fingerprint),/W52JB_BACKUP_HASH/);
 const badProject=backup();badProject.metadata.project_ref='wrong';assert.throws(()=>issueBackup(badProject,fingerprint),/W52JB_BACKUP_IDENTITY/);
});
test('backup freshness is at most fifteen minutes with bounded clock skew',()=>{
 const receipt=issueBackup(backup(),fingerprint),completed=Date.parse(receipt.completed_at_utc);
 assert.doesNotThrow(()=>requireBackup(receipt,fingerprint,completed+900000));
 for(const now of [completed+900001,completed-30001,NaN])assert.throws(()=>requireBackup(receipt,fingerprint,now),/W52LC_BACKUP_EXPIRED/);
});
test('external archive guard rejects repo paths, nested repos and overwrites',()=>{
 assert.throws(()=>externalPath(resolve(root,directory,'seal.json')),/W52LC_EXTERNAL_PATH_REQUIRED/);
 assert.throws(()=>externalPath('relative'),/W52LC_EXTERNAL_ABSOLUTE_PATH_REQUIRED/);
 const dir=mkdtempSync(resolve(tmpdir(),'w52lc-path-test-'));
 try{
  const file=resolve(dir,'existing');writeFileSync(file,'non-sensitive-fixture');
  assert.ok(externalPath(file));assert.throws(()=>externalPath(file,{newFile:true}),/W52LC_BACKUP_OVERWRITE_FORBIDDEN/);
  mkdirSync(resolve(dir,'.git'));assert.throws(()=>externalPath(file),/W52LC_INPUT_INSIDE_GIT_CHECKOUT/);
 }finally{const target=resolve(dir);assert.equal(dirname(target),resolve(tmpdir()));assert.ok(basename(target).startsWith('w52lc-path-test-'));rmSync(target,{recursive:true,force:true});}
});
test('factory rejects missing authority/wrong target and clears temporary environment on error',()=>{
 const saved=process.env.PGPASSWORD;delete process.env.PGPASSWORD;
 try{
  for(const config of [{},{production_authorized:true,project_ref:'wrong'}]){
   process.env.PGPASSWORD=randomBytes(24).toString('hex');
   assert.throws(()=>connectionFactory(config),/W52LC_EXPLICIT_LIVE_AUTHORIZATION_REQUIRED|W52LC_TARGET_IDENTITY/);
   assert.equal(process.env.PGPASSWORD,undefined);
  }
 }finally{if(saved!==undefined)process.env.PGPASSWORD=saved;}
});
test('safe CLI failure neither connects nor prints private error details',async()=>{
 const saved=process.env.PGPASSWORD;delete process.env.PGPASSWORD;
 try{
  process.env.PGPASSWORD=randomBytes(24).toString('hex');
  const result=await run(['deploy','--production-authorized','--seal-sha256','0'.repeat(64)]);
  assert.equal(result.result,'STOPPED_BEFORE_WRITE');assert.equal(result.safe_error,'W52LC_PACKAGE_HASH');
  assert.equal(result.production_write_attempted,false);assert.equal(result.public_activation_performed,false);
  assert.equal(result.child_pgpassword_cleared,true);assert.equal(process.env.PGPASSWORD,undefined);
 }finally{if(saved!==undefined)process.env.PGPASSWORD=saved;}
});
