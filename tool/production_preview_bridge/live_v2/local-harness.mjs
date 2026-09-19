// Isolated rehearsal adapter only. Never imported by the live CLI or seal.
import {createHmac,randomUUID,timingSafeEqual} from 'node:crypto';
import {create,session,guard,stop,run,sql,container,freshBackup,latestBackupHash} from '../local.mjs';
import {restore} from '../restore.mjs';
import {baseline,archiveRows} from '../baseline.mjs';
import {apply0012,readPostflight} from '../../production_taxonomy/execution/engine.mjs';
import {HttpChecks} from '../http.mjs';
import {check,literal,project,facade,stable} from './common.mjs';
import {resolveIdentity,disposeIdentity,origin} from './identity.mjs';
import {httpClient} from './http.mjs';
export {guard,stop,run,sql,container,freshBackup,latestBackupHash,archiveRows};
export class Harness {
 constructor(){this.ctx=null;this.http=null;this.handles=[];this.key='sb_publishable_isolated_fixture_only';}
 async bootstrap(){
  check(['w52kb-byone','w52kb-bytwo'].includes(container),'LOCAL_CONTAINER_ALLOWLIST');
  await create();this.restore=await restore();this.ctx={db:session(),reconnect:()=>session()};
  await this.ctx.db.exec("SET search_path=public,extensions; SET timezone='UTC'; SET datestyle='ISO';");
  await baseline(this.ctx.db);await apply0012(this.ctx.db,freshBackup());await readPostflight(this.ctx.db);
  const binary=run(['cp','w52hr-pg176-proof:/tmp/postgrest','-'],undefined,true);run(['cp','-',container+':/tmp'],binary);
  await this.ctx.db.close();guard();
  sql('template1',"SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='postgres'; CREATE DATABASE w52kby_checkpoint WITH TEMPLATE postgres OWNER postgres;");
 }
 async reset(){
  if(this.http){try{this.http.stop();}catch{}this.http=null;}
  for(const h of this.handles)disposeIdentity(h);this.handles=[];
  if(this.ctx?.db)await this.ctx.db.close();guard();
  // Whole-database clone reset, never a SQL repair of a failed rollout.
  sql('template1',"SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='postgres'; DROP DATABASE postgres WITH (FORCE); CREATE DATABASE postgres WITH TEMPLATE w52kby_checkpoint OWNER postgres;");
  this.ctx={db:session(),reconnect:()=>session()};
  await this.ctx.db.exec("SET search_path=public,extensions; SET timezone='UTC'; SET datestyle='ISO';");
  this.ids=[randomUUID(),randomUUID()];
  await this.ctx.db.exec(`INSERT INTO auth.users(id,aud,role,email,raw_app_meta_data,raw_user_meta_data,created_at,updated_at) SELECT id,'authenticated','authenticated',id::text||'@local.invalid','{}','{}',now(),now() FROM unnest(${literal(this.ids)}::uuid[]) id;`);
  this.http=new HttpChecks(this.ctx.db);await this.http.start();
  this.fixture=this.session(this.ids[0]);this.handle=await resolveIdentity(this.fixture,this.key,this.fetch.bind(this));this.handles.push(this.handle);
  this.other=await resolveIdentity(this.session(this.ids[1]),this.key,this.fetch.bind(this));this.handles.push(this.other);
  this.client=httpClient(this.key,this.handle,this.fetch.bind(this));this.otherClient=httpClient(this.key,this.other,this.fetch.bind(this));
  this.backup=freshBackup();
 }
 session(uid,claims={}){
  const data={iss:origin+'/auth/v1',aud:'authenticated',role:'authenticated',sub:uid,exp:Math.floor(Date.now()/1000)+3600,...claims};
  const encode=x=>Buffer.from(JSON.stringify(x)).toString('base64url');const body=encode({alg:'HS256',typ:'JWT'})+'.'+encode(data);
  return {access_token:body+'.'+createHmac('sha256',this.http.key).update(body).digest('base64url'),user:{id:uid}};
 }
 async fetch(url,options){
  const target=new URL(url);check(target.origin===origin&&options.method==='GET'&&options.redirect==='error','ISOLATED_FETCH_CONTRACT');
  if(target.pathname==='/auth/v1/user'){
   const token=options.headers.Authorization?.slice(7)??'';const parts=token.split('.');let valid=false,claims;
   try{const signature=createHmac('sha256',this.http.key).update(parts[0]+'.'+parts[1]).digest('base64url');valid=signature===parts[2];claims=JSON.parse(Buffer.from(parts[1],'base64url'));}catch{}
   if(valid)valid=claims.iss===origin+'/auth/v1'&&claims.role==='authenticated'&&claims.exp*1000>Date.now()&&(await this.ctx.db.query('SELECT count(*)::int AS n FROM auth.users WHERE id=$1::uuid',[claims.sub])).rows[0].n===1;
   return {status:valid?200:401,json:async()=>valid?{id:claims.sub,role:'authenticated',is_anonymous:false}:{code:'invalid_fixture_session'}};
  }
  check(target.pathname.startsWith('/rest/v1/'),'ISOLATED_PATH');
  const local=new URL(target.pathname.slice('/rest/v1'.length)+target.search,'http://127.0.0.1:3000');
  let config=`url = ${JSON.stringify(local.href)}\n`;for(const[k,v]of Object.entries(options.headers))if(k!=='apikey')config+=`header = ${JSON.stringify(k+': '+v)}\n`;
  const raw=run(['exec','-i',container,'curl','--silent','--show-error','--max-time','15','--write-out','\n%{http_code}','--config','-'],config),i=raw.lastIndexOf('\n');
  return {status:Number(raw.slice(i+1)),json:async()=>JSON.parse(raw.slice(0,i))};
 }
 async reload(){await this.ctx.db.exec("NOTIFY pgrst,'reload schema';");await new Promise(r=>setTimeout(r,350));}
 async assertNoAccess({executeRevoked=false}={}){
  if(this.ctx.db.closed)this.ctx.db=await this.ctx.reconnect();
  const exists=(await this.ctx.db.query("SELECT to_regclass('production_preview_private.testers') IS NOT NULL AS present")).rows[0].present;
  const active=exists?(await this.ctx.db.query('SELECT count(*)::int AS n FROM production_preview_private.testers WHERE user_id=$1::uuid AND enabled AND expires_at>now()',[this.ids[0]])).rows[0].n:0;
  check(active===0,'TEST_PREVIEW_AUTH_LEFT_ACTIVE');await this.reload();
  for(const [client,auth]of [[this.client,true],[this.otherClient,true],[this.client,false]]){
   const r=await client.request('/rpc/taxonomy_capabilities_v2',{p_client_contract_version:'taxonomy-client-v1',p_taxonomy_version:'canonical-v1.0.0'},auth);
   check([401,403,404].includes(r.status),'TEST_PREVIEW_HTTP_STILL_AVAILABLE');
  }
  if(executeRevoked)check((await this.ctx.db.query("SELECT count(*)::int AS n FROM pg_proc p CROSS JOIN (VALUES ('anon'),('authenticated')) r(role) WHERE p.pronamespace='public'::regnamespace AND p.proname=ANY($1::text[]) AND has_function_privilege(r.role,p.oid,'EXECUTE')",[facade])).rows[0].n===0,'TEST_EXECUTE_STILL_GRANTED');
  return {active_authorizations:0,tester:'DENIED',ordinary_authenticated:'DENIED',anonymous:'DENIED'};
 }
 async archiveCheck(){await this.ctx.db.exec(`DELETE FROM auth.users WHERE id=ANY(${literal(this.ids)}::uuid[]);`);await archiveRows(this.ctx.db,{preserve0012:true});}
 async close(){if(this.http)try{this.http.stop();}catch{}for(const h of this.handles)disposeIdentity(h);if(this.ctx?.db)try{await this.ctx.db.close();}catch{}try{stop();}catch{}}
}
