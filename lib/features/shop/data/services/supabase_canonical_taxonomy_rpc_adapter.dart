import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/shop/data/models/deployed_canonical_taxonomy_rpc_dto.dart';

typedef CanonicalTaxonomyRpcCaller =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

enum CanonicalTaxonomyRpcFailureKind {
  invalidArgument,
  permissionDenied,
  contractUnavailable,
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
  String get taxonomyVersion;

  Future<List<DeployedTaxonomyNodeRpcDto>> getRoots();

  Future<List<DeployedTaxonomyNodeRpcDto>> getChildren(String parentId);

  Future<List<DeployedTaxonomyDescendantRpcDto>> getDescendants(
    String categoryId,
  );

  Future<List<DeployedTaxonomyExactLeafRpcDto>> qualifyExactLeaf(
    String categoryId,
  );

  Future<List<DeployedTaxonomyBreadcrumbRpcDto>> getBreadcrumb(
    String categoryId,
  );

  Future<List<DeployedTaxonomyResolvedAliasRpcDto>> resolveAlias(
    String aliasSlug,
  );

  Future<List<DeployedTaxonomySearchMatchRpcDto>> searchTaxonomy(String term);
}

class SupabaseCanonicalTaxonomyRpcAdapter
    implements CanonicalTaxonomyRpcAdapter {
  SupabaseCanonicalTaxonomyRpcAdapter({
    required CanonicalTaxonomyRpcCaller rpcCaller,
    this.taxonomyVersion = deployedTaxonomyVersion,
  }) : _rpcCaller = rpcCaller {
    if (taxonomyVersion.trim().isEmpty) {
      throw ArgumentError.value(
        taxonomyVersion,
        'taxonomyVersion',
        'Value cannot be empty.',
      );
    }
  }

  factory SupabaseCanonicalTaxonomyRpcAdapter.fromSupabaseService(
    SupabaseService service,
  ) {
    return SupabaseCanonicalTaxonomyRpcAdapter(
      rpcCaller: (functionName, parameters) =>
          service.client.rpc(functionName, params: parameters),
    );
  }

  static const deployedTaxonomyVersion = 'canonical-v1.0.0';
  static const rootsRpc = 'taxonomy_roots_v1';
  static const childrenRpc = 'taxonomy_children_v1';
  static const descendantsRpc = 'taxonomy_descendants_v1';
  static const exactLeafRpc = 'taxonomy_exact_leaf_v1';
  static const breadcrumbRpc = 'taxonomy_breadcrumb_v1';
  static const resolveAliasRpc = 'taxonomy_resolve_alias_v1';
  static const searchContextRpc = 'taxonomy_search_context_v1';

  final CanonicalTaxonomyRpcCaller _rpcCaller;

  @override
  final String taxonomyVersion;

  @override
  Future<List<DeployedTaxonomyNodeRpcDto>> getRoots() {
    return _invokeList(
      operation: rootsRpc,
      parameters: {'p_taxonomy_version': taxonomyVersion},
      mapper: (json) {
        final dto = DeployedTaxonomyNodeRpcDto.fromJson(json);
        _requireResponseVersion(dto.taxonomyVersion, rootsRpc);
        return dto;
      },
    );
  }

  @override
  Future<List<DeployedTaxonomyNodeRpcDto>> getChildren(String parentId) {
    final normalizedId = _requiredUuid(parentId, childrenRpc);
    return _invokeList(
      operation: childrenRpc,
      parameters: {
        'p_parent_id': normalizedId,
        'p_taxonomy_version': taxonomyVersion,
      },
      mapper: (json) {
        final dto = DeployedTaxonomyNodeRpcDto.fromJson(json);
        _requireResponseVersion(dto.taxonomyVersion, childrenRpc);
        return dto;
      },
    );
  }

  @override
  Future<List<DeployedTaxonomyDescendantRpcDto>> getDescendants(
    String categoryId,
  ) {
    final normalizedId = _requiredUuid(categoryId, descendantsRpc);
    return _invokeList(
      operation: descendantsRpc,
      parameters: {
        'p_category_id': normalizedId,
        'p_taxonomy_version': taxonomyVersion,
      },
      mapper: DeployedTaxonomyDescendantRpcDto.fromJson,
    );
  }

  @override
  Future<List<DeployedTaxonomyExactLeafRpcDto>> qualifyExactLeaf(
    String categoryId,
  ) {
    final normalizedId = _requiredUuid(categoryId, exactLeafRpc);
    return _invokeList(
      operation: exactLeafRpc,
      parameters: {
        'p_category_id': normalizedId,
        'p_taxonomy_version': taxonomyVersion,
      },
      mapper: (json) {
        final dto = DeployedTaxonomyExactLeafRpcDto.fromJson(json);
        _requireResponseVersion(dto.taxonomyVersion, exactLeafRpc);
        return dto;
      },
    );
  }

  @override
  Future<List<DeployedTaxonomyBreadcrumbRpcDto>> getBreadcrumb(
    String categoryId,
  ) {
    final normalizedId = _requiredUuid(categoryId, breadcrumbRpc);
    return _invokeList(
      operation: breadcrumbRpc,
      parameters: {
        'p_category_id': normalizedId,
        'p_taxonomy_version': taxonomyVersion,
      },
      mapper: DeployedTaxonomyBreadcrumbRpcDto.fromJson,
    );
  }

  @override
  Future<List<DeployedTaxonomyResolvedAliasRpcDto>> resolveAlias(
    String aliasSlug,
  ) {
    final normalizedSlug = _requiredText(aliasSlug, resolveAliasRpc);
    return _invokeList(
      operation: resolveAliasRpc,
      parameters: {
        'p_alias_slug': normalizedSlug,
        'p_taxonomy_version': taxonomyVersion,
      },
      mapper: DeployedTaxonomyResolvedAliasRpcDto.fromJson,
    );
  }

  @override
  Future<List<DeployedTaxonomySearchMatchRpcDto>> searchTaxonomy(String term) {
    final normalizedTerm = _requiredText(term, searchContextRpc);
    return _invokeList(
      operation: searchContextRpc,
      parameters: {
        'p_term': normalizedTerm,
        'p_taxonomy_version': taxonomyVersion,
      },
      mapper: DeployedTaxonomySearchMatchRpcDto.fromJson,
    );
  }

  Future<List<T>> _invokeList<T>({
    required String operation,
    required Map<String, dynamic> parameters,
    required T Function(Map<String, dynamic>) mapper,
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
            try {
              return mapper(Map<String, dynamic>.from(item));
            } on CanonicalTaxonomyRpcException {
              rethrow;
            } on Object {
              throw CanonicalTaxonomyRpcException(
                kind: CanonicalTaxonomyRpcFailureKind.malformedResponse,
                operation: operation,
              );
            }
          })
          .toList(growable: false);
    } on CanonicalTaxonomyRpcException {
      rethrow;
    } on PostgrestException catch (error) {
      throw CanonicalTaxonomyRpcException(
        kind: _failureKindForPostgrestCode(error.code),
        operation: operation,
      );
    } on Object {
      throw CanonicalTaxonomyRpcException(
        kind: CanonicalTaxonomyRpcFailureKind.remoteFailure,
        operation: operation,
      );
    }
  }

  void _requireResponseVersion(String value, String operation) {
    if (value != taxonomyVersion) {
      throw CanonicalTaxonomyRpcException(
        kind: CanonicalTaxonomyRpcFailureKind.malformedResponse,
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

  CanonicalTaxonomyRpcFailureKind _failureKindForPostgrestCode(String? code) {
    return switch (code) {
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
