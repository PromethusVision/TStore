import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/shop/data/models/canonical_taxonomy_contract_dto.dart';
import 'package:t_store/features/shop/data/services/canonical_taxonomy_contract_adapter.dart';
import 'package:t_store/features/shop/domain/repositories/canonical_taxonomy_repository.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_alias_resolution.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';

typedef CanonicalTaxonomyRpcCaller =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

enum CanonicalTaxonomyRpcFailureKind {
  invalidArgument,
  permissionDenied,
  contractUnavailable,
  contractMismatch,
  previewDisabled,
  malformedResponse,
  remoteFailure,
}

class CanonicalTaxonomyRpcException extends Equatable implements Exception {
  const CanonicalTaxonomyRpcException({
    required this.kind,
    required this.operation,
  });

  final CanonicalTaxonomyRpcFailureKind kind;
  final String operation;

  @override
  List<Object?> get props => [kind, operation];

  @override
  String toString() => 'Canonical taxonomy RPC failed safely ($operation).';
}

abstract interface class CanonicalTaxonomyRpcAdapter {
  String get clientContractVersion;
  String get taxonomyVersion;
  bool get previewRequested;

  Future<TaxonomyBackendContractProof> getCapabilityProof();

  Future<List<CanonicalTaxonomyCategoryDto>> getRoots();

  Future<List<CanonicalTaxonomyCategoryDto>> getChildren(String parentId);

  Future<List<CanonicalTaxonomyCategoryDto>> getDescendants(String categoryId);

  Future<List<CanonicalTaxonomyCategoryDto>> qualifyExactLeaf(
    String categoryId,
  );

  Future<List<CanonicalTaxonomyCategoryDto>> getBreadcrumb(String categoryId);

  Future<List<CanonicalTaxonomyAliasResolutionDto>> resolveAlias(
    String aliasLocator,
  );

  Future<List<CanonicalTaxonomySearchResultDto>> searchTaxonomy(String term);
}

