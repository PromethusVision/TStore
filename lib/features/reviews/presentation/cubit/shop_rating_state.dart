import 'package:equatable/equatable.dart';
import 'package:t_store/features/reviews/domain/entities/shop_rating_entity.dart';

abstract class ShopRatingState extends Equatable {
  const ShopRatingState();

  @override
  List<Object?> get props => [];
}

class ShopRatingInitial extends ShopRatingState {}

class ShopRatingSubmitting extends ShopRatingState {}

class ShopRatingSuccess extends ShopRatingState {
  final ShopRatingEntity rating;

  const ShopRatingSuccess(this.rating);

  @override
  List<Object?> get props => [rating];
}

class ShopRatingFailure extends ShopRatingState {
  final String message;

  const ShopRatingFailure(this.message);

  @override
  List<Object?> get props => [message];
}
