import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/cart/domain/usecases/create_qr_session_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/get_qr_session_status_usecase.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_state.dart';

class QrSessionCubit extends Cubit<QrSessionState> {
  final CreateQrSessionUsecase createQrSessionUsecase;
  final GetQrSessionStatusUsecase getQrSessionStatusUsecase;
  final Duration statusCheckInterval;

  Timer? _statusTimer;
  QrSessionEntity? _activeSession;
  bool _isCheckingStatus = false;
  int _operationId = 0;

  QrSessionCubit({
    required this.createQrSessionUsecase,
    required this.getQrSessionStatusUsecase,
    this.statusCheckInterval = const Duration(seconds: 3),
  }) : super(QrSessionInitial());

  Future<void> createQrSession(String cartId) async {
    final operationId = ++_operationId;
    _stopStatusPolling();
    _activeSession = null;
    emit(QrSessionLoading());

    final result = await createQrSessionUsecase(
      CreateQrSessionParams(cartId: cartId),
    );

    if (isClosed || operationId != _operationId) return;

    result.fold((error) => emit(QrSessionFailure(error)), (session) {
      _activeSession = session;
      emit(QrSessionCreated(session));

      if (session.status == 'active' &&
          session.expiresAt.isAfter(DateTime.now())) {
        _startStatusPolling();
      }
    });
  }

  Future<void> checkSessionStatus([String? sessionId]) async {
    final targetSessionId = sessionId ?? _activeSession?.id;
    if (targetSessionId == null ||
        targetSessionId.isEmpty ||
        _isCheckingStatus ||
        isClosed) {
      return;
    }

    _isCheckingStatus = true;
    try {
      final result = await getQrSessionStatusUsecase(
        GetQrSessionStatusParams(sessionId: targetSessionId),
      );

      if (isClosed || _activeSession?.id != targetSessionId) return;

      result.fold((_) {}, (status) {
        if (status == 'used') {
          _stopStatusPolling();
          _activeSession = null;
          emit(QrSessionCompleted());
          return;
        }

        if (status == 'expired' || status == 'cancelled') {
          _stopStatusPolling();
          _activeSession = null;
          emit(
            QrSessionFailure(
              status == 'expired'
                  ? 'QR kodunun süresi doldu. Yeni bir kod oluşturun.'
                  : 'Sepet değiştiği için QR kodu iptal edildi. Yeni bir kod oluşturun.',
            ),
          );
        }
      });
    } finally {
      _isCheckingStatus = false;
    }
  }

  void _startStatusPolling() {
    _stopStatusPolling();
    _statusTimer = Timer.periodic(statusCheckInterval, (_) {
      final activeSession = _activeSession;
      if (activeSession == null) {
        _stopStatusPolling();
        return;
      }

      if (!activeSession.expiresAt.isAfter(DateTime.now())) {
        _stopStatusPolling();
        unawaited(checkSessionStatus(activeSession.id));
        return;
      }

      unawaited(checkSessionStatus());
    });
  }

  void _stopStatusPolling() {
    _statusTimer?.cancel();
    _statusTimer = null;
  }

  @override
  Future<void> close() {
    _operationId++;
    _stopStatusPolling();
    return super.close();
  }
}
