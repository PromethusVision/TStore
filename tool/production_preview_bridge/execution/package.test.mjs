import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync,writeFileSync,unlinkSync,existsSync} from 'node:fs';
import {resolve} from 'node:path';
import {randomUUID} from 'node:crypto';
import {validatePlan} from './authorization.mjs';
import {connect} from './production.mjs';
import {payload,project,root,directory,read,hash,sourcePath} from './common.mjs';
import {verify,measure} from './seal.mjs';
const plan=()=>({project_ref:project,user_ids:[randomUUID()],expires_at_utc:new Date(Date.now()+3600000).toISOString()});
test('frozen SQL sources and exact outer-transaction reconstruction',()=>{assert.equal(payload().source_sha256,'9b56e249a6e3054b8303742ca4bcc41d40e216de9c1a62a72193e4bae81091a4');assert.equal(payload(true).source_sha256,'fa138b7d9c42086323e10ef9e05985bc71f65357fc3c4a81e38dbdaab52104d4');});
test('explicit owner plan is valid and cloned/frozen',()=>{const p=plan(),f=validatePlan(p);assert.ok(Object.isFrozen(f.user_ids));p.user_ids[0]='changed';assert.notEqual(f.user_ids[0],'changed');});
for(const [label,mutate]of [
 ['wrong target',p=>p.project_ref='wrong'],['missing UID',p=>p.user_ids=[]],['invalid UID',p=>p.user_ids=['invalid']],['duplicate UID',p=>p.user_ids.push(p.user_ids[0])],['absent expiry',p=>delete p.expires_at_utc],['expired approval',p=>p.expires_at_utc='2020-01-01T00:00:00Z'],['excessive lease',p=>p.expires_at_utc=new Date(Date.now()+31*86400000).toISOString()],['unexpected field',p=>p.email='unused@local.invalid'],
 ])test('refuse '+label,()=>{const p=plan();mutate(p);assert.throws(()=>validatePlan(p));});
test('revocation accepts expired lease for exact removal',()=>{const p=plan();p.expires_at_utc='2020-01-01T00:00:00Z';assert.doesNotThrow(()=>validatePlan(p,Date.now(),true));});
test('transport refuses absent live authorization before any IO',()=>assert.throws(()=>connect({}),/LIVE_AUTHORIZATION_REQUIRED/));
test('wrong manifest hash is rejected',()=>assert.throws(()=>verify('0'.repeat(64)),/BX_PACKAGE_HASH/));
test('runtime changes fail; unrelated evidence additions preserve seal',()=>{
 const expected=hash(read(`${directory}/manifest.json`));verify(expected);
 const path=resolve(root,directory,'authorization.mjs'),bytes=readFileSync(path);
 try{writeFileSync(path,Buffer.concat([bytes,Buffer.from('\n// controlled tamper probe\n')]));assert.throws(()=>verify(expected),/SEALED_INPUT_DRIFT/);}finally{writeFileSync(path,bytes);}
 const evidence=resolve(root,'docs/data/w52k_bx_scope_test_temporary.json');assert.equal(existsSync(evidence),false);
 try{writeFileSync(evidence,'{"test":"unrelated evidence output"}\n');assert.doesNotThrow(()=>verify(expected));}finally{unlinkSync(evidence);}
 verify(expected);
});
test('inventory covers live, rollback, authorization and transitive imports',()=>{
 const paths=new Set(measure().map(x=>x.path));for(const path of [sourcePath,`${directory}/engine.mjs`,`${directory}/production.mjs`,`${directory}/authorization.mjs`,'tool/production_taxonomy/execution/session.mjs','tool/production_taxonomy/real_contract_checks.mjs','tool/taxonomy_migration/lib.mjs','docs/TAXONOMY_W36_CATEGORY_IMPORT.csv'])assert.ok(paths.has(path),path);
 assert.ok(!paths.has('docs/data/w52k_a_canonical_production_rc_validation.json'));
});
