import {check,facade,uuid,json,directory} from './common.mjs';
import {subject} from './identity.mjs';
import {baseline,security,postflight as bxPostflight} from '../execution/validators.mjs';
import {asRole,denied,call,rpcArguments} from '../execution/rpc-checks.mjs';
export {baseline,security};
export const settings=()=>json(`${directory}/runtime-manifest.json`);
export async function existingTester(db,handle){const uid=subject(handle);check((await db.query('SELECT count(*)::int AS n FROM auth.users WHERE id=$1::uuid',[uid])).rows[0].n===1,'EXISTING_TESTER_REQUIRED');return uid;}
export async function preflight(db,handle){await existingTester(db,handle);return baseline(db,false);}
export async function defaultDeny(db,handle){
 const uid=await existingTester(db,handle),args=await rpcArguments(db);
 check((await db.query('SELECT count(*)::int AS n FROM production_preview_private.testers')).rows[0].n===0,'STAGE_A_ALLOWLIST_MUST_BE_EMPTY');
 const ordinary=(await db.query('SELECT gen_random_uuid()::text AS id')).rows[0].id;
 check(ordinary!==uid,'NEGATIVE_CONTROL_COLLISION');
 for(const [role,id]of [['anon',null],['authenticated',ordinary],['authenticated',uid]])await asRole(db,role,id,async()=>{for(const fn of facade)await denied(db,call(fn,args(fn)));});
 return {result:'PASS',allowlist_rows:0,anonymous:'DENIED',ordinary_authenticated:'DENIED',tester_before_allowlisting:'DENIED',rpc_checks:30};
}
export async function stageAState(db,handle){return {...await baseline(db,true),security:await security(db),default_deny:await defaultDeny(db,handle)};}
export async function activeLease(db,handle){
 const uid=await existingTester(db,handle);
 const rows=(await db.query("SELECT user_id::text,enabled,to_char(expires_at AT TIME ZONE 'UTC','YYYY-MM-DD\"T\"HH24:MI:SS.MS\"Z\"') AS expiry,expires_at>clock_timestamp() AND expires_at<=granted_at+interval '24 hours' AND granted_at<=clock_timestamp() AS valid FROM production_preview_private.testers")).rows;
 check(rows.length===1&&rows[0].user_id===uid&&rows[0].enabled&&rows[0].valid,'EXACT_SINGLE_UNEXPIRED_LEASE_REQUIRED');
 return {uid,expiry:rows[0].expiry};
}
export async function stageBState(db,handle){const lease=await activeLease(db,handle);return {...await bxPostflight(db,{user_ids:[lease.uid],expires_at_utc:lease.expiry}),lease_expiry_utc:lease.expiry};}
