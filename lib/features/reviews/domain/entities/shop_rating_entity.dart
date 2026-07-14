import 'package:equatable/equatable.dart';

class ShopRatingEntity extends Equatable {
  final String id;
  final String shopId;
  final int rating;
  final double averageRating;
  final int ratingCount;

  const ShopRatingEntity({
    required this.id,
    required this.shopId,
    required this.rating,
    required this.averageRating,
    required this.ratingCount,
  });

  @override
  List<Object?> get props => [id, shopId, rating, averageRating, ratingCount];
}
