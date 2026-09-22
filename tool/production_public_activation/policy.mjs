import {parseCsv} from '../taxonomy_migration/lib.mjs';
import {check,read,stable,hash,tables} from './common.mjs';

// Source-derived publication review: all eligible containers (including empty
// roots), eligible terminal leaves, and an entirely eligible ancestor chain.
// No policy or professional-review field is changed by publication.
export function publicationPlan(){
 const categories=parseCsv(read('docs/TAXONOMY_W36_CATEGORY_IMPORT.csv')).rows;
 const qualification=parseCsv(read('docs/TAXONOMY_W36_ACTIVATION_QUALIFICATION.csv')).rows;
 const q=new Map(qualification.map(r=>[r.DEVELOPMENT_UUID,r]));
 const nodes=new Map(categories.map(r=>[r.ID,r]));
 check(nodes.size===1563&&q.size===1563,'SOURCE_CARDINALITY');
 const eligible=id=>{
  const seen=new Set();
  while(id){
   check(!seen.has(id)&&seen.size<4,'SOURCE_ANCESTRY');seen.add(id);
   const c=nodes.get(id),g=q.get(id);check(c&&g,'SOURCE_JOIN');
   if(g.EFFECTIVE_POLICY_GATE!=='PASS'||g.EFFECTIVE_PROFESSIONAL_REVIEW_GATE!=='PASS'||!['CONTAINER_NOT_ASSIGNABLE','LEAF_ASSIGNABLE_CANDIDATE'].includes(g.QUALIFICATION))return false;
   id=c.PARENT_ID;
  }return true;
 };
 const active=categories.filter(c=>eligible(c.ID)).map(c=>({id:c.ID,assignable:q.get(c.ID).QUALIFICATION==='LEAF_ASSIGNABLE_CANDIDATE'})).sort((a,b)=>a.id.localeCompare(b.id));
 check(active.length===325&&active.filter(c=>c.assignable).length===247&&active.filter(c=>!nodes.get(c.id).PARENT_ID).length===24,'REVIEWED_PUBLICATION_SET');
 return {active,qualification,sha256:hash(stable(active))};
}
export async function policy(db,active){
 const plan=publicationPlan(),selected=new Map(plan.active.map(c=>[c.id,c.assignable]));
 const actual=(await db.query('SELECT category_id::text,qualification,policy_gate,professional_gate,source_gate_reason FROM public.canonical_category_qualification ORDER BY category_id')).rows;
 const expected=plan.qualification.map(q=>({category_id:q.DEVELOPMENT_UUID,qualification:q.QUALIFICATION,policy_gate:q.EFFECTIVE_POLICY_GATE,professional_gate:q.EFFECTIVE_PROFESSIONAL_REVIEW_GATE,source_gate_reason:q.FAIL_CLOSED_REASON})).sort((a,b)=>a.category_id.localeCompare(b.category_id));
 check(stable(actual)===stable(expected),'EXACT_QUALIFICATION_GATES');
 const nodes=(await db.query('SELECT id::text,is_active,is_assignable,lifecycle_state FROM public.canonical_categories')).rows;
 check(nodes.length===1563,'EXACT_NODE_COUNT');
 for(const n of nodes){const on=active&&selected.has(n.id);check(n.is_active===on&&n.is_assignable===(on&&selected.get(n.id))&&n.lifecycle_state===(on?'active':'staged'),'EXACT_PUBLICATION_STATE');}
 return {result:'PASS',published_nodes:active?325:0,assignable_leaves:active?247:0,staged_nodes:active?1238:1563,roots:active?24:0,publication_set_sha256:plan.sha256};
}
// Ignore installation timestamps only in the cross-install structural oracle.
// The executor separately compares full rows, including every timestamp, across
// each actual transaction and rollback.
export async function structuralData(db){
 const result={};
 for(const table of tables){
  const rows=(await db.query(`SELECT to_jsonb(t)-'created_at'-'updated_at'-'applied_at' AS row FROM public.${table} t ORDER BY (to_jsonb(t)-'created_at'-'updated_at'-'applied_at')::text COLLATE "C"`)).rows;
  result[table]=hash(stable(rows));
 }return result;
}
export async function preservedData(db){
 const result={};
 for(const table of tables){
  const subtract=table==='canonical_categories'?"-'is_active'-'is_assignable'-'lifecycle_state'":table==='taxonomy_aliases'?"-'is_active'":table==='production_taxonomy_config'?"-'public_enabled'":'';
  result[table]=hash(stable((await db.query(`SELECT to_jsonb(t)${subtract} AS row FROM public.${table} t ORDER BY (to_jsonb(t)${subtract})::text COLLATE "C"`)).rows));
 }
 result.private_testers=hash(stable((await db.query('SELECT to_jsonb(t) AS row FROM production_preview_private.testers t ORDER BY to_jsonb(t)::text COLLATE "C"')).rows));
 return result;
}
