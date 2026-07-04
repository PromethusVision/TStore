import 'package:equatable/equatable.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';

abstract class MyShopState extends Equatable {
  const MyShopState();

  @override
  List<Object?> get props => [];
}

class MyShopInitial extends MyShopState {}

class MyShopLoading extends MyShopState {}

class MyShopLoaded extends MyShopState {
  final ShopEntity shop;

  const MyShopLoaded(this.shop);

  @override
  List<Object?> get props => [shop];
}

class MyShopEmpty extends MyShopState {}

class MyShopError extends MyShopState {
  final String message;

  const MyShopError(this.message);

  @override
  List<Object?> get props => [message];
}
