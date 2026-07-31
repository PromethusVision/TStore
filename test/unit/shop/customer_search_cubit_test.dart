import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/usecases/get_categories_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/get_shops_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/search_products_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_state.dart';

class MockSearchProductsUsecase extends Mock implements SearchProductsUsecase {}

class MockGetCategoriesUsecase extends Mock implements GetCategoriesUsecase {}

class MockGetShopsUsecase extends Mock implements GetShopsUsecase {}

void main() {
  late MockSearchProductsUsecase searchProductsUsecase;
  late MockGetCategoriesUsecase getCategoriesUsecase;
  late MockGetShopsUsecase getShopsUsecase;

  const product = ProductEntity(
    id: 'product-1',
    name: 'Market Çantası',
    price: 120,
    categoryId: 'category-1',
    stock: 5,
    images: [],
  );
  const category = CategoryEntity(id: 'category-1', name: 'Grocery');
  const inactiveCategory = CategoryEntity(
    id: 'category-2',
    name: 'Market Fırsatları',
    isActive: false,
  );
  const shop = ShopEntity(
    id: 'shop-1',
    name: 'Mahalle Market',
    address: 'Esenler, İstanbul',
  );
  const inactiveShop = ShopEntity(
    id: 'shop-2',
    name: 'Kapalı Market',
    isActive: false,
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    searchProductsUsecase = MockSearchProductsUsecase();
    getCategoriesUsecase = MockGetCategoriesUsecase();
    getShopsUsecase = MockGetShopsUsecase();
  });

  CustomerSearchCubit buildCubit() {
    return CustomerSearchCubit(
      searchProductsUsecase: searchProductsUsecase,
      getCategoriesUsecase: getCategoriesUsecase,
      getShopsUsecase: getShopsUsecase,
    );
  }

  void stubSuccess() {
    when(
      () => searchProductsUsecase(any()),
    ).thenAnswer((_) async => const Right([product]));
    when(
      () => getCategoriesUsecase(any()),
    ).thenAnswer((_) async => const Right([category, inactiveCategory]));
    when(
      () => getShopsUsecase(any()),
    ).thenAnswer((_) async => const Right([shop, inactiveShop]));
  }

  blocTest<CustomerSearchCubit, CustomerSearchState>(
    'ürün, yerelleştirilmiş kategori ve aktif mağaza sonuçlarını birleştirir',
    setUp: stubSuccess,
    build: buildCubit,
    act: (cubit) => cubit.search('market'),
    expect: () => [
      const CustomerSearchLoading('market'),
      const CustomerSearchLoaded(
        query: 'market',
        products: [product],
        categories: [category],
        shops: [shop],
      ),
    ],
    verify: (_) {
      verify(() => searchProductsUsecase('market')).called(1);
      verify(() => getCategoriesUsecase(any())).called(1);
      verify(() => getShopsUsecase(any())).called(1);
    },
  );

  blocTest<CustomerSearchCubit, CustomerSearchState>(
    'bir bölüm hata verdiğinde kalan sonuçları uyarıyla gösterir',
    setUp: () {
      when(
        () => searchProductsUsecase(any()),
      ).thenAnswer((_) async => const Right([product]));
      when(
        () => getCategoriesUsecase(any()),
      ).thenAnswer((_) async => const Left('Kategori hatası'));
      when(
        () => getShopsUsecase(any()),
      ).thenAnswer((_) async => const Right([shop]));
    },
    build: buildCubit,
    act: (cubit) => cubit.search('market'),
    expect: () => [
      const CustomerSearchLoading('market'),
      const CustomerSearchLoaded(
        query: 'market',
        products: [product],
        categories: [],
        shops: [shop],
        warningMessage:
            'Bazı sonuçlar yüklenemedi. Diğer sonuçlar gösteriliyor.',
      ),
    ],
  );

  blocTest<CustomerSearchCubit, CustomerSearchState>(
    'bütün bölümler hata verdiğinde tekrar denenebilir hata gösterir',
    setUp: () {
      when(
        () => searchProductsUsecase(any()),
      ).thenAnswer((_) async => const Left('Ürün hatası'));
      when(
        () => getCategoriesUsecase(any()),
      ).thenAnswer((_) async => const Left('Kategori hatası'));
      when(
        () => getShopsUsecase(any()),
      ).thenAnswer((_) async => const Left('Mağaza hatası'));
    },
    build: buildCubit,
    act: (cubit) => cubit.search('market'),
    expect: () => [
      const CustomerSearchLoading('market'),
      const CustomerSearchError('Arama tamamlanamadı. Lütfen tekrar deneyin.'),
    ],
  );

  test(
    'kategori ve mağaza listesini sonraki aramada önbellekten kullanır',
    () async {
      stubSuccess();
      final cubit = buildCubit();

      await cubit.search('market');
      await cubit.search('mahalle');

      verify(() => searchProductsUsecase(any())).called(2);
      verify(() => getCategoriesUsecase(any())).called(1);
      verify(() => getShopsUsecase(any())).called(1);

      await cubit.close();
    },
  );
}
