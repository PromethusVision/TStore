import 'package:equatable/equatable.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';

abstract class CustomerSearchState extends Equatable {
  const CustomerSearchState();

  @override
  List<Object?> get props => [];
}

class CustomerSearchInitial extends CustomerSearchState {}

class CustomerSearchLoading extends CustomerSearchState {
  const CustomerSearchLoading(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class CustomerSearchLoaded extends CustomerSearchState {
  const CustomerSearchLoaded({
    required this.query,
    required this.products,
    required this.categories,
    required this.shops,
    this.warningMessage,
  });

  final String query;
  final List<ProductEntity> products;
  final List<CategoryEntity> categories;
  final List<ShopEntity> shops;
  final String? warningMessage;

  bool get isEmpty => products.isEmpty && categories.isEmpty && shops.isEmpty;

  @override
  List<Object?> get props => [
    query,
    products,
    categories,
    shops,
    warningMessage,
  ];
}

class CustomerSearchError extends CustomerSearchState {
  const CustomerSearchError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