class SupabaseCanonicalTaxonomyRpcAdapter
    implements CanonicalTaxonomyRpcAdapter, CanonicalTaxonomyContractAdapter {
  SupabaseCanonicalTaxonomyRpcAdapter({
    required CanonicalTaxonomyRpcCaller rpcCaller,
    this.clientContractVersion = deployedClientContractVersion,
    this.taxonomyVersion = deployedTaxonomyVersion,
    this.previewRequested = false,
  }) : _rpcCaller = rpcCaller {
    _requiredText(clientContractVersion, capabilitiesRpc);
    _requiredText(taxonomyVersion, capabilitiesRpc);
  }

  factory SupabaseCanonicalTaxonomyRpcAdapter.fromSupabaseService(
    SupabaseService service, {
    bool previewRequested = false,
  }) {
    return SupabaseCanonicalTaxonomyRpcAdapter(
      rpcCaller: (functionName, parameters) =>
          service.client.rpc(functionName, params: parameters),
      previewRequested: previewRequested,
    );
  }

  static const deployedClientContractVersion = 'taxonomy-client-v1';
  static const deployedTaxonomyVersion = 'canonical-v1.0.0';
  static const capabilitiesRpc = 'taxonomy_capabilities_v2';
  static const rootsRpc = 'taxonomy_roots_v2';
  static const childrenRpc = 'taxonomy_children_v2';
  static const descendantsRpc = 'taxonomy_descendants_v2';
  static const exactLeafRpc = 'taxonomy_exact_leaf_v2';
  static const breadcrumbRpc = 'taxonomy_breadcrumb_v2';
  static const resolveAliasRpc = 'taxonomy_resolve_alias_v2';
  static const searchContextRpc = 'taxonomy_search_context_v2';

  final CanonicalTaxonomyRpcCaller _rpcCaller;

  @override
  final String clientContractVersion;

  @override
  final String taxonomyVersion;

  @override
  final bool previewRequested;

  @override
  Future<TaxonomyBackendContractProof> getCapabilityProof() async {
    final payloads = await _invokePayloadList(
      operation: capabilitiesRpc,
      parameters: _capabilityParameters,
    );
    if (payloads.length != 1) {
      throw const CanonicalTaxonomyRpcException(
        kind: CanonicalTaxonomyRpcFailureKind.malformedResponse,
        operation: capabilitiesRpc,
      );
    }
    try {
      return CanonicalTaxonomyCapabilityDto.fromRpcPayload(
        payloads.single,
      ).toProof();
    } on Object {
      throw const CanonicalTaxonomyRpcException(
        kind: CanonicalTaxonomyRpcFailureKind.malformedResponse,
        operation: capabilitiesRpc,
      );
    }
  }

  @override
  Future<List<CanonicalTaxonomyCategoryDto>> getRoots() async {
    final payloads = await getRootsPayload();
    return payloads.map(_categoryDto).toList(growable: false);
  }

  @override
  Future<List<CanonicalTaxonomyCategoryDto>> getChildren(
    String parentId,
  ) async {
    final payloads = await getChildrenPayload(parentId);
    return payloads.map(_categoryDto).toList(growable: false);
  }

  @override
  Future<List<CanonicalTaxonomyCategoryDto>> getDescendants(
    String categoryId,
  ) async {
    final payloads = await getDescendantsPayload(categoryId);
    return payloads.map(_categoryDto).toList(growable: false);
  }

  @override
  Future<List<CanonicalTaxonomyCategoryDto>> qualifyExactLeaf(
    String categoryId,
  ) async {
    final payloads = await getExactLeafPayload(categoryId);
    return payloads.map(_categoryDto).toList(growable: false);
  }

  @override
  Future<List<CanonicalTaxonomyCategoryDto>> getBreadcrumb(
    String categoryId,
  ) async {
    final payloads = await getBreadcrumbPayload(categoryId);
    return payloads.map(_categoryDto).toList(growable: false);
  }

  @override
  Future<List<CanonicalTaxonomyAliasResolutionDto>> resolveAlias(
    String aliasLocator,
  ) async {
    final payloads = await _aliasPayloads(aliasLocator);
    return payloads
        .map(CanonicalTaxonomyAliasResolutionDto.fromRpcPayload)
        .toList(growable: false);
  }

  @override
  Future<List<CanonicalTaxonomySearchResultDto>> searchTaxonomy(
    String term,
  ) async {
    final payloads = await _searchPayloads(term);
    return payloads
        .map(CanonicalTaxonomySearchResultDto.fromRpcPayload)
        .toList(growable: false);
  }

  @override
  Future<List<Map<String, dynamic>>> getRootsPayload() {
    return _nodePayloads(operation: rootsRpc, parameters: _dataParameters);
  }

  @override
  Future<List<Map<String, dynamic>>> getChildrenPayload(String categoryId) {
    return _nodePayloads(
      operation: childrenRpc,
      parameters: {
        'p_parent_id': _requiredUuid(categoryId, childrenRpc),
        ..._dataParameters,
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getDescendantsPayload(String categoryId) {
    return _nodePayloads(
      operation: descendantsRpc,
      parameters: {
        'p_category_id': _requiredUuid(categoryId, descendantsRpc),
        ..._dataParameters,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getExactLeafPayload(String categoryId) {
    return _nodePayloads(
      operation: exactLeafRpc,
      parameters: {
        'p_category_id': _requiredUuid(categoryId, exactLeafRpc),
        ..._dataParameters,
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getBreadcrumbPayload(String categoryId) {
    return _nodePayloads(
      operation: breadcrumbRpc,
      parameters: {
        'p_category_id': _requiredUuid(categoryId, breadcrumbRpc),
        ..._dataParameters,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> resolveAliasPayload(
    TaxonomyAliasLookup lookup,
  ) async {
    final payloads = await _aliasPayloads(lookup.locator);
    if (payloads.length != 1) {
      throw const CanonicalTaxonomyRpcException(
        kind: CanonicalTaxonomyRpcFailureKind.malformedResponse,
        operation: resolveAliasRpc,
      );
    }
    return payloads.single;
  }

  @override
  Future<List<Map<String, dynamic>>> searchTaxonomyPayload(
    TaxonomySearchRequest request,
  ) async {
    final payloads = await _searchPayloads(request.query);
    return payloads.take(request.limit).toList(growable: false);
  }

  Map<String, dynamic> get _capabilityParameters => {
    'p_client_contract_version': clientContractVersion,
    'p_taxonomy_version': taxonomyVersion,
  };

  Map<String, dynamic> get _dataParameters => {
    ..._capabilityParameters,
    'p_preview': previewRequested,
  };

  Future<List<Map<String, dynamic>>> _nodePayloads({
    required String operation,
    required Map<String, dynamic> parameters,
  }) async {
    final payloads = await _invokePayloadList(
      operation: operation,
      parameters: parameters,
    );
    for (final payload in payloads) {
      _categoryDto(payload);
    }
    return payloads;
  }

  CanonicalTaxonomyCategoryDto _categoryDto(Map<String, dynamic> payload) {
    try {
      final dto = CanonicalTaxonomyCategoryDto.fromRpcPayload(payload);
      if (dto.taxonomyVersion != taxonomyVersion) {
        throw const FormatException('Taxonomy version differs.');
      }
      return dto;
    } on Object {
      throw const CanonicalTaxonomyRpcException(
        kind: CanonicalTaxonomyRpcFailureKind.malformedResponse,
        operation: 'taxonomy_node_v2',
      );
    }
  }

  Future<List<Map<String, dynamic>>> _aliasPayloads(String locator) async {
    final payloads = await _invokePayloadList(
      operation: resolveAliasRpc,
      parameters: {
        'p_alias_locator': _requiredText(locator, resolveAliasRpc),
        ..._dataParameters,
      },
    );
    for (final payload in payloads) {
      try {
        CanonicalTaxonomyAliasResolutionDto.fromRpcPayload(payload);
      } on Object {
        throw const CanonicalTaxonomyRpcException(
          kind: CanonicalTaxonomyRpcFailureKind.malformedResponse,
          operation: resolveAliasRpc,
        );
      }
    }
    return payloads;
  }

  Future<List<Map<String, dynamic>>> _searchPayloads(String term) async {
    final payloads = await _invokePayloadList(
      operation: searchContextRpc,
      parameters: {
        'p_term': _requiredText(term, searchContextRpc),
        ..._dataParameters,
      },
    );
    for (final payload in payloads) {
      try {
        CanonicalTaxonomySearchResultDto.fromRpcPayload(payload).toDomain();
      } on Object {
        throw const CanonicalTaxonomyRpcException(
          kind: CanonicalTaxonomyRpcFailureKind.malformedResponse,
          operation: searchContextRpc,
        );
      }
    }
    return payloads;
  }

  Future<List<Map<String, dynamic>>> _invokePayloadList({
    required String operation,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      final response = await _rpcCaller(operation, parameters);
      if (response is! List) {
        throw CanonicalTaxonomyRpcException(
          kind: CanonicalTaxonomyRpcFailureKind.malformedResponse,
          operation: operation,
        );
      }
      return response
          .map((item) {
            if (item is! Map) {
              throw CanonicalTaxonomyRpcException(
                kind: CanonicalTaxonomyRpcFailureKind.malformedResponse,
                operation: operation,
              );
            }
            return Map<String, dynamic>.from(item);
          })
          .toList(growable: false);
    } on CanonicalTaxonomyRpcException {
      rethrow;
    } on PostgrestException catch (error) {
      throw CanonicalTaxonomyRpcException(
        kind: _failureKindForPostgrest(error),
        operation: operation,
      );
    } on Object {
      throw CanonicalTaxonomyRpcException(
        kind: CanonicalTaxonomyRpcFailureKind.remoteFailure,
        operation: operation,
      );
    }
  }

  String _requiredUuid(String value, String operation) {
    final normalized = value.trim();
    if (!_uuidPattern.hasMatch(normalized)) {
      throw CanonicalTaxonomyRpcException(
        kind: CanonicalTaxonomyRpcFailureKind.invalidArgument,
        operation: operation,
      );
    }
    return normalized;
  }

  String _requiredText(String value, String operation) {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized.length > 200) {
      throw CanonicalTaxonomyRpcException(
        kind: CanonicalTaxonomyRpcFailureKind.invalidArgument,
        operation: operation,
      );
    }
    return normalized;
  }

  CanonicalTaxonomyRpcFailureKind _failureKindForPostgrest(
    PostgrestException error,
  ) {
    if (error.code == 'P0001') {
      final message = error.message;
      if (message.contains('W38_PREVIEW_DISABLED')) {
        return CanonicalTaxonomyRpcFailureKind.previewDisabled;
      }
      if (message.contains('W38_CLIENT_CONTRACT_VERSION_MISMATCH') ||
          message.contains('W38_TAXONOMY_VERSION_MISMATCH') ||
          message.contains('W38_RPC_CONTRACT_VERSION_MISMATCH') ||
          message.contains('W38_RPC_GENERATION_MISMATCH')) {
        return CanonicalTaxonomyRpcFailureKind.contractMismatch;
      }
      if (message.contains('W38_')) {
        return CanonicalTaxonomyRpcFailureKind.invalidArgument;
      }
    }
    return switch (error.code) {
      '22P02' => CanonicalTaxonomyRpcFailureKind.invalidArgument,
      '42501' => CanonicalTaxonomyRpcFailureKind.permissionDenied,
      'PGRST202' ||
      '42883' => CanonicalTaxonomyRpcFailureKind.contractUnavailable,
      _ => CanonicalTaxonomyRpcFailureKind.remoteFailure,
    };
  }
}

final _uuidPattern = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);
