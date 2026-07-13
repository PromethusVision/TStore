import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/usecases/get_shops_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_state.dart';

class NearbyShopsCubit extends Cubit<NearbyShopsState> {
  final GetShopsUsecase getShopsUsecase;

  int _activeRequestId = 0;

  NearbyShopsCubit({required this.getShopsUsecase})
    : super(const NearbyShopsInitial());

  Future<void> loadShops() async {
    final requestId = ++_activeRequestId;
    emit(const NearbyShopsLoading());

    final result = await getShopsUsecase(const NoParams());

    if (isClosed || requestId != _activeRequestId) return;

    result.fold(
      (error) => emit(NearbyShopsError(error)),
      (shops) => emit(
        shops.isEmpty ? const NearbyShopsEmpty() : NearbyShopsLoaded(shops),
      ),
    );
  }
}
