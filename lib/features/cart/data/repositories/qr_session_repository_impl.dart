import 'package:dartz/dartz.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/cart/data/models/qr_session_model.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/cart/domain/repositories/qr_session_repository.dart';

class QrSessionRepositoryImpl implements QrSessionRepository {
  final SupabaseService supabaseService;

  QrSessionRepositoryImpl({required this.supabaseService});

  @override
  Future<Either<String, QrSessionEntity>> createQrSession({
    required String cartId,
  }) async {
    try {
      if (supabaseService.currentUser == null) {
        return const Left('Lutfen once giris yapin');
      }

      if (cartId.trim().isEmpty) {
        return const Left('Aktif magaza sepeti bulunamadi');
      }

      final response = await supabaseService.client.rpc(
        'create_qr_session',
        params: {'p_cart_id': cartId},
      );

      if (response is Map<String, dynamic>) {
        return Right(QrSessionModel.fromJson(response));
      }

      if (response is Map) {
        return Right(
          QrSessionModel.fromJson(Map<String, dynamic>.from(response)),
        );
      }

      return const Left('QR oturumu olusturulamadi');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
