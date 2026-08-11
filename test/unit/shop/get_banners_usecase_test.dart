import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/banner_entity.dart';
import 'package:t_store/features/shop/domain/repositories/banner_repository.dart';
import 'package:t_store/features/shop/domain/usecases/get_banners_usecase.dart';

class MockBannerRepository extends Mock implements BannerRepository {}

void main() {
  late MockBannerRepository repository;
  late DateTime instant;
  late GetBannersUsecase usecase;

  setUp(() {
    repository = MockBannerRepository();
    instant = DateTime.parse('2026-08-12T09:00:00Z');
    usecase = GetBannersUsecase(repository, clock: () => instant);
  });

  test('revalidates active ranges at one captured instant', () async {
    final banners = [
      BannerEntity(
        id: 'starts-now',
        imageUrl: 'starts.png',
        startDate: instant,
        sortOrder: 3,
      ),
      BannerEntity(
        id: 'ends-now',
        imageUrl: 'ends.png',
        endDate: instant,
        sortOrder: 4,
      ),
      BannerEntity(
        id: 'future',
        imageUrl: 'future.png',
        startDate: instant.add(const Duration(microseconds: 1)),
      ),
      BannerEntity(
        id: 'expired',
        imageUrl: 'expired.png',
        endDate: instant.subtract(const Duration(microseconds: 1)),
      ),
      const BannerEntity(
        id: 'inactive',
        imageUrl: 'inactive.png',
        isActive: false,
      ),
    ];
    when(
      () => repository.getActiveBanners(),
    ).thenAnswer((_) async => Right(banners));

    final result = await usecase(const NoParams());

    expect(result.getOrElse(() => const []), hasLength(2));
    expect(result.getOrElse(() => const []).map((banner) => banner.id), [
      'starts-now',
      'ends-now',
    ]);
  });

  test(
    'orders deterministically and rejects duplicate or incomplete rows',
    () async {
      const banners = [
        BannerEntity(id: 'z', imageUrl: ' z.png ', sortOrder: 1),
        BannerEntity(id: 'b', imageUrl: 'b-high.png', sortOrder: 2),
        BannerEntity(id: 'b', imageUrl: 'b-low.png', sortOrder: 1),
        BannerEntity(id: 'a', imageUrl: ' a.png ', sortOrder: 1),
        BannerEntity(id: '', imageUrl: 'missing-id.png'),
        BannerEntity(id: 'missing-image', imageUrl: '   '),
      ];
      when(
        () => repository.getActiveBanners(),
      ).thenAnswer((_) async => const Right(banners));

      final result = await usecase(const NoParams());
      final normalized = result.getOrElse(() => const []);

      expect(normalized.map((banner) => banner.id), ['a', 'b', 'z']);
      expect(normalized.map((banner) => banner.imageUrl), [
        'a.png',
        'b-low.png',
        'z.png',
      ]);
    },
  );

  test('preserves empty and repository error results', () async {
    when(
      () => repository.getActiveBanners(),
    ).thenAnswer((_) async => const Right([]));
    expect(
      (await usecase(const NoParams())).getOrElse(() => const []),
      isEmpty,
    );

    when(
      () => repository.getActiveBanners(),
    ).thenAnswer((_) async => const Left('temporary failure'));
    expect(await usecase(const NoParams()), const Left('temporary failure'));
  });
}
