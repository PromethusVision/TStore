import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/usecases/get_my_shop_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/my_shop_state.dart';

class MyShopCubit extends Cubit<MyShopState> {
  final GetMyShopUsecase getMyShopUsecase;

  MyShopCubit({required this.getMyShopUsecase}) : super(MyShopInitial());

  Future<void> loadMyShop() async {
    emit(MyShopLoading());

    final result = await getMyShopUsecase(const NoParams());

    result.fold(
      (error) => emit(MyShopError(error)),
      (shop) {
        if (shop == null) {
          emit(MyShopEmpty());
        } else {
          emit(MyShopLoaded(shop));
        }
      },
    );
  }
}
