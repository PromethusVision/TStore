import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/merchant/domain/merchant_operations_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';

class SupabaseMerchantOperationsRepository
    implements MerchantOperationsRepository {
  SupabaseMerchantOperationsRepository(
    this.client, {
    String? Function()? currentUserId,
  }) : currentUserId = currentUserId ?? (() => client.auth.currentUser?.id);
  final SupabaseClient client;
  final String? Function() currentUserId;

  @override
  Future<Either<String, MerchantOperations>> read(
    MerchantAccess access, {
    int page = 0,
  }) async {
    if (currentUserId() != access.user.id || !access.canManage) {
      return const Left(merchantSessionChanged);
    }
    if (page < 0) return const Left('Geçersiz sayfa.');
    try {
      final j = await client.rpc(
        'merchant_operations_read_v1',
        params: {
          'p_shop_id': access.shop!.id,
          'p_offset': page * merchantOperationsPageSize,
          'p_limit': merchantOperationsPageSize,
        },
      );
      if (currentUserId() != access.user.id) {
        return const Left(merchantSessionChanged);
      }
      return Right(
        MerchantOperations(
          pendingSubmissions: j['pending_submissions'] as int,
          approvedSubmissions: j['approved_submissions'] as int,
          rejectedSubmissions: j['rejected_submissions'] as int,
          pendingListings: j['pending_listings'] as int,
          uploads: [
            for (final u in j['uploads'] as List)
              PendingListingUpload(
                u['listing_id'],
                u['product_name'],
                u['photo_count'],
              ),
          ],
        ),
      );
    } on PostgrestException catch (e) {
      return Left(
        e.code == '42501'
            ? merchantAccessDenied
            : ['PGRST202', '42883'].contains(e.code)
            ? 'İşlem özeti henüz kullanıma açılmadı.'
            : 'İşlem özeti yüklenemedi. Yeniden dene.',
      );
    } catch (_) {
      return const Left(
        'İşlem özeti yüklenemedi. Bağlantını kontrol edip yeniden dene.',
      );
    }
  }
}
