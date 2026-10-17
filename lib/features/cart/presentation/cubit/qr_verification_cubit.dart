import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:t_store/features/cart/data/qr_installation.dart';
import 'package:t_store/features/cart/domain/repositories/qr_claim_repository.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';
import 'package:t_store/features/cart/domain/usecases/confirm_qr_verification_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/get_qr_verification_usecase.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_verification_state.dart';

class QrVerificationCubit extends Cubit<QrVerificationState> {
  final GetQrVerificationUsecase getQrVerificationUsecase;
  final ConfirmQrVerificationUsecase confirmQrVerificationUsecase;
  final DateTime Function() currentTime;

  QrVerificationEntity? _verification;
  int _operationId = 0;
  final String? shopId;
  String? _claimRequestId;
  String? _claimInput;
  QrClaimRepository? get claims {
    final r = getQrVerificationUsecase.repository;
    return r is QrClaimRepository && (r as QrClaimRepository).claimsEnabled
        ? r as QrClaimRepository
        : null;
  }

  QrVerificationCubit({
    required this.getQrVerificationUsecase,
    required this.confirmQrVerificationUsecase,
    DateTime Function()? currentTime,
    this.shopId,
  }) : currentTime = currentTime ?? DateTime.now,
       super(QrVerificationInitial());

  Future<void> loadVerification(String sessionToken) async {
    if (shopId != null && claims != null) {
      return claimVerification(sessionToken: sessionToken.trim());
    }
    final operationId = ++_operationId;
    final normalizedToken = sessionToken.trim();
    if (normalizedToken.isEmpty) {
      _verification = null;
      emit(
        const QrVerificationFailure(
          'QR kodu okunamadı. Lütfen yeniden okutun.',
        ),
      );
      return;
    }

    _verification = null;
    emit(QrVerificationLoading());

    final result = await getQrVerificationUsecase(
      GetQrVerificationParams(sessionToken: normalizedToken),
    );

    if (isClosed || operationId != _operationId) return;

    result.fold((error) => emit(QrVerificationFailure(error)), (verification) {
      if (!_canBeConfirmed(verification)) {
        _verification = null;
        final status = verification.status == 'active'
            ? 'expired'
            : verification.status;
        emit(QrVerificationFailure(_inactiveQrMessage(status)));
        return;
      }
      _verification = verification;
      emit(QrVerificationLoaded(verification));
    });
  }

  Future<void> confirmVerification() async {
    if (isClosed ||
        state is QrClaimRecoveryRequired ||
        state is QrVerificationLoading) {
      return;
    }
    final verification = _verification;
    if (verification == null) {
      _operationId++;
      emit(const QrVerificationFailure('Onaylanacak alışveriş bulunamadı.'));
      return;
    }
    if (state is QrVerificationConfirming || state is QrVerificationSuccess) {
      return;
    }
    if (verification.protocolVersion == 2) {
      if (state is QrVerificationUncertain) return;
      return _claimOperation(complete: true);
    }
    if (!_canBeConfirmed(verification)) {
      _operationId++;
      _verification = null;
      emit(const QrVerificationFailure('QR kodunun süresi dolmuş.'));
      return;
    }

    final operationId = ++_operationId;
    emit(QrVerificationConfirming(verification));

    final result = await confirmQrVerificationUsecase(
      ConfirmQrVerificationParams(sessionToken: verification.sessionToken),
    );

    if (isClosed || operationId != _operationId) return;

    await result.fold(
      (error) => _reconcileConfirmationFailure(
        operationId: operationId,
        verification: verification,
        originalError: error,
      ),
      (confirmedVerification) async {
        if (!_isConfirmedVersionOf(verification, confirmedVerification)) {
          emit(
            const QrVerificationFailure(
              'Sunucu alışveriş onayını güvenli biçimde doğrulayamadı.',
            ),
          );
          return;
        }

        _verification = confirmedVerification;
        emit(QrVerificationSuccess(confirmedVerification));
      },
    );
  }

