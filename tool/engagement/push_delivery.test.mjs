import { test } from 'node:test';
import assert from 'node:assert/strict';
import { deliverExistingNotification } from './push_delivery.mjs';
import { PostgresPushStore } from './postgres_push_store.mjs';

function fixture(role='customer') {
  let claimed=false, state=null;
  const sent=[], finished=[];
  const store={
    page:async()=>({status:'ready',installations:['installation']}),
    claim:async()=>{if(claimed)return null;claimed=true;state='planned';return 'claim';},
    begin:async()=>{state='unknown';return {token:'synthetic-token',notification_id:'notification',user_id:'user',app_role:role};},
    finish:async(...args)=>{finished.push(args);state=args[1];return state;},
  };
  const provider={configured:true,send:async(message)=>{assert.equal(state,'unknown');sent.push(message);return {outcome:'accepted'};}};
  const run=(extra={})=>deliverExistingNotification({notificationId:'notification',store,provider,...extra});
  return {store,provider,sent,finished,run,state:()=>state};
}
test('unconfigured provider never accesses store',async()=>{
 assert.deepEqual(await deliverExistingNotification({provider:{configured:false}}),{status:'pending_configuration',sent:0});
});
for(const status of ['disabled','rejected','opted_out','marketing_deferred']) test(status+' does not claim/send',async()=>{
 const f=fixture();f.store.page=async()=>({status});f.store.claim=()=>assert.fail();
 assert.deepEqual(await f.run(),{status,sent:0});assert.equal(f.sent.length,0);
});
for(const role of ['customer','merchant']) test(role+' generic private routing and replay',async()=>{
 const f=fixture(role);assert.equal((await f.run()).sent,1);assert.equal((await f.run()).skipped,1);
 assert.deepEqual(f.sent[0],{token:'synthetic-token',title:'EsnaftaVar',body:'Yeni bir bildirimin var.',
 data:{notification_id:'notification',user_id:'user',app_role:role,delivery_id:'claim'}});
});
test('cancelled revalidation never calls provider',async()=>{
 const f=fixture();f.store.begin=async()=>null;assert.equal((await f.run()).cancelled,1);assert.equal(f.sent.length,0);
});
test('lost begin commit acknowledgement never calls provider',async()=>{
 const f=fixture();f.store.begin=async()=>{throw Error('db unavailable');};
 await assert.rejects(f.run());assert.equal(f.sent.length,0);
});
test('accepted provider then lost persistence acknowledgement remains uncertain and is not resent',async()=>{
 const f=fixture();f.store.finish=async()=>{throw Error('db unavailable');};
 assert.equal((await f.run()).unknown,1);assert.equal(f.state(),'unknown');
 assert.equal((await f.run()).sent,0);assert.equal(f.sent.length,1);
});
test('definitive unregistered response alone requests atomic revision-aware disable',async()=>{
 const f=fixture();f.provider.send=async()=>({outcome:'rejected',code:'token_unregistered',private:'never-store'});
 assert.equal((await f.run()).failed,1);assert.deepEqual(f.finished,[['claim','failed',true]]);
});
test('ordinary rejection cannot disable device',async()=>{
 const f=fixture();f.provider.send=async()=>({outcome:'rejected',code:'invalid_payload'});
 assert.equal((await f.run()).failed,1);assert.deepEqual(f.finished,[['claim','failed',false]]);
});
for(const response of [undefined,{}, {outcome:'sent'}, {outcome:'unknown'}, {outcome:'accepted_by_os'}]) {
 test('unrecognized response stays unknown '+JSON.stringify(response),async()=>{
 const f=fixture();f.provider.send=async()=>response;
 assert.equal((await f.run()).unknown,1);assert.equal(f.finished[0][1],'unknown');
 });
}
test('exception including token-like error never becomes proof of rejection',async()=>{
 const f=fixture();f.provider.send=async()=>{throw {code:'token_unregistered',body:'sensitive'};};
 assert.equal((await f.run()).unknown,1);assert.deepEqual(f.finished,[['claim','unknown',false]]);
});
test('timeout aborts provider and never blindly retries',async()=>{
 const f=fixture();let signal;
 f.provider.send=async(_,options)=>{signal=options.signal;await new Promise(()=>{});};
 assert.equal((await f.run({timeoutMs:5})).unknown,1);assert(signal.aborted);
 assert.equal((await f.run()).skipped,1);
});
test('late acknowledgement after timeout cannot change durable uncertainty',async()=>{
 const f=fixture();let resolve;
 f.provider.send=()=>new Promise(r=>{resolve=r;});
 assert.equal((await f.run({timeoutMs:5})).unknown,1);
 resolve({outcome:'accepted'});await Promise.resolve();assert.equal(f.state(),'unknown');assert.equal(f.finished.length,1);
});
for(const timeoutMs of [0,-1,60001,NaN,1.1]) test('invalid timeout '+timeoutMs,async()=>{
 await assert.rejects(fixture().run({timeoutMs}),RangeError);
});
test('bounded fanout uses server pagination cursor',async()=>{
 const f=fixture();let afterSeen;f.store.page=async(_,after)=>{afterSeen=after;return {status:'ready',installations:Array.from({length:100},(_,i)=>String(i))};};
 const result=await f.run({after:'previous'});assert.equal(afterSeen,'previous');assert.equal(result.next,'99');
 assert.equal(result.sent,1);assert.equal(result.skipped,99);
});
test('DB adapter commits before returning authoritative token and releases connection',async()=>{
 const events=[];const client={query:async(sql,args)=>{events.push([sql,args]);return {rows:[{result:{token:'synthetic'}}]};},release:()=>events.push(['release'])};
 const store=new PostgresPushStore({connect:async()=>client});
 assert.deepEqual(await store.begin('opaque'),{token:'synthetic'});
 assert.equal(events[0][0],'BEGIN ISOLATION LEVEL READ COMMITTED');
 assert.equal(events.at(-2)[0],'COMMIT');assert.equal(events.at(-1)[0],'release');
 assert.deepEqual(events.find(x=>x[0].startsWith('SELECT'))[1],['opaque']);
});
test('uncertain device does not prevent another device and neither is blindly resent',async()=>{
 const f=fixture();const claimed=new Set();const outcomes=[];
 f.store.page=async()=>({status:'ready',installations:['first','second']});
 f.store.claim=async(_,id)=>{if(claimed.has(id))return null;claimed.add(id);return id;};
 f.store.begin=async id=>({token:id,notification_id:'notification',user_id:'user',app_role:'customer'});
 f.provider.send=async message=>{if(message.token==='first')throw Error('uncertain');return {outcome:'accepted'};};
 f.store.finish=async(id,outcome)=>{outcomes.push([id,outcome]);return outcome;};
 const result=await f.run();assert.equal(result.unknown,1);assert.equal(result.sent,1);
 assert.deepEqual(outcomes,[['first','unknown'],['second','provider_accepted']]);
 assert.equal((await f.run()).skipped,2);assert.equal(outcomes.length,2);
});
test('DB adapter redacts raw SQL/parameters and rolls back/releases on lost commit',async()=>{
 const events=[];const client={query:async(sql)=>{events.push(sql);if(sql==='COMMIT')throw Error('private token');return {rows:[{result:1}]};},release:()=>events.push('release')};
 await assert.rejects(new PostgresPushStore({connect:async()=>client}).begin('opaque'),e=>e.message==='push_store_unavailable'&&!e.cause);
 assert.deepEqual(events.slice(-2),['ROLLBACK','release']);
});
