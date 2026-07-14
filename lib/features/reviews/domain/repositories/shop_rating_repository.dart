import 'package:dartz/dartz.dart';
import 'package:t_store/features/reviews/domain/entities/shop_rating_entity.dart';

abstract class ShopRatingRepository {
  Future<Either<String, ShopRatingEntity>> submitVerifiedShopRating({
    required String qrSessionId,
    required int rating,
  });
}
