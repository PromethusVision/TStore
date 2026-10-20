import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/purchases/domain/usecases/get_verified_purchases_usecase.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_state.dart';
import 'dart:async';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';

class PurchaseHistoryCubit extends Cubit<PurchaseHistoryState> {
  final GetVerifiedPurchasesUsecase getVerifiedPurchasesUsecase;
  bool _requestInFlight = false;
  final AuthenticatedSessionEvents? sessionSource;
  String? _session;
  bool _expired = false;
  StreamSubscription<String?>? _subscription;
  static const _sessionError =
      'Oturumunuz değişti. Bu ekranı kapatıp yeniden açın.';

  PurchaseHistoryCubit({
    required this.getVerifiedPurchasesUsecase,
    this.sessionSource,
  }) : super(PurchaseHistoryInitial()) {
    _session = sessionSource?.currentSessionKey;
    _subscription = sessionSource?.sessionKeyChanges.listen(
      (key) {
        if (key != _session || !_current) _expire();
      },
      onError: (Object _) => _expire(),
      onDone: _expire,
    );
  }
  bool get _current =>
      !_expired &&
      (sessionSource == null ||
          (_session != null && sessionSource!.currentSessionKey == _session));
  void _expire() {
    if (isClosed || _expired) return;
    _expired = true;
    emit(const PurchaseHistoryError(_sessionError));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }

  Future<void> loadPurchases() => _fetchPurchases(showLoading: true);

  Future<void> refreshPurchasesSilently() =>
      _fetchPurchases(showLoading: false);

  Future<void> _fetchPurchases({required bool showLoading}) async {
    if (isClosed) return;
    if (!_current) {
      _expire();
      return;
    }
    if (_requestInFlight) return;

    final previousState = state;
    _requestInFlight = true;
    if (showLoading) {
      emit(PurchaseHistoryLoading());
    }

    try {
      final result = await getVerifiedPurchasesUsecase(const NoParams());
      if (isClosed) return;
      if (!_current) {
        _expire();
        return;
      }

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
