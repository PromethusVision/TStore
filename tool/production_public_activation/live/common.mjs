import {read,hash,json,stable,literal,root,project,version,name,body} from '../common.mjs';
import {target} from '../../production_public_client/live/common.mjs';
export {read,hash,json,stable,literal,root,project,version,name,target};
export const directory='tool/production_public_activation/live';
export const authority='c75c17c6ebe8683b1d652a2fab05ed7700739453';
export const activationSeal='6ec54cc42daa4f8d166bc1fc0f56982d42e0c4050c214b8ce307a6f6fc45c584';
export const facadeSeal='ad0d1c6c51ac2d2bd064df78f099d2659fc4575949d529e10ffc4f4bdc595a69';
export const check=(ok,code)=>{if(!ok)throw Error('W52LE_'+code);};
export const safeError=e=>e?.message?.match(/W52(?:LE|LC|LB|LA|JB|KBY|H)_[A-Z0-9_]+/)?.[0]??'W52LE_PRIVATE_ERROR_SUPPRESSED';
export const manifest=()=>json(directory+'/runtime-manifest.json');
export function payload(rollback=false){const sql=body(rollback);check(hash(sql)===manifest()[rollback?'rollback_sql_sha256':'activation_sql_sha256'],'REVIEWED_SQL_HASH');return sql;}
export function writeIntent(db,options){
 target(db);check(options?.production_authorized===true,'EXPLICIT_ACTIVATION_AUTHORIZATION_REQUIRED');
 check(options.sql_sha256===manifest().activation_sql_sha256,'EXPECTED_SQL_HASH');payload();payload(true);
}
