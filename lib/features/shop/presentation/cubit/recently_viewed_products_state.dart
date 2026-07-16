import 'package:equatable/equatable.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';

sealed class RecentlyViewedProductsState extends Equatable {
  const RecentlyViewedProductsState();

  @override
  List<Object?> get props => const [];
}

final class RecentlyViewedProductsInitial extends RecentlyViewedProductsState {
  const RecentlyViewedProductsInitial();
}

final class RecentlyViewedProductsLoading extends RecentlyViewedProductsState {
  const RecentlyViewedProductsLoading();
}

final class RecentlyViewedProductsLoaded extends RecentlyViewedProductsState {
  const RecentlyViewedProductsLoaded(this.products);

  final List<ProductEntity> products;

  @override
  List<Object?> get props => [products];
}

final class RecentlyViewedProductsError extends RecentlyViewedProductsState {
  const RecentlyViewedProductsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
