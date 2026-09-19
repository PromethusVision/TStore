import {check,hash,stable,facade} from './common.mjs';
import {authHeaders,origin} from './identity.mjs';
import {params,rpcArguments} from '../execution/rpc-checks.mjs';
export function httpClient(key,handle,fetcher=globalThis.fetch){
 check(typeof key==='string'&&key.startsWith('sb_publishable_'),'PUBLISHABLE_KEY_ONLY');
 async function request(path,args,authenticated=true,single=false){
  check(/^\/(rpc\/[a-z0-9_]+|categories|products|shops|shop_products)$/.test(path),'READ_ONLY_HTTP_PATH');
  if(path.startsWith('/rpc/'))check(facade.includes(path.slice(5)),'RPC_ALLOWLIST');
  const url=new URL('/rest/v1'+path,origin);for(const[k,v]of Object.entries(args))url.searchParams.set(k,String(v));
  for(let attempt=0;attempt<5;attempt++){
   const response=await fetcher(url.href,{method:'GET',redirect:'error',headers:{...(authenticated?authHeaders(handle):{apikey:key}),...(single?{Accept:'application/vnd.pgrst.object+json'}:{})},signal:AbortSignal.timeout(20000)});
   const result={status:response.status,body:await response.json()};
   // Only a newly installed RPC missing from the HTTP schema cache may retry.
   // A missing endpoint never counts as an authorization-denial success.
   if(!(path.startsWith('/rpc/')&&result.status===404&&result.body?.code==='PGRST202')||attempt===4)return result;
   await new Promise(resolve=>setTimeout(resolve,500));
  }
 }
 async function preview(db,allowed){
  const args=await rpcArguments(db);const result={};
  for(const fn of facade){
   const a=await request('/rpc/'+fn,{...params,...args(fn)}),anon=await request('/rpc/'+fn,{...params,...args(fn)},false);
   check(allowed?a.status===200:[401,403].includes(a.status),'HTTP_TESTER_CONTRACT');check([401,403].includes(anon.status),'HTTP_ANON_DENIED');
   result[fn]={tester_status:a.status,anonymous_status:anon.status};
   if(allowed&&fn==='taxonomy_roots_v2')check(a.body.length===24,'HTTP_ROOTS_24');
   if(allowed&&fn==='production_preview_mappings_v1')check(a.body.length===20,'HTTP_MAPPINGS_20');
   if(allowed&&fn==='production_preview_products_v1')check(a.body.length===14,'HTTP_PRODUCT_SCOPE_14');
  }return {result:'PASS',tester:allowed?'ALLOWED':'DENIED',anonymous:'DENIED',rpcs:result};
 }
 async function legacy(){
  const p=(await request('/products',{select:'id,category_id',order:'id.asc',limit:1},false)).body[0];
  const s=(await request('/shops',{select:'id',is_active:'eq.true',order:'id.asc',limit:1},false)).body[0];check(p&&s,'LEGACY_TEST_REFERENCES');
  const product='*,categories(name),brands(name)',listing='*,products(*,categories(name),brands(name)),shops(*)';
  const queries={home:['/categories',{select:'*',is_active:'eq.true',parent_id:'is.null',order:'sort_order.asc'}],listing:['/products',{select:product,is_active:'eq.true',order:'created_at.asc',limit:20}],category:['/products',{select:product,is_active:'eq.true',category_id:'eq.'+p.category_id}],details:['/products',{select:product,id:'eq.'+p.id},true],sellers:['/shop_products',{select:listing,is_active:'eq.true',is_available:'eq.true',product_id:'eq.'+p.id}],shop:['/shops',{select:'*',id:'eq.'+s.id,is_active:'eq.true'},true],shop_listings:['/shop_products',{select:listing,is_active:'eq.true',is_available:'eq.true',shop_id:'eq.'+s.id}],search:['/products',{select:product,is_active:'eq.true',or:'(name.ilike.%Kalem%,description.ilike.%Kalem%)',limit:50}]};
  const result={};for(const authenticated of [false,true]){
   const role=authenticated?'tester':'anon';result[role]={};
   for(const[label,[path,args,single]]of Object.entries(queries)){
    const response=await request(path,args,authenticated,single);check(response.status===200,'LEGACY_HTTP_STATUS');const rows=Array.isArray(response.body)?response.body:[response.body];check(rows.length>0,'LEGACY_HTTP_EMPTY');
    if(label==='home')check(rows.length===4,'LEGACY_HTTP_CATEGORIES');if(label==='listing')check(rows.length===20,'LEGACY_HTTP_PRODUCTS');
    result[role][label]={status:200,rows:rows.length,sha256:hash(stable([...rows].sort((a,b)=>String(a.id)<String(b.id)?-1:1)))};
   }
  }return result;
 }
 return {preview,legacy,request};
}
