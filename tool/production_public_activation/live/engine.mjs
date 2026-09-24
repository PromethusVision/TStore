import {check,target,writeIntent,payload,literal,project,version,name,stable,safeError} from './common.mjs';
import {verify} from './seal.mjs';
import {state,preserved} from './validators.mjs';
import {artifactGate,physicalGate} from './artifact.mjs';
import {transaction} from '../../production_preview_bridge/live_v2/transaction.mjs';
import {issueBackup,requireBackup} from '../../production_public_client/live/backup.mjs';
export async function readState(db,options,active=false,{requireArtifact=!active}={}){
 verify(options.seal_sha256);target(db);if(requireArtifact)artifactGate(options);
 return transaction(db,()=>state(db,active));
}
export async function captureFreshBackup(db,options,dump){
 const before=await readState(db,options),proof=await dump(),after=await readState(db,options);
 check(before.fingerprint===after.fingerprint,'STATE_CHANGED_DURING_BACKUP');return issueBackup(proof,before.fingerprint);
}
async function setup(db){await db.exec(`SELECT set_config('esnaftavar.w52la.target_ref',${literal(project)},true); LOCK TABLE production_preview_private.testers IN SHARE ROW EXCLUSIVE MODE;`);}
export async function activate(db,options,backup){
 verify(options.seal_sha256);writeIntent(db,options);artifactGate(options);physicalGate(db);
 const before=await readState(db,options);requireBackup(backup,before.fingerprint);
 return transaction(db,async()=>{
  verify(options.seal_sha256);writeIntent(db,options);artifactGate(options);physicalGate(db);await setup(db);
  const locked=await state(db,false),proof=requireBackup(backup,locked.fingerprint),data=await preserved(db);
  options.write_attempted=true;await db.exec(payload());
  await db.exec(`INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES(${literal(version)},${literal(name)},${literal([payload()])}::text[]);`);
  const after=await state(db,true);check(stable(await preserved(db))===stable(data),'ACTIVATION_CHANGED_UNREVIEWED_STATE');
  await db.exec("NOTIFY pgrst,'reload schema';");
  return {result:'PASS',operation:'ACTIVATE_0014_ONLY',atomic:'REVIEWED_PUBLICATION_AND_EXACT_LEDGER',backup:proof,after};
 },{write:true,coreLocks:true});
}
export async function rollback(db,options){
 verify(options.seal_sha256);writeIntent(db,options);await readState(db,options,true);
 return transaction(db,async()=>{
  verify(options.seal_sha256);writeIntent(db,options);await setup(db);await state(db,true);const data=await preserved(db);
  options.write_attempted=true;await db.exec(payload(true));
  await db.exec(`DELETE FROM supabase_migrations.schema_migrations WHERE version=${literal(version)} AND name=${literal(name)};`);
  const after=await state(db,false);check(stable(await preserved(db))===stable(data),'ROLLBACK_CHANGED_UNREVIEWED_STATE');
  await db.exec("NOTIFY pgrst,'reload schema';");
  return {result:'PASS',operation:'ROLLBACK_0014_ONLY',atomic:'PUBLIC_OFF_STAGED_AND_0014_LEDGER_REMOVED',after};
 },{write:true,coreLocks:true});
}
export async function deploy(db,options,dump){
 verify(options.seal_sha256);writeIntent(db,options);artifactGate(options);physicalGate(db);
 const backup=await captureFreshBackup(db,options,dump),activation=await activate(db,options,backup);
 return {result:'PASS',activation,postflight:await readState(db,options,true)};
}
// Unknown COMMIT is reconciled using a fresh verified connection. Rollback is
// possible without the APK still being present, but only from the exact active
// schema/data/0015/0014 state. No fallback migration or whole-DB restore exists.
export async function reconcile(factory,options){
 let db=factory.open();try{
  try{await readState(db,options,false,{requireArtifact:false});return {result:'BASELINE_NO_WRITE'};}catch{if(db.closed){await db.close();db=factory.open();}}
  try{await readState(db,options,true);}catch(e){return {result:'STOPPED_REQUIRES_REVIEW',safe_error:safeError(e)};}
  await rollback(db,options);await readState(db,options,false,{requireArtifact:false});return {result:'ROLLED_BACK_0014_ONLY'};
 }finally{await db.close();}
}
