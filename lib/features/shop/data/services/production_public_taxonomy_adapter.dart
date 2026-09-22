import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/features/shop/data/models/canonical_taxonomy_contract_dto.dart';
import 'package:t_store/features/shop/data/services/supabase_canonical_taxonomy_rpc_adapter.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';

const productionPublicProjectRef = 'mefhfvrgkwciubeajjeb';
const productionPublicClientContract = 'production-taxonomy-client-v1';

void validateProductionPublicConfig(SupabaseConfig config) {
  final uri = Uri.parse(config.supabaseUrl);
  if (config.environment != AppEnvironment.production ||
      uri.scheme != 'https' ||
      uri.host != '$productionPublicProjectRef.supabase.co' ||
      (uri.hasPort && uri.port != 443) ||
      uri.userInfo.isNotEmpty ||
      !['', '/'].contains(uri.path) ||
      uri.hasQuery ||
      uri.hasFragment) {
    throw StateError('Approved Production public project is required.');
  }
}

/// Only a fresh public runtime/capability/facade handshake can create this.
/// It represents publication, never a tester identity or private permission.
class ProductionPublicAuthorization {
  const ProductionPublicAuthorization._(this.contractProof);
  final TaxonomyBackendContractProof contractProof;
}

class ProductionPublicTaxonomyAdapter
    extends SupabaseCanonicalTaxonomyRpcAdapter {
  factory ProductionPublicTaxonomyAdapter({
    required SupabaseConfig config,
    required CanonicalTaxonomyRpcCaller rpcCaller,
    void Function()? onUnavailable,
  }) {
    validateProductionPublicConfig(config);
    return ProductionPublicTaxonomyAdapter._(
      _PublicBoundary(rpcCaller, onUnavailable),
    );
  }
  ProductionPublicTaxonomyAdapter._(this._boundary)
    : super(
        rpcCaller: _boundary.invoke,
        clientContractVersion: productionPublicClientContract,
      );
  final _PublicBoundary _boundary;
  ProductionPublicAuthorization? get authorization => _boundary.authorization;
  bool get isVerified => authorization != null;
  void invalidate() => _boundary.invalidate();
  Future<ProductionPublicAuthorization> authorize() => _boundary.authorize();
  @override
  Future<TaxonomyBackendContractProof> getCapabilityProof() async =>
      (await authorize()).contractProof;
  Future<dynamic> readProducts(Map<String, dynamic> args) =>
      _boundary.invoke('production_public_products_v1', args);
  Future<dynamic> readListings(Map<String, dynamic> args) =>
      _boundary.invoke('production_public_listings_v1', args);
  Future<dynamic> readShops(Map<String, dynamic> args) =>
      _boundary.invoke('production_public_shops_v1', args);
}

class _PublicBoundary {
  _PublicBoundary(this.caller, this.onUnavailable);
  final CanonicalTaxonomyRpcCaller caller;
  final void Function()? onUnavailable;
  ProductionPublicAuthorization? authorization;
  int generation = 0;
  static const params = {
    'p_client_contract_version': productionPublicClientContract,
    'p_taxonomy_version': 'canonical-v1.0.0',
  };
  static const taxonomyMethods = [
    'roots',
    'children',
    'descendants',
    'exact_leaf',
    'breadcrumb',
    'resolve_alias',
    'search_context',
  ];
  void invalidate() {
    generation++;
    authorization = null;
  }

  Map<String, dynamic> _object(dynamic value) {
    if (value is! Map) {
      throw const FormatException('Public contract object required.');
    }
    return Map<String, dynamic>.from(value);
  }

  Future<TaxonomyBackendContractProof> _verify() async {
    final runtime = _object(await caller('production_taxonomy_runtime_v1', {}));
    if (runtime['public_enabled'] != true ||
        runtime['preview_enabled'] != false ||
        runtime['client_contract'] != productionPublicClientContract ||
        runtime['taxonomy_version'] != 'canonical-v1.0.0' ||
        runtime['rpc_contract'] != 'production-taxonomy-rpc-v1' ||
        runtime['product_scope_rpc'] != 'production_taxonomy_products_v1') {
      throw StateError('Public runtime unavailable.');
    }
    final raw = await caller('production_taxonomy_capabilities_v1', params);
    if (raw is! List || raw.length != 1) {
      throw const FormatException('One public capability required.');
    }
    final row = _object(raw.single);
    for (final field in ['supported_features', 'verified_evidence']) {
      final values = row[field];
      if (values is! List || values.length != 7 || values.toSet().length != 7) {
        throw const FormatException('Ambiguous public capability.');
      }
    }
    final proof = CanonicalTaxonomyCapabilityDto.fromRpcPayload(row).toProof();
    if (!proof.supportsProductionPublic) {
      throw StateError('Public capability mismatch.');
    }
    final reads = _object(
      await caller('production_public_read_capabilities_v1', params),
    );
    const expected = {
      'contract': 'production-public-customer-reads-v1',
      'project_ref': productionPublicProjectRef,
      'public_enabled': true,
      'preview_required': false,
      'tester_required': false,
      'policy_fail_closed': true,
      'products_rpc': 'production_public_products_v1',
      'listings_rpc': 'production_public_listings_v1',
      'shops_rpc': 'production_public_shops_v1',
    };
    if (expected.entries.any((e) => reads[e.key] != e.value)) {
      throw StateError('Public product contract mismatch.');
    }
    return proof;
  }

  Future<ProductionPublicAuthorization> authorize() async {
    invalidate();
    final ticket = generation;
    try {
      final proof = await _verify();
      if (ticket != generation) throw StateError('Public runtime changed.');
      return authorization = ProductionPublicAuthorization._(proof);
    } on Object {
      if (ticket == generation) invalidate();
      rethrow;
    }
  }

  Future<dynamic> invoke(String method, Map<String, dynamic> args) async {
    if (authorization == null) {
      throw StateError('Verified public runtime required.');
    }
    final ticket = generation;
    try {
      final publicName = taxonomyMethods
          .where((m) => method == 'taxonomy_${m}_v2')
          .firstOrNull;
      if (publicName == null &&
          ![
            'production_public_products_v1',
            'production_public_listings_v1',
            'production_public_shops_v1',
          ].contains(method)) {
        throw StateError('Public RPC not allowed.');
      }
      if (args['p_preview'] == true) {
        throw StateError('Preview is not a public mode.');
      }
      await _verify(); // Do not serve a cached proof after public OFF/rollback.
      if (ticket != generation || authorization == null) {
        throw StateError('Public runtime changed.');
      }
      final result = await caller(
        publicName == null ? method : 'production_taxonomy_${publicName}_v1',
        {...args, ...params, if (publicName != null) 'p_preview': false},
      );
      if (ticket != generation || authorization == null) {
        throw StateError('Public runtime changed.');
      }
      return result;
    } on Object {
      if (ticket == generation) {
        invalidate();
        onUnavailable?.call();
      }
      rethrow;
    }
  }
}
