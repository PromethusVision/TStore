import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/cart/domain/usecases/get_active_cart_items_v2_usecase.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';

class CartV2Cubit extends Cubit<CartV2State> {
  final GetActiveCartItemsV2Usecase getActiveCartItemsV2Usecase;

  CartV2Cubit(this.getActiveCartItemsV2Usecase) : super(CartV2Initial());

  Future<void> getActiveCartItems() async {
    emit(CartV2Loading());

    final result = await getActiveCartItemsV2Usecase(const NoParams());

    result.fold(
      (error) => emit(CartV2Error(error)),
      (items) => emit(CartV2Loaded(items)),
    );
  }
}
