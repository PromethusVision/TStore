import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_product_query_scope.dart';
import 'package:t_store/features/shop/presentation/views/taxonomy_browse_view.dart';

import '../../helpers/canonical_taxonomy_test_support.dart';

void main() {
  testWidgets(
    'L2-L4 recursive navigation, back stack, long name and 122-char path work',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final fixture = _BrowseFixture();
      String? openedPath;
      TaxonomyProductQueryScope? openedScope;

      await tester.pumpWidget(
        MaterialApp(
          home: TaxonomyBrowseView(
            category: fixture.root,
            repository: fixture.repository,
            capability: canonicalCapability(),
            leafDestinationBuilder: (category, breadcrumb, scope) {
              openedPath = breadcrumb.fullLabel;
              openedScope = scope;
              return Scaffold(
                body: Center(
                  child: Text(
                    'Leaf: ${category.id}',
                    key: const Key('taxonomy-leaf-destination'),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('taxonomy-child-long-leaf')), findsOneWidget);
      expect(_longNodeName.length, 48);
      expect(
        tester
            .widget<ListTile>(
              find.byKey(const Key('taxonomy-child-regulated-leaf')),
            )
            .onTap,
        isNull,
      );

      await tester.tap(find.byKey(const Key('taxonomy-child-l2')));
      await tester.pumpAndSettle();
      expect(find.text(fixture.l2.displayName), findsWidgets);

      await tester.tap(find.byKey(const Key('taxonomy-child-l3')));
      await tester.pumpAndSettle();
      expect(find.text(fixture.l3.displayName), findsWidgets);

      await tester.tap(find.byKey(const Key('taxonomy-child-l4')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('taxonomy-leaf-destination')),
        findsOneWidget,
      );
      expect(openedPath?.length, 122);
      expect(openedScope?.kind, TaxonomyProductQueryScopeKind.exactLeaf);
      expect(openedScope?.categoryId, 'l4');
      expect(tester.takeException(), isNull);

      Navigator.of(
        tester.element(find.byKey(const Key('taxonomy-leaf-destination'))),
      ).pop();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('taxonomy-child-l4')), findsOneWidget);

      await tester.tap(find.byKey(const Key('taxonomy-browse-back')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('taxonomy-child-l3')), findsOneWidget);

      await tester.tap(find.byKey(const Key('taxonomy-browse-back')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('taxonomy-child-l2')), findsOneWidget);
    },
  );
}

const _longNodeName = 'Sürpriz & Rastgele İçerikli Koleksiyon Paketleri';

class _BrowseFixture {
  _BrowseFixture() {
    repository.childrenResults
      ..[root.id] = Right([l2, longLeaf, regulatedLeaf])
      ..[l2.id] = Right([l3])
      ..[l3.id] = Right([l4]);
    repository.breadcrumbResults
      ..[root.id] = Right(_breadcrumb([root]))
      ..[l2.id] = Right(_breadcrumb([root, l2]))
      ..[l3.id] = Right(_breadcrumb([root, l2, l3]))
      ..[l4.id] = Right(_breadcrumb([root, l2, l3, l4]));
  }

  final repository = FakeCanonicalTaxonomyRepository();

  final root = canonicalNode(
    id: 'root',
    name: 'Beyaz Eşya & Ev Aletleri',
    level: TaxonomyCategoryLevel.l1,
    kind: TaxonomyCategoryKind.container,
  );
  final l2 = canonicalNode(
    id: 'l2',
    name: 'Elektrikli Kişisel Bakım Cihazları',
    parentId: 'root',
    level: TaxonomyCategoryLevel.l2,
    kind: TaxonomyCategoryKind.container,
  );
  final l3 = canonicalNode(
    id: 'l3',
    name: 'Saç Bakım Cihazları',
    parentId: 'l2',
    level: TaxonomyCategoryLevel.l3,
    kind: TaxonomyCategoryKind.container,
  );
  final l4 = canonicalNode(
    id: 'l4',
    name: 'Saç Düzleştirici & Şekillendiriciler',
    parentId: 'l3',
    level: TaxonomyCategoryLevel.l4,
    kind: TaxonomyCategoryKind.leaf,
    assignable: true,
  );
  final longLeaf = canonicalNode(
    id: 'long-leaf',
    name: _longNodeName,
    parentId: 'root',
    level: TaxonomyCategoryLevel.l2,
    kind: TaxonomyCategoryKind.leaf,
    assignable: true,
  );
  final regulatedLeaf = canonicalNode(
    id: 'regulated-leaf',
    name: 'Profesyonel Medikal Cihazlar',
    parentId: 'root',
    level: TaxonomyCategoryLevel.l2,
    kind: TaxonomyCategoryKind.leaf,
    assignable: true,
    policyClass: TaxonomyPolicyClass.regulated,
    professionalReviewStatus: TaxonomyProfessionalReviewStatus.pending,
  );
}

TaxonomyBreadcrumb _breadcrumb(List<TaxonomyCategoryNode> nodes) {
  return TaxonomyBreadcrumb([
    for (final node in nodes)
      TaxonomyBreadcrumbItem(
        categoryId: node.id,
        label: node.displayName,
        level: node.level,
      ),
  ]);
}
