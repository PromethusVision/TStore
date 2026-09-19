import {readFileSync} from 'node:fs';
import {isAbsolute,relative,sep,resolve} from 'node:path';
import {check,uuid,project,root} from './common.mjs';
const records=new WeakMap();
export const origin=`https://${project}.supabase.co`;
export const cacheKey=`flutter.sb-${project}-auth-token`;
export function readExistingSession(path){
 check(isAbsolute(path??''),'EXPLICIT_EXISTING_SESSION_PATH_REQUIRED');
 const rel=relative(root,resolve(path));check(rel==='..'||rel.startsWith('..'+sep)||isAbsolute(rel),'SESSION_MUST_BE_OUTSIDE_REPO');
 let cache;try{cache=JSON.parse(readFileSync(path,'utf8').replace(/^\uFEFF/,''));}catch{throw new Error('W52KBY_EXISTING_SESSION_UNAVAILABLE_SIGN_IN_EXISTING_ACCOUNT');}
 // Exact SDK-owned project key only. No recursive search or generic token files.
 check(typeof cache?.[cacheKey]==='string','EXISTING_SESSION_UNAVAILABLE_SIGN_IN_EXISTING_ACCOUNT');
 try{return JSON.parse(cache[cacheKey]);}catch{throw new Error('W52KBY_SESSION_FORMAT');}
}
export function sessionShape(session,{allowExpired=false}={}){
 check(session&&uuid(session.user?.id),'TESTER_UID_MISSING_OR_INVALID');
 check(typeof session.access_token==='string'&&session.access_token.split('.').length===3,'SESSION_TOKEN_REQUIRED');
 let claims;try{claims=JSON.parse(Buffer.from(session.access_token.split('.')[1],'base64url').toString('utf8'));}catch{throw new Error('W52KBY_SESSION_FORMAT');}
 check(claims.iss===origin+'/auth/v1','TESTER_PROJECT_IDENTITY_MISMATCH');
 check(claims.sub===session.user.id&&claims.role==='authenticated'&&(claims.aud==='authenticated'||Array.isArray(claims.aud)&&claims.aud.includes('authenticated')),'SESSION_SUBJECT_OR_ROLE');
 check(Number.isFinite(claims.exp),'SESSION_EXPIRY_REQUIRED');
 if(!allowExpired)check(claims.exp*1000>Date.now()+60000,'SESSION_EXPIRED_SIGN_IN_EXISTING_ACCOUNT');
 return {uid:session.user.id,token:session.access_token,expires:claims.exp*1000};
}
export async function resolveIdentity(session,key,fetcher=globalThis.fetch){
 const value=sessionShape(session);
 check(typeof key==='string'&&key.startsWith('sb_publishable_'),'PUBLISHABLE_KEY_REQUIRED');
 // GET /user verifies the existing token with the exact Auth server. No refresh,
 // login, signup, password change, mutable metadata or self-asserted UID trust.
 const response=await fetcher(origin+'/auth/v1/user',{method:'GET',redirect:'error',headers:{apikey:key,Authorization:'Bearer '+value.token},signal:AbortSignal.timeout(15000)});
 check(response.status===200,'TESTER_SESSION_INVALID');const user=await response.json();
 check(user?.id===value.uid&&user.role==='authenticated'&&user.is_anonymous!==true,'AUTH_SERVER_SUBJECT_MISMATCH');
 const handle=Object.freeze({tester_uid_resolved:true,tester_session_valid:true,tester_project_identity_match:true});
 records.set(handle,{...value,key,verifiedAt:Date.now()});return handle;
}
export function subject(handle,{containment=false}={}){
 const value=records.get(handle);check(value&&uuid(value.uid),'VERIFIED_RUNTIME_IDENTITY_REQUIRED');
 if(!containment)check(value.expires>Date.now()+15000&&Date.now()-value.verifiedAt<=300000,'SESSION_REVALIDATION_REQUIRED');
 return value.uid;
}
export function authHeaders(handle){subject(handle);const value=records.get(handle);return {apikey:value.key,Authorization:'Bearer '+value.token};}
export function disposeIdentity(handle){records.delete(handle);}
// Revocation-only recovery accepts the same explicitly selected cached subject
// after session expiry. It cannot create a grant or pass a deployment identity gate.
export function recoverySubject(session){return sessionShape(session,{allowExpired:true}).uid;}
