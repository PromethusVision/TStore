import {check,literal,project,version,name,payload,stable,safeError} from './common.mjs';
import {verify} from './seal.mjs';
import {subject} from './identity.mjs';
import {canonicalData} from '../execution/catalog.mjs';
import {transaction} from './transaction.mjs';
import {preflight,stageAState,stageBState,existingTester,settings} from './validators.mjs';
import {connection,containAndRollback} from './containment.mjs';
export async function readPreflight(ctx,seal,handle){verify(seal);subject(handle);const db=await connection(ctx);return transaction(db,()=>preflight(db,handle));}
export async function readStageA(ctx,seal,handle){verify(seal);subject(handle);const db=await connection(ctx);return transaction(db,()=>stageAState(db,handle));}
export async function readStageB(ctx,seal,handle){verify(seal);subject(handle);const db=await connection(ctx);return transaction(db,()=>stageBState(db,handle));}
function backupGate(backup){check(backup?.verified===true&&backup.project_ref===project,'VERIFIED_BACKUP_REQUIRED');const age=Date.now()-Date.parse(backup.completed_at_utc);check(Number.isFinite(age)&&age>=-30000&&age<=900000,'FRESH_BACKUP_REQUIRED');}
export function leaseSeconds(seconds=settings().default_lease_seconds){check(Number.isInteger(seconds)&&seconds>=1&&seconds<=settings().maximum_lease_seconds,'LEASE_MUST_BE_POSITIVE_AT_MOST_24_HOURS');return seconds;}
export async function stageA(ctx,seal,handle,backup){
 verify(seal);subject(handle);backupGate(backup);await readPreflight(ctx,seal,handle);const db=await connection(ctx);
 return transaction(db,async()=>{
  verify(seal);backupGate(backup);await preflight(db,handle);const core=await canonicalData(db),body=payload();
  ctx.bridgeWriteAttempted=true;
  await db.exec(body.sql);
  await db.exec(`INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES(${literal(version)},${literal(name)},${literal([body.sql])}::text[]);`);
  const after=await stageAState(db,handle);check(stable(await canonicalData(db))===stable(core),'STAGE_A_CHANGED_CANONICAL_DATA');
  return {result:'PASS',stage:'A',atomic:'BRIDGE_AND_LEDGER_ONLY',allowlist_rows:0,after};
 },{write:true,coreLocks:true});
}
export async function stageB(ctx,seal,handle,seconds){
 verify(seal);subject(handle);const ttl=leaseSeconds(seconds);await readStageA(ctx,seal,handle);const db=await connection(ctx);
 return transaction(db,async()=>{
  verify(seal);await stageAState(db,handle);const uid=await existingTester(db,handle),core=await canonicalData(db);
  // The immutable server guard uses now() (transaction time). A later wall-clock
  // grant would appear to be in the future inside this same atomic transaction.
  await db.exec(`WITH stamp AS (SELECT date_trunc('milliseconds',transaction_timestamp()) AS at) INSERT INTO production_preview_private.testers(user_id,enabled,granted_at,expires_at) SELECT ${literal(uid)}::uuid,true,at,at+make_interval(secs=>${ttl}) FROM stamp;`);
  const after=await stageBState(db,handle);check(stable(await canonicalData(db))===stable(core),'STAGE_B_CHANGED_CANONICAL_DATA');
  return {result:'PASS',stage:'B',atomic:'ONE_EXACT_RUNTIME_TESTER_LEASE',lease_seconds:ttl,after};
 },{write:true,coreLocks:true});
}
export async function deployStaged(ctx,seal,handle,backup,{seconds,afterA,afterB}={}){
 verify(seal);subject(handle);leaseSeconds(seconds);await readPreflight(ctx,seal,handle);
 ctx.bridgeWriteAttempted=false;
 try{
  const a=await stageA(ctx,seal,handle,backup);
  // Independent committed-state gate before any Stage B operation.
  await readStageA(ctx,seal,handle);if(afterA)await afterA();
  const b=await stageB(ctx,seal,handle,seconds);await readStageB(ctx,seal,handle);if(afterB)await afterB();
  return {result:'PASS',stage_a:a,stage_b:b};
 }catch(error){
  const result={result:'STOPPED_BEFORE_WRITE',safe_error:safeError(error)};
  if(ctx.bridgeWriteAttempted){result.containment=await containAndRollback(ctx,seal,subject(handle,{containment:true}));result.result=result.containment.result;}
  return result;
 }
}
