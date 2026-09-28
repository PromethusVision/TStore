import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';

class MerchantCatalogState {
  const MerchantCatalogState({
    this.items = const [],
    this.loading = false,
    this.hasMore = true,
    this.error,
    this.query = '',
  });
  final List<ShopProductEntity> items;
  final bool loading, hasMore;
  final String? error;
  final String query;
}

class MerchantCatalogCubit extends Cubit<MerchantCatalogState> {
  MerchantCatalogCubit(this.repository, this.access)
    : super(const MerchantCatalogState());
  final MerchantRepository repository;
  final MerchantAccess access;
  int _epoch = 0;
  int _nextPage = 0;

  Future<void> load({bool refresh = false, String? query}) async {
    if (isClosed || (state.loading && !refresh)) return;
    if (!refresh && !state.hasMore) return;
    if (refresh) {
      ++_epoch;
      _nextPage = 0;
    }
    final epoch = _epoch;
    final search = query ?? state.query;
    final previous = refresh ? <ShopProductEntity>[] : state.items;
    emit(MerchantCatalogState(items: previous, loading: true, query: search));
    try {
      final result = await repository.listings(
        access,
        page: _nextPage,
        query: search,
      );
      if (isClosed || epoch != _epoch) return;
      result.fold(
        (error) {
          emit(
            MerchantCatalogState(items: previous, query: search, error: error),
          );
        },
        (items) {
          ++_nextPage;
          final merged = {for (final item in previous) item.id: item};
          for (final item in items) {
            merged[item.id] = item;
          }
          emit(
            MerchantCatalogState(
              items: List.unmodifiable(merged.values),
              query: search,
              hasMore: items.length == merchantPageSize,
            ),
          );
        },
      );
    } catch (_) {
      if (!isClosed && epoch == _epoch) {
        emit(
          MerchantCatalogState(
            items: previous,
            query: search,
            error: 'Ürünler yüklenemedi. Tekrar deneyin.',
          ),
        );
      }
    }
  }
}
