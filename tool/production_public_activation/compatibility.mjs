import {check,client,taxonomy,literal,stable} from './common.mjs';
import {legacyContract} from '../production_taxonomy/execution/validators.mjs';
import {canonicalQueries} from '../production_taxonomy/real_contract_checks.mjs';
import {asRole,denied,call as previewCall} from '../production_preview_bridge/execution/rpc-checks.mjs';
export {legacyContract as legacyCompatibility};
export async function publicContract(db,active){
 const result={};
 const path=(await db.query(`WITH RECURSIVE tree AS (
 SELECT id,parent_id,level FROM public.canonical_categories WHERE id=(SELECT c.id FROM public.canonical_categories c JOIN public.canonical_category_qualification q ON q.category_id=c.id WHERE c.level=4 AND q.qualification='LEAF_ASSIGNABLE_CANDIDATE' AND q.policy_gate='PASS' AND q.professional_gate='PASS' ORDER BY c.id LIMIT 1)
 UNION ALL SELECT c.id,c.parent_id,c.level FROM public.canonical_categories c JOIN tree t ON c.id=t.parent_id
 ) SELECT id::text,parent_id::text,level FROM tree ORDER BY level`)).rows;
 check(path.length===4,'ACTUAL_L4_PATH');
 for(const role of ['anon','authenticated'])await asRole(db,role,null,async()=>{
  const summary=await canonicalQueries(db,active);
  check(summary.public_roots===(active?24:0),'PUBLIC_ROOTS_24');
  const cap=(await db.query('SELECT * FROM public.production_taxonomy_capabilities_v1($1,$2)',[client,taxonomy])).rows;
  check(cap.length===1&&cap[0].client_contract_version===client&&cap[0].taxonomy_version===taxonomy&&cap[0].rpc_contract_version==='production-taxonomy-rpc-v1'&&cap[0].public_active_root_count===(active?24:0)&&cap[0].preview_root_count===0&&cap[0].pilot_active_root_count===0&&cap[0].product_scope_requires_assignable&&cap[0].product_scope_policy_fail_closed,'PUBLIC_CAPABILITY');
  for(const n of path.slice(1)){
   const children=(await db.query('SELECT * FROM public.production_taxonomy_children_v1($1,$2,$3,false)',[n.parent_id,client,taxonomy])).rows;
   const breadcrumb=(await db.query('SELECT * FROM public.production_taxonomy_breadcrumb_v1($1,$2,$3,false)',[n.id,client,taxonomy])).rows;
   check(active?children.some(c=>c.id===n.id)&&breadcrumb.length===n.level:children.length===0&&breadcrumb.length===0,'RECURSIVE_BREADCRUMB');
  }
  const assignments=(await db.query('SELECT count(*)::int AS n FROM public.product_canonical_assignments')).rows[0].n;
  check(assignments===(active?14:0),'PUBLIC_MAPPING_RLS');
  await denied(db,`SELECT * FROM public.production_taxonomy_roots_v1('wrong',${literal(taxonomy)},false)`,'P0001');
  await denied(db,`SELECT * FROM public.production_taxonomy_roots_v1(${literal(client)},${literal(taxonomy)},true)`,'P0001');
  await denied(db,previewCall('taxonomy_capabilities_v2'),'42501');
  result[role]={...summary,recursive_levels:[2,3,4],breadcrumb:'PASS',wrong_contract:'DENIED',preview_request:'DENIED',preview_bridge:'DENIED',public_mapping_rows:assignments};
 });
 check(stable(result.anon)===stable(result.authenticated),'PUBLIC_NO_TESTER_DEPENDENCY');
 return {result:'PASS',state:active?'PUBLIC':'STAGED',roles:result,flutter_client_tested:false};
}
