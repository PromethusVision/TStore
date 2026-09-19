import 'package:t_store/core/supabase/supabase_config.dart';

const previewTestSubject = '00000000-0000-4000-8000-000000005301';
SupabaseConfig previewTestConfig({
  String host = 'mefhfvrgkwciubeajjeb.supabase.co',
}) => SupabaseConfig.forEnvironment(
  environment: AppEnvironment.production,
  supabaseUrl: 'https://$host',
  supabaseAnonKey:
      'sb_publishable_'
      'unit_test_client_key_only',
);

Map<String, dynamic> previewCapabilityFixture() => {
  'contract_version': 'taxonomy-client-v1',
  'client_contract_version': 'taxonomy-client-v1',
  'taxonomy_version': 'canonical-v1.0.0',
  'taxonomy_data_version': 'canonical-v1.0.0',
  'rpc_contract_version': 'taxonomy-rpc-v2',
  'rpc_generation': 2,
  'supported_features': [
    'roots',
    'children',
    'descendants',
    'breadcrumb',
    'alias_resolution',
    'search',
    'product_scopes',
  ],
  'verified_evidence': [
    'authoritative_contract_version',
    'exact_rpc_signatures',
    'required_response_shapes',
    'lifecycle_publication_semantics',
    'hierarchy_semantics',
    'alias_outcome_semantics',
    'taxonomy_version_semantics',
  ],
  'preview_support': true,
  'preview_enabled': true,
  'lifecycle_metadata': true,
  'policy_metadata': true,
  'alias_state_metadata': true,
  'path_metadata': true,
  'public_active_root_count': 0,
  'pilot_active_root_count': 0,
  'preview_root_count': 24,
  'product_scope_contract': 'exact-leaf-visible-assignable-policy-eligible',
  'product_scope_requires_assignable': true,
  'product_scope_policy_fail_closed': true,
  'preview_authorized': true,
  'preview_subject': previewTestSubject,
  'public_enabled': false,
  'project_ref': 'mefhfvrgkwciubeajjeb',
  'preview_bridge_contract': 'production-private-preview-v1',
  'product_scope_rpc': 'production_preview_products_v1',
};

Map<String, dynamic> previewProductFixture() => {
  'product_id': '00000000-0000-4000-8000-000000000001',
  'canonical_category_id': '00000000-0000-4000-8000-000000000002',
  'canonical_path': 'Root > Leaf',
  'product': {
    'id': '00000000-0000-4000-8000-000000000001',
    'name': 'Unit test product',
    'price': 10,
    'category_id': '00000000-0000-4000-8000-000000000002',
    'legacy_category_id': '00000000-0000-4000-8000-000000000003',
    'categories': {'name': 'Leaf'},
    'brands': null,
  },
};
