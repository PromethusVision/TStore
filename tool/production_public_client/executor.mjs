// Readiness only: no live transport can write through this package.
import {check,read,json,hash,stable,literal,project,payload,version,name,functions,directory,activationSeal,functionQuery,ledgerQuery} from './common.mjs';
import {verify as verifyActivation} from '../production_public_activation/seal.mjs';
import {readPreflight,readPostflight,activate,rollback as rollbackActivation} from '../production_public_activation/executor.mjs';
import {preflight as activationPreflight} from '../production_public_activation/validators.mjs';
import {transaction} from '../production_preview_bridge/live_v2/transaction.mjs';
import {verify} from './seal.mjs';

export function localBoundary(db){check(db.transport?.kind==='ISOLATED_REAL_BACKUP_RESTORE'&&db.transport.verified===true&&db.transport.project_ref===project,'LOCAL_WRITE_ONLY');}
export async function facadeRows(db){return (await db.query(functionQuery)).rows.filter(r=>functions.includes(r.name));}
export async function verifyFacade(db){
 const expected=json(directory+'/function-oracle.json');
 check(expected.source_payload_sha256===hash(payload()),'ORACLE_PAYLOAD');
 const rows=await facadeRows(db);
 check(rows.length===4&&new Set(rows.map(r=>r.name)).size===4&&hash(stable(rows))===expected.function_rows_sha256,'FACADE_DEFINITION_OR_GRANT_DRIFT');
 const ledger=(await db.query('SELECT name,statements FROM supabase_migrations.schema_migrations WHERE version=$1',[version])).rows;
 check(ledger.length===1&&ledger[0].name===name&&ledger[0].statements?.length===1&&hash(ledger[0].statements[0])===hash(payload()),'EXACT_FACADE_LEDGER');
 return {result:'PASS',functions:4,definition_and_grants_sha256:expected.function_rows_sha256};
}
// W52L-A is immutable. Project its original baseline only for these two exact
// inventory queries, after independently attesting EVERY added function byte,
// signature, owner, ACL and the exact 0015 ledger. No other metadata is hidden.
// Unrelated drift and a fifth/overloaded function still fail the old validators.
export function activationView(db){
 return new Proxy(db,{get(target,key){
  if(key==='query')return async(sql,args)=>{
   if(sql===functionQuery||sql===ledgerQuery){
    await verifyFacade(target);const result=await target.query(sql,args);
    return {...result,rows:result.rows.filter(r=>sql===functionQuery?!functions.includes(r.name):r.version!==version)};
   }return target.query(sql,args);
  };
  const value=Reflect.get(target,key);return typeof value==='function'?value.bind(target):value;
 }});
}
export async function preflight(db,seal,{installed=false,active=false}={}){
 verify(seal);verifyActivation(activationSeal);
 if(installed)await verifyFacade(db);
 else {check((await facadeRows(db)).length===0,'FACADE_ALREADY_PRESENT');check((await db.query('SELECT count(*)::int AS n FROM supabase_migrations.schema_migrations WHERE version=$1',[version])).rows[0].n===0,'FACADE_LEDGER_ALREADY_PRESENT');}
 return active?readPostflight(activationView(db),activationSeal):readPreflight(installed?activationView(db):db,activationSeal);
}
export async function install(db,seal){
 localBoundary(db);await preflight(db,seal);
 return transaction(db,async()=>{
  verify(seal);await activationPreflight(db);
  await db.exec(`SELECT set_config('esnaftavar.w52lb.target_ref',${literal(project)},true);`);
  await db.exec(payload());
  await db.exec(`INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES(${literal(version)},${literal(name)},${literal([payload()])}::text[]);`);
  await verifyFacade(db);return activationPreflight(activationView(db));
 },{write:true,coreLocks:true});
}
export async function publication(db,seal,enabled){
 localBoundary(db);verify(seal);await verifyFacade(db);
 const result=await (enabled?activate:rollbackActivation)(activationView(db),activationSeal);
 await verifyFacade(db);return result;
}
export async function uninstall(db,seal){
 localBoundary(db);await preflight(db,seal,{installed:true});
 return transaction(db,async()=>{
  verify(seal);await verifyFacade(db);
  await db.exec(`SELECT set_config('esnaftavar.w52lb.target_ref',${literal(project)},true);`);
  await db.exec(read(directory+'/rollback.sql'));
  await db.exec(`DELETE FROM supabase_migrations.schema_migrations WHERE version=${literal(version)};`);
  return activationPreflight(db);
 },{write:true,coreLocks:true});
}
