import {check,project,literal,body,version,name,stable,manifest} from './common.mjs';
import {verify} from './seal.mjs';
import {preflight,postflight,state} from './validators.mjs';
import {preservedData} from './policy.mjs';
import {transaction} from '../production_preview_bridge/live_v2/transaction.mjs';

function writeBoundary(db){
 // This readiness wave has no live-write authority and the public Flutter
 // runtime is absent on authoritative main. Do not ship an accidental live
 // activation switch. A later reviewed seal must explicitly remove this gate.
 check(db.transport?.kind==='ISOLATED_REAL_BACKUP_RESTORE'&&db.transport.verified===true&&db.transport.project_ref===project,'READINESS_PACKAGE_LOCAL_WRITE_ONLY');
 check(manifest().live_write_enabled===false,'MANIFEST_BOUNDARY');
}
async function setup(db){
 await db.exec(`SELECT set_config('esnaftavar.w52la.target_ref',${literal(project)},true); LOCK TABLE production_preview_private.testers IN SHARE ROW EXCLUSIVE MODE;`);
}
export async function readPreflight(db,seal){verify(seal);return transaction(db,()=>preflight(db));}
export async function readPostflight(db,seal){verify(seal);return transaction(db,()=>postflight(db));}
export async function activate(db,seal){
 verify(seal);writeBoundary(db);await readPreflight(db,seal);
 return transaction(db,async()=>{
  verify(seal);await setup(db);await preflight(db);
  const preserved=await preservedData(db);
  await db.exec(body(false));
  await db.exec(`INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES(${literal(version)},${literal(name)},${literal([body(false)])}::text[]);`);
  const after=await postflight(db);
  check(stable(await preservedData(db))===stable(preserved),'ACTIVATION_CHANGED_UNREVIEWED_DATA');
  return {result:'PASS',operation:'ACTIVATE',atomic:'PUBLIC_STATE_AND_EXACT_LEDGER',after};
 },{write:true,coreLocks:true});
}
export async function rollback(db,seal){
 verify(seal);writeBoundary(db);await readPostflight(db,seal);
 return transaction(db,async()=>{
  verify(seal);await setup(db);await postflight(db);
  const preserved=await preservedData(db);
  await db.exec(body(true));
  await db.exec(`DELETE FROM supabase_migrations.schema_migrations WHERE version=${literal(version)};`);
  const after=await state(db,false);
  check(stable(await preservedData(db))===stable(preserved),'ROLLBACK_CHANGED_UNREVIEWED_DATA');
  return {result:'PASS',operation:'ROLLBACK',atomic:'PUBLIC_OFF_STAGED_AND_LEDGER',after};
 },{write:true,coreLocks:true});
}
