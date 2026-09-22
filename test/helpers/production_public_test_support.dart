import 'production_preview_test_support.dart';
export 'production_preview_test_support.dart'
    show previewTestConfig, previewProductFixture;

Map<String, dynamic> publicRuntimeFixture() => {
  'public_enabled': true,
  'preview_enabled': false,
  'client_contract': 'production-taxonomy-client-v1',
  'taxonomy_version': 'canonical-v1.0.0',
  'rpc_contract': 'production-taxonomy-rpc-v1',
  'product_scope_rpc': 'production_taxonomy_products_v1',
};
Map<String, dynamic> publicCapabilityFixture() =>
    {
      ...previewCapabilityFixture(),
      'contract_version': 'production-taxonomy-client-v1',
      'client_contract_version': 'production-taxonomy-client-v1',
      'rpc_contract_version': 'production-taxonomy-rpc-v1',
      'rpc_generation': 1,
      'preview_support': false,
      'preview_enabled': false,
      'public_active_root_count': 24,
      'preview_root_count': 0,
      'product_scope_contract': 'production-shadow-mapping-policy-eligible-v1',
    }..removeWhere(
      (key, _) => [
        'preview_authorized',
        'preview_subject',
        'public_enabled',
        'project_ref',
        'preview_bridge_contract',
        'product_scope_rpc',
      ].contains(key),
    );
Map<String, dynamic> publicReadsFixture() => {
  'contract': 'production-public-customer-reads-v1',
  'project_ref': 'mefhfvrgkwciubeajjeb',
  'public_enabled': true,
  'preview_required': false,
  'tester_required': false,
  'policy_fail_closed': true,
  'products_rpc': 'production_public_products_v1',
  'listings_rpc': 'production_public_listings_v1',
  'shops_rpc': 'production_public_shops_v1',
};
dynamic publicHandshakeFixture(String name) => switch (name) {
  'production_taxonomy_runtime_v1' => publicRuntimeFixture(),
  'production_taxonomy_capabilities_v1' => [publicCapabilityFixture()],
  'production_public_read_capabilities_v1' => publicReadsFixture(),
  _ => throw StateError('Not a public handshake'),
};