  Future<void> _reconcileConfirmationFailure({
    required int operationId,
    required QrVerificationEntity verification,
    required String originalError,
  }) async {
    final result = await getQrVerificationUsecase(
      GetQrVerificationParams(sessionToken: verification.sessionToken),
    );

    if (isClosed || operationId != _operationId) return;

    result.fold((_) => emit(QrVerificationFailure(originalError)), (current) {
      if (_isConfirmedVersionOf(verification, current)) {
        _verification = current;
        emit(QrVerificationSuccess(current));
        return;
      }

      if (!_canBeConfirmed(current)) {
        _verification = null;
        final status = current.status == 'active' ? 'expired' : current.status;
        emit(QrVerificationFailure(_inactiveQrMessage(status)));
        return;
      }

      _verification = current;
      emit(QrVerificationFailure(originalError));
    });
  }

  static bool _isConfirmedVersionOf(
    QrVerificationEntity original,
    QrVerificationEntity candidate,
  ) =>
      candidate.sessionId == original.sessionId &&
      candidate.sessionToken == original.sessionToken &&
      candidate.shopId == original.shopId &&
      candidate.status == 'used' &&
      candidate.usedAt != null;

  bool _canBeConfirmed(QrVerificationEntity verification) =>
      verification.canConfirmAt(currentTime());

  Future<void> claimVerification({
    String? sessionToken,
    String? manualCode,
  }) async {
    if (isClosed ||
        claims == null ||
        shopId == null ||
        state is QrVerificationLoading ||
        state is QrVerificationConfirming ||
        state is QrVerificationUncertain ||
        state is QrClaimRecoveryRequired ||
        _verification?.canConfirmAt(currentTime()) == true) {
      return;
    }
    final input = sessionToken == null
        ? 'manual:$manualCode'
        : 'scan:$sessionToken';
    if ((manualCode == null) == (sessionToken == null) ||
        manualCode != null && !RegExp(r'^\d{6}$').hasMatch(manualCode) ||
        sessionToken != null && sessionToken.isEmpty) {
      emit(const QrVerificationFailure('Altı haneli kodu eksiksiz girin.'));
      return;
    }
    if (_claimInput != input) {
      _claimInput = input;
      _claimRequestId = newQrRequestId();
    }
    final operation = ++_operationId;
    _verification = null;
    emit(QrVerificationLoading());
    final result = await _claimCall(
      () => claims!.claimVerification(
        shopId: shopId!,
        requestId: _claimRequestId!,
        sessionToken: sessionToken,
        manualCode: manualCode,
      ),
    );
    if (isClosed || operation != _operationId) return;
    result.fold((e) => emit(QrClaimRecoveryRequired(e)), _acceptClaim);
  }

  void _acceptClaim(QrVerificationEntity value) {
    if (value.protocolVersion != 2 ||
        value.shopId != shopId ||
        value.claimId == null ||
        value.completionExpiresAt == null ||
        value.status == 'used' &&
            (value.purchaseId == null || value.usedAt == null)) {
      emit(const QrClaimRecoveryRequired('QR işlem bilgisi doğrulanamadı.'));
      return;
    }
    _verification = value;
    if (value.status == 'used' &&
        value.purchaseId != null &&
        value.usedAt != null) {
      emit(QrVerificationSuccess(value));
    } else if (_canBeConfirmed(value)) {
      emit(QrVerificationLoaded(value));
    } else {
      _verification = null;
      emit(
        QrVerificationFailure(
          _inactiveQrMessage(
            value.status == 'claimed' ? 'expired' : value.status,
          ),
        ),
      );
    }
  }

  Future<void> recoverClaim() async {
    if (isClosed ||
        claims == null ||
        shopId == null ||
        state is QrVerificationConfirming ||
        state is QrVerificationLoading) {
      return;
    }
    // Never replace a known uncertain attempt with "latest claim" or null.
    if (_verification?.claimId != null) return _claimOperation();
    final operation = ++_operationId;
    emit(QrVerificationLoading());
    final result = await _claimCall(() => claims!.recoverClaim(shopId!));
    if (isClosed || operation != _operationId) return;
    result.fold((e) => emit(QrClaimRecoveryRequired(e)), (v) {
      if (v == null) {
        _verification = null;
        emit(QrVerificationInitial());
      } else {
        _acceptClaim(v);
      }
    });
  }

