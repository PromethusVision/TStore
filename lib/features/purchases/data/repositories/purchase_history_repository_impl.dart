import 'package:dartz/dartz.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/features/purchases/data/models/verified_purchase_model.dart';
import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';
import 'package:t_store/features/purchases/domain/repositories/purchase_history_repository.dart';

class PurchaseHistoryRepositoryImpl implements PurchaseHistoryRepository {
  final SupabaseService supabaseService;

  PurchaseHistoryRepositoryImpl({required this.supabaseService});

  @override
  Future<Either<String, List<VerifiedPurchaseEntity>>>
  getVerifiedPurchases() async {
    try {
      final user = supabaseService.currentUser;
      if (user == null) {
        return const Left('Alışverişlerini görmek için giriş yapın.');
      }

      final response = await supabaseService.client
          .from(SupabaseTables.verifiedTransactions)
          .select(
            'id, source_qr_session_id, shop_id, shop_name, item_count, '
            'total_amount, confirmed_at, '
            'verified_transaction_items('
            'id, shop_product_id, product_name, quantity, unit_price, '
            'line_total)',
          )
          .eq('customer_user_id', user.id)
          .order('confirmed_at', ascending: false);

      final purchases = (response as List)
          .map(
            (json) => VerifiedPurchaseModel.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
          )
          .toList(growable: false);

      return Right(purchases);
    } catch (error) {
      return Left(_friendlyError(error));
    }
  }

  static String _friendlyError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('jwt') ||
        message.contains('not authenticated') ||
        message.contains('authentication required')) {
      return 'Oturumunuz sona ermiş olabilir. Lütfen yeniden giriş yapın.';
    }
    if (message.contains('permission denied') ||
        message.contains('row-level security') ||
        message.contains('42501')) {
      return 'Alışveriş kayıtlarını görüntüleme izniniz bulunamadı.';
    }
    return 'Alışverişlerin şu anda görüntülenemiyor. Lütfen tekrar dene.';
  }
}
