// Real PostgREST over container loopback; no network adapter to Production.
import {createHmac} from 'node:crypto';
import {check,client,taxonomy,stable,hash} from './common.mjs';
export function httpContract(s,http){
 function request(role,path,params={},method='GET',payload){
  const url=new URL(path,'http://127.0.0.1:3000');
  for(const[k,v]of Object.entries(params))url.searchParams.set(k,String(v));
  let config=`url = ${JSON.stringify(url.href)}\nrequest = ${JSON.stringify(method)}\n`;
  if(role==='authenticated'){
   const b=x=>Buffer.from(JSON.stringify(x)).toString('base64url');
   const body=b({alg:'HS256',typ:'JWT'})+'.'+b({role:'authenticated',sub:'00000000-0000-4000-8000-000000005252',exp:Math.floor(Date.now()/1000)+3600});
   config+=`header = ${JSON.stringify('Authorization: Bearer '+body+'.'+createHmac('sha256',http.key).update(body).digest('base64url'))}\n`;
  }
  if(payload!==undefined)config+=`header = "Content-Type: application/json"\ndata = ${JSON.stringify(JSON.stringify(payload))}\n`;
  const raw=s.run(['exec','-i',s.container,'curl','--silent','--show-error','--max-time','15','--write-out','\n%{http_code}','--config','-'],config);
  const i=raw.lastIndexOf('\n');return {status:Number(raw.slice(i+1)),data:JSON.parse(raw.slice(0,i))};
 }
 const base={p_client_contract_version:client,p_taxonomy_version:taxonomy};
 const node={...base,p_preview:false};
 async function canonical(db,active){
  s.guard();const result={},path=(await db.query(`WITH RECURSIVE tree AS (
   SELECT id,parent_id,level FROM public.canonical_categories WHERE id=(SELECT c.id FROM public.canonical_categories c JOIN public.canonical_category_qualification q ON q.category_id=c.id WHERE c.level=4 AND q.qualification='LEAF_ASSIGNABLE_CANDIDATE' AND q.policy_gate='PASS' AND q.professional_gate='PASS' ORDER BY c.id LIMIT 1)
   UNION ALL SELECT c.id,c.parent_id,c.level FROM public.canonical_categories c JOIN tree t ON c.id=t.parent_id
  ) SELECT id::text,parent_id::text,level FROM tree ORDER BY level`)).rows;
  for(const role of ['anon','authenticated']){
   let reads=0;const get=(fn,p)=>{const r=request(role,'/rpc/'+fn,p);check(r.status===200,'HTTP_PUBLIC_STATUS');reads++;return r.data;};
   const runtime=get('production_taxonomy_runtime_v1',{});
   const cap=get('production_taxonomy_capabilities_v1',base);
   const roots=get('production_taxonomy_roots_v1',node);
   check(runtime.public_enabled===active&&runtime.preview_enabled===false&&runtime.product_scope_rpc==='production_taxonomy_products_v1','HTTP_RUNTIME');
   check(Array.isArray(cap)&&cap.length===1&&cap[0].rpc_generation===1&&cap[0].public_active_root_count===(active?24:0)&&!cap[0].preview_support,'HTTP_CAPABILITY_SHAPE');
   check(roots.length===(active?24:0),'HTTP_ROOTS_24');
   const ids=new Set();
   for(const root of roots){
    const descendants=get('production_taxonomy_descendants_v1',{...node,p_category_id:root.id});
    check(descendants.some(n=>n.id===root.id),'HTTP_DESCENDANTS');
    const products=get('production_taxonomy_products_v1',{...base,p_category_id:root.id,p_limit:100,p_offset:0});
    for(const p of products){check(p.product.category_id===p.canonical_category_id&&p.product.legacy_category_id,'HTTP_PRODUCT_PROJECTION');ids.add(p.product_id);}
   }
   check(ids.size===(active?14:0),'HTTP_14_ELIGIBLE_6_GATED');
   for(const p of path.slice(1)){
    const children=get('production_taxonomy_children_v1',{...node,p_parent_id:p.parent_id});
    const crumb=get('production_taxonomy_breadcrumb_v1',{...node,p_category_id:p.id});
    check(active?children.some(c=>c.id===p.id)&&crumb.length===p.level:children.length===0&&crumb.length===0,'HTTP_L2_L3_L4_BREADCRUMB');
   }
   const leaf=get('production_taxonomy_exact_leaf_v1',{...node,p_category_id:path.at(-1).id});
   check(leaf.length===(active?1:0),'HTTP_EXACT_LEAF');
   const alias=get('production_taxonomy_resolve_alias_v1',{...node,p_alias_locator:'powerbank'});
   const search=get('production_taxonomy_search_context_v1',{...node,p_term:'Defterler'});
   check(active?alias.length===1&&search.length>0:alias.length===0&&search.length===0,'HTTP_SEARCH_ALIAS');
   const mappings=request(role,'/product_canonical_assignments',{select:'product_id,canonical_category_id'});
   check(mappings.status===200&&mappings.data.length===(active?14:0),'HTTP_MAPPING_RLS');
   // Exercise denied writes on the local copy only. A grant/RLS defect fails the
   // test even when a zero-row UPDATE would leave no data changed.
   const write=request(role,'/canonical_categories',{id:'eq.00000000-0000-4000-8000-000000000000'},'PATCH',{is_active:true});
   check([401,403].includes(write.status),'HTTP_ANONYMOUS_WRITE_DENIAL');
   const preview=request(role,'/rpc/taxonomy_capabilities_v2',{p_client_contract_version:'taxonomy-client-v1',p_taxonomy_version:taxonomy});
   check([401,403].includes(preview.status),'HTTP_PREVIEW_NOT_PUBLIC');
   // The actual preview repository has these parameters. Public v1 deliberately
   // lacks them: document the real client gap instead of renaming RPCs blindly.
   const mismatch=request(role,'/rpc/production_taxonomy_products_v1',{...base,p_product_id:'00000000-0000-4000-8000-000000000000'});
   check(mismatch.status===404&&mismatch.data.code==='PGRST202','HTTP_PREVIEW_PRODUCT_SIGNATURE_MISMATCH');
   result[role]={result:'PASS',reads_200:reads,roots:roots.length,eligible_products:ids.size,gated_products:active?6:20,levels:[2,3,4],breadcrumb:'PASS',search_alias:'PASS',write_status:write.status,preview_status:preview.status,current_client_product_signature_status:mismatch.status,current_client_product_signature_code:mismatch.data.code,product_ids_sha256:hash(stable([...ids].sort()))};
  }return result;
 }
 return {request,canonical};
}
