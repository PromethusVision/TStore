import {check,literal,facade,stable} from './common.mjs';
export const params={p_client_contract_version:'taxonomy-client-v1',p_taxonomy_version:'canonical-v1.0.0'};
export function call(name,args={}){
 check(facade.includes(name),'BX_RPC_ALLOWLIST');
 const named={...params,...args};
 check(Object.keys(named).every(k=>/^p_[a-z_]+$/.test(k)),'BX_RPC_PARAMETERS');
 return `SELECT * FROM public.${name}(${Object.entries(named).map(([k,v])=>`${k}=>${literal(v)}`).join(',')})`;
}
export async function asRole(db,role,uid,operation){
 check(['anon','authenticated'].includes(role),'BX_TEST_ROLE');
 await db.exec(`SET LOCAL ROLE ${role}; SELECT set_config('request.jwt.claims',${literal(JSON.stringify(uid?{role,sub:uid}:{role}))},true);`);
 try{return await operation();}finally{await db.exec("RESET ROLE; SELECT set_config('request.jwt.claims','{}',true);");}
}
export async function denied(db,sql,code='42501'){
 check(['42501','P0001'].includes(code),'BX_EXPECTED_SQLSTATE');
 // Catch only the specified error. Unexpected success raises a different code.
 await db.exec(`DO $denial$ BEGIN BEGIN PERFORM * FROM (${sql}) q; EXCEPTION WHEN SQLSTATE '${code}' THEN RETURN; END; RAISE EXCEPTION 'W52JB_BX_EXPECTED_DENIAL' USING ERRCODE='XX000'; END $denial$;`);
}
export async function rpcArguments(db){
 const root=(await db.query('SELECT id::text FROM public.canonical_categories WHERE parent_id IS NULL ORDER BY sort_order,id LIMIT 1')).rows[0].id;
 const leaf=(await db.query("SELECT c.id::text FROM public.canonical_categories c JOIN public.canonical_category_qualification q ON q.category_id=c.id WHERE c.level=4 AND q.qualification='LEAF_ASSIGNABLE_CANDIDATE' ORDER BY c.id LIMIT 1")).rows[0].id;
 return name=>({...(!['taxonomy_capabilities_v2','production_preview_mappings_v1','production_preview_products_v1'].includes(name)?{p_preview:true}:{}),...(name==='taxonomy_children_v2'?{p_parent_id:root}:{}),...(['taxonomy_descendants_v2','taxonomy_breadcrumb_v2','taxonomy_exact_leaf_v2'].includes(name)?{p_category_id:name==='taxonomy_descendants_v2'?root:leaf}:{}),...(name==='taxonomy_resolve_alias_v2'?{p_alias_locator:'powerbank'}:{}),...(name==='taxonomy_search_context_v2'?{p_term:'Defterler'}:{})});
}
export async function previewContracts(db,plan){
 const args=await rpcArguments(db);
 // Some valid branches end at L3. Select one actual eligible L4 ancestry;
 // then exercise every edge with the caller role instead of assuming the
 // first visible root's first child necessarily reaches maximum depth.
 const path=(await db.query(`WITH RECURSIVE branch AS (
 SELECT id,parent_id,level FROM public.canonical_categories WHERE id=(SELECT id FROM public.canonical_categories WHERE level=4 AND public._w52kb_assignable(id) ORDER BY id LIMIT 1)
 UNION ALL SELECT c.id,c.parent_id,c.level FROM public.canonical_categories c JOIN branch b ON c.id=b.parent_id
 ) SELECT id::text,parent_id::text,level FROM branch WHERE level>1 ORDER BY level`)).rows;
 check(path.length===3,'BX_REAL_L4_PATH_REQUIRED');
 // A non-listed UUID is a negative control, not a user inserted by the executor.
 const nonlisted=(await db.query('SELECT gen_random_uuid()::text AS id')).rows[0].id;
 check((await db.query('SELECT count(*)::int AS n FROM production_preview_private.testers WHERE user_id=$1::uuid',[nonlisted])).rows[0].n===0,'BX_NEGATIVE_CONTROL_COLLISION');
 for(const [role,uid]of [['anon',null],['authenticated',nonlisted]])await asRole(db,role,uid,async()=>{
  for(const name of facade)await denied(db,call(name,args(name)));
 });
 for(const uid of plan.user_ids)await asRole(db,'authenticated',uid,async()=>{
  const results={};for(const name of facade)results[name]=(await db.query(call(name,args(name)))).rows;
  const cap=results.taxonomy_capabilities_v2[0]?.taxonomy_capabilities_v2;
  check(cap?.preview_authorized===true&&cap.public_enabled===false&&cap.preview_subject===uid,'BX_CAPABILITY');
  check(results.taxonomy_roots_v2.length===24,'BX_ROOTS_24');
  check(results.taxonomy_resolve_alias_v2.length===1&&results.taxonomy_search_context_v2.length>0,'BX_SEARCH_ALIAS');
  const mapped=results.production_preview_mappings_v1,products=results.production_preview_products_v1;
  check(mapped.length===20&&mapped.filter(m=>m.eligible).length===14,'BX_MAPPING_POLICY');
  check(products.length===14&&products.every(p=>p.product.category_id===p.canonical_category_id&&p.product.legacy_category_id),'BX_PRODUCT_SCOPE');
  for(const mapping of mapped){
   const rows=(await db.query(call('production_preview_products_v1',{p_product_id:mapping.product_id}))).rows;
   check(rows.length===(mapping.eligible?1:0),'BX_PRODUCT_DETAIL');
   if(mapping.eligible){const leaf=(await db.query(call('production_preview_products_v1',{p_category_id:mapping.canonical_category_id,p_exact_leaf:true}))).rows;check(leaf.some(p=>p.product_id===mapping.product_id)&&leaf.every(p=>p.canonical_category_id===mapping.canonical_category_id),'BX_EXACT_LEAF_SCOPE');}
  }
  for(const node of path){
   const children=(await db.query(call('taxonomy_children_v2',{p_parent_id:node.parent_id,p_preview:true}))).rows;
   check(children.some(n=>n.id===node.id)&&children.every(n=>n.level===node.level),'BX_RECURSIVE_DEPTH');
   const breadcrumb=(await db.query(call('taxonomy_breadcrumb_v2',{p_category_id:node.id,p_preview:true}))).rows;
   check(breadcrumb.length===node.level,'BX_BREADCRUMB');
  }
  await denied(db,call('taxonomy_roots_v2',{p_client_contract_version:'wrong',p_preview:true}),'P0001');
 });
 return {result:'PASS',authorized_subjects:plan.user_ids.length,roots:24,recursive_levels:[2,3,4],mappings:20,eligible_products:14,gated_products:6,denied_rpc_checks:20,search_alias:'PASS',breadcrumb:'PASS',product_scope:'PASS'};
}
