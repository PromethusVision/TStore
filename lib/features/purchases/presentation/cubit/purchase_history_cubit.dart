import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/purchases/domain/usecases/get_verified_purchases_usecase.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_state.dart';

class PurchaseHistoryCubit extends Cubit<PurchaseHistoryState> {
  final GetVerifiedPurchasesUsecase getVerifiedPurchasesUsecase;
  bool _requestInFlight = false;

  PurchaseHistoryCubit({required this.getVerifiedPurchasesUsecase})
    : super(PurchaseHistoryInitial());

  Future<void> loadPurchases() => _fetchPurchases(showLoading: true);

  Future<void> refreshPurchasesSilently() =>
      _fetchPurchases(showLoading: false);

  Future<void> _fetchPurchases({required bool showLoading}) async {
    if (_requestInFlight) return;

    final previousState = state;
    _requestInFlight = true;
    if (showLoading) {
      emit(PurchaseHistoryLoading());
    }

    try {
      final result = await getVerifiedPurchasesUsecase(const NoParams());
      if (isClosed) return;

      result.fold((error) {
        if (showLoading || previousState is! PurchaseHistoryLoaded) {
          emit(PurchaseHistoryError(error));
        }
      }, (purchases) => emit(PurchaseHistoryLoaded(purchases)));
    } finally {
      _requestInFlight = false;
    }
  }
}
