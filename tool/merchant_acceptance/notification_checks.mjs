import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import pg from 'pg';
import { connect, rpc, sqlAs } from './fixture.mjs';
import { contended } from './postgres_checks.mjs';
import { PostgresPushStore } from '../engagement/postgres_push_store.mjs';
import { deliverExistingNotification } from '../engagement/push_delivery.mjs';

async function service(config,name,args=[],{before,hold}={}) {
 const db=await connect(config);
 try {
  await db.query('BEGIN');await db.query('SET LOCAL ROLE service_role');
  if(before)await before(db);
  const result=await db.query('SELECT public.'+name+'('+args.map((_,i)=>'$'+(i+1)).join(',')+') result',args);
  if(hold)await hold(db);
  await db.query('COMMIT');return result.rows[0].result;
 }catch(error){await db.query('ROLLBACK');throw error;}finally{await db.end();}
}
export async function notificationChecks(db,config,f) {
 const checks=[];const check=async(name,fn)=>{await fn();checks.push({name:'I0 '+name,result:'PASS'});console.log('PASS I0 '+name);};
 const pool=new pg.Pool({...config,max:4});const store=new PostgresPushStore(pool);
 const call=(name,args,options)=>service(config,name,args,options);
 const register=(a,role='customer',token='fixture-'+randomUUID(),installation=a.installation)=>
   rpc(config,a,'register_push_device_v1',[installation,role,token,'android']);
 const pref=(a,enabled,options)=>rpc(config,a,'set_notification_preferences_v1',['customer',enabled,false],options);
 const disable=(a,role='customer')=>rpc(config,a,'disable_push_device_v1',[a.installation,role]);
 const device=async(a,role='customer')=>(await db.query('SELECT * FROM public.push_devices WHERE installation_id=$1 AND app_role=$2',[a.installation,role])).rows[0];
 const note=async(a=f.customer,type='chat',data={})=>{
  const id=randomUUID();await db.query('INSERT INTO public.notifications(id,user_id,title,body,type,data) VALUES($1,$2,$3,$4,$5,$6)',
  [id,a.id,'Synthetic private title','Synthetic private body',type,data]);return id;
 };
 const claim=async(a=f.customer)=>{const id=await note(a);return {id,c:await store.claim(id,a.installation)};};
 try {
 await check('default OFF and no client activation',async()=>{
  const id=await note();assert.equal((await store.page(id)).status,'disabled');
  await assert.rejects(sqlAs(config,f.customer,'UPDATE public.push_dispatch_config SET enabled=true'),e=>e.code==='42501');
  await db.query('UPDATE public.push_dispatch_config SET enabled=true');
 });
 await check('both host roles register with live Auth; notification identities remain separate',async()=>{
  await register(f.customer);await register(f.merchant,'merchant');
  for(const [a,role] of [[f.customer,'customer'],[f.merchant,'merchant']]) {
   const id=await note(a);const p=await store.page(id);assert.equal(p.app_role,role);
   assert.deepEqual(p.installations,[a.installation]);assert(!JSON.stringify(p).includes('token'));
   const c=await store.claim(id,a.installation);assert(c);assert.equal((await store.begin(c)).user_id,a.id);
   assert.equal(await store.finish(c,'provider_accepted'), 'provider_accepted');
  }
 });
 await check('wrong role, invalid token, ownership collision and token collision denied',async()=>{
  await assert.rejects(register(f.customer,'merchant'),e=>e.code==='42501');
  await assert.rejects(register(f.customer,'customer','bad token'),e=>e.code==='22023');
  await assert.rejects(register(f.other,'merchant','fixture-'+randomUUID(),f.merchant.installation),e=>e.code==='42501');
  await assert.rejects(register(f.merchant,'merchant',(await device(f.customer)).push_token),e=>e.code==='42501');
 });
 await check('legacy device without bound session cannot dispatch',async()=>{
  const install=randomUUID();await db.query("INSERT INTO public.push_devices(installation_id,app_role,user_id,push_token,platform) VALUES($1,'customer',$2,$3,'ios')",
   [install,f.customer.id,'fixture-'+randomUUID()]);
  assert.equal(await store.claim(await note(),install),null);
 });
 await check('marketing and campaign attempts fail closed even with explicit consent',async()=>{
  await rpc(config,f.customer,'set_notification_preferences_v1',['customer',true,true]);
  for(const [type,data] of [['promotion',{}],['promotion',{delivery_purpose:'service'}],['chat',{delivery_purpose:'marketing'}],
   ['system',{delivery_purpose:'service',campaign_id:randomUUID()}]]) {
   const id=await note(f.customer,type,data);assert.equal((await store.page(id)).status,'marketing_deferred');
   assert.equal(await store.claim(id,f.customer.installation),null);
  }
 });
 await check('unknown system, explicit null and role mismatch rejected',async()=>{
  for(const [type,data] of [['system',{}],['chat',{delivery_purpose:null}],['chat',{app_role:'merchant'}],['chat',{app_role:null}]]) {
   assert.equal((await store.page(await note(f.customer,type,data))).status,'rejected');
  }
  assert.equal((await store.page(await note(f.customer,'system',{delivery_purpose:'service'}))).status,'ready');
 });
 await check('service consent independent from marketing and absent first opt-out serialized',async()=>{
  await pref(f.customer,false);assert.equal((await store.page(await note())).status,'opted_out');await pref(f.customer,true);
  await db.query('DELETE FROM public.notification_preferences WHERE user_id=$1',[f.customer.id]);
  const id=await note();
  const results=await contended(db,o=>pref(f.customer,false,o),o=>call('claim_push_dispatch_i0',[id,f.customer.installation],o));
  assert(results.every(r=>r.status==='fulfilled'));assert.equal(results[1].value,null);await pref(f.customer,true);
 });
 await check('simultaneous workers acquire only one durable claim',async()=>{
  const id=await note();
  const results=await contended(db,o=>call('claim_push_dispatch_i0',[id,f.customer.installation],o),
   o=>call('claim_push_dispatch_i0',[id,f.customer.installation],o));
  assert(results.every(r=>r.status==='fulfilled'));assert(results[0].value);assert.equal(results[1].value,null);
 });
 await check('stale repeatable-read snapshot cannot bypass newly committed opt-out',async()=>{
  const id=await note(), stale=await connect(config);
  try {
   await stale.query('BEGIN ISOLATION LEVEL REPEATABLE READ');
   await stale.query('SELECT count(*) FROM public.notification_preferences');
   await pref(f.customer,false);await stale.query('SET LOCAL ROLE service_role');
   await assert.rejects(stale.query('SELECT public.claim_push_dispatch_i0($1,$2)',[id,f.customer.installation]),e=>e.code==='25001');
  } finally {await stale.query('ROLLBACK');await stale.end();await pref(f.customer,true);}
 });
 await check('simultaneous begin returns token to only one worker',async()=>{
  const {c}=await claim();
  const results=await contended(db,o=>call('begin_push_dispatch_i0',[c],o),o=>call('begin_push_dispatch_i0',[c],o));
  assert(results.every(r=>r.status==='fulfilled'));assert(results[0].value.token);assert.equal(results[1].value,null);
  assert.equal((await store.read(c)).outcome,'unknown');
 });
 await check('opt-out between claim and begin cancels without provider attempt',async()=>{
  const {c}=await claim();await pref(f.customer,false);assert.equal(await store.begin(c),null);
  assert.equal((await store.read(c)).outcome,'cancelled');await pref(f.customer,true);
 });
 await check('actual opt-out versus begin contention honors first committed consent',async()=>{
  const {c}=await claim();const results=await contended(db,o=>pref(f.customer,false,o),o=>call('begin_push_dispatch_i0',[c],o));
  assert(results.every(r=>r.status==='fulfilled'));assert.equal(results[1].value,null);await pref(f.customer,true);
 });
 await check('token rotation cancels planned old target; heartbeat retains revision',async()=>{
  const prior=await device(f.customer);await register(f.customer,'customer',prior.push_token);
  assert.equal((await device(f.customer)).revision,prior.revision);
  const {c}=await claim();await register(f.customer);assert.notEqual((await device(f.customer)).revision,prior.revision);
  assert.equal(await store.begin(c),null);assert.equal((await store.read(c)).outcome,'cancelled');
 });
 await check('disabled or rebound installation cancels prior recipient claim',async()=>{
  const {c}=await claim();await disable(f.customer);assert.equal(await store.begin(c),null);
  const otherCustomer=await f.session(f.customer.id); // different live session, same account ABA protection
  otherCustomer.installation=f.customer.installation;await register(otherCustomer);
  const {c:next}=await claim();await register(f.customer);
  assert.equal(await store.begin(next),null);
 });
 await check('session deletion and expiry stop dispatch even if disable was missed',async()=>{
  const session=await f.session(f.customer.id);session.installation=f.customer.installation;await register(session);
  const {c}=await claim();await db.query('DELETE FROM auth.sessions WHERE id=$1',[session.claims.session_id]);
  assert.equal(await store.begin(c),null);assert.equal((await store.page(await note())).installations.length,0);
  await assert.rejects(register(session),e=>e.code==='28000');
  await assert.rejects(pref(session,false),e=>e.code==='28000');
  await assert.rejects(disable(session),e=>e.code==='28000');
  assert.equal((await sqlAs(config,session,'SELECT * FROM public.notification_preferences')).rows.length,0);
  const expired=await f.session(f.customer.id);expired.installation=f.customer.installation;await register(expired);
  await db.query("UPDATE auth.sessions SET not_after=clock_timestamp()-interval '1 second' WHERE id=$1",[expired.claims.session_id]);
  assert.equal(await store.claim(await note(),expired.installation),null);await register(f.customer);
 });
 await check('late disable from another still-live session cannot revoke a replacement binding',async()=>{
  const otherSession=await f.session(f.customer.id);otherSession.installation=f.customer.installation;
  await register(otherSession);const bound=await device(f.customer);await disable(f.customer);
  assert.equal((await device(f.customer)).enabled,true);assert.equal((await device(f.customer)).revision,bound.revision);
  await register(f.customer);
 });
 await check('profile role change cancels old host and preference read',async()=>{
  const {c}=await claim();await db.query("UPDATE public.profiles SET role='merchant' WHERE id=$1",[f.customer.id]);
  assert.equal(await store.begin(c),null);
  assert.equal((await sqlAs(config,f.customer,'SELECT * FROM public.notification_preferences')).rows.length,0);
  await db.query("UPDATE public.profiles SET role='customer' WHERE id=$1",[f.customer.id]);
 });
 await check('default OFF kill switch cancels planned delivery and prevents new claims',async()=>{
  const {id,c}=await claim();await db.query('UPDATE public.push_dispatch_config SET enabled=false');
  assert.equal(await store.begin(c),null);assert.equal(await store.claim(id,f.customer.installation),null);
  await db.query('UPDATE public.push_dispatch_config SET enabled=true');
 });
 await check('provider acceptance and DB persistence are distinct; no retry after uncertain acknowledgement',async()=>{
  const id=await note();let sends=0;
  const provider={configured:true,send:async()=>{sends++;return {outcome:'accepted'};}};
  const broken={page:(...a)=>store.page(...a),claim:(...a)=>store.claim(...a),begin:(...a)=>store.begin(...a),finish:async()=>{throw Error('synthetic loss');}};
  const r=await deliverExistingNotification({notificationId:id,store:broken,provider});assert.equal(r.sent,0);assert.equal(r.unknown,1);
  assert.equal((await deliverExistingNotification({notificationId:id,store,provider})).skipped,1);assert.equal(sends,1);
  const c=(await db.query('SELECT claim_id FROM public.push_deliveries WHERE notification_id=$1',[id])).rows[0].claim_id;
  assert.equal((await store.read(c)).outcome,'unknown');
  const recovered=await new PostgresPushStore(pool).find(id,f.customer.installation,'customer');
  assert.equal(recovered.claim_id,c);assert.equal(recovered.outcome,'unknown');
  assert(!JSON.stringify(recovered).includes('token'));
  assert.equal(await store.find(id,f.merchant.installation,'customer'),null);
  assert.equal(await store.find(id,f.customer.installation,'merchant'),null);
  await store.finish(c,'provider_accepted');assert.equal((await store.read(c)).outcome,'provider_accepted');
  assert.equal(await store.finish(c,'provider_accepted'),'provider_accepted');
  await assert.rejects(call('finish_push_dispatch_i0',[c,'failed',false]),e=>e.code==='40001');
 });
 await check('unknown acknowledgement keeps claim and current device; raw errors never stored',async()=>{
  const id=await note();let calls=0;
  const provider={configured:true,send:async()=>{calls++;throw Error('fixture-private-token');}};
  assert.equal((await deliverExistingNotification({notificationId:id,store,provider})).unknown,1);
  assert.equal((await deliverExistingNotification({notificationId:id,store,provider})).skipped,1);assert.equal(calls,1);
  assert.equal((await device(f.customer)).enabled,true);
  const row=(await db.query('SELECT * FROM public.push_deliveries WHERE notification_id=$1',[id])).rows[0];
  assert(!JSON.stringify(row).includes('fixture-private-token'));assert.equal(row.outcome,'unknown');
 });
 await check('invalid-token response cannot disable a rotated or rebound installation',async()=>{
  const {c}=await claim();await store.begin(c);await register(f.customer);const current=await device(f.customer);
  await store.finish(c,'failed',true);assert.equal((await device(f.customer)).enabled,true);
  assert.equal((await device(f.customer)).revision,current.revision);
  const {c:old}=await claim();await store.begin(old);await disable(f.customer);
  await db.query("UPDATE public.profiles SET role='customer' WHERE id=$1",[f.other.id]);
  await register(f.other,'customer','fixture-'+randomUUID(),f.customer.installation);
  await store.finish(old,'failed',true);assert.equal((await device(f.customer)).user_id,f.other.id);
  assert.equal((await device(f.customer)).enabled,true);
  await rpc(config,f.other,'disable_push_device_v1',[f.customer.installation,'customer']);
  await register(f.customer);await db.query("UPDATE public.profiles SET role='merchant' WHERE id=$1",[f.other.id]);
 });
 await check('invalid-token response disables exact attempted revision atomically',async()=>{
  const {c}=await claim();await store.begin(c);await store.finish(c,'failed',true);
  assert.equal((await device(f.customer)).enabled,false);assert.equal((await store.read(c)).outcome,'failed');await register(f.customer);
 });
 await check('finish cannot invent an attempt or mutate conflicting terminal result',async()=>{
  const {c}=await claim();await assert.rejects(call('finish_push_dispatch_i0',[c,'provider_accepted',false]),e=>e.code==='22023');
  for(const args of [[c,null,false],[c,'sent',false],[c,'provider_accepted',true],[c,'failed',null]]) {
   await assert.rejects(call('finish_push_dispatch_i0',args),e=>e.code==='22023');
  }
 });
 await check('clients cannot read tokens/deliveries, alter state or execute service entrypoints',async()=>{
  for(const table of ['push_devices','push_deliveries','push_dispatch_config']) {
   await assert.rejects(sqlAs(config,f.customer,'SELECT * FROM public.'+table),e=>e.code==='42501');
  }
  const id=await note();const {c}=await claim();
  for(const [name,args] of [['push_dispatch_page_i0',[id,null]],['claim_push_dispatch_i0',[id,f.customer.installation]],
   ['begin_push_dispatch_i0',[c]],['finish_push_dispatch_i0',[c,'provider_accepted',false]],['read_push_dispatch_i0',[c]]]) {
   await assert.rejects(rpc(config,f.customer,name,args),e=>e.code==='42501');
   assert.equal((await db.query('SELECT has_function_privilege($1,$2,$3) allowed',
    ['anon','public.'+name+'('+({push_dispatch_page_i0:'uuid,uuid',claim_push_dispatch_i0:'uuid,uuid',begin_push_dispatch_i0:'uuid',finish_push_dispatch_i0:'uuid,text,boolean',read_push_dispatch_i0:'uuid,uuid,uuid,text'}[name])+')','EXECUTE'])).rows[0].allowed,false);
  }
 });
 await check('service role only has narrowed functions; former direct write grants removed',async()=>{
  for(const [table,priv] of [['push_devices','SELECT'],['push_deliveries','INSERT'],['push_dispatch_config','UPDATE']]) {
   assert.equal((await db.query('SELECT has_table_privilege($1,$2,$3) allowed',['service_role','public.'+table,priv])).rows[0].allowed,false);
  }
  for(const [table,column] of [['push_devices','enabled'],['push_deliveries','outcome']]) {
   assert.equal((await db.query("SELECT has_column_privilege('service_role',$1,$2,'UPDATE') allowed",['public.'+table,column])).rows[0].allowed,false);
  }
 });
 await check('paged fanout has no token exposure, stable cursor and no extra logical claim',async()=>{
  const ids=Array.from({length:102},()=>randomUUID()).sort();
  for(const id of ids)await register(f.customer,'customer','fixture-'+randomUUID(),id);
  const notification=await note();const page=await store.page(notification);assert.equal(page.installations.length,100);
  const next=await store.page(notification,page.installations.at(-1));assert.equal(next.installations.length,3);
  assert.equal(new Set([...page.installations,...next.installations]).size,103);
  assert(!JSON.stringify(page).includes('fixture-'));
  await db.query('DELETE FROM public.push_devices WHERE installation_id=ANY($1::uuid[])',[ids]);
 });
 await check('notification delete cannot resurrect or re-send an existing claim',async()=>{
  const {id,c}=await claim();await db.query('DELETE FROM public.notifications WHERE id=$1',[id]);
  assert.equal(await store.begin(c),null);assert.equal(await store.read(c),null);assert.equal(await store.claim(id,f.customer.installation),null);
 });
 } finally {await pool.end();}
 return checks;
}

