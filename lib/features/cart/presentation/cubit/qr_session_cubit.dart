import 'package:t_store/features/cart/domain/qr_session_guard.dart';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/cart/domain/repositories/qr_claim_repository.dart';
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
  bool _isCreatingSession = false;
  bool _isCheckingStatus = false;
  int _operationId = 0;

  QrSessionCubit({
    required this.createQrSessionUsecase,
    required this.getQrSessionStatusUsecase,
    this.statusCheckInterval = const Duration(seconds: 3),
  }) : super(QrSessionInitial()) {
    _sessionGuard = QrSessionGuard(
      createQrSessionUsecase.repository,
      onRetired: _retireSession,
    );
  }

  late final QrSessionGuard _sessionGuard;
  bool get _current => !isClosed && _sessionGuard.current;
  void _retireSession() {
    if (isClosed) return;
    _operationId++;
    _activeSession = null;
    _stopStatusPolling();
    emit(
      const QrSessionFailure(
        'Oturumunuz değişti. Bu ekranı kapatıp yeniden açın.',
      ),
    );
  }

  Future<void> createQrSession(String cartId) async {
    if (_isCreatingSession || !_current) return;

    _isCreatingSession = true;
    final operationId = ++_operationId;
    _stopStatusPolling();
    _activeSession = null;
    try {
      emit(QrSessionLoading());

      final result = await createQrSessionUsecase(
        CreateQrSessionParams(cartId: cartId),
      );

      if (!_current || operationId != _operationId) return;

      result.fold((error) => emit(QrSessionFailure(error)), (session) {
        _activeSession = session;
        emit(QrSessionCreated(session));

        if (session.protocolVersion == 2 ||
            session.status == 'active' &&
                session.expiresAt.isAfter(DateTime.now())) {
          _startStatusPolling();
        }
      });
    } finally {
      _isCreatingSession = false;
    }
  }

  /// A customer-approved checkout uses the same polling and terminal states.
  void useApprovedSession(QrSessionEntity session) {
    if (!_current ||
        _isCreatingSession ||
        session.protocolVersion != 2 ||
        session.couponCheckout == null) {
      return;
    }
    _operationId++;
    _stopStatusPolling();
    _activeSession = session;
    if (session.status == 'used') {
      _activeSession = null;
      emit(QrSessionCompleted(sessionId: session.id));
    } else if (session.status == 'cancelled') {
      _activeSession = null;
      emit(const QrSessionCancelled());
    } else if (session.status == 'expired') {
      _activeSession = null;
      emit(const QrSessionExpired());
    } else {
      emit(QrSessionCreated(session));
      _startStatusPolling();
    }
  }

  Future<void> checkSessionStatus([String? sessionId]) async {
    final targetSessionId = sessionId ?? _activeSession?.id;
    if (targetSessionId == null ||
        targetSessionId.isEmpty ||
        _isCheckingStatus ||
        !_current) {
      return;
    }

    _isCheckingStatus = true;
    final operation = _operationId;
    try {
      final repository = _activeSession?.protocolVersion == 2
          ? getQrSessionStatusUsecase.repository
          : null;
      if (_activeSession?.protocolVersion == 2 &&
          repository is QrClaimRepository) {
        final result = await (repository as QrClaimRepository)
            .readCustomerSession(targetSessionId);
        if (!_current ||
            operation != _operationId ||
            _activeSession?.id != targetSessionId) {
          return;
        }
        result.fold(
          (_) {
            emit(QrSessionCreated(_activeSession!, isStatusCheckDelayed: true));
          },
          (session) {
            if (session.id != targetSessionId) {
              emit(
                QrSessionCreated(_activeSession!, isStatusCheckDelayed: true),
              );
              return;
            }
            if (session.status == 'active' || session.status == 'claimed') {
              _activeSession = session;
              emit(QrSessionCreated(session));
            } else {
              _stopStatusPolling();
              _activeSession = null;
              if (session.status == 'used') {
                emit(QrSessionCompleted(sessionId: session.id));
              } else if (session.status == 'cancelled') {
                emit(const QrSessionCancelled());
              } else {
                emit(const QrSessionExpired());
              }
            }
          },
        );
        return;
      }
      final result = await getQrSessionStatusUsecase(
        GetQrSessionStatusParams(sessionId: targetSessionId),
      );

      if (!_current ||
          operation != _operationId ||
          _activeSession?.id != targetSessionId) {
        return;
      }

      result.fold(
        (_) {
          final activeSession = _activeSession;
          if (activeSession != null) {
            emit(QrSessionCreated(activeSession, isStatusCheckDelayed: true));
          }
        },
        (status) {
          if (status == 'active') {
            final activeSession = _activeSession;
            final currentState = state;
            if (activeSession != null &&
                currentState is QrSessionCreated &&
                currentState.isStatusCheckDelayed) {
              emit(QrSessionCreated(activeSession));
            }
            return;
          }

          if (status == 'used') {
            final completedSessionId = _activeSession?.id ?? targetSessionId;
            _stopStatusPolling();
            _activeSession = null;
            emit(QrSessionCompleted(sessionId: completedSessionId));
            return;
          }

          if (status == 'cancelled') {
            _stopStatusPolling();
            _activeSession = null;
            emit(const QrSessionCancelled());
            return;
          }

          if (status == 'expired') {
            _stopStatusPolling();
            _activeSession = null;
            emit(const QrSessionExpired());
          }
        },
      );
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

      if (activeSession.protocolVersion != 2 &&
          !activeSession.expiresAt.isAfter(DateTime.now())) {
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
    _sessionGuard.close();
    _operationId++;
    _stopStatusPolling();
    return super.close();
  }
}