  Future<void> refreshClaim() =>
      _verification?.claimId == null ? recoverClaim() : _claimOperation();
  Future<void> cancelClaim() => _claimOperation(cancel: true);
  Future<void> _claimOperation({
    bool complete = false,
    bool cancel = false,
  }) async {
    final previous = _verification;
    if (isClosed ||
        claims == null ||
        previous?.claimId == null ||
        state is QrVerificationConfirming ||
        state is QrVerificationLoading ||
        (complete || cancel) && state is QrVerificationUncertain) {
      return;
    }
    if (complete && !_canBeConfirmed(previous!)) {
      return _claimOperation();
    }
    final operation = ++_operationId;
    emit(QrVerificationConfirming(previous!));
    final result = await _claimCall(
      () => complete
          ? claims!.completeClaim(previous.claimId!)
          : cancel
          ? claims!.cancelClaim(previous.claimId!)
          : claims!.reconcileClaim(previous.claimId!),
    );
    if (isClosed || operation != _operationId) return;
    await result.fold((error) async {
      if (complete || cancel) {
        final reconciled = await _claimCall(
          () => claims!.reconcileClaim(previous.claimId!),
        );
        if (isClosed || operation != _operationId) return;
        reconciled.fold(
          (_) => emit(QrVerificationUncertain(previous, error)),
          (v) => _acceptMatchingClaim(previous, v),
        );
      } else {
        emit(QrVerificationUncertain(previous, error));
      }
    }, (v) async => _acceptMatchingClaim(previous, v));
  }

  void _acceptMatchingClaim(
    QrVerificationEntity previous,
    QrVerificationEntity value,
  ) {
    if (value.sessionId != previous.sessionId ||
        value.claimId != previous.claimId ||
        value.shopId != previous.shopId ||
        value.sessionToken != previous.sessionToken ||
        value.protocolVersion != previous.protocolVersion ||
        value.expiresAt != previous.expiresAt ||
        value.completionExpiresAt != previous.completionExpiresAt ||
        (previous.purchaseId != null &&
            value.purchaseId != previous.purchaseId) ||
        value.totalAmount != previous.totalAmount ||
        value.itemCount != previous.itemCount ||
        value.rewardConfirmationRequired !=
            previous.rewardConfirmationRequired ||
        value.rewardSaleMinor != previous.rewardSaleMinor ||
        value.couponCheckout != previous.couponCheckout ||
        value.items.length != previous.items.length ||
        !List.generate(
          value.items.length,
          (i) => value.items[i] == previous.items[i],
        ).every((v) => v)) {
      emit(
        QrVerificationUncertain(
          previous,
          'İşlemin sonucu doğrulanamadı. Yeniden kontrol edin.',
        ),
      );
      return;
    }
    _acceptClaim(value);
  }

  void reset() {
    if (isClosed ||
        state is QrClaimRecoveryRequired ||
        (shopId != null && state is QrVerificationLoading && claims != null)) {
      return;
    }
    if (_verification?.protocolVersion == 2 &&
        (state is QrVerificationUncertain ||
            state is QrVerificationConfirming ||
            _verification?.canConfirmAt(currentTime()) == true)) {
      return;
    }
    _operationId++;
    _verification = null;
    _claimInput = null;
    _claimRequestId = null;
    emit(QrVerificationInitial());
  }

  Future<Either<String, T>> _claimCall<T>(
    Future<Either<String, T>> Function() request,
  ) async {
    try {
      return await request();
    } catch (_) {
      return const Left(
        'İşlem sonucu doğrulanamadı. Aynı işlemi geri yükleyin.',
      );
    }
  }

  static String _inactiveQrMessage(String status) {
    switch (status) {
      case 'used':
        return 'Bu QR kodu daha önce kullanılmış.';
      case 'expired':
        return 'QR kodunun süresi dolmuş.';
      case 'cancelled':
        return 'Sepet değiştiği için bu QR kodu iptal edilmiş.';
      default:
        return 'QR kodu artık geçerli değil.';
    }
  }
}
