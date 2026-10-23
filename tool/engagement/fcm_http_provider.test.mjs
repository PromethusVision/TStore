import {test} from 'node:test';
import assert from 'node:assert/strict';
import {FcmHttpProvider} from './fcm_http_provider.mjs';
import {googleServiceToken} from './google_service_token.mjs';
import {createDevelopmentPushWorker,DevelopmentRpcPushStore} from './development_push_worker.mjs';
import {webcrypto} from 'node:crypto';
const id='11111111-1111-4111-8111-111111111111';
const user='22222222-2222-4222-8222-222222222222';
const claim='33333333-3333-4333-8333-333333333333';
const secret='a'.repeat(64);
const message={token:'synthetic-device-token',title:'private title',body:'private text',
  data:{notification_id:id,user_id:user,app_role:'merchant',delivery_id:claim,route:'admin'}};
function provider(fetchImpl, enabled=true) {return new FcmHttpProvider({projectId:'esnaftavar-development',
  enabled,accessToken:async()=> 'synthetic-oauth',fetchImpl});}
test('FCM enforces Development project and inert default',async()=>{
  assert.throws(()=>new FcmHttpProvider({projectId:'production'}));
  let calls=0; await provider(async()=>{calls++;},false).send(message); assert.equal(calls,0);
});
test('FCM sends generic copy and allowlisted data to exact role package',async()=>{
  let submitted;
  const result=await provider(async(url,options)=>{
    submitted=JSON.parse(options.body).message;
    assert.equal(url,'https://fcm.googleapis.com/v1/projects/esnaftavar-development/messages:send');
    assert.equal(options.redirect,'error');
    return Response.json({name:'projects/esnaftavar-development/messages/synthetic-1'});
  }).send(message);
  assert.deepEqual(result,{outcome:'accepted'});
  assert.deepEqual(submitted.notification,{title:'EsnaftaVar',body:'Yeni bir bildirimin var.'});
  assert.equal(submitted.android.restricted_package_name,'com.esnaftavar.app.merchant.pilot');
  assert.equal(submitted.android.ttl,'300s'); assert.equal(submitted.data.route,undefined);
});
test('invalid role and payload rejected before OAuth/network',async()=>{
  let calls=0; const p=provider(async()=>{calls++;});
  for(const bad of [{...message,token:'bad token'},{...message,data:{...message.data,app_role:'admin'}},
    {...message,data:{...message.data,notification_id:'not-uuid'}}]) {
    assert.equal((await p.send(bad)).outcome,'rejected');
  } assert.equal(calls,0);
});
test('only explicit UNREGISTERED disables the exact attempted token',async()=>{
  for(const [status,body,code] of [[404,{error:{details:[{
    '@type':'type.googleapis.com/google.firebase.fcm.v1.FcmError',errorCode:'UNREGISTERED'}]}},'token_unregistered'],
    [400,{error:{status:'INVALID_ARGUMENT'}},'provider_rejected'],
    [403,{error:{status:'PERMISSION_DENIED'}},'provider_rejected']]) {
    assert.equal((await provider(async()=>Response.json(body,{status})).send(message)).code,code);
  }
});
test('timeout, 5xx, 429, malformed or mismatched success remain unknown without retry',async()=>{
  for(const response of [()=>{throw Error('private raw details');},
    ()=>Response.json({error:{status:'UNAVAILABLE'}},{status:503}),
    ()=>Response.json({error:{status:'RESOURCE_EXHAUSTED'}},{status:429}),
    ()=>new Response('malformed',{status:200}),
    ()=>Response.json({name:'projects/other/messages/1'})]) {
    let calls=0;const result=await provider(async()=>{calls++;return response();}).send(message);
    assert.deepEqual(result,{outcome:'unknown'});assert.equal(calls,1);
  }
});
const now=Date.parse('2026-10-24T12:00:00Z');
function harness(overrides={}) {
  const calls=[];let claimed=false;
  const store={notification:async()=>({id,user_id:user,type:'chat',created_at:new Date(now-1000).toISOString()}),
    page:async()=>({status:'ready',installations:[id]}),
    claim:async()=>{calls.push('claim');if(claimed)return null;claimed=true;return claim;},
    begin:async()=>{calls.push('begin-committed');return {token:message.token,notification_id:id,user_id:user,app_role:'merchant'};},
    finish:async(_,outcome)=>{calls.push(outcome);return outcome;},...overrides.store};
  const p={configured:true,send:async()=>{calls.push('provider');return {outcome:'accepted'};},...overrides.provider};
  const worker=createDevelopmentPushWorker({enabled:true,secret,recipients:[user],
    notBefore:new Date(now-10000).toISOString(),store,provider:p,now:()=>now,cryptoImpl:webcrypto,...overrides.config});
  return {calls,worker};
}
function request(body={notification_id:id},authorization=`Bearer ${secret}`) {
  return new Request('https://example.invalid/worker',{method:'POST',headers:{Authorization:authorization},body:JSON.stringify(body)});
}
test('worker rejects default off, empty cohort, missing auth before DB or send',async()=>{
  const defaults=createDevelopmentPushWorker({});
  assert.equal((await defaults(request())).status,503);
  const empty=harness({config:{recipients:[]}});assert.equal((await empty.worker(request())).status,503);
  const h=harness();assert.equal((await h.worker(request({},'Bearer wrong'))).status,401);
  assert.deepEqual(h.calls,[]);
});
test('forged webhook recipient/type cannot override current server row',async()=>{
  for(const row of [{user_id:claim},{type:'promotion'},{created_at:new Date(now-600000).toISOString()},
    {created_at:new Date(now+1).toISOString()},{created_at:'invalid'}]) {
    const h=harness({store:{notification:async()=>({id,user_id:user,type:'chat',created_at:new Date(now-1).toISOString(),...row})}});
    const response=await h.worker(request({record:{id,user_id:user,type:'chat'}}));
    assert.equal((await response.json()).status,'outside_test_scope');assert.deepEqual(h.calls,[]);
  }
});
test('worker commits begin before send and duplicate webhook never resends',async()=>{
  const h=harness();const first=await (await h.worker(request())).json();
  assert.equal(first.sent,1);await h.worker(request());
  assert.deepEqual(h.calls,['claim','begin-committed','provider','provider_accepted','claim']);
});
test('lost provider response stays unknown and replay cannot resend',async()=>{
  const h=harness({provider:{send:async()=>{throw Error('fixture');}}});
  const result=await (await h.worker(request())).json();assert.equal(result.unknown,1);
  await h.worker(request());assert.deepEqual(h.calls,['claim','begin-committed','unknown','claim']);
});
test('worker response redacts arbitrary database exception and token details',async()=>{
  const h=harness({store:{notification:async()=>{throw Error('secret-raw-error');}}});
  const result=await h.worker(request());assert.equal(result.status,503);
  assert.equal(await result.text(),'{"status":"unavailable"}');
});
test('RPC adapter pins endpoint and commits as independent requests without retries',async()=>{
  assert.throws(()=>new DevelopmentRpcPushStore({url:'https://production.example',serviceKey:'synthetic'}));
  const calls=[]; const store=new DevelopmentRpcPushStore({url:'https://tnipyxnvhgelwdpykyez.supabase.co',serviceKey:'synthetic',
    fetchImpl:async(url,options)=>{calls.push([url,JSON.parse(options.body)]);return Response.json(claim);}});
  await store.claim(id,user); await store.begin(claim);
  assert.equal(calls.length,2);assert.equal(calls[0][1].p_notification_id,id);
  assert.equal(calls[1][1].p_claim_id,claim);
  await store.notification(id);
  assert.equal(calls[2][0],'https://tnipyxnvhgelwdpykyez.supabase.co/rest/v1/rpc/read_push_notification_development_v1');
  assert.deepEqual(calls[2][1],{p_notification_id:id});
});

