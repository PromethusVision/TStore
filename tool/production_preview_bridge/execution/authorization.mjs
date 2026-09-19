import {check,literal,project,stable} from './common.mjs';
const uuid=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
export function validatePlan(plan,now=Date.now(),revoke=false){
 check(plan&&plan.project_ref===project,'BX_APPROVAL_TARGET');
 check(stable(Object.keys(plan).sort())===stable(['expires_at_utc','project_ref','user_ids']),'BX_APPROVAL_FIELDS');
 check(Array.isArray(plan.user_ids)&&plan.user_ids.length>=1&&plan.user_ids.length<=10,'BX_UID_REQUIRED');
 check(plan.user_ids.every(id=>typeof id==='string'&&uuid.test(id)&&!/^0{8}-0{4}-0{4}-0{4}-0{12}$/.test(id)),'BX_UID_INVALID');
 check(new Set(plan.user_ids).size===plan.user_ids.length,'BX_UID_DUPLICATE');
 const expiry=Date.parse(plan.expires_at_utc);
 check(typeof plan.expires_at_utc==='string'&&/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(?:\.\d{3})?Z$/.test(plan.expires_at_utc)&&Number.isFinite(expiry),'BX_EXPIRY_REQUIRED');
 if(!revoke)check(expiry>now&&expiry<=now+30*86400000,'BX_EXPIRY_WINDOW');
 return Object.freeze({...plan,user_ids:Object.freeze([...plan.user_ids])});
}
export async function existingUsers(db,plan){
 const now=(await db.query('SELECT extract(epoch FROM clock_timestamp())*1000 AS ms')).rows[0].ms;
 validatePlan(plan,Number(now));
 const n=(await db.query('SELECT count(*)::int AS n FROM auth.users WHERE id=ANY($1::uuid[])',[plan.user_ids])).rows[0].n;
 check(n===plan.user_ids.length,'BX_UID_NOT_AUTH_USER');
}
export async function authorize(db,plan){
 await existingUsers(db,plan);
 // No Auth user creation, upsert, metadata trust or privilege-bearing client key.
 await db.exec(`INSERT INTO production_preview_private.testers(user_id,enabled,expires_at) SELECT id,true,${literal(plan.expires_at_utc)}::timestamptz FROM auth.users WHERE id=ANY(${literal(plan.user_ids)}::uuid[]);`);
}
export async function checkAllowlist(db,plan){
 const rows=(await db.query('SELECT user_id::text,enabled,expires_at>now() AND granted_at<=now() AS valid,expires_at=$1::timestamptz AS expiry_match FROM production_preview_private.testers ORDER BY user_id',[plan.expires_at_utc])).rows;
 check(rows.length===plan.user_ids.length&&rows.every(r=>plan.user_ids.includes(r.user_id)&&r.enabled&&r.valid&&r.expiry_match),'BX_ALLOWLIST_MISMATCH');
 return {count:rows.length,expiry_enforced:true};
}
