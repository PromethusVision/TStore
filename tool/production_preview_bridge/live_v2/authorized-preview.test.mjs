import test from 'node:test';
import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {validateAuthorizedPreview} from './authorized-preview.mjs';
import {httpClient} from './http.mjs';
import {resolveIdentity,disposeIdentity,origin} from './identity.mjs';
import {measure} from './seal.mjs';
const uid=randomUUID();
function row(){return {
 contract_version:'taxonomy-client-v1',client_contract_version:'taxonomy-client-v1',taxonomy_version:'canonical-v1.0.0',taxonomy_data_version:'canonical-v1.0.0',rpc_contract_version:'taxonomy-rpc-v2',rpc_generation:2,
 supported_features:['roots','children','descendants','breadcrumb','alias_resolution','search','product_scopes'],
 verified_evidence:['authoritative_contract_version','exact_rpc_signatures','required_response_shapes','lifecycle_publication_semantics','hierarchy_semantics','alias_outcome_semantics','taxonomy_version_semantics'],
 preview_support:true,preview_enabled:true,lifecycle_metadata:true,policy_metadata:true,alias_state_metadata:true,path_metadata:true,public_active_root_count:0,pilot_active_root_count:0,preview_root_count:24,
 product_scope_contract:'exact-leaf-visible-assignable-policy-eligible',product_scope_requires_assignable:true,product_scope_policy_fail_closed:true,
 preview_authorized:true,preview_subject:uid,public_enabled:false,project_ref:'mefhfvrgkwciubeajjeb',preview_bridge_contract:'production-private-preview-v1',product_scope_rpc:'production_preview_products_v1',
};}
const reply=(body=[row()],status=200)=>({body,status});
test('reviewed one-item JSON array passes without leaking the subject',()=>{
 const result=validateAuthorizedPreview(reply(),uid);assert.equal(result.result,'PASS');assert.equal(result.rows,1);assert(!JSON.stringify(result).includes(uid));
 // Regression: the superseded external object's property access is false.
 assert.equal(reply().body?.preview_authorized===true,false);
});
test('multi-item capability list is ambiguous and forbidden by the contract',()=>assert.throws(()=>validateAuthorizedPreview(reply([row(),row()]),uid),/SINGLE_ROW_LIST/));
for(const [name,body]of [['empty',[]],['object',row()],['null',null],['string','[]'],['null row',[null]],['array row',[[]]],['primitive row',[true]],['sparse row',Array(1)],['unexpected field',[{...row(),unexpected:true}]]]){
 test('fail closed: '+name,()=>assert.throws(()=>validateAuthorizedPreview(reply(body),uid),/HTTP_CAPABILITY/));
}
for(const status of [0,201,204,302,400,401,403,404,500])test('reject HTTP '+status+' even with a valid row',()=>assert.throws(()=>validateAuthorizedPreview(reply([row()],status),uid),/STATUS/));
for(const key of Object.keys(row()))test('reject missing required '+key,()=>{const value=row();delete value[key];assert.throws(()=>validateAuthorizedPreview(reply([value]),uid),/FIELDS/);});
for(const key of ['contract_version','client_contract_version','taxonomy_version','taxonomy_data_version','rpc_contract_version','project_ref','preview_bridge_contract','product_scope_rpc','product_scope_contract']){
 test('reject wrong '+key,()=>assert.throws(()=>validateAuthorizedPreview(reply([{...row(),[key]:'wrong'}]),uid),/SEMANTICS/));
}
for(const key of ['preview_authorized','preview_support','preview_enabled','lifecycle_metadata','policy_metadata','alias_state_metadata','path_metadata','product_scope_requires_assignable','product_scope_policy_fail_closed']){
 test('reject false '+key,()=>assert.throws(()=>validateAuthorizedPreview(reply([{...row(),[key]:false}]),uid),/SEMANTICS/));
}
test('public activation ON is refused',()=>assert.throws(()=>validateAuthorizedPreview(reply([{...row(),public_enabled:true}]),uid),/SEMANTICS/));
for(const [key,value]of [['public_active_root_count',1],['pilot_active_root_count',1],['preview_root_count',23],['rpc_generation',1],['preview_authorized','true'],['public_enabled',0],['preview_root_count','24']]){
 test('reject semantic value or type '+key+'='+value,()=>assert.throws(()=>validateAuthorizedPreview(reply([{...row(),[key]:value}]),uid),/SEMANTICS/));
}
test('subject must match the verified runtime identity',()=>assert.throws(()=>validateAuthorizedPreview(reply([{...row(),preview_subject:randomUUID()}]),uid),/IDENTITY/));
test('missing expected identity cannot authorize a response',()=>assert.throws(()=>validateAuthorizedPreview(reply(),undefined),/EXPECTED_SUBJECT/));
for(const key of ['supported_features','verified_evidence']){
 test(key+' is order independent',()=>{const value=row();value[key].reverse();assert.equal(validateAuthorizedPreview(reply([value]),uid).result,'PASS');});
 for(const kind of ['missing','duplicate','unknown','wrong type','not array'])test(key+' rejects '+kind,()=>{
  const value=row();if(kind==='missing')value[key].pop();if(kind==='duplicate')value[key][0]=value[key][1];if(kind==='unknown')value[key][0]='unknown';if(kind==='wrong type')value[key][0]=null;if(kind==='not array')value[key]='invalid';
  assert.throws(()=>validateAuthorizedPreview(reply([value]),uid),/FEATURES/);
 });
}
async function integrated(response){
 const claims={iss:origin+'/auth/v1',sub:uid,role:'authenticated',aud:'authenticated',exp:Math.floor(Date.now()/1000)+3600};
 const session={user:{id:uid},access_token:'unit.'+Buffer.from(JSON.stringify(claims)).toString('base64url')+'.signature'};
 const key='sb_'+'publishable_unit_fixture';
 const handle=await resolveIdentity(session,key,async()=>({status:200,json:async()=>({id:uid,role:'authenticated',is_anonymous:false})}));
 try{
  const client=httpClient(key,handle,async(url,opts)=>{
   assert.equal(opts.method,'GET');assert.equal(opts.redirect,'error');
   if(!opts.headers.Authorization)return {status:401,json:async()=>({code:'42501'})};
   const name=new URL(url).pathname.split('/').at(-1);
   if(name==='taxonomy_capabilities_v2')return {status:response.status,json:async()=>response.body};
   const n={taxonomy_roots_v2:24,production_preview_mappings_v1:20,production_preview_products_v1:14}[name]??0;
   return {status:200,json:async()=>Array.from({length:n},()=>({}))};
  });
  return await client.preview({query:async()=>({rows:[{id:randomUUID()}]})},true);
 }finally{disposeIdentity(handle);}
}
test('actual sealed HTTP preview path uses the corrected validator',async()=>{const result=await integrated(reply());assert.equal(result.rpcs.taxonomy_capabilities_v2.authorized_preview.result,'PASS');});
test('actual HTTP path rejects malformed capability despite status 200',async()=>{await assert.rejects(()=>integrated(reply([])),/SINGLE_ROW_LIST/);});
test('actual HTTP path rejects semantic authorization failure',async()=>{await assert.rejects(()=>integrated(reply([{...row(),preview_authorized:false}])),/SEMANTICS/);});
test('corrected response validator is a transitive sealed runtime input',()=>assert(measure().some(x=>x.path==='tool/production_preview_bridge/live_v2/authorized-preview.mjs')));
