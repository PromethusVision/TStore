import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_by_id_usecase.dart';

class MockShopRepository extends Mock implements ShopRepository {}

void main() {
  late MockShopRepository repository;
  late GetShopByIdUsecase usecase;

  setUp(() {
    repository = MockShopRepository();
    usecase = GetShopByIdUsecase(repository);
  });

  test('mağazayı kimliğiyle repositoryden getirir', () async {
    const shop = ShopEntity(id: 'shop-1', name: 'Mahalle Marketi');
    when(
      () => repository.getShopById('shop-1'),
    ).thenAnswer((_) async => const Right(shop));

    final result = await usecase('shop-1');

    expect(result, const Right<String, ShopEntity?>(shop));
    verify(() => repository.getShopById('shop-1')).called(1);
  });

  test('bulunamayan mağazayı boş sonuç olarak korur', () async {
    when(
      () => repository.getShopById('shop-missing'),
    ).thenAnswer((_) async => const Right(null));

    final result = await usecase('shop-missing');

    expect(result, const Right<String, ShopEntity?>(null));
  });

  test('repository hatasını değiştirmeden döndürür', () async {
    when(
      () => repository.getShopById('shop-1'),
    ).thenAnswer((_) async => const Left('Mağaza yüklenemedi'));

    final result = await usecase('shop-1');

    expect(result, const Left<String, ShopEntity?>('Mağaza yüklenemedi'));
  });
}
