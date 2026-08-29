import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_navigation.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_search_context.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_product_query_scope.dart';

void main() {
  group('TaxonomyCategoryHierarchy variable depth', () {
    test('supports L2, L3 and L4 leaves with mixed-depth siblings', () {
      final hierarchy = _mixedDepthHierarchy();

      expect(hierarchy.roots.map((node) => node.id), ['root']);
      expect(hierarchy.maxDepth, 4);
      expect(hierarchy.childrenOf('root').map((node) => node.id), [
        'l2-leaf',
        'l2-container',
      ]);
      expect(hierarchy.descendantsOf('root').map((node) => node.id), [
        'l2-leaf',
        'l2-container',
        'l3-leaf',
        'l3-container',
        'l4-leaf',
      ]);
      expect(hierarchy.nodeById('l2-leaf')?.canAssignProducts, isTrue);
      expect(hierarchy.nodeById('l3-leaf')?.canAssignProducts, isTrue);
      expect(hierarchy.nodeById('l4-leaf')?.canAssignProducts, isTrue);
    });

    test('builds a contiguous variable-depth breadcrumb through L4', () {
      final hierarchy = _mixedDepthHierarchy();
      final breadcrumb = hierarchy.breadcrumbFor('l4-leaf');

      expect(breadcrumb.items.map((item) => item.level), [
        TaxonomyCategoryLevel.l1,
        TaxonomyCategoryLevel.l2,
        TaxonomyCategoryLevel.l3,
        TaxonomyCategoryLevel.l4,
      ]);
      expect(
        breadcrumb.fullLabel,
        'Beyaz Eşya & Ev Aletleri > Elektrikli Kişisel Bakım Cihazları > '
        'Saç Bakım Cihazları > Saç Düzleştirici & Şekillendiriciler',
      );
      expect(breadcrumb.current.categoryId, 'l4-leaf');
    });

    test('returns active roots in deterministic canonical order', () {
      final hierarchy = TaxonomyCategoryHierarchy.fromNodes([
        _node(
          id: 'second',
          name: 'Giyim & Moda',
          level: TaxonomyCategoryLevel.l1,
          kind: TaxonomyCategoryKind.container,
          sortOrder: 2,
        ),
        _node(
          id: 'staged',
          name: 'Staged root',
          level: TaxonomyCategoryLevel.l1,
          kind: TaxonomyCategoryKind.container,
          lifecycle: TaxonomyCategoryLifecycle.staged,
          sortOrder: 0,
        ),
        _node(
          id: 'first',
          name: 'Gıda & İçecek',
          level: TaxonomyCategoryLevel.l1,
          kind: TaxonomyCategoryKind.container,
          sortOrder: 1,
        ),
      ]);

      expect(hierarchy.activeRoots.map((node) => node.id), ['first', 'second']);
    });

    test(
      'accepts all 24 owner-final L1 names without name-derived identity',
      () {
        const names = [
          'Gıda & İçecek',
          'Giyim & Moda',
          'Ayakkabı',
          'Çanta & Aksesuar',
          'Elektronik',
          'Bilgisayar & Tablet',
          'Beyaz Eşya & Ev Aletleri',
          'Ev & Yaşam',
          'Züccaciye & Mutfak',
          'Yapı, Hırdavat & Tesisat',
          'Otomotiv & Motosiklet',
          'Kozmetik & Kişisel Bakım',
          'Anne & Bebek',
          'Oyuncak & Hobi',
          'Müzik & Enstrüman',
          'Spor & Outdoor',
          'Kitap',
          'Kırtasiye & Ofis',
          'Evcil Hayvan Ürünleri',
          'Gözlük & Optik',
          'Saat & Takı',
          'Sağlık & Medikal',
          'Çiçek & Bahçe',
          'Hediyelik & Parti',
        ];
        final hierarchy = TaxonomyCategoryHierarchy.fromNodes([
          for (var index = 0; index < names.length; index++)
            _node(
              id: 'stable-node-${index + 1}',
              name: names[index],
              level: TaxonomyCategoryLevel.l1,
              kind: TaxonomyCategoryKind.container,
              sortOrder: index + 1,
            ),
        ]);

        expect(hierarchy.activeRoots, hasLength(24));
        expect(hierarchy.activeRoots.map((node) => node.displayName), names);
        expect(
          hierarchy.activeRoots.map((node) => node.id).toSet(),
          hasLength(24),
        );
      },
    );

    test('preserves the 48-character lower-node fixture', () {
      const longName = 'Sürpriz & Rastgele İçerikli Koleksiyon Paketleri';
      final node = _node(
        id: 'long-leaf',
        name: longName,
        parentId: 'parent',
        level: TaxonomyCategoryLevel.l3,
        kind: TaxonomyCategoryKind.leaf,
        assignable: true,
      );

      expect(longName.length, 48);
      expect(node.displayName, longName);
    });
  });

  group('TaxonomyCategoryHierarchy invariants', () {
    test('rejects an L1 leaf', () {
      expect(
        () => _node(
          id: 'invalid',
          name: 'Invalid',
          level: TaxonomyCategoryLevel.l1,
          kind: TaxonomyCategoryKind.leaf,
          assignable: true,
        ),
        throwsArgumentError,
      );
    });

    test('rejects an L4 container', () {
      expect(
        () => _node(
          id: 'invalid',
          name: 'Invalid',
          parentId: 'parent',
          level: TaxonomyCategoryLevel.l4,
          kind: TaxonomyCategoryKind.container,
        ),
        throwsArgumentError,
      );
    });

    test('rejects assignability for a container or inactive leaf', () {
      expect(
        () => _node(
          id: 'container',
          name: 'Container',
          level: TaxonomyCategoryLevel.l1,
          kind: TaxonomyCategoryKind.container,
          assignable: true,
        ),
        throwsArgumentError,
      );
      expect(
        () => _node(
          id: 'retired',
          name: 'Retired',
          parentId: 'parent',
          level: TaxonomyCategoryLevel.l2,
          kind: TaxonomyCategoryKind.leaf,
          lifecycle: TaxonomyCategoryLifecycle.retired,
          assignable: true,
        ),
        throwsArgumentError,
      );
    });

    test('rejects duplicate, missing and non-contiguous parents', () {
      final root = _node(
        id: 'root',
        name: 'Root',
        level: TaxonomyCategoryLevel.l1,
        kind: TaxonomyCategoryKind.container,
      );
      expect(
        () => TaxonomyCategoryHierarchy.fromNodes([root, root]),
        throwsArgumentError,
      );
      expect(
        () => TaxonomyCategoryHierarchy.fromNodes([
          _node(
            id: 'orphan',
            name: 'Orphan',
            parentId: 'missing',
            level: TaxonomyCategoryLevel.l2,
            kind: TaxonomyCategoryKind.leaf,
            assignable: true,
          ),
        ]),
        throwsArgumentError,
      );
      expect(
        () => TaxonomyCategoryHierarchy.fromNodes([
          root,
          _node(
            id: 'skipped',
            name: 'Skipped',
            parentId: root.id,
            level: TaxonomyCategoryLevel.l3,
            kind: TaxonomyCategoryKind.leaf,
            assignable: true,
          ),
        ]),
        throwsArgumentError,
      );
    });

    test('rejects a child attached to a leaf', () {
      final root = _node(
        id: 'root',
        name: 'Root',
        level: TaxonomyCategoryLevel.l1,
        kind: TaxonomyCategoryKind.container,
      );
      final leaf = _node(
        id: 'leaf',
        name: 'Leaf',
        parentId: root.id,
        level: TaxonomyCategoryLevel.l2,
        kind: TaxonomyCategoryKind.leaf,
        assignable: true,
      );
      expect(
        () => TaxonomyCategoryHierarchy.fromNodes([
          root,
          leaf,
          _node(
            id: 'child',
            name: 'Child',
            parentId: leaf.id,
            level: TaxonomyCategoryLevel.l3,
            kind: TaxonomyCategoryKind.leaf,
            assignable: true,
          ),
        ]),
        throwsArgumentError,
      );
    });
  });

  group('taxonomy navigation and query scope', () {
    test(
      'container navigates deeper and assignable leaf opens exact listing',
      () {
        final hierarchy = _mixedDepthHierarchy();
        final containerDecision =
            TaxonomyCategoryNavigationDecision.forCanonicalNode(
              hierarchy.nodeById('l2-container')!,
            );
        final leafDecision =
            TaxonomyCategoryNavigationDecision.forCanonicalNode(
              hierarchy.nodeById('l3-leaf')!,
            );

        expect(
          containerDecision.action,
          TaxonomyCategoryNavigationAction.navigateDeeper,
        );
        expect(containerDecision.productQueryScope, isNull);
        expect(
          leafDecision.action,
          TaxonomyCategoryNavigationAction.openProductListing,
        );
        expect(
          leafDecision.productQueryScope?.kind,
          TaxonomyProductQueryScopeKind.exactLeaf,
        );
        expect(
          leafDecision.productQueryScope?.hasCanonicalHierarchyEvidence,
          isTrue,
        );
      },
    );

    test('staged, retired and non-assignable leaves fail closed', () {
      for (final node in [
        _node(
          id: 'staged',
          name: 'Staged',
          parentId: 'root',
          level: TaxonomyCategoryLevel.l2,
          kind: TaxonomyCategoryKind.leaf,
          lifecycle: TaxonomyCategoryLifecycle.staged,
        ),
        _node(
          id: 'retired',
          name: 'Retired',
          parentId: 'root',
          level: TaxonomyCategoryLevel.l2,
          kind: TaxonomyCategoryKind.leaf,
          lifecycle: TaxonomyCategoryLifecycle.retired,
        ),
        _node(
          id: 'policy-gated',
          name: 'Policy gated',
          parentId: 'root',
          level: TaxonomyCategoryLevel.l2,
          kind: TaxonomyCategoryKind.leaf,
        ),
      ]) {
        final decision = TaxonomyCategoryNavigationDecision.forCanonicalNode(
          node,
        );
        expect(decision.action, TaxonomyCategoryNavigationAction.unavailable);
        expect(decision.productQueryScope, isNull);
      }
    });

    test(
      'current runtime fallback preserves the exact category listing path',
      () {
        const legacyCategory = CategoryEntity(
          id: ' legacy-category ',
          name: 'Market',
        );
        final decision = TaxonomyCategoryNavigationDecision.resolve(
          currentCategory: legacyCategory,
        );

        expect(
          decision.action,
          TaxonomyCategoryNavigationAction.openProductListing,
        );
        expect(
          decision.evidence,
          TaxonomyCategoryNavigationEvidence.currentRuntimeFallback,
        );
        expect(decision.productQueryScope?.categoryId, 'legacy-category');
        expect(
          decision.productQueryScope?.kind,
          TaxonomyProductQueryScopeKind.exactLeaf,
        );
        expect(
          decision.productQueryScope?.hasCanonicalHierarchyEvidence,
          isFalse,
        );
      },
    );

    test('canonical and legacy ids cannot be silently mismatched', () {
      const legacyCategory = CategoryEntity(id: 'legacy', name: 'Market');
      final canonicalNode = _node(
        id: 'canonical',
        name: 'Gıda & İçecek',
        level: TaxonomyCategoryLevel.l1,
        kind: TaxonomyCategoryKind.container,
      );

      expect(
        () => TaxonomyCategoryNavigationDecision.resolve(
          currentCategory: legacyCategory,
          canonicalNode: canonicalNode,
        ),
        throwsArgumentError,
      );
    });

    test('EXACT_LEAF and DESCENDANTS query scopes remain explicit', () {
      final exact = TaxonomyProductQueryScope.exactLeaf(categoryId: 'leaf-id');
      final descendants = TaxonomyProductQueryScope.descendants(
        categoryId: 'container-id',
      );

      expect(exact.kind, TaxonomyProductQueryScopeKind.exactLeaf);
      expect(descendants.kind, TaxonomyProductQueryScopeKind.descendants);
      expect(exact, isNot(descendants));
    });
  });

  test(
    'search context carries path and leaf/container navigation evidence',
    () {
      final hierarchy = _mixedDepthHierarchy();
      final leafContext = TaxonomyCategorySearchContext.fromHierarchy(
        hierarchy: hierarchy,
        matchedCategoryId: 'l4-leaf',
      );
      final containerContext = TaxonomyCategorySearchContext.fromHierarchy(
        hierarchy: hierarchy,
        matchedCategoryId: 'l2-container',
      );

      expect(leafContext.isLeaf, isTrue);
      expect(leafContext.canonicalPathLabel, contains('Saç Bakım Cihazları'));
      expect(
        leafContext.navigationDecision.action,
        TaxonomyCategoryNavigationAction.openProductListing,
      );
      expect(containerContext.isContainer, isTrue);
      expect(
        containerContext.navigationDecision.action,
        TaxonomyCategoryNavigationAction.navigateDeeper,
      );
    },
  );
}

