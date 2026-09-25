// Transport injected by the caller; no credential discovery or network default.
import {check} from './classifier.mjs';
import {project,stable} from '../live/common.mjs';
export function reader(request){
 check(typeof request==='function','EXPLICIT_HTTP_TRANSPORT');
 const params={p_client_contract_version:'production-taxonomy-client-v1',p_taxonomy_version:'canonical-v1.0.0'};
 return async(name,args={})=>{
  check(/^(production_taxonomy_(runtime|capabilities|roots|children|descendants|exact_leaf|breadcrumb|resolve_alias|search_context)_v1|production_public_(read_capabilities|products|listings|shops)_v1)$/.test(name),'PUBLIC_READ_RPC_ALLOWLIST');
  const taxonomy=!['production_taxonomy_runtime_v1','production_taxonomy_capabilities_v1'].includes(name)&&name.startsWith('production_taxonomy_');
  const r=await request('/rpc/'+name,{...name==='production_taxonomy_runtime_v1'?{}:params,...taxonomy?{p_preview:false}:{},...args});
  check(r.status===200,'PUBLIC_HTTP_'+name.toUpperCase()+'_'+r.status);return r.data;
 };
}
export async function publicHttp(refs,request){
 const get=reader(request),base='production_taxonomy_',pub='production_public_';
 const runtime=await get(base+'runtime_v1');check(runtime.public_enabled===true&&runtime.preview_enabled===false&&runtime.client_contract==='production-taxonomy-client-v1'&&runtime.taxonomy_version==='canonical-v1.0.0'&&runtime.rpc_contract==='production-taxonomy-rpc-v1'&&runtime.product_scope_rpc==='production_taxonomy_products_v1','PUBLIC_RUNTIME_SHAPE');
 const cap=await get(base+'capabilities_v1');check(Array.isArray(cap)&&cap.length===1&&cap[0].public_active_root_count===24&&!cap[0].preview_support&&cap[0].rpc_generation===1,'PUBLIC_CAPABILITY_SHAPE');
 const reads=await get(pub+'read_capabilities_v1');
 for(const[k,v]of Object.entries({contract:'production-public-customer-reads-v1',project_ref:project,public_enabled:true,preview_required:false,tester_required:false,policy_fail_closed:true,products_rpc:pub+'products_v1',listings_rpc:pub+'listings_v1',shops_rpc:pub+'shops_v1'}))check(reads?.[k]===v,'PUBLIC_FACADE_CAPABILITY_SHAPE');
 const roots=await get(base+'roots_v1');check(roots.length===24&&new Set(roots.map(r=>r.id)).size===24,'PUBLIC_ROOTS_24');
 check(refs.path.length===4&&refs.eligible.length===14&&refs.gated.length===6,'PUBLIC_REFERENCE_COUNTS');
 for(let level=1;level<4;level++){
  const children=await get(base+'children_v1',{p_parent_id:refs.path[level-1]}),breadcrumb=await get(base+'breadcrumb_v1',{p_category_id:refs.path[level]});
  check(children.some(c=>c.id===refs.path[level])&&breadcrumb.length===level+1,'PUBLIC_RECURSIVE_BREADCRUMB');
 }
 check((await get(base+'descendants_v1',{p_category_id:refs.path[0]})).some(n=>n.id===refs.path[3]),'PUBLIC_DESCENDANTS');
 check((await get(base+'exact_leaf_v1',{p_category_id:refs.path[3]})).length===1,'PUBLIC_EXACT_LEAF');
 check((await get(base+'resolve_alias_v1',{p_alias_locator:'powerbank'})).length===1&&(await get(base+'search_context_v1',{p_term:'Defterler'})).length>0,'PUBLIC_ALIAS_SEARCH');
 const products=await get(pub+'products_v1',{p_limit:100});
 check(stable(products.map(p=>p.product_id).sort())===stable([...refs.eligible].sort()),'PUBLIC_HTTP_PRODUCT_SET');
 for(const p of products){
  const detail=await get(pub+'products_v1',{p_product_id:p.product_id}),sellers=await get(pub+'listings_v1',{p_product_id:p.product_id,p_limit:100});
  check(detail.length===1&&detail[0].product.category_id===p.canonical_category_id&&sellers.length>0&&sellers.every(s=>s.product_id===p.product_id&&s.shop_product.products.category_id===s.canonical_category_id&&s.shop_product.shops.id===s.shop_product.shop_id),'PUBLIC_DETAILS_AND_SELLERS');
 }
 for(const id of refs.gated)check((await get(pub+'products_v1',{p_product_id:id})).length===0&&(await get(pub+'listings_v1',{p_product_id:id})).length===0,'PUBLIC_HTTP_GATED_EXCLUSION');
 const listings=[];for(let offset=0;offset<1000;offset+=100){const page=await get(pub+'listings_v1',{p_limit:100,p_offset:offset});listings.push(...page);if(page.length<100)break;}
 check(listings.length>0&&new Set(listings.map(r=>r.shop_product_id)).size===listings.length&&listings.every(r=>refs.eligible.includes(r.product_id)),'PUBLIC_HTTP_LISTINGS');
 const shops=await get(pub+'shops_v1',{p_limit:100}),id=listings[0].shop_product.shop_id;
 check(shops.length>0&&shops.every(s=>s.is_active)&&(await get(pub+'shops_v1',{p_shop_id:id})).length===1,'PUBLIC_HTTP_SHOPS');
 const shopRows=await get(pub+'listings_v1',{p_shop_id:id,p_limit:100});check(shopRows.length>0&&shopRows.every(r=>r.shop_product.shop_id===id),'PUBLIC_HTTP_SHOP_LISTINGS');
 check((await get(pub+'products_v1',{p_term:products[0].product.name})).some(r=>r.product_id===products[0].product_id),'PUBLIC_HTTP_PRODUCT_SEARCH');
 return {result:'PASS',role:'anon',method:'GET_ONLY',tester_required:false,auth_session_used:false,roots:24,recursive_levels:[2,3,4],breadcrumb:'PASS',alias_search:'PASS',product_listing:'PASS',product_details:'PASS',seller_comparison:'PASS',shop_details:'PASS',search:'PASS',eligible_products:14,gated_products_excluded:6,listing_rows:listings.length,shop_rows:shops.length,four_facade_functions:'PASS',legacy_fallback:false,preview_fallback:false,development_fallback:false};
}
