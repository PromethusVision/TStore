import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/reviews/domain/entities/shop_rating_entity.dart';
import 'package:t_store/features/reviews/domain/usecases/submit_shop_rating_usecase.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_cubit.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_state.dart';

class MockSubmitShopRatingUsecase extends Mock
    implements SubmitShopRatingUsecase {}

class FakeSubmitShopRatingParams extends Fake
    implements SubmitShopRatingParams {}

void main() {
  late MockSubmitShopRatingUsecase submitShopRatingUsecase;

  const ratingResult = ShopRatingEntity(
    id: 'rating-1',
    shopId: 'shop-1',
    rating: 5,
    averageRating: 4.75,
    ratingCount: 8,
  );

  setUpAll(() {
    registerFallbackValue(FakeSubmitShopRatingParams());
  });

  setUp(() {
    submitShopRatingUsecase = MockSubmitShopRatingUsecase();
  });

  ShopRatingCubit buildCubit() =>
      ShopRatingCubit(submitShopRatingUsecase: submitShopRatingUsecase);

  blocTest<ShopRatingCubit, ShopRatingState>(
    'doğrulanmış alışveriş puanını kaydeder',
    build: () {
      when(
        () => submitShopRatingUsecase(any()),
      ).thenAnswer((_) async => const Right(ratingResult));
      return buildCubit();
    },
    act: (cubit) => cubit.submitRating(qrSessionId: 'session-1', rating: 5),
    expect: () => [
      ShopRatingSubmitting(),
      const ShopRatingSuccess(ratingResult),
    ],
    verify: (_) {
      final params =
          verify(() => submitShopRatingUsecase(captureAny())).captured.single
              as SubmitShopRatingParams;
      expect(params.qrSessionId, 'session-1');
      expect(params.rating, 5);
    },
  );

  blocTest<ShopRatingCubit, ShopRatingState>(
    'kayıt hatasını müşteriye gösterir',
    build: () {
      when(
        () => submitShopRatingUsecase(any()),
      ).thenAnswer((_) async => const Left('Puan kaydedilemedi'));
      return buildCubit();
    },
    act: (cubit) => cubit.submitRating(qrSessionId: 'session-1', rating: 4),
    expect: () => [
      ShopRatingSubmitting(),
      const ShopRatingFailure('Puan kaydedilemedi'),
    ],
  );

  blocTest<ShopRatingCubit, ShopRatingState>(
    'geçersiz yıldız sayısını göndermeden reddeder',
    build: buildCubit,
    act: (cubit) => cubit.submitRating(qrSessionId: 'session-1', rating: 0),
    expect: () => [
      const ShopRatingFailure('Lütfen 1 ile 5 arasında bir puan seçin.'),
    ],
    verify: (_) {
      verifyNever(() => submitShopRatingUsecase(any()));
    },
  );
}
