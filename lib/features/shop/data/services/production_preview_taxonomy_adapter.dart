import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/features/shop/data/models/canonical_taxonomy_contract_dto.dart';
import 'package:t_store/features/shop/data/services/supabase_canonical_taxonomy_rpc_adapter.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';

const productionPreviewProjectRef = 'mefhfvrgkwciubeajjeb';

void validateProductionPreviewConfig(SupabaseConfig config) {
  if (config.environment != AppEnvironment.production ||
      Uri.parse(config.supabaseUrl).host !=
          '$productionPreviewProjectRef.supabase.co') {
    throw StateError(
      'Production preview requires the approved Production project.',
    );
  }
}

/// Created only from a fresh server response bound to the current Auth subject.
class ProductionPreviewAuthorization {
  const ProductionPreviewAuthorization._(this.subject, this.contractProof);
  final String subject;
  final TaxonomyBackendContractProof contractProof;
}

class ProductionPreviewTaxonomyAdapter
    extends SupabaseCanonicalTaxonomyRpcAdapter {
  factory ProductionPreviewTaxonomyAdapter({
    required SupabaseConfig config,
    required CanonicalTaxonomyRpcCaller rpcCaller,
    required String? Function() currentUserId,
  }) {
    validateProductionPreviewConfig(config);
    return ProductionPreviewTaxonomyAdapter._(
      _PreviewRpcBoundary(rpcCaller, currentUserId),
    );
  }

  ProductionPreviewTaxonomyAdapter._(this._boundary)
    : super(rpcCaller: _boundary.invoke, previewRequested: true);

  final _PreviewRpcBoundary _boundary;
  bool get hasCurrentAuthorization => _boundary.isAuthorized;
  String? get authorizedSubject => _boundary.authorizedSubject;
  void invalidateAuthorization() => _boundary.invalidate();

  Future<ProductionPreviewAuthorization> authorize() async {
    _boundary.invalidate();
    final generation = _boundary.generation;
    final subject = _boundary.currentUserId();
    if (subject == null) throw StateError('Preview authentication required.');
    final raw = await _boundary.caller(
      SupabaseCanonicalTaxonomyRpcAdapter.capabilitiesRpc,
      _parameters,
    );
    if (_boundary.generation != generation ||
        _boundary.currentUserId() != subject ||
        raw is! List ||
        raw.length != 1 ||
        raw.single is! Map) {
      throw StateError('Preview capability unavailable.');
    }
    final row = Map<String, dynamic>.from(raw.single as Map);
    if (row['preview_authorized'] != true ||
        row['preview_subject'] != subject ||
        row['public_enabled'] != false ||
        row['project_ref'] != productionPreviewProjectRef ||
        row['preview_bridge_contract'] != 'production-private-preview-v1' ||
        row['product_scope_rpc'] != 'production_preview_products_v1') {
      throw StateError('Preview authorization could not be verified.');
    }
    final proof = CanonicalTaxonomyCapabilityDto.fromRpcPayload(row).toProof();
    if (!proof.supportsCanonicalV1 ||
        !proof.previewEnabled ||
        proof.previewRootCount != 24 ||
        proof.publicActiveRootCount != 0 ||
        proof.pilotActiveRootCount != 0) {
      throw StateError('Preview contract is incompatible.');
    }
    _boundary.authorizedSubject = subject;
    return ProductionPreviewAuthorization._(subject, proof);
  }

  @override
  Future<TaxonomyBackendContractProof> getCapabilityProof() async =>
      (await authorize()).contractProof;

  Future<dynamic> readProducts(Map<String, dynamic> parameters) =>
      _boundary.invoke('production_preview_products_v1', {
        ..._parameters,
        ...parameters,
      });

  Map<String, dynamic> get _parameters => {
    'p_client_contract_version': clientContractVersion,
    'p_taxonomy_version': taxonomyVersion,
  };
}

class _PreviewRpcBoundary {
  _PreviewRpcBoundary(this.caller, this.currentUserId);
  final CanonicalTaxonomyRpcCaller caller;
  final String? Function() currentUserId;
  String? authorizedSubject;
  int generation = 0;
  void invalidate() {
    generation++;
    authorizedSubject = null;
  }

  bool get isAuthorized =>
      authorizedSubject != null && currentUserId() == authorizedSubject;

  Future<dynamic> invoke(String name, Map<String, dynamic> parameters) async {
    if (!isAuthorized) throw StateError('Preview capability required.');
    final subject = authorizedSubject;
    final requestGeneration = generation;
    final response = await caller(name, parameters);
    if (!isAuthorized ||
        subject != authorizedSubject ||
        requestGeneration != generation) {
      throw StateError('Preview session changed.');
    }
    return response;
  }
}
