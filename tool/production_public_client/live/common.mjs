import {read,hash,json,stable,literal,root,project,version,name,functions,payload as originalPayload,migration} from '../common.mjs';
export {read,hash,json,stable,literal,root,project,version,name,functions,migration};
export const directory='tool/production_public_client/live';
export const authority='449f10ae72da912b83688d6b7b8a0d04d810bb51';
export const sourceHash='53559e2608fbbcdfedc22112db899340283a782239a6847930842961ba119aa6';
export const payloadHash='3b8d31ba0c37dd87dac8f04de8e108762bc8d106e5fe26b6b0d2ca835b3b3d5c';
export const previousSeal='ad0d1c6c51ac2d2bd064df78f099d2659fc4575949d529e10ffc4f4bdc595a69';
export const rollbackPath='tool/production_public_client/rollback.sql';
export const check=(value,code)=>{if(!value)throw Error('W52LC_'+code);};
export const safeError=e=>e?.message?.match(/W52(?:LC|LB|LA|JB|KBY|H)_[A-Z0-9_]+/)?.[0]??'W52LC_PRIVATE_ERROR_SUPPRESSED';
export function payload(){check(hash(read(migration))===sourceHash,'SQL_SOURCE_HASH');const sql=originalPayload();check(hash(sql)===payloadHash,'SQL_PAYLOAD_HASH');return sql;}
export function target(db){
 check(db.transport?.verified===true&&db.transport.project_ref===project,'TARGET_IDENTITY');
 check(['ISOLATED_REAL_BACKUP_RESTORE','TLS_VERIFY_FULL_EXACT_PRODUCTION_HOST'].includes(db.transport.kind),'TRUSTED_TRANSPORT_REQUIRED');
 if(db.transport.kind==='TLS_VERIFY_FULL_EXACT_PRODUCTION_HOST')check(db.transport.hostname===`db.${project}.supabase.co`&&db.transport.sslmode==='verify-full'&&db.transport.database==='postgres'&&db.transport.username==='postgres'&&db.transport.port===5432,'TLS_IDENTITY_REQUIRED');
}
export function writeIntent(db,options){target(db);check(options?.production_authorized===true,'EXPLICIT_DEPLOY_AUTHORIZATION_REQUIRED');check(options.sql_sha256===sourceHash,'EXPECTED_SQL_HASH');}
