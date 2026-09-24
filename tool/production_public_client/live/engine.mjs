import {check,target,writeIntent,payload,literal,project,version,name,read,rollbackPath,stable,safeError} from './common.mjs';
import {verify} from './seal.mjs';
import {state,unchangedData} from './validators.mjs';
import {transaction} from '../../production_preview_bridge/live_v2/transaction.mjs';
import {issueBackup,requireBackup} from './backup.mjs';
export async function readState(db,seal,installed=false){verify(seal);target(db);return transaction(db,()=>state(db,installed));}
export async function captureFreshBackup(db,seal,dump){
 const before=await readState(db,seal);const proof=await dump();
 const after=await readState(db,seal);check(before.fingerprint===after.fingerprint,'STATE_CHANGED_DURING_BACKUP');
 return issueBackup(proof,before.fingerprint);
}
async function setup(db){await db.exec(`SELECT set_config('esnaftavar.w52lb.target_ref',${literal(project)},true); LOCK TABLE production_preview_private.testers IN SHARE ROW EXCLUSIVE MODE;`);}
export async function install(db,options,backup){
 verify(options.seal_sha256);writeIntent(db,options);payload();
 const before=await readState(db,options.seal_sha256);requireBackup(backup,before.fingerprint);
 return transaction(db,async()=>{
  verify(options.seal_sha256);writeIntent(db,options);await setup(db);
  const locked=await state(db,false),proof=requireBackup(backup,locked.fingerprint),data=await unchangedData(db);
  options.write_attempted=true;
  await db.exec(payload());
  await db.exec(`INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES(${literal(version)},${literal(name)},${literal([payload()])}::text[]);`);
  const after=await state(db,true);check(stable(await unchangedData(db))===stable(data),'INSTALL_CHANGED_DATA');
  await db.exec("NOTIFY pgrst,'reload schema';");
  return {result:'PASS',operation:'DEPLOY_0015',atomic:'FOUR_READ_FUNCTIONS_AND_EXACT_LEDGER',public_enabled:false,backup:proof,after};
 },{write:true,coreLocks:true});
}
export async function rollback(db,options){
 verify(options.seal_sha256);writeIntent(db,options);await readState(db,options.seal_sha256,true);
 return transaction(db,async()=>{
  verify(options.seal_sha256);writeIntent(db,options);await setup(db);await state(db,true);const before=await unchangedData(db);
  options.write_attempted=true;
  await db.exec(read(rollbackPath));
  await db.exec(`DELETE FROM supabase_migrations.schema_migrations WHERE version=${literal(version)} AND name=${literal(name)};`);
  const after=await state(db,false);check(stable(await unchangedData(db))===stable(before),'ROLLBACK_CHANGED_DATA');
  await db.exec("NOTIFY pgrst,'reload schema';");
  return {result:'PASS',operation:'ROLLBACK_0015_ONLY',atomic:'FOUR_READ_FUNCTIONS_AND_0015_LEDGER_REMOVED',public_enabled:false,after};
 },{write:true,coreLocks:true});
}
// No blind retry after connection loss/uncertain COMMIT. Read the actual state
// first. Teardown is permitted only when every installed byte/ACL/ledger matches.
export async function reconcile(factory,options){
 let db=factory.open();try{
  try{await readState(db,options.seal_sha256);return {result:'BASELINE_NO_WRITE'};}catch{if(db.closed){await db.close();db=factory.open();}}
  try{await readState(db,options.seal_sha256,true);}catch(e){return {result:'STOPPED_REQUIRES_REVIEW',safe_error:safeError(e)};}
  await rollback(db,options);await readState(db,options.seal_sha256);return {result:'ROLLED_BACK_0015_ONLY'};
 }finally{await db.close();}
}
export async function deploy(db,options,dump){
 verify(options.seal_sha256);writeIntent(db,options);
 const backup=await captureFreshBackup(db,options.seal_sha256,dump);
 const installed=await install(db,options,backup);
 const postflight=await readState(db,options.seal_sha256,true);
 return {result:'PASS',installed,postflight};
}