export async function notificationHttpChecks({db,request,rpc,session,f,status}) {
 const checks=[];const check=async(name,fn)=>{await fn();checks.push({name:'I0 HTTP '+name,result:'PASS'});console.log('PASS I0 HTTP '+name);};
 const customer=await session(f.customer.id),merchant=await session(f.merchant.id);
 const args=a=>({p_installation_id:a.installation,p_app_role:a===merchant?'merchant':'customer',p_push_token:'fixture-'+randomUUID(),p_platform:'android'});
 await check('real Auth registration/preferences for both hosts and RLS privacy',async()=>{
  for(const a of [customer,merchant]) {
   await rpc('register_push_device_v1',a,args(a));
   await rpc('set_notification_preferences_v1',a,{p_app_role:a===merchant?'merchant':'customer',p_service:true,p_marketing:false});
   const prefs=await request('/rest/v1/notification_preferences?select=user_id,app_role,service_enabled,marketing_enabled',a,undefined,'GET');
   assert(prefs.ok);assert.equal(prefs.data.length,1);assert.equal(prefs.data[0].user_id,a.id);
   for(const table of ['push_devices','push_deliveries','push_dispatch_config'])assert.equal((await request('/rest/v1/'+table+'?select=*',a,undefined,'GET')).ok,false);
  }
 });
 await check('service dispatch RPC inaccessible to anon and authenticated even with guessed IDs',async()=>{
  for(const a of [null,customer,merchant]) for(const [name,params] of [
   ['push_dispatch_page_i0',{p_notification_id:randomUUID()}],
   ['claim_push_dispatch_i0',{p_notification_id:randomUUID(),p_installation_id:randomUUID()}],
   ['begin_push_dispatch_i0',{p_claim_id:randomUUID()}],
   ['finish_push_dispatch_i0',{p_claim_id:randomUUID(),p_outcome:'provider_accepted'}],
   ['read_push_dispatch_i0',{p_claim_id:randomUUID()}]]) assert.equal((await request('/rest/v1/rpc/'+name,a,params)).ok,false);
 });
 await check('real Auth logout rejects stale registration/preferences and delivery selection',async()=>{
  const notification=randomUUID();await db.query("INSERT INTO public.notifications(id,user_id,title,body,type) VALUES($1,$2,'Local','Local','chat')",[notification,customer.id]);
  const worker={token:status.SERVICE_ROLE_KEY};
  const page=await rpc('push_dispatch_page_i0',worker,{p_notification_id:notification});
  assert(page.installations.includes(customer.installation));
  const c=await rpc('claim_push_dispatch_i0',worker,{p_notification_id:notification,p_installation_id:customer.installation});assert(c);
  assert((await request('/auth/v1/logout?scope=local',customer,undefined)).ok);
  assert.equal((await request('/rest/v1/rpc/register_push_device_v1',customer,args(customer))).ok,false);
  assert.equal((await request('/rest/v1/rpc/set_notification_preferences_v1',customer,{p_app_role:'customer',p_service:true,p_marketing:true})).ok,false);
  assert.equal(await rpc('begin_push_dispatch_i0',worker,{p_claim_id:c}),null);
  const prefs=await request('/rest/v1/notification_preferences?select=user_id',customer,undefined,'GET');
  assert(prefs.ok);assert.equal(prefs.data.length,0);
 });
 await check('local service HTTP acknowledgement is idempotent and contains no device secrets',async()=>{
  const id=randomUUID();await db.query("INSERT INTO public.notifications(id,user_id,title,body,type) VALUES($1,$2,'Local','Local','chat')",[id,merchant.id]);
  const worker={token:status.SERVICE_ROLE_KEY};
  const c=await rpc('claim_push_dispatch_i0',worker,{p_notification_id:id,p_installation_id:merchant.installation});
  const target=await rpc('begin_push_dispatch_i0',worker,{p_claim_id:c});assert(target.token);assert.equal(target.user_id,merchant.id);
  assert.equal(await rpc('begin_push_dispatch_i0',worker,{p_claim_id:c}),null);
  await rpc('finish_push_dispatch_i0',worker,{p_claim_id:c,p_outcome:'provider_accepted'});
  assert.equal(await rpc('finish_push_dispatch_i0',worker,{p_claim_id:c,p_outcome:'provider_accepted'}),'provider_accepted');
  const receipt=await rpc('read_push_dispatch_i0',worker,{p_claim_id:c});assert.equal(receipt.outcome,'provider_accepted');assert(!JSON.stringify(receipt).includes('token'));
 });
 return checks;
}
