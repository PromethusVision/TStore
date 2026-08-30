import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/shop/data/services/supabase_canonical_taxonomy_rpc_adapter.dart';

void main() {
  const rootId = '11111111-1111-1111-1111-111111111111';
  const childId = '22222222-2222-2222-2222-222222222222';
  const version = SupabaseCanonicalTaxonomyRpcAdapter.deployedTaxonomyVersion;

  test(
    'uses exact deployed RPC names, parameters, and typed node shape',
    () async {
      late String functionName;
      late Map<String, dynamic> parameters;
      final adapter = SupabaseCanonicalTaxonomyRpcAdapter(
        rpcCaller: (name, params) async {
          functionName = name;
          parameters = params;
          return [
            {
              'id': childId,
              'parent_id': rootId,
              'name': 'Telefon',
              'slug': 'telefon',
              'level': 2,
              'is_assignable': true,
              'sort_order': 3,
              'taxonomy_version': version,
            },
          ];
        },
      );

      final result = await adapter.getChildren(rootId);

      expect(functionName, 'taxonomy_children_v1');
      expect(parameters, {
        'p_parent_id': rootId,
        'p_taxonomy_version': version,
      });
      expect(result.single.id, childId);
      expect(result.single.isAssignable, isTrue);
    },
  );

  test(
    'maps all seven deployed operations without recursive fan-out',
    () async {
      final calls = <String>[];
      final adapter = SupabaseCanonicalTaxonomyRpcAdapter(
        rpcCaller: (name, params) async {
          calls.add(name);
          return const <Map<String, dynamic>>[];
        },
      );

      await adapter.getRoots();
      await adapter.getChildren(rootId);
      await adapter.getDescendants(rootId);
      await adapter.qualifyExactLeaf(rootId);
      await adapter.getBreadcrumb(rootId);
      await adapter.resolveAlias('telefon');
      await adapter.searchTaxonomy('telefon');

      expect(calls, [
        'taxonomy_roots_v1',
        'taxonomy_children_v1',
        'taxonomy_descendants_v1',
        'taxonomy_exact_leaf_v1',
        'taxonomy_breadcrumb_v1',
        'taxonomy_resolve_alias_v1',
        'taxonomy_search_context_v1',
      ]);
    },
  );

  test(
    'empty alias response remains empty instead of guessing a state',
    () async {
      final adapter = SupabaseCanonicalTaxonomyRpcAdapter(
        rpcCaller: (_, _) async => const <Map<String, dynamic>>[],
      );

      expect(await adapter.resolveAlias('ambiguous-alias'), isEmpty);
    },
  );

  test(
    'maps every reduced deployed response shape without enrichment',
    () async {
      final adapter = SupabaseCanonicalTaxonomyRpcAdapter(
        rpcCaller: (name, _) async => switch (name) {
          'taxonomy_descendants_v1' => [
            {'id': childId, 'level': 2, 'is_assignable': true},
          ],
          'taxonomy_exact_leaf_v1' => [
            {
              'id': childId,
              'name': 'Telefon',
              'slug': 'telefon',
              'taxonomy_version': version,
            },
          ],
          'taxonomy_breadcrumb_v1' => [
            {
              'id': rootId,
              'parent_id': null,
              'name': 'Elektronik',
              'slug': 'elektronik',
              'level': 1,
            },
          ],
          'taxonomy_resolve_alias_v1' => [
            {
              'category_id': childId,
              'canonical_slug': 'telefon',
              'resolution_state': 'RESOLVED',
            },
          ],
          'taxonomy_search_context_v1' => [
            {
              'category_id': childId,
              'name': 'Telefon',
              'slug': 'telefon',
              'match_kind': 'CANONICAL',
            },
          ],
          _ => const <Map<String, dynamic>>[],
        },
      );

      expect((await adapter.getDescendants(rootId)).single.level, 2);
      expect((await adapter.qualifyExactLeaf(childId)).single.slug, 'telefon');
      expect((await adapter.getBreadcrumb(childId)).single.parentId, isNull);
      expect(
        (await adapter.resolveAlias('cep-telefonu')).single.resolutionState,
        'RESOLVED',
      );
      expect(
        (await adapter.searchTaxonomy('telefon')).single.matchKind,
        'CANONICAL',
      );
    },
  );

  test('rejects an invalid UUID locally without calling the backend', () async {
    var called = false;
    final adapter = SupabaseCanonicalTaxonomyRpcAdapter(
      rpcCaller: (_, _) async {
        called = true;
        return const [];
      },
    );

    expect(
      () => adapter.getChildren('not-a-uuid'),
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

  test('rejects mismatched response taxonomy version', () async {
    final adapter = SupabaseCanonicalTaxonomyRpcAdapter(
      rpcCaller: (_, _) async => [
        {
          'id': rootId,
          'parent_id': null,
          'name': 'Elektronik',
          'slug': 'elektronik',
          'level': 1,
          'is_assignable': false,
          'sort_order': 1,
          'taxonomy_version': 'other-version',
        },
      ],
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
  });

  test(
    'maps PostgREST error codes deterministically without leaking details',
    () async {
      final adapter = SupabaseCanonicalTaxonomyRpcAdapter(
        rpcCaller: (_, _) async => throw const PostgrestException(
          message: 'raw backend detail',
          code: '42501',
        ),
      );

      try {
        await adapter.getRoots();
        fail('Expected a safe RPC exception.');
      } on CanonicalTaxonomyRpcException catch (error) {
        expect(error.kind, CanonicalTaxonomyRpcFailureKind.permissionDenied);
        expect(error.toString(), isNot(contains('raw backend detail')));
      }
    },
  );
}
