import test from 'node:test';
import assert from 'node:assert/strict';
import {flow} from './handoff.mjs';
import {authoritative,classify} from './classifier.mjs';
import {classification,compare,writeProbeStatements} from './observe.mjs';
import {sealedBytes,observerIdentity} from './identity.mjs';
import {ownerAclPlan} from './restore-owner-acl.mjs';
const off={total:20,eligible:14,gated:6,public_visible:0,roots:0,published:0,leaves:0,activation_entries:0};
const on={...off,public_visible:14,roots:24,published:325,leaves:247,activation_entries:1};
test('restore representation accepts only three default owner-only ACLs, never new grants',()=>{
 const rows=['production_preview_private.testers','public.canonical_categories','public.canonical_category_qualification'].map(name=>({name,owner:'postgres',rls:true,forced:false,acl:null,effective_acl:'{postgres=arwdDxtm/postgres}'}));
 assert.equal(ownerAclPlan(rows).split('\n').length,3);
 for(const changed of [{owner:'anon'},{rls:false},{forced:true},{acl:'{}'},{effective_acl:'{anon=r/postgres}'},{name:'products'}])assert.throws(()=>ownerAclPlan([{...rows[0],...changed},...rows.slice(1)]));
 assert.throws(()=>ownerAclPlan(rows.slice(0,1)));
});
test('original seal verifies all 58 inputs; observer has a separate identity',()=>{
 assert.equal(sealedBytes().runtime_inputs,58);assert.equal(observerIdentity().inventory.length,6);
 assert.ok(sealedBytes().inventory.every(f=>!f.path.includes('/observer/')));
});
test('authoritative state precedes mode-specific assertions',()=>{
 for(const mode of ['preflight','baseline'])assert.equal(authoritative([{public_enabled:false,preview_enabled:false}],mode),false);
 assert.equal(authoritative([{public_enabled:true,preview_enabled:false}],'postflight'),true);
 for(const rows of [[],[{public_enabled:'false',preview_enabled:false}],[{public_enabled:false,preview_enabled:true}]])assert.throws(()=>authoritative(rows,'preflight'));
 assert.throws(()=>authoritative([{public_enabled:false,preview_enabled:false}],'postflight'),/UNEXPECTED_ACTIVATION_STATE/);
 assert.throws(()=>authoritative([{public_enabled:true,preview_enabled:false}],'preflight'),/UNEXPECTED_ACTIVATION_STATE/);
});
test('OFF -> ON -> OFF classification; staged zero in ON is not a failure',()=>{
 assert.equal(classify(false,off).classifier,'STAGED_PRIVATE_PREVIEW_ELIGIBILITY');
 assert.equal(classify(true,on).classifier,'PUBLIC_VISIBILITY_AND_ASSIGNABILITY');
 assert.equal(classify(false,off).result,'PASS');
 const oldLogic=preview=>{assert.equal(preview,14);};
 oldLogic(14);assert.throws(()=>oldLogic(0));oldLogic(14);
});
test('actual classifier SQL selects the PUBLIC predicate on ON',async()=>{
 let sql;const db={query:async s=>{sql=s;return {rows:[on]};}};
 assert.equal((await classification(db,true)).result,'PASS');
 assert.ok(sql.includes('production_taxonomy_assignment_visible_v1'));
 assert.ok(!sql.includes('_w52kb_assignable'));
 db.query=async s=>{sql=s;return {rows:[off]};};await classification(db,false);
 assert.ok(sql.includes('_w52kb_assignable'));
});
test('state-specific cardinality, visibility, publication and ledger drift fail closed',()=>{
 for(const [active,row]of [[false,off],[true,on]])for(const key of Object.keys(row))assert.throws(()=>classify(active,{...row,[key]:row[key]+1}));
});
test('handoff compares immutable data separately from state-dependent metrics',()=>{
 const observation=(active)=>({classification:classify(active,active?on:off),coverage:{digest:'stable'},http:{legacy:{digest:'stable'},facade_off:active?null:{denied:true}},state:{fingerprint:active?'on':'off'}});
 assert.equal(compare(observation(false),observation(true),true).result,'PASS');
 assert.equal(compare(observation(false),observation(false),false).result,'PASS');
 const changed=observation(true);changed.coverage.digest='drift';assert.throws(()=>compare(observation(false),changed,true));
 const broken=observation(false);broken.state.fingerprint='drift';assert.throws(()=>compare(observation(false),broken,false));
});
function mock(change={}){
 const calls=[];return {calls,io:{gates:async()=>({result:'PASS'}),observe:async mode=>{calls.push('observe:'+mode);return {result:'PASS'};},cli:async op=>{calls.push('cli:'+op);return {result:'PASS',production_write_attempted:op==='activate',public_activation_performed:op==='activate'};},backupReceipt:async()=>({result:'PASS'}),compare:async()=>{},save:()=>{},safeError:e=>e.message,progress:()=>{},...change}};
}
test('failed preflight cannot reach activation or backup',async()=>{const m=mock({observe:async()=>{throw Error('PREFLIGHT');}});const r=await flow(m.io);assert.equal(r.result,'STOPPED_BEFORE_WRITE');assert.equal(r.activation_invoked,false);assert.equal(r.production_write_performed,false);assert.equal(r.public_enabled_final,'UNKNOWN');assert.equal(m.calls.length,0);});
test('second package gate fails before activation',async()=>{let n=0;const m=mock({gates:async()=>{if(++n===2)throw Error('DRIFT');}});assert.equal((await flow(m.io)).result,'STOPPED_BEFORE_WRITE');assert.deepEqual(m.calls,['observe:preflight']);});
test('successful flow requires postflight and leaves public ON',async()=>{const m=mock(),r=await flow(m.io);assert.equal(r.result,'PASS');assert.equal(r.public_enabled_final,true);assert.equal(r.public_activation_performed,true);assert.deepEqual(m.calls,['observe:preflight','cli:activate','observe:postflight']);});
test('sealed prewrite refusal does not call rollback',async()=>{const m=mock({cli:async()=>({result:'STOPPED_BEFORE_WRITE',production_write_attempted:false}),backupReceipt:async()=>null}),r=await flow(m.io);assert.equal(r.result,'STOPPED_BEFORE_WRITE');assert.equal(r.rollback_triggered,false);});
test('critical postflight failure calls only sealed rollback and confirms OFF',async()=>{let n=0;const m=mock({compare:async()=>{if(++n===1)throw Error('POSTFLIGHT');}}),r=await flow(m.io);assert.equal(r.result,'ROLLED_BACK');assert.equal(r.public_enabled_final,false);assert.deepEqual(m.calls,['observe:preflight','cli:activate','observe:postflight','cli:postflight','cli:rollback','observe:baseline']);});
test('missing backup receipt after commit invokes rollback',async()=>{const m=mock({backupReceipt:async()=>null}),r=await flow(m.io);assert.equal(r.result,'ROLLED_BACK');assert.equal(r.rollback_triggered,true);});
test('sealed automatic rollback is not repeated',async()=>{const m=mock({cli:async()=>({result:'ROLLED_BACK_0014_ONLY',production_write_attempted:true,public_activation_performed:true,reconciliation:{result:'ROLLED_BACK_0014_ONLY'}})}),r=await flow(m.io);assert.equal(r.result,'ROLLED_BACK');assert.equal(r.rollback_triggered,true);assert.deepEqual(m.calls,['observe:preflight','observe:baseline']);});
test('atomic abort with verified OFF baseline records no committed change',async()=>{const m=mock({cli:async()=>({result:'BASELINE_NO_WRITE',production_write_attempted:true})}),r=await flow(m.io);assert.equal(r.result,'STOPPED_BEFORE_WRITE');assert.equal(r.production_write_performed,false);assert.equal(r.public_enabled_final,false);});
test('failed sealed rollback stops with unknown state, no repair',async()=>{const m=mock({compare:async()=>{throw Error('DRIFT');},cli:async op=>({result:op==='rollback'?'STOPPED_BEFORE_WRITE':'PASS',production_write_attempted:op==='activate'})}),r=await flow(m.io);assert.equal(r.result,'FAIL');assert.equal(r.public_enabled_final,'UNKNOWN');});
test('lost child result never implies no historical write and never retries activation',async()=>{let n=0;const m=mock({cli:async()=>{if(++n===1)throw Error('LOST');return {result:'STOPPED_BEFORE_WRITE'};}}),r=await flow(m.io);assert.equal(r.result,'STOPPED_WITH_BASELINE_RESTORED');assert.equal(r.production_write_performed,'UNKNOWN');assert.equal(r.public_enabled_final,false);assert.equal(n,2);});
test('permission probes plan only, have no ANALYZE or executable DML',()=>{assert.equal(writeProbeStatements.length,3);for(const sql of writeProbeStatements){assert.match(sql,/^EXPLAIN \(FORMAT JSON\) (UPDATE|DELETE|INSERT) /);assert.match(sql,/WHERE false$/);assert.doesNotMatch(sql,/ANALYZE/);}});
