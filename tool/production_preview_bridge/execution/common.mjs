import {read,hash,check,literal,json,stable,root,project} from '../../production_taxonomy/execution/common.mjs';
export {read,hash,check,literal,json,stable,root,project};
export const directory='tool/production_preview_bridge/execution';
export const version='20260919001300';
export const name='0013_production_canonical_private_preview';
export const sourcePath=`supabase/migrations/${version}_${name}.sql`;
export const rollbackPath='tool/production_preview_bridge/rollback.sql';
export const sourceHash='9b56e249a6e3054b8303742ca4bcc41d40e216de9c1a62a72193e4bae81091a4';
export const rollbackHash='fa138b7d9c42086323e10ef9e05985bc71f65357fc3c4a81e38dbdaab52104d4';
export const facade=['taxonomy_capabilities_v2','taxonomy_roots_v2','taxonomy_children_v2','taxonomy_descendants_v2','taxonomy_exact_leaf_v2','taxonomy_breadcrumb_v2','taxonomy_resolve_alias_v2','taxonomy_search_context_v2','production_preview_mappings_v1','production_preview_products_v1'];
export const functions=[...facade,'_w52kb_assert_contract_v2','_w52kb_visible_v2','_w52kb_assignable','_w52kb_node_json_v2','_w52kb_path_json_v2'];
export function payload(rollback=false){
 const source=read(rollback?rollbackPath:sourcePath);
 check(hash(source)===(rollback?rollbackHash:sourceHash),'BX_FROZEN_ARTIFACT');
 const start=source.indexOf('\nBEGIN;\n');
 check(start>0&&source.endsWith('COMMIT;\n'),'BX_OUTER_TRANSACTION');
 // Only transaction ownership changes. No SQL, guard, grant or function rewrite.
 const sql=source.slice(start+8,-8);
 check(source.slice(0,start)+'\nBEGIN;\n'+sql+'COMMIT;\n'===source,'BX_EXACT_RECONSTRUCTION');
 return {sql,sha256:hash(sql),source_sha256:hash(source)};
}
export function safeError(error){return error?.message?.match(/W52(?:JB|H|KBX|KB)_[A-Z0-9_]+/)?.[0]??'W52KBX_PRIVATE_ERROR_SUPPRESSED';}
