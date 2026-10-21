import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/authenticated_session_key.dart';
import 'package:t_store/features/merchant/data/merchant_request_scope.dart';
import 'package:t_store/features/merchant/domain/merchant_operations_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';

class SupabaseMerchantOperationsRepository
    implements MerchantOperationsRepository {
  SupabaseMerchantOperationsRepository(
    this.client, {
    String? Function()? currentUserId,
    String? Function()? currentSessionKey,
    this.readTimeout = const Duration(seconds: 15),
  }) : currentUserId = currentUserId ?? (() => client.auth.currentUser?.id),
       currentSessionKey =
           currentSessionKey ?? (() => authenticatedSessionKey(client));
  final SupabaseClient client;
  final String? Function() currentUserId;
  final String? Function() currentSessionKey;
  final Duration readTimeout;

  @override
  Future<Either<String, MerchantOperations>> read(
    MerchantAccess access, {
    int page = 0,
  }) async {
    if (currentUserId() != access.user.id || !access.canManage) {
      return const Left(merchantSessionChanged);
    }
    if (page < 0) return const Left('Geçersiz sayfa.');
    final scope = MerchantRequestScope(
      userId: currentUserId(),
      sessionKey: currentSessionKey(),
      currentUserId: currentUserId,
      currentSessionKey: currentSessionKey,
      changes: client.auth.onAuthStateChange.map(
        (event) => event.session?.user.id,
      ),
      sessionKeys: client.auth.onAuthStateChange.map(
        (event) => authenticatedSessionKeyFromSession(event.session),
      ),
    );
    try {
      final j = await scope.run(
        () => client
            .rpc(
              'merchant_operations_read_v1',
              params: {
                'p_shop_id': access.shop!.id,
                'p_offset': page * merchantOperationsPageSize,
                'p_limit': merchantOperationsPageSize,
              },
            )
            .timeout(readTimeout),
      );
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
    } on MerchantRequestChanged {
      return const Left(merchantSessionChanged);
    } on TimeoutException {
      return const Left(merchantReadTimeout);
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
    } finally {
      await scope.close();
    }
  }
}
