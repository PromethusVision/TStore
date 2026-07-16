import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/services/recently_viewed_products_storage.dart';
import 'package:t_store/features/shop/domain/usecases/get_products_by_ids_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/recently_viewed_products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/recently_viewed_products_state.dart';

class MockRecentlyViewedProductsStorage extends Mock
    implements RecentlyViewedProductsStorage {}

class MockGetProductsByIdsUsecase extends Mock
    implements GetProductsByIdsUsecase {}

void main() {
  const firstProduct = ProductEntity(
    id: 'p1',
    name: 'Birinci Ürün',
    price: 100,
    categoryId: 'category-1',
    stock: 1,
    images: [],
  );
  const secondProduct = ProductEntity(
    id: 'p2',
    name: 'İkinci Ürün',
    price: 200,
    categoryId: 'category-1',
    stock: 1,
    images: [],
  );

  late MockRecentlyViewedProductsStorage storage;
  late MockGetProductsByIdsUsecase getProductsByIdsUsecase;

  setUp(() {
    storage = MockRecentlyViewedProductsStorage();
    getProductsByIdsUsecase = MockGetProductsByIdsUsecase();
  });

  RecentlyViewedProductsCubit buildCubit() => RecentlyViewedProductsCubit(
    storage: storage,
    getProductsByIdsUsecase: getProductsByIdsUsecase,
  );

  blocTest<RecentlyViewedProductsCubit, RecentlyViewedProductsState>(
    'ürünleri kayıt sırasını koruyarak yükler',
    setUp: () {
      when(
        () => storage.getProductIds('customer-1'),
      ).thenAnswer((_) async => ['p2', 'p1']);
      when(
        () => getProductsByIdsUsecase(['p2', 'p1']),
      ).thenAnswer((_) async => const Right([firstProduct, secondProduct]));
    },
    build: buildCubit,
    act: (cubit) => cubit.load('customer-1'),
    expect: () => const [
      RecentlyViewedProductsLoading(),
      RecentlyViewedProductsLoaded([secondProduct, firstProduct]),
    ],
  );

  blocTest<RecentlyViewedProductsCubit, RecentlyViewedProductsState>(
    'kayıt yoksa ürün sorgusu yapmadan boş durumu yükler',
    setUp: () {
      when(
        () => storage.getProductIds('customer-1'),
      ).thenAnswer((_) async => []);
    },
    build: buildCubit,
    act: (cubit) => cubit.load('customer-1'),
    expect: () => const [
      RecentlyViewedProductsLoading(),
      RecentlyViewedProductsLoaded([]),
    ],
    verify: (_) => verifyNever(() => getProductsByIdsUsecase(any())),
  );

  blocTest<RecentlyViewedProductsCubit, RecentlyViewedProductsState>(
    'ürünler alınamazsa kullanıcıya sade hata gösterir',
    setUp: () {
      when(
        () => storage.getProductIds('customer-1'),
      ).thenAnswer((_) async => ['p1']);
      when(
        () => getProductsByIdsUsecase(['p1']),
      ).thenAnswer((_) async => const Left('teknik hata'));
    },
    build: buildCubit,
    act: (cubit) => cubit.load('customer-1'),
    expect: () => const [
      RecentlyViewedProductsLoading(),
      RecentlyViewedProductsError(
        'Son görüntülediğin ürünler şu anda yüklenemiyor.',
      ),
    ],
  );

  test('geçmişi temizleyip boş duruma geçer', () async {
    when(() => storage.clear('customer-1')).thenAnswer((_) async {});
    final cubit = buildCubit();

    final didClear = await cubit.clear('customer-1');

    expect(didClear, isTrue);
    expect(cubit.state, const RecentlyViewedProductsLoaded([]));
    await cubit.close();
  });

  test(
    'tek ürünü kaldırır ve geri alındığında eski sırasına yerleştirir',
    () async {
      when(
        () => storage.getProductIds('customer-1'),
      ).thenAnswer((_) async => ['p1', 'p2']);
      when(
        () => getProductsByIdsUsecase(['p1', 'p2']),
      ).thenAnswer((_) async => const Right([firstProduct, secondProduct]));
      when(
        () => storage.removeProduct(customerId: 'customer-1', productId: 'p1'),
      ).thenAnswer((_) async {});
      when(
        () => storage.restoreProduct(
          customerId: 'customer-1',
          productId: 'p1',
          position: 0,
        ),
      ).thenAnswer((_) async {});
      final cubit = buildCubit();
      await cubit.load('customer-1');

      final removal = await cubit.removeProduct('customer-1', 'p1');

      expect(removal?.product, firstProduct);
      expect(removal?.originalPosition, 0);
      expect(cubit.state, const RecentlyViewedProductsLoaded([secondProduct]));

      final didRestore = await cubit.restoreProduct('customer-1', removal!);

      expect(didRestore, isTrue);
      expect(
        cubit.state,
        const RecentlyViewedProductsLoaded([firstProduct, secondProduct]),
      );
      await cubit.close();
    },
  );

  test('kaldırma kaydedilemezse mevcut listeyi korur', () async {
    when(
      () => storage.getProductIds('customer-1'),
    ).thenAnswer((_) async => ['p1']);
    when(
      () => getProductsByIdsUsecase(['p1']),
    ).thenAnswer((_) async => const Right([firstProduct]));
    when(
      () => storage.removeProduct(customerId: 'customer-1', productId: 'p1'),
    ).thenThrow(Exception('kayıt hatası'));
    final cubit = buildCubit();
    await cubit.load('customer-1');

    final removal = await cubit.removeProduct('customer-1', 'p1');

    expect(removal, isNull);
    expect(cubit.state, const RecentlyViewedProductsLoaded([firstProduct]));
    await cubit.close();
  });
}
