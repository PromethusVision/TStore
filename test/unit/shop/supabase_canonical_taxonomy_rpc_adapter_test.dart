import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/shop/data/repositories/canonical_taxonomy_scoped_product_repository_impl.dart';
import 'package:t_store/features/shop/data/services/supabase_canonical_taxonomy_rpc_adapter.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_alias_resolution.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_product_query_scope.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';

void main() {
  const rootId = '11111111-1111-1111-1111-111111111111';
  const leafId = '22222222-2222-2222-2222-222222222222';
  const version = SupabaseCanonicalTaxonomyRpcAdapter.deployedTaxonomyVersion;

  test('uses exact eight V2 RPC names and strict parameters', () async {
    final calls = <(String, Map<String, dynamic>)>[];
    final adapter = SupabaseCanonicalTaxonomyRpcAdapter(
      previewRequested: true,
      rpcCaller: (name, params) async {
        calls.add((name, params));
        if (name == SupabaseCanonicalTaxonomyRpcAdapter.capabilitiesRpc) {
          return [_capability(previewEnabled: true, previewRootCount: 24)];
        }
        return const <Map<String, dynamic>>[];
      },
    );

    await adapter.getCapabilityProof();
    await adapter.getRoots();
    await adapter.getChildren(rootId);
    await adapter.getDescendants(rootId);
    await adapter.qualifyExactLeaf(leafId);
    await adapter.getBreadcrumb(leafId);
    await adapter.resolveAlias('legacy/telefon');
    await adapter.searchTaxonomy('telefon');

    expect(calls.map((call) => call.$1), [
      'taxonomy_capabilities_v2',
      'taxonomy_roots_v2',
      'taxonomy_children_v2',
      'taxonomy_descendants_v2',
      'taxonomy_exact_leaf_v2',
      'taxonomy_breadcrumb_v2',
      'taxonomy_resolve_alias_v2',
      'taxonomy_search_context_v2',
    ]);
    expect(calls[2].$2, {
      'p_parent_id': rootId,
      'p_client_contract_version': 'taxonomy-client-v1',
      'p_taxonomy_version': version,
      'p_preview': true,
    });
    expect(calls.every((call) => !call.$1.endsWith('_v1')), isTrue);
  });

  test(
    'capability proof distinguishes compatible preview off and on',
    () async {
      var previewEnabled = false;
      final adapter = SupabaseCanonicalTaxonomyRpcAdapter(
        rpcCaller: (_, _) async => [
          _capability(
            previewEnabled: previewEnabled,
            previewRootCount: previewEnabled ? 24 : 0,
          ),
        ],
      );

      var proof = await adapter.getCapabilityProof();
      expect(proof.supportsCanonicalV1, isTrue);
      expect(
        proof.runtimeReadiness,
        TaxonomyBackendRuntimeReadiness.supportedPreviewOff,
      );
      previewEnabled = true;
      proof = await adapter.getCapabilityProof();
      expect(
        proof.runtimeReadiness,
        TaxonomyBackendRuntimeReadiness.supportedPreviewOn,
      );
      expect(proof.canStartDevelopmentAcceptance, isTrue);
    },
  );

  test(
    'strict node, breadcrumb and search payloads retain server truth',
    () async {
      final root = _node(
        id: rootId,
        level: 1,
        hasChildren: true,
        lifecycle: 'active',
      );
      final leaf = _node(
        id: leafId,
        parentId: rootId,
        level: 2,
        hasChildren: false,
        assignable: true,
        lifecycle: 'active',
      );
      final adapter = SupabaseCanonicalTaxonomyRpcAdapter(
        previewRequested: true,
        rpcCaller: (name, _) async => switch (name) {
          'taxonomy_roots_v2' => [root],
          'taxonomy_breadcrumb_v2' => [root, leaf],
          'taxonomy_search_context_v2' => [
            {
              'matched_node': leaf,
              'path': [root, leaf],
              'alias_context': null,
              'taxonomy_version': version,
              'match_kind': 'CANONICAL',
              'matched_via_alias': false,
            },
          ],
          _ => const <Map<String, dynamic>>[],
        },
      );

      expect((await adapter.getRoots()).single.toDomain().isContainer, isTrue);
      expect(
        (await adapter.getBreadcrumb(leafId)).last.toDomain().isLeaf,
        isTrue,
      );
      final search = (await adapter.searchTaxonomy(
        'telefon',
      )).single.toDomain();
      expect(search.breadcrumb.items, hasLength(2));
      expect(search.matchedCategory.id, leafId);
    },
  );

  test('preserves every explicit alias state and never infers empty', () async {
    for (final state in TaxonomyAliasResolutionState.values) {
      final target = state == TaxonomyAliasResolutionState.resolved
          ? leafId
          : null;
      final count = switch (state) {
        TaxonomyAliasResolutionState.resolved => 1,
        TaxonomyAliasResolutionState.ambiguous => 2,
        _ => 0,
      };
      final adapter = SupabaseCanonicalTaxonomyRpcAdapter(
        previewRequested: true,
        rpcCaller: (_, _) async => [
          {
            'alias_locator': 'legacy/telefon',
            'resolution_state': state.name.toUpperCase(),
            'direct_target_category_id': target,
            'taxonomy_version': version,
            'alias_kind': 'LEGACY',
            'matched_via_alias': true,
            'target_count': count,
          },
        ],
      );
      expect(
        (await adapter.resolveAlias('legacy/telefon')).single.toDomain().state,
        state,
      );
    }

    final empty = SupabaseCanonicalTaxonomyRpcAdapter(
      rpcCaller: (_, _) async => const <Map<String, dynamic>>[],
    );
    expect(await empty.resolveAlias('missing'), isEmpty);
    await expectLater(
      empty.resolveAliasPayload(TaxonomyAliasLookup(locator: 'missing')),
      throwsA(
        isA<CanonicalTaxonomyRpcException>().having(
          (error) => error.kind,
          'kind',
          CanonicalTaxonomyRpcFailureKind.malformedResponse,
        ),
      ),
    );
  });

  test(
    'exact leaf accepts server-empty as no qualifying product scope',
    () async {
      final adapter = SupabaseCanonicalTaxonomyRpcAdapter(
        rpcCaller: (_, _) async => const <Map<String, dynamic>>[],
      );

      expect(await adapter.qualifyExactLeaf(leafId), isEmpty);
    },
  );

  test(
    'product scope resolver uses only server-qualified V2 results',
    () async {
      var exactPayload = const <Map<String, dynamic>>[];
      final eligible = _node(
        id: leafId,
        parentId: rootId,
        level: 4,
        hasChildren: false,
        assignable: true,
        lifecycle: 'active',
      );
      final adapter = SupabaseCanonicalTaxonomyRpcAdapter(
        rpcCaller: (name, _) async => switch (name) {
          'taxonomy_exact_leaf_v2' => exactPayload,
          'taxonomy_descendants_v2' => [eligible, eligible],
          _ => const <Map<String, dynamic>>[],
        },
      );
      final resolver = CanonicalTaxonomyProductScopeResolver(adapter);

      expect(
        await resolver.resolveCategoryIds(
          TaxonomyProductQueryScope.exactLeaf(categoryId: leafId),
        ),
        isEmpty,
      );
      exactPayload = [eligible];
      expect(
        await resolver.resolveCategoryIds(
          TaxonomyProductQueryScope.exactLeaf(categoryId: leafId),
        ),
        [leafId],
      );
      expect(
        await resolver.resolveCategoryIds(
          TaxonomyProductQueryScope.descendants(categoryId: rootId),
        ),
        [leafId],
      );
    },
  );

  test(
    'rejects missing lifecycle or policy metadata in node payload',
    () async {
      for (final missing in ['lifecycle_state', 'policy_class']) {
        final payload = _node(id: rootId, level: 1, hasChildren: true)
          ..remove(missing);
        final adapter = SupabaseCanonicalTaxonomyRpcAdapter(
          rpcCaller: (_, _) async => [payload],
        );
        await expectLater(
          adapter.getRoots(),
          throwsA(
            isA<CanonicalTaxonomyRpcException>().having(
              (error) => error.kind,
              'kind',
              CanonicalTaxonomyRpcFailureKind.malformedResponse,
            ),
          ),
        );
      }
    },
  );

  test('rejects invalid UUID locally before any remote call', () async {
    var called = false;
    final adapter = SupabaseCanonicalTaxonomyRpcAdapter(
      rpcCaller: (_, _) async {
        called = true;
        return const [];
      },
    );

    await expectLater(
      adapter.getChildren('not-a-uuid'),
      throwsA(
        isA<CanonicalTaxonomyRpcException>().having(
          (error) => error.kind,
          'kind',
          CanonicalTaxonomyRpcFailureKind.invalidArgument,
        ),
      ),
    );
    expect(called, isFalse);
  });

  test(
    'maps preview and version failures without leaking remote detail',
    () async {
      Future<void> expectKind(
        String message,
        CanonicalTaxonomyRpcFailureKind expected,
      ) async {
        final adapter = SupabaseCanonicalTaxonomyRpcAdapter(
          rpcCaller: (_, _) async =>
              throw PostgrestException(message: message, code: 'P0001'),
        );
        try {
          await adapter.getRoots();
          fail('Expected safe RPC exception.');
        } on CanonicalTaxonomyRpcException catch (error) {
          expect(error.kind, expected);
          expect(error.toString(), isNot(contains(message)));
        }
      }

      await expectKind(
        'W38_PREVIEW_DISABLED private details',
        CanonicalTaxonomyRpcFailureKind.previewDisabled,
      );
      await expectKind(
        'W38_TAXONOMY_VERSION_MISMATCH private details',
        CanonicalTaxonomyRpcFailureKind.contractMismatch,
      );
    },
  );
}

