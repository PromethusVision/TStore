import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/shop/domain/repositories/canonical_taxonomy_repository.dart';
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

  const evidenceCases = <_R2GoldenCase>[
    _R2GoldenCase(
      name: 'w40a_r2_electronics_l2_390',
      scenario: _R2Scenario.electronicsL2,
      width: 390,
    ),
    _R2GoldenCase(
      name: 'w40a_r2_phone_l3_390',
      scenario: _R2Scenario.phoneL3,
      width: 390,
    ),
    _R2GoldenCase(
      name: 'w40a_r2_deep_l4_390',
      scenario: _R2Scenario.deepL4,
      width: 390,
    ),
    _R2GoldenCase(
      name: 'w40a_r2_long_name_130_390',
      scenario: _R2Scenario.longNames,
      width: 390,
      textScale: 1.3,
    ),
    _R2GoldenCase(
      name: 'w40a_r2_electronics_l2_320',
      scenario: _R2Scenario.electronicsL2,
      width: 320,
    ),
    _R2GoldenCase(
      name: 'w40a_r2_electronics_l2_430',
      scenario: _R2Scenario.electronicsL2,
      width: 430,
    ),
    _R2GoldenCase(
      name: 'w40a_r2_loading_390',
      scenario: _R2Scenario.loading,
      width: 390,
    ),
    _R2GoldenCase(
      name: 'w40a_r2_empty_390',
      scenario: _R2Scenario.empty,
      width: 390,
    ),
    _R2GoldenCase(
      name: 'w40a_r2_error_390',
      scenario: _R2Scenario.error,
      width: 390,
    ),
    _R2GoldenCase(
      name: 'w40a_r2_unavailable_390',
      scenario: _R2Scenario.unavailable,
      width: 390,
    ),
  ];

  for (final evidence in evidenceCases) {
    testWidgets('${evidence.name} final visual evidence', (tester) async {
      tester.view.physicalSize = Size(evidence.width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fixture = _fixtureFor(evidence.scenario);
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(evidence.textScale)),
            child: child!,
          ),
          home: RepaintBoundary(
            key: const Key('w40a-r2-category-visual-evidence'),
            child: TaxonomyBrowseView(
              category: fixture.category,
              repository: fixture.repository,
              capability: canonicalCapability(),
            ),
          ),
        ),
      );
      if (evidence.scenario == _R2Scenario.loading) {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      } else {
        await tester.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('taxonomy-browse-view')), findsOneWidget);
      expect(find.byKey(const Key('taxonomy-browse-back')), findsOneWidget);
      _expectScenario(evidence.scenario, tester);
      await expectLater(
        find.byKey(const Key('w40a-r2-category-visual-evidence')),
        matchesGoldenFile('goldens/${evidence.name}.png'),
      );
    });
  }
}

void _expectScenario(_R2Scenario scenario, WidgetTester tester) {
  switch (scenario) {
    case _R2Scenario.electronicsL2:
      expect(find.text('Alt kategoriler'), findsOneWidget);
      expect(find.textContaining('9 alt kategori'), findsOneWidget);
      expect(find.byKey(const Key('taxonomy-breadcrumb')), findsOneWidget);
      final first = find.byKey(
        Key('taxonomy-child-${_electronicsChildren.first.id}'),
      );
      final eighth = find.byKey(
        Key('taxonomy-child-${_electronicsChildren[7].id}'),
      );
      final ninth = find.byKey(
        Key('taxonomy-child-${_electronicsChildren[8].id}'),
      );
      expect(first, findsOneWidget);
      expect(eighth, findsOneWidget);
      expect(ninth, findsOneWidget);
      expect(tester.getSize(ninth).width, tester.getSize(eighth).width);
      expect(tester.getTopLeft(ninth).dx, tester.getTopLeft(first).dx);
    case _R2Scenario.phoneL3:
      expect(find.text('Telefon & Aksesuarları'), findsWidgets);
      expect(find.text('Cep Telefonları'), findsOneWidget);
      expect(find.text('Telefon Yedek Parçaları'), findsOneWidget);
    case _R2Scenario.deepL4:
      expect(find.text('Cep Telefonları'), findsWidgets);
      expect(find.text('Akıllı Telefonlar'), findsOneWidget);
      expect(find.text('Tuşlu Telefonlar'), findsOneWidget);
      expect(find.byIcon(Icons.storefront_outlined), findsNWidgets(2));
    case _R2Scenario.longNames:
      expect(find.text(_longCanonicalName), findsOneWidget);
      expect(_longCanonicalName.length, 48);
    case _R2Scenario.loading:
      expect(find.text('Kategoriler hazırlanıyor…'), findsOneWidget);
    case _R2Scenario.empty:
      expect(find.byKey(const Key('taxonomy-browse-empty')), findsOneWidget);
    case _R2Scenario.error:
      expect(find.byKey(const Key('taxonomy-browse-error')), findsOneWidget);
    case _R2Scenario.unavailable:
      expect(find.byKey(const Key('taxonomy-browse-blocked')), findsOneWidget);
      expect(find.text('Telefon Bataryaları'), findsOneWidget);
  }
}

