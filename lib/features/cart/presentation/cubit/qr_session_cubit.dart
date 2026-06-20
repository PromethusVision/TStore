import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/cart/domain/usecases/create_qr_session_usecase.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_state.dart';

class QrSessionCubit extends Cubit<QrSessionState> {
  final CreateQrSessionUsecase createQrSessionUsecase;

  QrSessionCubit({required this.createQrSessionUsecase})
      : super(QrSessionInitial());

  Future<void> createQrSession(String cartId) async {
    emit(QrSessionLoading());

    final result = await createQrSessionUsecase(
      CreateQrSessionParams(cartId: cartId),
    );

    result.fold(
      (error) => emit(QrSessionFailure(error)),
      (session) => emit(QrSessionCreated(session)),
    );
  }
}