Map<String, dynamic> _node({
  required String id,
  required int level,
  required bool hasChildren,
  String? parentId,
  bool assignable = false,
  String policyClass = 'NORMAL',
  String reviewStatus = 'not_required',
  String lifecycle = 'staged',
}) {
  return {
    'id': id,
    'parent_id': parentId,
    'name': 'Canonical node',
    'slug': 'canonical-node',
    'level': level,
    'lifecycle_state': lifecycle,
    'is_assignable': assignable,
    'policy_class': policyClass,
    'professional_review_status': reviewStatus,
    'taxonomy_version':
        SupabaseCanonicalTaxonomyRpcAdapter.deployedTaxonomyVersion,
    'has_children': hasChildren,
    'sort_order': 1,
    'is_public_active': false,
    'is_pilot_active': false,
    'preview_context': true,
  };
}

Map<String, dynamic> _capability({
  required bool previewEnabled,
  required int previewRootCount,
}) {
  return {
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
    'preview_enabled': previewEnabled,
    'lifecycle_metadata': true,
    'policy_metadata': true,
    'alias_state_metadata': true,
    'path_metadata': true,
    'public_active_root_count': 0,
    'pilot_active_root_count': 0,
    'preview_root_count': previewRootCount,
    'product_scope_contract': 'exact-leaf-visible-assignable-policy-eligible',
    'product_scope_requires_assignable': true,
    'product_scope_policy_fail_closed': true,
  };
}