_R2Fixture _fixtureFor(_R2Scenario scenario) {
  return switch (scenario) {
    _R2Scenario.electronicsL2 => _loadedFixture(
      category: _electronicsRoot,
      breadcrumb: [_electronicsRoot],
      children: _electronicsChildren,
    ),
    _R2Scenario.phoneL3 => _loadedFixture(
      category: _phoneAndAccessories,
      breadcrumb: [_electronicsRoot, _phoneAndAccessories],
      children: _phoneL3Children,
    ),
    _R2Scenario.deepL4 => _loadedFixture(
      category: _mobilePhones,
      breadcrumb: [_electronicsRoot, _phoneAndAccessories, _mobilePhones],
      children: _mobilePhoneL4Children,
    ),
    _R2Scenario.longNames => _loadedFixture(
      category: _collectionProducts,
      breadcrumb: [_toyRoot, _collectionProducts],
      children: _collectionChildren,
    ),
    _R2Scenario.loading => _R2Fixture(
      category: _electronicsRoot,
      repository: _PendingTaxonomyRepository(),
    ),
    _R2Scenario.empty => _loadedFixture(
      category: _electronicsRoot,
      breadcrumb: [_electronicsRoot],
      children: const [],
    ),
    _R2Scenario.error => _errorFixture(),
    _R2Scenario.unavailable => _R2Fixture(
      category: _unavailableBattery,
      repository: FakeCanonicalTaxonomyRepository(),
    ),
  };
}

_R2Fixture _loadedFixture({
  required TaxonomyCategoryNode category,
  required List<TaxonomyCategoryNode> breadcrumb,
  required List<TaxonomyCategoryNode> children,
}) {
  final repository = FakeCanonicalTaxonomyRepository()
    ..breadcrumbResults[category.id] = Right(_breadcrumb(breadcrumb))
    ..childrenResults[category.id] = Right(children);
  return _R2Fixture(category: category, repository: repository);
}

_R2Fixture _errorFixture() {
  final repository = FakeCanonicalTaxonomyRepository()
    ..breadcrumbResults[_electronicsRoot.id] = const Left(
      'Kategorilere şu anda ulaşılamıyor.',
    );
  return _R2Fixture(category: _electronicsRoot, repository: repository);
}

class _R2Fixture {
  const _R2Fixture({required this.category, required this.repository});

  final TaxonomyCategoryNode category;
  final CanonicalTaxonomyRepository repository;
}

class _PendingTaxonomyRepository extends FakeCanonicalTaxonomyRepository {
  final _pendingBreadcrumb = Completer<Either<String, TaxonomyBreadcrumb>>();

  @override
  Future<Either<String, TaxonomyBreadcrumb>> getBreadcrumb(String categoryId) =>
      _pendingBreadcrumb.future;
}

class _R2GoldenCase {
  const _R2GoldenCase({
    required this.name,
    required this.scenario,
    required this.width,
    this.textScale = 1,
  });

  final String name;
  final _R2Scenario scenario;
  final double width;
  final double textScale;
}

