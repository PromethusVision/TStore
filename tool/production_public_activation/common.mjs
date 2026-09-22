import {read,hash,json,stable,literal,root,project} from '../production_taxonomy/execution/common.mjs';
export {read,hash,json,stable,literal,root,project};
export const directory='tool/production_public_activation';
export const authority='513ab9ce7fcec517bbad9922743a629d1512e9b6';
export const version='20260922001400';
export const name='0014_public_canonical_activation';
export const client='production-taxonomy-client-v1';
export const taxonomy='canonical-v1.0.0';
export const manifest=()=>json(`${directory}/runtime-manifest.json`);
export function check(ok,code){if(!ok)throw Error('W52LA_'+code);}
export const safeError=e=>e?.message?.match(/W52(?:LA|JB|KBY|H)_[A-Z0-9_]+/)?.[0]??'W52LA_PRIVATE_ERROR_SUPPRESSED';
export const body=rollback=>read(`${directory}/${rollback?'rollback':'activate'}.sql`);
export const tables=['canonical_categories','canonical_category_qualification','taxonomy_aliases','taxonomy_alias_targets','taxonomy_id_allocations','taxonomy_import_runs','taxonomy_node_relationships','production_taxonomy_config','product_canonical_assignments'];
