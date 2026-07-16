import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/product_repository.dart';
import 'package:t_store/features/shop/domain/usecases/get_products_by_ids_usecase.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  const products = [
    ProductEntity(
      id: 'product-1',
      name: 'Birinci Ürün',
      price: 100,
      categoryId: 'category-1',
      stock: 1,
      images: [],
    ),
    ProductEntity(
      id: 'product-2',
      name: 'İkinci Ürün',
      price: 200,
      categoryId: 'category-1',
      stock: 1,
      images: [],
    ),
  ];

  late MockProductRepository repository;
  late GetProductsByIdsUsecase usecase;

  setUp(() {
    repository = MockProductRepository();
    usecase = GetProductsByIdsUsecase(repository);
  });

  test('ürün kimliklerini toplu olarak depoya iletir', () async {
    when(
      () => repository.getProductsByIds(['product-2', 'product-1']),
    ).thenAnswer((_) async => const Right(products));

    final result = await usecase(['product-2', 'product-1']);

    expect(result, const Right<String, List<ProductEntity>>(products));
    verify(
      () => repository.getProductsByIds(['product-2', 'product-1']),
    ).called(1);
  });

  test('boş listede depoya gitmeden boş sonuç verir', () async {
    final result = await usecase(const []);

    expect(result, const Right<String, List<ProductEntity>>([]));
    verifyNever(() => repository.getProductsByIds(any()));
  });
}
