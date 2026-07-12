import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';
import 'package:t_store/features/cart/domain/usecases/confirm_qr_verification_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/get_qr_verification_usecase.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_verification_state.dart';

class QrVerificationCubit extends Cubit<QrVerificationState> {
  final GetQrVerificationUsecase getQrVerificationUsecase;
  final ConfirmQrVerificationUsecase confirmQrVerificationUsecase;

  QrVerificationEntity? _verification;
  int _operationId = 0;

  QrVerificationCubit({
    required this.getQrVerificationUsecase,
    required this.confirmQrVerificationUsecase,
  }) : super(QrVerificationInitial());

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
      if (verification.status != 'active') {
        _verification = null;
        emit(QrVerificationFailure(_inactiveQrMessage(verification.status)));
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
    if (state is QrVerificationConfirming) return;

    final operationId = ++_operationId;
    emit(QrVerificationConfirming(verification));

    final result = await confirmQrVerificationUsecase(
      ConfirmQrVerificationParams(sessionToken: verification.sessionToken),
    );

    if (isClosed || operationId != _operationId) return;

    result.fold((error) => emit(QrVerificationFailure(error)), (
      confirmedVerification,
    ) {
      _verification = confirmedVerification;
      emit(QrVerificationSuccess(confirmedVerification));
    });
  }

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
