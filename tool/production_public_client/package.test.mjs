import test from 'node:test';
import assert from 'node:assert/strict';
import {verify} from './seal.mjs';
import {install,publication,uninstall,localBoundary,activationView} from './executor.mjs';
import {json,directory,functionQuery,ledgerQuery} from './common.mjs';
const seal=json(directory+'/seal.json').sha256;
test('new seal verifies its additive inputs and the unchanged activation seal',()=>assert.equal(verify(seal).result,'PASS'));
test('wrong externally supplied seal fails before a DB action',()=>assert.throws(()=>verify('0'.repeat(64)),/W52LB_PACKAGE_SEAL/));
test('every facade/publication write rejects live and unverified transports',async()=>{
 for(const transport of [{kind:'LIVE_PRODUCTION',verified:true,project_ref:'mefhfvrgkwciubeajjeb'},{kind:'ISOLATED_REAL_BACKUP_RESTORE',verified:false,project_ref:'mefhfvrgkwciubeajjeb'},{kind:'ISOLATED_REAL_BACKUP_RESTORE',verified:true,project_ref:'wrong'}]){
  const db={transport,exec(){throw Error('DB_MUST_NOT_BE_ACCESSED');},query(){throw Error('DB_MUST_NOT_BE_ACCESSED');}};
  assert.throws(()=>localBoundary(db),/W52LB_LOCAL_WRITE_ONLY/);
  await assert.rejects(install(db,seal),/W52LB_LOCAL_WRITE_ONLY/);
  await assert.rejects(publication(db,seal,true),/W52LB_LOCAL_WRITE_ONLY/);
  await assert.rejects(publication(db,seal,false),/W52LB_LOCAL_WRITE_ONLY/);
  await assert.rejects(uninstall(db,seal),/W52LB_LOCAL_WRITE_ONLY/);
 }
});
test('compatibility view cannot mask unverified facade inventory or ledger',async()=>{
 const db={query:async()=>({rows:[]})},view=activationView(db);
 await assert.rejects(view.query(functionQuery),/W52LB_FACADE_DEFINITION_OR_GRANT_DRIFT/);
 await assert.rejects(view.query(ledgerQuery),/W52LB_FACADE_DEFINITION_OR_GRANT_DRIFT/);
});
test('compatibility view forwards every other query and argument unchanged',async()=>{
 const calls=[],response={rows:[{version:'must-not-be-hidden',name:'production_public_products_v1'}]};
 const db={query:async(...args)=>{calls.push(args);return response;}},view=activationView(db);
 assert.equal(await view.query(functionQuery+' ',['test']),response);
 assert.deepEqual(calls,[[functionQuery+' ',['test']]]);
});
