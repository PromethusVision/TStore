import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/usecases/create_my_shop_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/get_my_shop_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/update_my_shop_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/my_shop_state.dart';

class MyShopCubit extends Cubit<MyShopState> {
  final GetMyShopUsecase getMyShopUsecase;
  final CreateMyShopUsecase createMyShopUsecase;
  final UpdateMyShopUsecase updateMyShopUsecase;

  ShopEntity? _currentShop;

  MyShopCubit({
    required this.getMyShopUsecase,
    required this.createMyShopUsecase,
    required this.updateMyShopUsecase,
  }) : super(const MyShopInitial());

  Future<void> loadMyShop() async {
    emit(const MyShopLoading());

    final result = await getMyShopUsecase(const NoParams());

    result.fold(
      (error) => emit(MyShopError(error)),
      (shop) {
        _currentShop = shop;
        if (shop == null) {
          emit(const MyShopEmpty());
        } else {
          emit(MyShopLoaded(shop));
        }
      },
    );
  }

  Future<void> createMyShop({
    required String name,
    String? description,
    String? phone,
    String? address,
    Map<String, dynamic>? openingHours,
  }) async {
    final previousShop = _currentShop;
    emit(
      MyShopSaving(
        operation: MyShopSaveOperation.create,
        previousShop: previousShop,
      ),
    );

    final result = await createMyShopUsecase(
      CreateMyShopParams(
        name: name,
        description: description,
        phone: phone,
        address: address,
        openingHours: openingHours,
      ),
    );

    result.fold(
      (_) => emit(
        MyShopSaveFailure(
          operation: MyShopSaveOperation.create,
          message: 'Mağaza oluşturulamadı. Lütfen tekrar deneyin.',
          previousShop: previousShop,
        ),
      ),
      (shop) {
        _currentShop = shop;
        emit(
          MyShopSaveSuccess(
            shop: shop,
            operation: MyShopSaveOperation.create,
          ),
        );
      },
    );
  }

  Future<void> updateMyShop({
    required String shopId,
    required String name,
    String? description,
    String? phone,
    String? address,
    Map<String, dynamic>? openingHours,
  }) async {
    final previousShop = _currentShop;
    emit(
      MyShopSaving(
        operation: MyShopSaveOperation.update,
        previousShop: previousShop,
      ),
    );

    final result = await updateMyShopUsecase(
      UpdateMyShopParams(
        shopId: shopId,
        name: name,
        description: description,
        phone: phone,
        address: address,
        openingHours: openingHours,
      ),
    );

    result.fold(
      (_) => emit(
        MyShopSaveFailure(
          operation: MyShopSaveOperation.update,
          message: 'Mağaza güncellenemedi. Lütfen tekrar deneyin.',
          previousShop: previousShop,
        ),
      ),
      (shop) {
        _currentShop = shop;
        emit(
          MyShopSaveSuccess(
            shop: shop,
            operation: MyShopSaveOperation.update,
          ),
        );
      },
    );
  }
}
