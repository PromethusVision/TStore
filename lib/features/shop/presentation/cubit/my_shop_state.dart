import 'package:equatable/equatable.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';

enum MyShopSaveOperation { create, update }

abstract class MyShopState extends Equatable {
  const MyShopState();

  @override
  List<Object?> get props => [];
}

class MyShopInitial extends MyShopState {
  const MyShopInitial();
}

class MyShopLoading extends MyShopState {
  const MyShopLoading();
}

class MyShopLoaded extends MyShopState {
  final ShopEntity shop;

  const MyShopLoaded(this.shop);

  @override
  List<Object?> get props => [shop];
}

class MyShopEmpty extends MyShopState {
  const MyShopEmpty();
}

class MyShopError extends MyShopState {
  final String message;

  const MyShopError(this.message);

  @override
  List<Object?> get props => [message];
}

class MyShopSaving extends MyShopLoading {
  final MyShopSaveOperation operation;
  final ShopEntity? previousShop;

  const MyShopSaving({
    required this.operation,
    this.previousShop,
  });

  @override
  List<Object?> get props => [operation, previousShop];
}

class MyShopSaveSuccess extends MyShopLoaded {
  final MyShopSaveOperation operation;

  const MyShopSaveSuccess({
    required ShopEntity shop,
    required this.operation,
  }) : super(shop);

  @override
  List<Object?> get props => [shop, operation];
}

class MyShopSaveFailure extends MyShopError {
  final MyShopSaveOperation operation;
  final ShopEntity? previousShop;

  const MyShopSaveFailure({
    required this.operation,
    required String message,
    this.previousShop,
  }) : super(message);

  @override
  List<Object?> get props => [message, operation, previousShop];
}
