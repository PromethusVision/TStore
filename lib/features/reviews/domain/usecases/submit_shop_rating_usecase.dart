import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/reviews/domain/entities/shop_rating_entity.dart';
import 'package:t_store/features/reviews/domain/repositories/shop_rating_repository.dart';

class SubmitShopRatingUsecase
    implements UseCase<ShopRatingEntity, SubmitShopRatingParams> {
  final ShopRatingRepository repository;

  SubmitShopRatingUsecase(this.repository);

  @override
  Future<Either<String, ShopRatingEntity>> call(SubmitShopRatingParams params) {
    return repository.submitVerifiedShopRating(
      qrSessionId: params.qrSessionId,
      rating: params.rating,
    );
  }
}

class SubmitShopRatingParams {
  final String qrSessionId;
  final int rating;

  const SubmitShopRatingParams({
    required this.qrSessionId,
    required this.rating,
  });
}
