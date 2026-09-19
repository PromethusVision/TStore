import test from 'node:test';
import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {mkdtempSync,readFileSync,writeFileSync,unlinkSync,rmdirSync,existsSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {resolve} from 'node:path';
import {resolveIdentity,subject,disposeIdentity,origin,cacheKey,readExistingSession,recoverySubject} from './identity.mjs';
import {leaseSeconds} from './engine.mjs';
import {connectionFactory} from './production.mjs';
import {measure,verify} from './seal.mjs';
import {hash,read,root,directory,operationSucceeded} from './common.mjs';
import {httpClient} from './http.mjs';
const key='sb_'+'publishable_unit_fixture';
function fixture(claims={}){const uid=randomUUID(),payload={iss:origin+'/auth/v1',sub:uid,role:'authenticated',aud:'authenticated',exp:Math.floor(Date.now()/1000)+3600,...claims};return {access_token:Buffer.from('{"alg":"HS256"}').toString('base64url')+'.'+Buffer.from(JSON.stringify(payload)).toString('base64url')+'.unit_signature',user:{id:uid}};}
const accepted=s=>async(url,opts)=>{assert.equal(url,origin+'/auth/v1/user');assert.equal(opts.method,'GET');assert.equal(opts.redirect,'error');return {status:200,json:async()=>({id:s.user.id,role:'authenticated',is_anonymous:false})};};
test('server-verified identity has opaque JSON, then is disposed',async()=>{const s=fixture(),h=await resolveIdentity(s,key,accepted(s));assert.equal(subject(h),s.user.id);assert.ok(!JSON.stringify(h).includes(s.user.id));assert.ok(!JSON.stringify(h).includes(s.access_token));disposeIdentity(h);assert.throws(()=>subject(h));});
test('current-user, JWT subject and server user must all agree',async()=>{const s=fixture();await assert.rejects(()=>resolveIdentity(s,key,async()=>({status:200,json:async()=>({id:randomUUID(),role:'authenticated'})})),/AUTH_SERVER_SUBJECT_MISMATCH/);});
test('wrong project is rejected before network',async()=>{let calls=0;await assert.rejects(()=>resolveIdentity(fixture({iss:'https://wrong.invalid/auth/v1'}),key,async()=>{calls++;}),/PROJECT_IDENTITY_MISMATCH/);assert.equal(calls,0);});
test('expired session is rejected without refresh or network',async()=>{let calls=0;await assert.rejects(()=>resolveIdentity(fixture({exp:1}),key,async()=>{calls++;}),/SESSION_EXPIRED/);assert.equal(calls,0);});
test('missing existing session gives minimum sign-in instruction code',()=>{assert.throws(()=>readExistingSession(resolve(tmpdir(),'w52kby-session-that-does-not-exist.json')),/SIGN_IN_EXISTING_ACCOUNT/);});
test('invalid UID is rejected before network',async()=>{const s=fixture();s.user.id='invalid';await assert.rejects(()=>resolveIdentity(s,key),/UID_MISSING_OR_INVALID/);});
test('auth server rejection cannot create identity',async()=>{await assert.rejects(()=>resolveIdentity(fixture(),key,async()=>({status:401})),/SESSION_INVALID/);});
test('anonymous Auth account cannot become tester',async()=>{const s=fixture();await assert.rejects(()=>resolveIdentity(s,key,async()=>({status:200,json:async()=>({id:s.user.id,role:'authenticated',is_anonymous:true})})),/SUBJECT_MISMATCH/);});
test('SDK cache adapter reads exact project key and does not alter existing cache',()=>{const dir=mkdtempSync(resolve(tmpdir(),'w52kby-fixture-')),path=resolve(dir,'shared_preferences.json'),s=fixture(),text=JSON.stringify({[cacheKey]:JSON.stringify(s)});try{writeFileSync(path,text);assert.deepEqual(readExistingSession(path),s);assert.equal(readFileSync(path,'utf8'),text);}finally{unlinkSync(path);rmdirSync(dir);}});
test('expired cached subject is usable only as revocation input',()=>{const s=fixture({exp:1});assert.equal(recoverySubject(s),s.user.id);assert.throws(()=>subject({uid:s.user.id}));});
for(const ttl of [0,-1,86401,1.5,NaN,Infinity])test('reject lease '+String(ttl),()=>assert.throws(()=>leaseSeconds(ttl),/AT_MOST_24_HOURS/));
test('default one-hour lease and exact 24-hour upper bound',()=>{assert.equal(leaseSeconds(),3600);assert.equal(leaseSeconds(86400),86400);});
test('transport refuses absent explicit authorization before any IO',()=>assert.throws(()=>connectionFactory({}),/EXPLICIT_LIVE_AUTHORIZATION_REQUIRED/));
test('recovered failed deployment exits as failure; explicit healthy rollback can succeed',()=>{
 assert.equal(operationSucceeded('deploy-staged','ROLLED_BACK'),false);
 assert.equal(operationSucceeded('rollback-bridge','ROLLED_BACK'),true);
 for(const operation of ['deploy-staged','rollback-bridge'])for(const outcome of ['ROLLED_BACK_CORE_DRIFT','EMERGENCY_CONTAINMENT','CONTAINMENT_FAILED','STOPPED_BEFORE_WRITE'])assert.equal(operationSucceeded(operation,outcome),false);
 assert.equal(operationSucceeded('deploy-staged','PASS'),true);
});
test('RPC cache miss retries GET but still requires a real denied response',async()=>{
 const s=fixture(),h=await resolveIdentity(s,key,accepted(s));let calls=0;
 try{const client=httpClient(key,h,async(url,options)=>{assert.equal(options.method,'GET');calls++;return calls===1?{status:404,json:async()=>({code:'PGRST202'})}:{status:403,json:async()=>({code:'42501'})};});
 assert.equal((await client.request('/rpc/taxonomy_capabilities_v2',{})).status,403);assert.equal(calls,2);}finally{disposeIdentity(h);}
});
test('persistent RPC cache miss is bounded and remains a failure status',async()=>{
 const s=fixture(),h=await resolveIdentity(s,key,accepted(s));let calls=0;
 try{const client=httpClient(key,h,async()=>{calls++;return {status:404,json:async()=>({code:'PGRST202'})};});assert.equal((await client.request('/rpc/taxonomy_capabilities_v2',{})).status,404);assert.equal(calls,5);}finally{disposeIdentity(h);}
});
test('permission and server errors are never retried as cache misses',async()=>{
 const s=fixture(),h=await resolveIdentity(s,key,accepted(s));
 try{for(const status of [401,403,500]){let calls=0;const client=httpClient(key,h,async()=>{calls++;return {status,json:async()=>({code:'42501'})};});assert.equal((await client.request('/rpc/taxonomy_capabilities_v2',{})).status,status);assert.equal(calls,1);}}finally{disposeIdentity(h);}
});
test('runtime tamper refused; unrelated evidence and test files outside live seal',()=>{
 const expected=hash(read(`${directory}/seal.json`));verify(expected);
 const path=resolve(root,directory,'identity.mjs'),bytes=readFileSync(path);
 try{writeFileSync(path,Buffer.concat([bytes,Buffer.from('\n// tamper probe\n')]));assert.throws(()=>verify(expected),/RUNTIME_INPUT_DRIFT/);}finally{writeFileSync(path,bytes);}
 const doc=resolve(root,'docs/data/w52k_by_temporary_scope_probe.json');assert.equal(existsSync(doc),false);
 try{writeFileSync(doc,'{}\n');verify(expected);}finally{unlinkSync(doc);}
 const paths=measure().map(x=>x.path);for(const name of ['identity','engine','containment','validators','transaction','http','production','cli'])assert.ok(paths.includes(`${directory}/${name}.mjs`));
 assert.ok(!paths.includes(`${directory}/rehearse.mjs`));assert.ok(!paths.includes(`${directory}/package.test.mjs`));verify(expected);
});