TaxonomyCategoryHierarchy _mixedDepthHierarchy() {
  return TaxonomyCategoryHierarchy.fromNodes([
    _node(
      id: 'root',
      name: 'Beyaz Eşya & Ev Aletleri',
      level: TaxonomyCategoryLevel.l1,
      kind: TaxonomyCategoryKind.container,
    ),
    _node(
      id: 'l2-leaf',
      name: 'Bağımsız L2 Leaf',
      parentId: 'root',
      level: TaxonomyCategoryLevel.l2,
      kind: TaxonomyCategoryKind.leaf,
      assignable: true,
      sortOrder: 1,
    ),
    _node(
      id: 'l2-container',
      name: 'Elektrikli Kişisel Bakım Cihazları',
      parentId: 'root',
      level: TaxonomyCategoryLevel.l2,
      kind: TaxonomyCategoryKind.container,
      sortOrder: 2,
    ),
    _node(
      id: 'l3-leaf',
      name: 'Bağımsız L3 Leaf',
      parentId: 'l2-container',
      level: TaxonomyCategoryLevel.l3,
      kind: TaxonomyCategoryKind.leaf,
      assignable: true,
      sortOrder: 1,
    ),
    _node(
      id: 'l3-container',
      name: 'Saç Bakım Cihazları',
      parentId: 'l2-container',
      level: TaxonomyCategoryLevel.l3,
      kind: TaxonomyCategoryKind.container,
      sortOrder: 2,
    ),
    _node(
      id: 'l4-leaf',
      name: 'Saç Düzleştirici & Şekillendiriciler',
      parentId: 'l3-container',
      level: TaxonomyCategoryLevel.l4,
      kind: TaxonomyCategoryKind.leaf,
      assignable: true,
    ),
  ]);
}

TaxonomyCategoryNode _node({
  required String id,
  required String name,
  required TaxonomyCategoryLevel level,
  required TaxonomyCategoryKind kind,
  String? parentId,
  TaxonomyCategoryLifecycle lifecycle = TaxonomyCategoryLifecycle.active,
  bool assignable = false,
  int sortOrder = 0,
}) {
  return TaxonomyCategoryNode(
    id: id,
    displayName: name,
    parentId: parentId,
    level: level,
    kind: kind,
    lifecycle: lifecycle,
    assignability: assignable
        ? TaxonomyCategoryAssignability.assignable
        : TaxonomyCategoryAssignability.notAssignable,
    sortOrder: sortOrder,
    taxonomyVersion: 'canonical-v1-test',
  );
}
