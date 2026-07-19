import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:t_store/features/wishlist/domain/usecases/get_wishlist_usecase.dart';
import 'package:t_store/features/wishlist/domain/usecases/add_to_wishlist_usecase.dart';
import 'package:t_store/features/wishlist/domain/usecases/remove_from_wishlist_usecase.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class WishlistCubit extends Cubit<WishlistState> {
  final GetWishlistUsecase getWishlistUsecase;
  final AddToWishlistUsecase addToWishlistUsecase;
  final RemoveFromWishlistUsecase removeFromWishlistUsecase;
  int _dataGeneration = 0;

  WishlistCubit({
    required this.getWishlistUsecase,
    required this.addToWishlistUsecase,
    required this.removeFromWishlistUsecase,
  }) : super(WishlistInitial());

  List<WishlistItemEntity> _items = [];
  Set<String> _productIds = {};

  Future<void> getWishlist() async {
    final dataGeneration = _dataGeneration;
    emit(WishlistLoading());

    final result = await getWishlistUsecase(const NoParams());
    if (!_canApply(dataGeneration)) return;

    result.fold((error) => emit(WishlistError(error)), (items) {
      _items = items;
      _productIds = items.map((e) => e.productId).toSet();
      emit(WishlistLoaded(items));
    });
  }

  Future<void> addToWishlist(String productId) async {
    final dataGeneration = _dataGeneration;
    final result = await addToWishlistUsecase(productId);
    if (!_canApply(dataGeneration)) return;

    await result.fold<Future<void>>(
      (error) async => emit(WishlistError(error)),
      (item) async {
        emit(WishlistItemAdded(item));
        await getWishlist();
      },
    );
  }

  Future<void> removeFromWishlist(String productId) async {
    final dataGeneration = _dataGeneration;
    final result = await removeFromWishlistUsecase(productId);
    if (!_canApply(dataGeneration)) return;

    await result.fold<Future<void>>(
      (error) async => emit(WishlistError(error)),
      (_) async {
        emit(WishlistItemRemoved(productId));
        await getWishlist();
      },
    );
  }

  Future<void> toggleWishlist(String productId) async {
    if (isInWishlist(productId)) {
      await removeFromWishlist(productId);
    } else {
      await addToWishlist(productId);
    }
  }

  bool isInWishlist(String productId) {
    return _productIds.contains(productId);
  }

  void clearLocalWishlist() {
    _dataGeneration += 1;
    _items = [];
    _productIds = {};
    emit(WishlistLoaded(const []));
  }

  int get itemCount => _items.length;

  bool _canApply(int dataGeneration) {
    return !isClosed && dataGeneration == _dataGeneration;
  }
}
