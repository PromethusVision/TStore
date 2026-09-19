// No Production transport imports. All mutations require the inherited strict
// network-none, pinned image, no published ports, read-only backup mount guard.
import {randomUUID,createHmac} from 'node:crypto';
import {create,session,guard,stop,run,container,freshBackup,latestBackupHash} from '../local.mjs';
import {restore} from '../restore.mjs';
import {baseline,archiveRows} from '../baseline.mjs';
import {apply0012,readPostflight} from '../../production_taxonomy/execution/engine.mjs';
import {HttpChecks} from '../http.mjs';
import {check,literal,project} from './common.mjs';
export {guard,stop,run,container,freshBackup,latestBackupHash,archiveRows};
export async function bootstrap(){
 check(/^w52kb-bx(?:prepare|one|two)$/.test(container??''),'BX_LOCAL_CONTAINER_ALLOWLIST');
 await create();const restored=await restore();const db=session();
 await db.exec("SET search_path=public,extensions; SET timezone='UTC'; SET datestyle='ISO';");
 await baseline(db);
 // Latest available archive is PRE-0012. Reconstitute the already-reviewed
// immutable 0012 with its existing engine, covered by the NEW BX input seal.
 await apply0012(db,freshBackup());await readPostflight(db);
 return {db,restored};
}
export async function fixtures(db){
 guard();const ids=[randomUUID(),randomUUID()];
 check((await db.query('SELECT count(*)::int AS n FROM auth.users WHERE id=ANY($1::uuid[])',[ids])).rows[0].n===0,'BX_FIXTURE_COLLISION');
 // The restored profile trigger requires an email; disposable .invalid values
 // exist only in this guarded local clone and are deleted with these identities.
 await db.exec(`INSERT INTO auth.users(id,aud,role,email,raw_app_meta_data,raw_user_meta_data,created_at,updated_at) SELECT id,'authenticated','authenticated',id::text||'@local.invalid','{}','{}',now(),now() FROM unnest(${literal(ids)}::uuid[]) id;`);
 return {ids,plan:{project_ref:project,user_ids:[ids[0]],expires_at_utc:new Date(Date.now()+3600000).toISOString()}};
}
export async function removeFixtures(db,ids){guard();await db.exec(`DELETE FROM auth.users WHERE id=ANY(${literal(ids)}::uuid[]);`);}
export async function startHttp(db){
 const binary=run(['cp','w52hr-pg176-proof:/tmp/postgrest','-'],undefined,true);run(['cp','-',`${container}:/tmp`],binary);
 const http=new HttpChecks(db);await http.start();return http;
}
export function httpRequest(http,uid,name,args={},validSignature=true){
 guard();const url=new URL('/rpc/'+name,'http://127.0.0.1:3000');for(const[k,v]of Object.entries(args))url.searchParams.set(k,String(v));
 let config=`url = ${JSON.stringify(url.href)}\n`;
 if(uid){const encode=v=>Buffer.from(JSON.stringify(v)).toString('base64url');const body=encode({alg:'HS256',typ:'JWT'})+'.'+encode({role:'authenticated',sub:uid,exp:Math.floor(Date.now()/1000)+600});const token=body+'.'+createHmac('sha256',validSignature?http.key:'invalid-local-signature').update(body).digest('base64url');config+=`header = ${JSON.stringify('Authorization: Bearer '+token)}\n`;}
 const output=run(['exec','-i',container,'curl','--silent','--show-error','--max-time','15','--write-out','\n%{http_code}','--config','-'],config),i=output.lastIndexOf('\n');return {status:Number(output.slice(i+1)),body:JSON.parse(output.slice(0,i))};
}
export async function reload(db){await db.exec("NOTIFY pgrst,'reload schema';");await new Promise(r=>setTimeout(r,400));}