test('worker bounds streaming request before database access',async()=>{
  const h=harness({store:{notification:async()=>{throw Error('must not read');}}});
  const response=await h.worker(request({padding:'x'.repeat(20000)}));
  assert.equal(response.status,413);assert.deepEqual(h.calls,[]);
});
test('OAuth credential scope rejects wrong project before private-key parsing',()=>{
  assert.throws(()=>googleServiceToken({credentials:{type:'service_account',project_id:'production'}}),/credential_denied/);
});
test('OAuth signs messaging-only JWT, coalesces requests, caches and redacts failures',async()=>{
  const pair=await webcrypto.subtle.generateKey({name:'RSASSA-PKCS1-v1_5',modulusLength:2048,
    publicExponent:new Uint8Array([1,0,1]),hash:'SHA-256'},true,['sign','verify']);
  const pkcs8=await webcrypto.subtle.exportKey('pkcs8',pair.privateKey);
  // Ephemeral test key stays in memory; never persisted or logged.
  const credentials={type:'service_account',project_id:'esnaftavar-development',
    client_email:'dev-push-worker@esnaftavar-development.iam.gserviceaccount.com',
    private_key:`-----BEGIN PRIVATE KEY-----\n${Buffer.from(pkcs8).toString('base64')}\n-----END PRIVATE KEY-----`};
  let calls=0;
  const token=googleServiceToken({credentials,cryptoImpl:webcrypto,now:()=>now,fetchImpl:async(url,options)=>{
    calls++;assert.equal(url,'https://oauth2.googleapis.com/token');
    const assertion=new URLSearchParams(options.body).get('assertion');
    const [header,payload,signature]=assertion.split('.');
    const claims=JSON.parse(Buffer.from(payload,'base64url').toString());
    assert.equal(claims.scope,'https://www.googleapis.com/auth/firebase.messaging');
    assert.equal(claims.exp-claims.iat,3600);
    assert.equal(await webcrypto.subtle.verify('RSASSA-PKCS1-v1_5',pair.publicKey,
      Buffer.from(signature,'base64url'),new TextEncoder().encode(`${header}.${payload}`)),true);
    return Response.json({access_token:'synthetic-oauth',expires_in:3600,token_type:'Bearer'});
  }});
  assert.deepEqual(await Promise.all([token(),token()]),['synthetic-oauth','synthetic-oauth']);
  await token();assert.equal(calls,1);
  const failed=googleServiceToken({credentials,cryptoImpl:webcrypto,fetchImpl:async()=>{throw Error('sensitive');}});
  await assert.rejects(failed(),/^Error: fcm_auth_unavailable$/);
});
