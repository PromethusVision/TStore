import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/purchases/domain/usecases/get_verified_purchases_usecase.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_state.dart';

class PurchaseHistoryCubit extends Cubit<PurchaseHistoryState> {
  final GetVerifiedPurchasesUsecase getVerifiedPurchasesUsecase;

  PurchaseHistoryCubit({required this.getVerifiedPurchasesUsecase})
    : super(PurchaseHistoryInitial());

  Future<void> loadPurchases() async {
    emit(PurchaseHistoryLoading());

    final result = await getVerifiedPurchasesUsecase(const NoParams());
    result.fold(
      (error) => emit(PurchaseHistoryError(error)),
      (purchases) => emit(PurchaseHistoryLoaded(purchases)),
    );
  }
}
