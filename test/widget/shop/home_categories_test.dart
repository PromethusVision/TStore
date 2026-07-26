import 'package:cached_network_image/cached_network_image.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_state.dart';
import 'package:t_store/features/shop/presentation/widgets/home_categories.dart';

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
  }) async {
    tester.view.physicalSize = const Size(1400, 400);
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
        home: Scaffold(
          body: BlocProvider<CategoriesCubit>.value(
            value: categoriesCubit,
            child: const HomeCategories(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  void expectTurkishCategoryTitles() {
    for (final title in TTexts.homeCategoryTitles) {
      expect(find.text(title), findsOneWidget);
    }
  }

  testWidgets(
    'canlı İngilizce kategori adlarını Türkçe ve tutarlı simgelerle gösterir',
    (tester) async {
      await pumpCategories(
        tester,
        state: const CategoriesLoaded(englishCategories),
      );

      expectTurkishCategoryTitles();
      for (final category in englishCategories) {
        expect(find.text(category.name), findsNothing);
      }

      expect(find.byIcon(Icons.shopping_basket_rounded), findsOneWidget);
      expect(find.byIcon(Icons.eco_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bakery_dining_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lunch_dining_rounded), findsOneWidget);
      expect(find.byIcon(Icons.spa_rounded), findsOneWidget);
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
}
