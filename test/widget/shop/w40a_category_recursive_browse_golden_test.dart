import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/presentation/views/taxonomy_browse_view.dart';

import '../../helpers/canonical_taxonomy_test_support.dart';

void main() {
  setUpAll(() async {
    final poppins = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Bold.ttf'));
    final flutterArtifacts = File(
      Platform.resolvedExecutable,
    ).parent.parent.parent;
    final materialIcons = FontLoader('MaterialIcons')
      ..addFont(
        File(
          '${flutterArtifacts.path}${Platform.pathSeparator}material_fonts'
          '${Platform.pathSeparator}MaterialIcons-Regular.otf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await Future.wait([poppins.load(), materialIcons.load()]);
  });

  testWidgets('W40A Elektronik recursive browse 390 visual gate', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeCanonicalTaxonomyRepository()
      ..childrenResults[_electronicsRoot.id] = Right(_electronicsChildren)
      ..breadcrumbResults[_electronicsRoot.id] = Right(
        _breadcrumb([_electronicsRoot]),
      );

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: const Key('w40a-category-visual-evidence'),
          child: TaxonomyBrowseView(
            category: _electronicsRoot,
            repository: repository,
            capability: canonicalCapability(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Elektronik'), findsWidgets);
    expect(find.text('Neler arıyorsun?'), findsOneWidget);
    expect(find.textContaining('9 alt kategori'), findsOneWidget);
    expect(
      find.byKey(const Key('taxonomy-child-electronics-l2-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('taxonomy-child-electronics-l2-6')),
      findsOneWidget,
    );
    await expectLater(
      find.byKey(const Key('w40a-category-visual-evidence')),
      matchesGoldenFile(
        'goldens/w40a_category_recursive_browse_electronics_390.png',
      ),
    );
  });
}

final _electronicsRoot = TaxonomyCategoryNode(
  id: 'dae0270c-90ac-4248-919b-05531cf7c0e8',
  displayName: 'Elektronik',
  slug: 'elektronik-000251',
  level: TaxonomyCategoryLevel.l1,
  kind: TaxonomyCategoryKind.container,
  lifecycle: TaxonomyCategoryLifecycle.active,
  assignability: TaxonomyCategoryAssignability.notAssignable,
  sortOrder: 5,
  taxonomyVersion: canonicalTaxonomyVersion,
);

final _electronicsChildren = <TaxonomyCategoryNode>[
  TaxonomyCategoryNode(
    id: 'electronics-l2-1',
    displayName: 'Telefon & Aksesuarları',
    slug: 'telefon-aksesuarlar-000252',
    parentId: _electronicsRoot.id,
    level: TaxonomyCategoryLevel.l2,
    kind: TaxonomyCategoryKind.container,
    lifecycle: TaxonomyCategoryLifecycle.active,
    assignability: TaxonomyCategoryAssignability.notAssignable,
    sortOrder: 1,
    taxonomyVersion: canonicalTaxonomyVersion,
  ),
  TaxonomyCategoryNode(
    id: 'electronics-l2-2',
    displayName: 'TV & Görüntü Sistemleri',
    slug: 'tv-goruntu-sistemleri-000269',
    parentId: _electronicsRoot.id,
    level: TaxonomyCategoryLevel.l2,
    kind: TaxonomyCategoryKind.container,
    lifecycle: TaxonomyCategoryLifecycle.active,
    assignability: TaxonomyCategoryAssignability.notAssignable,
    sortOrder: 2,
    taxonomyVersion: canonicalTaxonomyVersion,
  ),
  TaxonomyCategoryNode(
    id: 'electronics-l2-3',
    displayName: 'Ses & Kulaklık',
    slug: 'ses-kulakl-k-000270',
    parentId: _electronicsRoot.id,
    level: TaxonomyCategoryLevel.l2,
    kind: TaxonomyCategoryKind.container,
    lifecycle: TaxonomyCategoryLifecycle.active,
    assignability: TaxonomyCategoryAssignability.notAssignable,
    sortOrder: 3,
    taxonomyVersion: canonicalTaxonomyVersion,
  ),
  TaxonomyCategoryNode(
    id: 'electronics-l2-4',
    displayName: 'Fotoğraf & Kamera',
    slug: 'fotograf-kamera-000271',
    parentId: _electronicsRoot.id,
    level: TaxonomyCategoryLevel.l2,
    kind: TaxonomyCategoryKind.container,
    lifecycle: TaxonomyCategoryLifecycle.active,
    assignability: TaxonomyCategoryAssignability.notAssignable,
    sortOrder: 4,
    taxonomyVersion: canonicalTaxonomyVersion,
  ),
  TaxonomyCategoryNode(
    id: 'electronics-l2-5',
    displayName: 'Oyun Konsolu & Aksesuarları',
    slug: 'oyun-konsolu-aksesuarlar-000272',
    parentId: _electronicsRoot.id,
    level: TaxonomyCategoryLevel.l2,
    kind: TaxonomyCategoryKind.container,
    lifecycle: TaxonomyCategoryLifecycle.active,
    assignability: TaxonomyCategoryAssignability.notAssignable,
    sortOrder: 5,
    taxonomyVersion: canonicalTaxonomyVersion,
  ),
  TaxonomyCategoryNode(
    id: 'electronics-l2-6',
    displayName: 'Giyilebilir Teknoloji',
    slug: 'giyilebilir-teknoloji-000273',
    parentId: _electronicsRoot.id,
    level: TaxonomyCategoryLevel.l2,
    kind: TaxonomyCategoryKind.container,
    lifecycle: TaxonomyCategoryLifecycle.active,
    assignability: TaxonomyCategoryAssignability.notAssignable,
    sortOrder: 6,
    taxonomyVersion: canonicalTaxonomyVersion,
  ),
  TaxonomyCategoryNode(
    id: 'electronics-l2-7',
    displayName: 'Akıllı Ev & Güvenlik',
    slug: 'ak-ll-ev-guvenlik-000274',
    parentId: _electronicsRoot.id,
    level: TaxonomyCategoryLevel.l2,
    kind: TaxonomyCategoryKind.container,
    lifecycle: TaxonomyCategoryLifecycle.active,
    assignability: TaxonomyCategoryAssignability.notAssignable,
    sortOrder: 7,
    taxonomyVersion: canonicalTaxonomyVersion,
  ),
  TaxonomyCategoryNode(
    id: 'electronics-l2-8',
    displayName: 'Güç, Şarj & Bağlantı',
    slug: 'guc-sarj-baglant-000275',
    parentId: _electronicsRoot.id,
    level: TaxonomyCategoryLevel.l2,
    kind: TaxonomyCategoryKind.container,
    lifecycle: TaxonomyCategoryLifecycle.active,
    assignability: TaxonomyCategoryAssignability.notAssignable,
    sortOrder: 8,
    taxonomyVersion: canonicalTaxonomyVersion,
  ),
  TaxonomyCategoryNode(
    id: 'electronics-l2-9',
    displayName: 'Elektronik Bileşenler',
    slug: 'elektronik-bilesenler-000276',
    parentId: _electronicsRoot.id,
    level: TaxonomyCategoryLevel.l2,
    kind: TaxonomyCategoryKind.container,
    lifecycle: TaxonomyCategoryLifecycle.active,
    assignability: TaxonomyCategoryAssignability.notAssignable,
    sortOrder: 9,
    taxonomyVersion: canonicalTaxonomyVersion,
  ),
];

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
