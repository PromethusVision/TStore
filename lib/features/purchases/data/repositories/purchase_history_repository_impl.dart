import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/features/purchases/data/models/verified_purchase_model.dart';
import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';
import 'package:t_store/features/purchases/domain/repositories/purchase_history_repository.dart';

class PurchaseHistoryRepositoryImpl implements PurchaseHistoryRepository {
  final SupabaseService supabaseService;
  final bool reviewsEnabled;

  PurchaseHistoryRepositoryImpl({
    required this.supabaseService,
    this.reviewsEnabled = const bool.fromEnvironment('REVIEWS_V2_ENABLED'),
  });

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
            'id, shop_product_id, product_id, product_name, quantity, unit_price, '
            'line_total), shop_ratings(rating, created_at)',
          )
          .eq('customer_user_id', user.id)
          .order('confirmed_at', ascending: false);

      final rows = (response as List)
          .map((r) => Map<String, dynamic>.from(r as Map))
          .toList();
      if (reviewsEnabled && rows.isNotEmpty) {
        bool available = false;
        try {
          final capability = await supabaseService.client
              .rpc('review_capabilities_v2')
              .timeout(const Duration(seconds: 20));
          if (capability is! Map || capability['version'] != 2) {
            throw const FormatException();
          }
          available = true;
        } on PostgrestException catch (error) {
          if (error.code != 'PGRST202' && error.code != '42883') rethrow;
        }
        if (available) {
          for (var start = 0; start < rows.length; start += 100) {
            if (supabaseService.currentUser?.id != user.id) {
              return const Left('Oturumunuz değişti. Yeniden giriş yapın.');
            }
            final batch = rows.skip(start).take(100).toList(),
                ids = rows
                    .skip(start)
                    .take(100)
                    .map((r) => r['id'] as String)
                    .toSet();
            final serviceRows = await supabaseService.client
                .rpc(
                  'read_customer_service_evaluations_v2',
                  params: {'p_purchase_ids': ids.toList()},
                )
                .timeout(const Duration(seconds: 20));
            if (serviceRows is! List) throw const FormatException();
            final byId = <String, Map<String, dynamic>>{};
            for (final raw in serviceRows) {
              final entry = Map<String, dynamic>.from(raw as Map),
                  id = entry['purchase_id'] as String;
              if (!ids.contains(id) || byId.containsKey(id)) {
                throw const FormatException();
              }
              byId[id] = entry;
            }
            for (final row in batch) {
              row['service_evaluation'] = byId[row['id']];
            }
          }
        }
      }

      if (supabaseService.currentUser?.id != user.id) {
        return const Left(
          'Oturumunuz değişti. Güvenliğiniz için yeniden giriş yapın.',
        );
      }

      final purchases = rows
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
