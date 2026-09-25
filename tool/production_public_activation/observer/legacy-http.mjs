// Explicit GET-only transport shared by live handoff and isolated rehearsal.
import {check} from './classifier.mjs';
import {hash,stable} from '../live/common.mjs';
import {functions} from '../../production_public_client/common.mjs';
export async function httpChecks(request,{installed=false}={}){
 check(typeof request==='function','EXPLICIT_HTTP_TRANSPORT');
 async function get(path,params,single=false){
  check(['/products','/categories','/shop_products','/shops',...functions.map(f=>'/rpc/'+f)].includes(path),'GET_PATH_ALLOWLIST');
  const r=await request(path,params,single);return {status:r.status,body:r.data};
 }
 const firstProduct=await get('/products',{select:'id,category_id',order:'id.asc',limit:1}),firstShop=await get('/shops',{select:'id',is_active:'eq.true',order:'id.asc',limit:1});
 check(firstProduct.status===200&&firstShop.status===200,'HTTP_REFERENCES_STATUS');
 const p=firstProduct.body[0],s=firstShop.body[0];check(p&&s,'HTTP_REFERENCES');
 const product='*,categories(name),brands(name)',listing='*,products(*,categories(name),brands(name)),shops(*)';
 const queries={home:['/categories',{select:'*',is_active:'eq.true',parent_id:'is.null',order:'sort_order.asc'}],listing:['/products',{select:product,is_active:'eq.true',order:'created_at.asc',limit:20}],category:['/products',{select:product,is_active:'eq.true',category_id:'eq.'+p.category_id}],details:['/products',{select:product,id:'eq.'+p.id},true],sellers:['/shop_products',{select:listing,is_active:'eq.true',is_available:'eq.true',product_id:'eq.'+p.id}],shop:['/shops',{select:'*',id:'eq.'+s.id,is_active:'eq.true'},true],shop_listings:['/shop_products',{select:listing,is_active:'eq.true',is_available:'eq.true',shop_id:'eq.'+s.id}],search:['/products',{select:product,is_active:'eq.true',or:'(name.ilike.%Kalem%,description.ilike.%Kalem%)',limit:50}]};
 const legacy={};for(const[label,args]of Object.entries(queries)){
  const r=await get(...args);check(r.status===200,'LEGACY_HTTP_'+label.toUpperCase()+'_'+r.status);
  const rows=Array.isArray(r.body)?r.body:[r.body];check(rows.length>0,'LEGACY_HTTP_EMPTY');
  if(label==='home')check(rows.length===4,'LEGACY_HOME_COUNT');if(label==='listing')check(rows.length===20,'LEGACY_PRODUCT_COUNT');
  if(['listing','category','details'].includes(label))check(rows.every(r=>r.categories&&Object.hasOwn(r,'brands')),'LEGACY_PRODUCT_DTO');
  if(['sellers','shop_listings'].includes(label))check(rows.every(r=>r.products?.categories&&r.shops?.id),'LEGACY_LISTING_DTO');
  legacy[label]={status:200,rows:rows.length,sha256:hash(stable([...rows].sort((a,b)=>String(a.id)<String(b.id)?-1:1))),object_response:!Array.isArray(r.body)};
 }
 const off={};if(installed)for(const fn of functions){
  const r=await get('/rpc/'+fn,{p_client_contract_version:'production-taxonomy-client-v1',p_taxonomy_version:'canonical-v1.0.0'});
  check([401,403].includes(r.status)&&r.body?.code==='42501','HTTP_PUBLIC_OFF_DENIAL');off[fn]={status:r.status,sqlstate:r.body.code,result:'DENIED'};
 }
 return {result:'PASS',role:'anon',method:'GET_ONLY',legacy,facade_off:installed?off:null};
}
