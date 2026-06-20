import 'package:dartz/dartz.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';

abstract class QrSessionRepository {
  Future<Either<String, QrSessionEntity>> createQrSession({
    required String cartId,
  });
}
