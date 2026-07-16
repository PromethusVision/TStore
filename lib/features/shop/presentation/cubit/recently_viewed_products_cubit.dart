import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/services/recently_viewed_products_storage.dart';
import 'package:t_store/features/shop/domain/usecases/get_products_by_ids_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/recently_viewed_products_state.dart';

class RecentlyViewedProductRemoval {
  const RecentlyViewedProductRemoval({
    required this.product,
    required this.originalPosition,
  });

  final ProductEntity product;
  final int originalPosition;
}

class RecentlyViewedProductsCubit extends Cubit<RecentlyViewedProductsState> {
  RecentlyViewedProductsCubit({
    required this.storage,
    required this.getProductsByIdsUsecase,
  }) : super(RecentlyViewedProductsInitial());

  final RecentlyViewedProductsStorage storage;
  final GetProductsByIdsUsecase getProductsByIdsUsecase;

  Future<void> load(String customerId) async {
    emit(RecentlyViewedProductsLoading());

    try {
      final productIds = await storage.getProductIds(customerId);
      if (productIds.isEmpty) {
        emit(const RecentlyViewedProductsLoaded([]));
        return;
      }

      final result = await getProductsByIdsUsecase(productIds);
      if (isClosed) return;

      result.fold(
        (_) => emit(
          const RecentlyViewedProductsError(
            'Son görüntülediğin ürünler şu anda yüklenemiyor.',
          ),
        ),
        (products) => emit(
          RecentlyViewedProductsLoaded(
            _orderByRecordedIds(productIds, products),
          ),
        ),
      );
    } catch (_) {
      if (!isClosed) {
        emit(
          const RecentlyViewedProductsError(
            'Son görüntülediğin ürünler şu anda yüklenemiyor.',
          ),
        );
      }
    }
  }

  Future<bool> clear(String customerId) async {
    try {
      await storage.clear(customerId);
      if (!isClosed) emit(const RecentlyViewedProductsLoaded([]));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<RecentlyViewedProductRemoval?> removeProduct(
    String customerId,
    String productId,
  ) async {
    final currentState = state;
    if (currentState is! RecentlyViewedProductsLoaded) return null;

    final productPosition = currentState.products.indexWhere(
      (product) => product.id == productId,
    );
    if (productPosition < 0) return null;

    final removal = RecentlyViewedProductRemoval(
      product: currentState.products[productPosition],
      originalPosition: productPosition,
    );

    try {
      await storage.removeProduct(customerId: customerId, productId: productId);
      if (!isClosed) {
        emit(
          RecentlyViewedProductsLoaded([
            ...currentState.products.take(productPosition),
            ...currentState.products.skip(productPosition + 1),
          ]),
        );
      }
      return removal;
    } catch (_) {
      return null;
    }
  }

  Future<bool> restoreProduct(
    String customerId,
    RecentlyViewedProductRemoval removal,
  ) async {
    final currentState = state;
    if (currentState is! RecentlyViewedProductsLoaded) return false;

    try {
      await storage.restoreProduct(
        customerId: customerId,
        productId: removal.product.id,
        position: removal.originalPosition,
      );
      if (isClosed) return false;

      final products = currentState.products
          .where((product) => product.id != removal.product.id)
          .toList();
      final safePosition = removal.originalPosition
          .clamp(0, products.length)
          .toInt();
      products.insert(safePosition, removal.product);
      emit(RecentlyViewedProductsLoaded(products));
      return true;
    } catch (_) {
      return false;
    }
  }

  List<ProductEntity> _orderByRecordedIds(
    List<String> productIds,
    List<ProductEntity> products,
  ) {
    final productsById = {for (final product in products) product.id: product};

    return [
      for (final productId in productIds)
        if (productsById[productId] case final product?) product,
    ];
  }
}
