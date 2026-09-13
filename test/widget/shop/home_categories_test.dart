import 'package:cached_network_image/cached_network_image.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_state.dart';
import 'package:t_store/features/shop/presentation/widgets/home_categories.dart';

import '../../helpers/canonical_taxonomy_test_support.dart';

class MockCategoriesCubit extends MockCubit<CategoriesState>
    implements CategoriesCubit {}

void main() {
  late MockCategoriesCubit categoriesCubit;

  const englishCategories = [
    CategoryEntity(id: 'category-1', name: 'Electronics', sortOrder: 1),
    CategoryEntity(id: 'category-2', name: 'Clothes', sortOrder: 2),
    CategoryEntity(id: 'category-3', name: 'Shoes', sortOrder: 3),
    CategoryEntity(id: 'category-4', name: 'Furniture', sortOrder: 4),
    CategoryEntity(id: 'category-5', name: 'Accessories', sortOrder: 5),
  ];

  setUp(() {
    categoriesCubit = MockCategoriesCubit();
    when(() => categoriesCubit.getCategories()).thenAnswer((_) async {});
  });

  tearDown(() {
    categoriesCubit.close();
  });

  Future<void> pumpCategories(
    WidgetTester tester, {
    required CategoriesState state,
    HomeCategoryDestinationBuilder? destinationBuilder,
    HomeCanonicalCategoryDestinationBuilder? canonicalDestinationBuilder,
    Size physicalSize = const Size(1400, 500),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = physicalSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    whenListen(
      categoriesCubit,
      const Stream<CategoriesState>.empty(),
      initialState: state,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: EsnaftaVarTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: BlocProvider<CategoriesCubit>.value(
            value: categoriesCubit,
            child: HomeCategories(
              destinationBuilder: destinationBuilder,
              canonicalDestinationBuilder: canonicalDestinationBuilder,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  for (final count in [0, 1, 3, 7, 8, 11]) {
    testWidgets('W53A Home renders min($count, 8) roots in supplied order', (
      tester,
    ) async {
      final categories = List.generate(
        count,
        (i) => CategoryEntity(
          id: 'root-$i',
          name: 'Kategori $i',
          sortOrder: count - i,
        ),
      );
      await pumpCategories(
        tester,
        state: CategoriesLoaded(categories),
        physicalSize: const Size(390, 844),
      );
      for (var i = 0; i < count; i++) {
        final item = find.byKey(Key('home-category-root-$i'));
        expect(item, i < 8 ? findsOneWidget : findsNothing);
        if (i < 8) expect(item.hitTestable(), findsOneWidget);
      }
      final positions = [
        for (var i = 0; i < count && i < 8; i++)
          tester.getTopLeft(find.byKey(Key('home-category-root-$i'))),
      ];
      for (var i = 1; i < positions.length; i++) {
        expect(
          positions[i].dy > positions[i - 1].dy ||
              (positions[i].dy == positions[i - 1].dy &&
                  positions[i].dx > positions[i - 1].dx),
          isTrue,
        );
      }
      expect(find.text('Tüm kategoriler'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('W53A duplicate IDs and children do not consume root slots', (
    tester,
  ) async {
    await pumpCategories(
      tester,
      state: const CategoriesLoaded([
        CategoryEntity(id: 'same', name: 'Birinci'),
        CategoryEntity(id: ' same ', name: 'Tekrar'),
        CategoryEntity(id: 'child', name: 'Alt kategori', parentId: 'same'),
        CategoryEntity(id: 'second', name: 'İkinci'),
      ]),
    );
    expect(find.text('Birinci'), findsOneWidget);
    expect(find.text('İkinci'), findsOneWidget);
    expect(find.text('Tekrar'), findsNothing);
    expect(find.text('Alt kategori'), findsNothing);
  });

  testWidgets('W53A full roots reuse selected identity and guard rapid taps', (
    tester,
  ) async {
    String? selected;
    await pumpCategories(
      tester,
      physicalSize: const Size(390, 844),
      state: CategoriesLoaded(
        List.generate(
          11,
          (i) => CategoryEntity(id: 'root-$i', name: 'Kategori $i'),
        ),
      ),
      destinationBuilder: (category, title) {
        selected = category.id;
        return Scaffold(appBar: AppBar(), body: Text('Seçim: $title'));
      },
    );
    final action = find.byKey(const Key('home-all-categories'));
    await tester.tap(action);
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('all-categories-root')), findsOneWidget);
    expect(find.byKey(const Key('home-category-root-10')), findsOneWidget);
    await tester.tap(find.byKey(const Key('home-category-root-10')));
    await tester.pumpAndSettle();
    expect(selected, 'root-10');
    expect(find.text('Seçim: Kategori 10'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('all-categories-root')), findsNothing);
    expect(find.byKey(const Key('home-category-root-8')), findsNothing);
  });

  testWidgets('W53A category grid at 320 and enlarged text remains usable', (
    tester,
  ) async {
    await pumpCategories(
      tester,
      physicalSize: const Size(320, 844),
      textScale: 1.3,
      state: CategoriesLoaded(
        List.generate(
          8,
          (i) => CategoryEntity(id: 'root-$i', name: 'Kategori $i'),
        ),
      ),
    );
    expect(
      find.byKey(const Key('home-category-root-7')).hitTestable(),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('home-all-categories')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  void expectTurkishCategoryTitles() {
    for (final title in TTexts.homeCategoryTitles) {
      expect(find.text(title), findsOneWidget);
    }
  }

  testWidgets(
    'canlı İngilizce kategori adlarını Türkçe ve semantik simgelerle gösterir',
    (tester) async {
      await pumpCategories(
        tester,
        state: const CategoriesLoaded(englishCategories),
      );

      expectTurkishCategoryTitles();
      for (final category in englishCategories) {
        expect(find.text(category.name), findsNothing);
      }

      expect(find.byIcon(Icons.devices_rounded), findsOneWidget);
      expect(find.byIcon(Icons.checkroom_rounded), findsOneWidget);
      expect(find.byIcon(Icons.roller_skating_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chair_rounded), findsOneWidget);
      expect(find.byIcon(Icons.business_center_rounded), findsOneWidget);
    },
  );

  testWidgets('gerçek kategori görseli varsa ağ adresini kullanır', (
    tester,
  ) async {
    const category = CategoryEntity(
      id: 'market',
      name: 'Market',
      imageUrl: 'https://example.com/market.png',
    );

    await pumpCategories(tester, state: const CategoriesLoaded([category]));

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.imageUrl, category.imageUrl);
  });

  testWidgets('yüklenirken sahte kategori göstermez', (tester) async {
    await pumpCategories(tester, state: CategoriesLoading());

    expect(find.byKey(const Key('home-categories-loading')), findsOneWidget);
    expect(find.text(TTexts.homeCategoryTitles.first), findsNothing);
  });

  testWidgets('boş sonucu açıkça gösterir', (tester) async {
    await pumpCategories(tester, state: const CategoriesLoaded([]));

    expect(
      find.text('Şu anda gösterilecek kategori bulunamadı.'),
      findsOneWidget,
    );
    expect(find.text(TTexts.homeCategoryTitles.first), findsNothing);
  });

  testWidgets('hata durumunda yeniden deneme sunar', (tester) async {
    await pumpCategories(
      tester,
      state: const CategoriesError('Kategoriler yüklenemedi.'),
    );
    clearInteractions(categoriesCubit);

    expect(find.text('Kategorileri Tekrar Yükle'), findsOneWidget);
    await tester.tap(find.byKey(const Key('home-categories-retry')));
    await tester.pump();

    verify(() => categoriesCubit.getCategories()).called(1);
  });

  testWidgets('kimliği eksik kategori bozuk sayfa açmaz', (tester) async {
    const category = CategoryEntity(id: '   ', name: 'Market');
    var destinationBuildCount = 0;

    await pumpCategories(
      tester,
      state: const CategoriesLoaded([category]),
      destinationBuilder: (_, _) {
        destinationBuildCount++;
        return const Scaffold(body: Text('Kategori hedefi'));
      },
    );

    final categoryItem = find.byKey(const Key('home-category-   '));
    final categoryInkWell = tester.widget<InkWell>(
      find.descendant(of: categoryItem, matching: find.byType(InkWell)),
    );

    expect(categoryInkWell.onTap, isNull);
    expect(destinationBuildCount, 0);
    expect(find.text('Kategori hedefi'), findsNothing);
  });

  testWidgets('kategoriye hızlı çift dokunma yalnız bir sayfa açar', (
    tester,
  ) async {
    const category = CategoryEntity(id: ' market ', name: 'Market');
    var destinationBuildCount = 0;
    CategoryEntity? openedCategory;

    await pumpCategories(
      tester,
      state: const CategoriesLoaded([category]),
      destinationBuilder: (selectedCategory, _) {
        destinationBuildCount++;
        openedCategory = selectedCategory;
        return const Scaffold(body: Text('Kategori hedefi'));
      },
    );

    final categoryItem = find.byKey(const Key('home-category- market '));
    final categoryInkWell = tester.widget<InkWell>(
      find.descendant(of: categoryItem, matching: find.byType(InkWell)),
    );
    categoryInkWell.onTap?.call();
    categoryInkWell.onTap?.call();
    await tester.pumpAndSettle();

    expect(destinationBuildCount, 1);
    expect(openedCategory?.id, 'market');
    expect(find.text('Kategori hedefi'), findsOneWidget);
  });

  testWidgets('gerçek uzun canonical adlar dar ekranda eylemi bozmaz', (
    tester,
  ) async {
    const categories = [
      CategoryEntity(
        id: 'white-goods',
        name: 'Beyaz Eşya & Ev Aletleri',
        sortOrder: 1,
      ),
      CategoryEntity(
        id: 'hardware',
        name: 'Yapı, Hırdavat & Tesisat',
        sortOrder: 2,
      ),
      CategoryEntity(
        id: 'collectible-packs',
        name: 'Sürpriz & Rastgele İçerikli Koleksiyon Paketleri',
        sortOrder: 3,
      ),
    ];
    CategoryEntity? openedCategory;

    await pumpCategories(
      tester,
      state: const CategoriesLoaded(categories),
      physicalSize: const Size(390, 400),
      destinationBuilder: (category, _) {
        openedCategory = category;
        return const Scaffold(body: Text('Canonical kategori hedefi'));
      },
    );

    expect(tester.takeException(), isNull);
    for (final category in categories) {
      final item = find.byKey(Key('home-category-${category.id}'));
      expect(item, findsOneWidget);
      expect(
        tester
            .widget<InkWell>(
              find.descendant(of: item, matching: find.byType(InkWell)),
            )
            .onTap,
        isNotNull,
      );
    }

    await tester.tap(find.byKey(const Key('home-category-white-goods')));
    await tester.pumpAndSettle();

    expect(openedCategory?.id, 'white-goods');
    expect(find.text('Canonical kategori hedefi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('canonical mode yalnız 24 root projectionını açar', (
    tester,
  ) async {
    final roots = canonicalRoots();
    final categories = roots
        .map(
          (node) => CategoryEntity(
            id: node.id,
            name: node.displayName,
            sortOrder: node.sortOrder,
          ),
        )
        .toList(growable: false);
    String? openedCanonicalId;

    await pumpCategories(
      tester,
      state: CategoriesLoaded(
        categories,
        runtimeMode: TaxonomyRuntimeMode.canonicalV1Runtime,
        canonicalNodes: roots,
      ),
      physicalSize: const Size(390, 400),
      canonicalDestinationBuilder: (node) {
        openedCanonicalId = node.id;
        return const Scaffold(body: Text('Canonical root hedefi'));
      },
    );

    expect(find.byKey(const Key('home-category-root-1')), findsOneWidget);
    expect(find.byKey(const Key('home-category-root-25')), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('home-category-root-1')));
    await tester.pumpAndSettle();

    expect(openedCanonicalId, 'root-1');
    expect(find.text('Canonical root hedefi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'W53A full index preserves canonical browse capability and roots beyond eight',
    (tester) async {
      final roots = canonicalRoots();
      String? selected;
      await pumpCategories(
        tester,
        physicalSize: const Size(390, 844),
        state: CategoriesLoaded(
          roots
              .map(
                (node) => CategoryEntity(id: node.id, name: node.displayName),
              )
              .toList(),
          runtimeMode: TaxonomyRuntimeMode.canonicalV1Runtime,
          canonicalNodes: roots,
        ),
        canonicalDestinationBuilder: (node) {
          selected = node.id;
          return Scaffold(appBar: AppBar(), body: Text(node.displayName));
        },
      );
      expect(find.byKey(const Key('home-category-root-9')), findsNothing);
      await tester.tap(find.byKey(const Key('home-all-categories')));
      await tester.pumpAndSettle();
      final last = find.byKey(Key('home-category-${roots.last.id}'));
      await tester.ensureVisible(last);
      await tester.pumpAndSettle();
      await tester.tap(last);
      await tester.pumpAndSettle();
      expect(selected, roots.last.id);
      expect(find.text(roots.last.displayName), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('48 karakterli Türkçe kategori adı anlamlı üç satır alanı alır', (
    tester,
  ) async {
    const longCategoryName =
        'Çocuk Giyim, Ayakkabı ve Günlük Kullanım Ürünleri';
    const category = CategoryEntity(
      id: 'long-category',
      name: longCategoryName,
    );

    await pumpCategories(
      tester,
      state: const CategoriesLoaded([category]),
      physicalSize: const Size(320, 400),
    );

    final label = tester.widget<Text>(find.text(longCategoryName));
    expect(label.maxLines, 3);
    expect(
      tester
          .getSize(find.byKey(const Key('home-category-long-category')))
          .width,
      greaterThanOrEqualTo(100),
    );
    expect(tester.takeException(), isNull);
  });
}
