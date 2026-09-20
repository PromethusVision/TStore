// Exact reviewed taxonomy_capabilities_v2 contract (SETOF jsonb, one row).
// Pure response validation: no transport, authorization grant or secret output.
import {check,uuid,project} from './common.mjs';
const scalars={
 contract_version:'taxonomy-client-v1',client_contract_version:'taxonomy-client-v1',
 taxonomy_version:'canonical-v1.0.0',taxonomy_data_version:'canonical-v1.0.0',
 rpc_contract_version:'taxonomy-rpc-v2',rpc_generation:2,
 preview_support:true,preview_enabled:true,lifecycle_metadata:true,policy_metadata:true,
 alias_state_metadata:true,path_metadata:true,public_active_root_count:0,pilot_active_root_count:0,preview_root_count:24,
 product_scope_contract:'exact-leaf-visible-assignable-policy-eligible',product_scope_requires_assignable:true,product_scope_policy_fail_closed:true,
 preview_authorized:true,public_enabled:false,project_ref:project,
 preview_bridge_contract:'production-private-preview-v1',product_scope_rpc:'production_preview_products_v1',
};
const sets={
 supported_features:['roots','children','descendants','breadcrumb','alias_resolution','search','product_scopes'],
 verified_evidence:['authoritative_contract_version','exact_rpc_signatures','required_response_shapes','lifecycle_publication_semantics','hierarchy_semantics','alias_outcome_semantics','taxonomy_version_semantics'],
};
export function validateAuthorizedPreview(response,expectedSubject){
 check(response?.status===200,'HTTP_CAPABILITY_STATUS');
 check(uuid(expectedSubject),'HTTP_CAPABILITY_EXPECTED_SUBJECT');
 check(Array.isArray(response.body)&&response.body.length===1,'HTTP_CAPABILITY_SINGLE_ROW_LIST');
 const row=response.body[0];
 check(row!==null&&typeof row==='object'&&!Array.isArray(row)&&Object.getPrototypeOf(row)===Object.prototype,'HTTP_CAPABILITY_ROW');
 const keys=[...Object.keys(scalars),...Object.keys(sets),'preview_subject'];
 check(Object.keys(row).length===keys.length&&keys.every(k=>Object.hasOwn(row,k)),'HTTP_CAPABILITY_FIELDS');
 check(row.preview_subject===expectedSubject,'HTTP_CAPABILITY_IDENTITY');
 for(const [key,value]of Object.entries(scalars))check(row[key]===value,'HTTP_CAPABILITY_SEMANTICS');
 for(const [key,expected]of Object.entries(sets)){
  const actual=row[key];
  check(Array.isArray(actual)&&actual.length===expected.length&&new Set(actual).size===expected.length&&actual.every(v=>typeof v==='string'&&expected.includes(v)),'HTTP_CAPABILITY_FEATURES');
 }
 return {result:'PASS',response_shape:'SINGLE_ITEM_JSON_ARRAY',rows:1,subject_match:true,contract:'taxonomy-client-v1',preview_authorized:true,public_enabled:false,roots:24};
}
