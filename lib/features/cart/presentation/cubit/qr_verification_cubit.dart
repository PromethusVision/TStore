import 'package:flutter_bloc/flutter_bloc.dart';
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

  QrVerificationCubit({
    required this.getQrVerificationUsecase,
    required this.confirmQrVerificationUsecase,
    DateTime Function()? currentTime,
  }) : currentTime = currentTime ?? DateTime.now,
       super(QrVerificationInitial());

  Future<void> loadVerification(String sessionToken) async {
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
    final verification = _verification;
    if (verification == null) {
      _operationId++;
      emit(const QrVerificationFailure('Onaylanacak alışveriş bulunamadı.'));
      return;
    }
    if (state is QrVerificationConfirming || state is QrVerificationSuccess) {
      return;
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
      verification.status == 'active' &&
      verification.expiresAt.isAfter(currentTime());

  void reset() {
    _operationId++;
    _verification = null;
    emit(QrVerificationInitial());
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