enum _R2Scenario {
  electronicsL2,
  phoneL3,
  deepL4,
  longNames,
  loading,
  empty,
  error,
  unavailable,
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

final _electronicsRoot = canonicalNode(
  id: 'dae0270c-90ac-4248-919b-05531cf7c0e8',
  name: 'Elektronik',
  level: TaxonomyCategoryLevel.l1,
  kind: TaxonomyCategoryKind.container,
  sortOrder: 5,
);

final _phoneAndAccessories = canonicalNode(
  id: '57418383-3e49-4bb7-ac9a-57432eaa5db7',
  name: 'Telefon & Aksesuarları',
  parentId: _electronicsRoot.id,
  level: TaxonomyCategoryLevel.l2,
  kind: TaxonomyCategoryKind.container,
  sortOrder: 1,
);

final _electronicsChildren = <TaxonomyCategoryNode>[
  _phoneAndAccessories,
  _container(
    id: '5dacd9c2-56dd-4b41-9c31-e3d99ba53865',
    name: 'TV & Görüntü Sistemleri',
    parentId: _electronicsRoot.id,
    level: TaxonomyCategoryLevel.l2,
    sortOrder: 2,
  ),
  _container(
    id: 'b7d2e9fc-fcab-4426-9a43-1831071ef0c3',
    name: 'Ses & Kulaklık',
    parentId: _electronicsRoot.id,
    level: TaxonomyCategoryLevel.l2,
    sortOrder: 3,
  ),
  _container(
    id: 'b8538f25-25b5-4047-9690-9b6e1de35ff7',
    name: 'Fotoğraf & Kamera',
    parentId: _electronicsRoot.id,
    level: TaxonomyCategoryLevel.l2,
    sortOrder: 4,
  ),
  _container(
    id: 'bfe7fa8f-fd01-4cd4-8e47-676df6c3884d',
    name: 'Oyun Konsolu & Aksesuarları',
    parentId: _electronicsRoot.id,
    level: TaxonomyCategoryLevel.l2,
    sortOrder: 5,
  ),
  _container(
    id: '99d6a538-2324-4e59-9dc9-6f0de8968482',
    name: 'Giyilebilir Teknoloji',
    parentId: _electronicsRoot.id,
    level: TaxonomyCategoryLevel.l2,
    sortOrder: 6,
  ),
  _container(
    id: '69a0de3e-4fd1-44cc-800a-887aac8581c1',
    name: 'Akıllı Ev & Güvenlik',
    parentId: _electronicsRoot.id,
    level: TaxonomyCategoryLevel.l2,
    sortOrder: 7,
  ),
  _container(
    id: '1bd43c2b-adb9-42a9-9a8e-f179e11739e8',
    name: 'Güç, Şarj & Bağlantı',
    parentId: _electronicsRoot.id,
    level: TaxonomyCategoryLevel.l2,
    sortOrder: 8,
  ),
  _container(
    id: '28a1783d-44f8-405d-8a31-758b80ce3877',
    name: 'Elektronik Bileşenler',
    parentId: _electronicsRoot.id,
    level: TaxonomyCategoryLevel.l2,
    sortOrder: 9,
  ),
];

final _mobilePhones = _container(
  id: '14cb432c-a2ea-4ab8-9ebf-948fd91ffff5',
  name: 'Cep Telefonları',
  parentId: _phoneAndAccessories.id,
  level: TaxonomyCategoryLevel.l3,
  sortOrder: 1,
);

final _phoneSpareParts = _container(
  id: '33cdeabc-024d-48de-b5c0-c8943b7b9c27',
  name: 'Telefon Yedek Parçaları',
  parentId: _phoneAndAccessories.id,
  level: TaxonomyCategoryLevel.l3,
  sortOrder: 9,
);

final _phoneL3Children = <TaxonomyCategoryNode>[
  _mobilePhones,
  _leaf(
    id: 'f962be59-61cd-4bb0-811f-4066263f0fa6',
    name: 'Telefon Kılıfları',
    parentId: _phoneAndAccessories.id,
    level: TaxonomyCategoryLevel.l3,
    sortOrder: 2,
  ),
  _leaf(
    id: 'eb8da75d-f847-4f8c-94cc-5fe921cbac40',
    name: 'Ekran Koruyucular',
    parentId: _phoneAndAccessories.id,
    level: TaxonomyCategoryLevel.l3,
    sortOrder: 3,
  ),
  _leaf(
    id: '55efa657-d036-4e78-9a96-2a7946cabd16',
    name: 'Kamera Lens Koruyucuları',
    parentId: _phoneAndAccessories.id,
    level: TaxonomyCategoryLevel.l3,
    sortOrder: 4,
  ),
  _leaf(
    id: 'bb29f067-1f0c-4f6f-bfd2-f3dcf3b8b03a',
    name: 'Telefon Tutucu, Stand & Askıları',
    parentId: _phoneAndAccessories.id,
    level: TaxonomyCategoryLevel.l3,
    sortOrder: 5,
  ),
  _leaf(
    id: '5f147f01-2889-4906-a375-a4912710fe72',
    name: 'Telefon Modeline Özgü Şarj Aksesuarları',
    parentId: _phoneAndAccessories.id,
    level: TaxonomyCategoryLevel.l3,
    sortOrder: 6,
  ),
  _leaf(
    id: 'cddf1092-28ba-4697-b18c-ff448838c794',
    name: 'Telefon Kamera & Çekim Aksesuarları',
    parentId: _phoneAndAccessories.id,
    level: TaxonomyCategoryLevel.l3,
    sortOrder: 7,
  ),
  _leaf(
    id: '547b9080-af66-4e6f-808e-fd074a256edf',
    name: 'Telefon Kalemleri',
    parentId: _phoneAndAccessories.id,
    level: TaxonomyCategoryLevel.l3,
    sortOrder: 8,
  ),
  _phoneSpareParts,
];

final _mobilePhoneL4Children = <TaxonomyCategoryNode>[
  _leaf(
    id: 'b7cee2cf-3005-4e9d-95ff-5dfe106f1da3',
    name: 'Akıllı Telefonlar',
    parentId: _mobilePhones.id,
    level: TaxonomyCategoryLevel.l4,
    sortOrder: 1,
  ),
  _leaf(
    id: '4fcbb434-492e-44d6-9f52-328cf2342478',
    name: 'Tuşlu Telefonlar',
    parentId: _mobilePhones.id,
    level: TaxonomyCategoryLevel.l4,
    sortOrder: 2,
  ),
];

final _toyRoot = canonicalNode(
  id: '52adad9e-8fcf-48e0-9418-33ee5d51abc4',
  name: 'Oyuncak & Hobi',
  level: TaxonomyCategoryLevel.l1,
  kind: TaxonomyCategoryKind.container,
  sortOrder: 14,
);

final _collectionProducts = _container(
  id: '114aa583-e5c4-4cb6-880a-4c8ddcd41717',
  name: 'Koleksiyon Ürünleri',
  parentId: _toyRoot.id,
  level: TaxonomyCategoryLevel.l2,
  sortOrder: 9,
);

const _longCanonicalName = 'Sürpriz & Rastgele İçerikli Koleksiyon Paketleri';

final _collectionChildren = <TaxonomyCategoryNode>[
  _leaf(
    id: 'f92e1d2a-545d-462e-adc5-eb9733d232b5',
    name: 'Koleksiyon Figürleri',
    parentId: _collectionProducts.id,
    level: TaxonomyCategoryLevel.l3,
    sortOrder: 1,
  ),
  _leaf(
    id: 'cb9afc6e-9a24-436f-881b-0312135f7bf7',
    name: 'Koleksiyon Kartları',
    parentId: _collectionProducts.id,
    level: TaxonomyCategoryLevel.l3,
    sortOrder: 2,
  ),
  _leaf(
    id: '0c603922-12ca-419a-aef6-7d617348bf35',
    name: 'Sergileme Amaçlı Model Araçlar',
    parentId: _collectionProducts.id,
    level: TaxonomyCategoryLevel.l3,
    sortOrder: 3,
  ),
  _leaf(
    id: '94ff6f23-ff5f-4667-b358-b0d56d419730',
    name: _longCanonicalName,
    parentId: _collectionProducts.id,
    level: TaxonomyCategoryLevel.l3,
    sortOrder: 4,
  ),
];

final _unavailableBattery = canonicalNode(
  id: '8da8849a-5f0e-4401-b502-f3eff77429f5',
  name: 'Telefon Bataryaları',
  parentId: _phoneSpareParts.id,
  level: TaxonomyCategoryLevel.l4,
  kind: TaxonomyCategoryKind.leaf,
  assignable: true,
  policyClass: TaxonomyPolicyClass.regulated,
  professionalReviewStatus: TaxonomyProfessionalReviewStatus.pending,
);

TaxonomyCategoryNode _container({
  required String id,
  required String name,
  required String parentId,
  required TaxonomyCategoryLevel level,
  required int sortOrder,
}) {
  return canonicalNode(
    id: id,
    name: name,
    parentId: parentId,
    level: level,
    kind: TaxonomyCategoryKind.container,
    sortOrder: sortOrder,
  );
}

TaxonomyCategoryNode _leaf({
  required String id,
  required String name,
  required String parentId,
  required TaxonomyCategoryLevel level,
  required int sortOrder,
}) {
  return canonicalNode(
    id: id,
    name: name,
    parentId: parentId,
    level: level,
    kind: TaxonomyCategoryKind.leaf,
    assignable: true,
    sortOrder: sortOrder,
  );
}
