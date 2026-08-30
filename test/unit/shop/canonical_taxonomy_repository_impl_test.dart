import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/shop/data/repositories/canonical_taxonomy_repository_impl.dart';
import 'package:t_store/features/shop/data/services/canonical_taxonomy_contract_adapter.dart';
import 'package:t_store/features/shop/domain/repositories/canonical_taxonomy_repository.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_alias_resolution.dart';

void main() {
  late _FakeContractAdapter adapter;
  late CanonicalTaxonomyRepositoryImpl repository;

  setUp(() {
    adapter = _FakeContractAdapter();
    repository = CanonicalTaxonomyRepositoryImpl(adapter: adapter);
  });

  test('maps roots, children and descendants through strict DTOs', () async {
    adapter.roots = [
      _payload(id: 'root', level: 1, hasChildren: true, assignable: false),
    ];
    adapter.children = [
      _payload(
        id: 'leaf',
        parentId: 'root',
        level: 2,
        hasChildren: false,
        assignable: true,
      ),
    ];
    adapter.descendants = adapter.children;

    final roots = await repository.getRoots();
    final children = await repository.getChildren(' root ');
    final descendants = await repository.getDescendants('root');

    expect(roots.getOrElse(() => const []).single.isRoot, isTrue);
    expect(children.getOrElse(() => const []).single.canAssignProducts, isTrue);
    expect(descendants.getOrElse(() => const []).single.id, 'leaf');
    expect(adapter.lastCategoryId, 'root');
  });

  test('builds a validated breadcrumb from the adapter path', () async {
    adapter.breadcrumb = [
      _payload(id: 'root', level: 1, hasChildren: true, assignable: false),
      _payload(
        id: 'leaf',
        parentId: 'root',
        level: 2,
        hasChildren: false,
        assignable: true,
      ),
    ];

    final result = await repository.getBreadcrumb('leaf');

    expect(
      result.getOrElse(() => throw StateError('expected path')).items,
      hasLength(2),
    );
  });

  test(
    'maps alias and server search payloads without remote assumptions',
    () async {
      final root = _payload(
        id: 'root',
        level: 1,
        hasChildren: true,
        assignable: false,
      );
      final leaf = _payload(
        id: 'leaf',
        parentId: 'root',
        level: 2,
        hasChildren: false,
        assignable: true,
      );
      adapter.alias = {
        'alias_locator': 'legacy/leaf',
        'resolution_state': 'RESOLVED',
        'direct_target_category_id': 'leaf',
        'taxonomy_version': 'canonical-v1.0.0',
        'alias_kind': 'LEGACY',
        'matched_via_alias': true,
        'target_count': 1,
      };
      adapter.search = [
        {
          'matched_node': leaf,
          'path': [root, leaf],
          'taxonomy_version': 'canonical-v1.0.0',
          'alias_context': null,
          'match_kind': 'CANONICAL',
          'matched_via_alias': false,
        },
      ];

      final alias = await repository.resolveAlias(
        TaxonomyAliasLookup(locator: 'legacy/leaf'),
      );
      final search = await repository.searchTaxonomy(
        TaxonomySearchRequest(query: 'leaf'),
      );

      expect(
        alias.getOrElse(() => throw StateError('expected alias')).canRedirect,
        isTrue,
      );
      expect(
        search.getOrElse(() => const []).single.matchedCategory.id,
        'leaf',
      );
    },
  );

  test('malformed payload and empty id fail closed as Left', () async {
    adapter.roots = [
      _payload(id: 'root', level: 1, hasChildren: true, assignable: false)
        ..remove('taxonomy_version'),
    ];

    expect((await repository.getRoots()).isLeft(), isTrue);
    expect((await repository.getChildren('   ')).isLeft(), isTrue);
    expect(adapter.childrenCallCount, 0);
  });
}

class _FakeContractAdapter implements CanonicalTaxonomyContractAdapter {
  List<Map<String, dynamic>> roots = [];
  List<Map<String, dynamic>> children = [];
  List<Map<String, dynamic>> descendants = [];
  List<Map<String, dynamic>> breadcrumb = [];
  Map<String, dynamic> alias = {};
  List<Map<String, dynamic>> search = [];
  int childrenCallCount = 0;
  String? lastCategoryId;

  @override
  Future<List<Map<String, dynamic>>> getRootsPayload() async => roots;

  @override
  Future<List<Map<String, dynamic>>> getChildrenPayload(
    String categoryId,
  ) async {
    childrenCallCount++;
    lastCategoryId = categoryId;
    return children;
  }

  @override
  Future<List<Map<String, dynamic>>> getDescendantsPayload(
    String categoryId,
  ) async {
    lastCategoryId = categoryId;
    return descendants;
  }

  @override
  Future<List<Map<String, dynamic>>> getBreadcrumbPayload(
    String categoryId,
  ) async {
    lastCategoryId = categoryId;
    return breadcrumb;
  }

  @override
  Future<Map<String, dynamic>> resolveAliasPayload(
    TaxonomyAliasLookup lookup,
  ) async {
    return alias;
  }

  @override
  Future<List<Map<String, dynamic>>> searchTaxonomyPayload(
    TaxonomySearchRequest request,
  ) async {
    return search;
  }
}

Map<String, dynamic> _payload({
  required String id,
  required int level,
  required bool hasChildren,
  required bool assignable,
  String? parentId,
}) {
  return {
    'id': id,
    'parent_id': parentId,
    'name': id,
    'slug': id,
    'level': level,
    'lifecycle_state': 'active',
    'is_assignable': assignable,
    'policy_class': 'NORMAL',
    'professional_review_status': 'not_required',
    'taxonomy_version': 'canonical-v1.0.0',
    'has_children': hasChildren,
    'sort_order': 0,
    'is_public_active': true,
    'is_pilot_active': false,
    'preview_context': false,
  };
}
