import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';
import 'package:t_store/core/supabase/authenticated_session_key.dart';
import 'package:t_store/features/cart/data/models/qr_session_model.dart';
import 'package:t_store/features/cart/data/models/qr_verification_model.dart';
import 'package:t_store/features/cart/data/qr_installation.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';

/// Versioned transport used by QrSessionRepositoryImpl, sharing Auth and QR IDs.
class QrProtocolV2 {
  QrProtocolV2(
    this.client, {
    Future<String> Function()? installation,
    String? Function()? sessionIdentity,
    Stream<String?>? sessionKeys,
    this.rewardEarningEnabled = false,
    this.couponCheckoutEnabled = false,
  }) : installation = installation ?? QrInstallation.load,
       sessionIdentity =
           sessionIdentity ?? (() => authenticatedSessionIdentity(client)),
       sessionKeys =
           sessionKeys ??
           client.auth.onAuthStateChange.map(
             (event) => authenticatedSessionKeyFromSession(event.session),
           );
  final SupabaseClient client;
  final bool rewardEarningEnabled;
  final bool couponCheckoutEnabled;
  final Future<String> Function() installation;
  final String? Function() sessionIdentity;
  final Stream<String?> sessionKeys;

  static String? authenticatedSessionIdentity(SupabaseClient client) =>
      authenticatedSessionKey(client);

  AuthenticatedRequestScope openScope() {
    final identity = sessionIdentity();
    return AuthenticatedRequestScope(
      user: identity,
      session: identity,
      currentUser: sessionIdentity,
      currentSession: sessionIdentity,
      changes: sessionKeys,
    );
  }

  Future<Either<String, T>> run<T>(
    Future<T> Function() operation, {
    void Function(PostgrestException)? onServerError,
  }) => runScoped((_) => operation(), onServerError: onServerError);

  Future<Either<String, T>> runScoped<T>(
    Future<T> Function(AuthenticatedRequestScope) operation, {
    void Function(PostgrestException)? onServerError,
  }) async {
    if (sessionIdentity() == null) {
      return const Left('Giriş oturumunuz doğrulanamadı. Yeniden giriş yapın.');
    }
    final scope = openScope();
    try {
      final result = await scope.run(() => operation(scope));
      return Right(result);
    } on PostgrestException catch (e) {
      if (!scope.current) {
        return const Left('Oturumunuz değişti. Yeniden giriş yapın.');
      }
      onServerError?.call(e);
      return Left(friendlyError(e.message));
    } on FormatException catch (_) {
      if (!scope.current) {
        return const Left('Oturumunuz değişti. Yeniden giriş yapın.');
      }
      return const Left(
        'Sunucunun işlem bilgisi doğrulanamadı. Durumu yeniden kontrol edin.',
      );
    } on QrProtocolFailure catch (e) {
      if (!scope.current) {
        return const Left('Oturumunuz değişti. Yeniden giriş yapın.');
      }
      return Left(friendlyError(e.code));
    } catch (_) {
      if (!scope.current) {
        return const Left('Oturumunuz değişti. Yeniden giriş yapın.');
      }
      return const Left(
        'Bağlantı kurulamadı. İşlemin sonucunu yeniden kontrol edin.',
      );
    } finally {
      await scope.close();
    }
  }

  Map<String, dynamic> row(dynamic value) {
    if (value is! Map) throw const FormatException('Missing QR response');
    final result = Map<String, dynamic>.from(value);
    if (result['error'] is String) {
      throw QrProtocolFailure(result['error'] as String);
    }
    return result;
  }

  Future<Either<String, QrSessionEntity>> create(String cartId) =>
      runScoped((scope) async {
        var earning = false;
        if (rewardEarningEnabled) {
          final caps = row(await client.rpc('reward_capabilities_v1'));
          if (caps['version'] != 1 ||
              caps['enabled'] is! bool ||
              caps['redemption_enabled'] != false) {
            throw const FormatException('Unsupported reward protocol');
          }
          earning = caps['enabled'] as bool;
        }
        scope.check();
        final value = QrSessionModel.fromJson(
          row(
            await client.rpc(
              earning ? 'create_reward_qr_v1' : 'create_qr_session_v2',
              params: {earning ? 'p_cart' : 'p_cart_id': cartId},
            ),
          ),
        );
        if (value.protocolVersion != 2 ||
            value.cartId != cartId ||
            value.userId != client.auth.currentUser?.id ||
            !const {'active', 'claimed'}.contains(value.status) ||
            value.itemCount == null ||
            value.itemCount! <= 0 ||
            value.totalAmount == null ||
            !value.totalAmount!.isFinite ||
            value.totalAmount! < 0 ||
            value.status == 'active' &&
                (value.manualCode == null ||
                    !value.expiresAt.isAfter(DateTime.now()))) {
          throw const FormatException('Invalid customer QR');
        }
        return value;
      });

  Future<Either<String, QrSessionEntity>> read(String sessionId) =>
      run(() async {
        final value = QrSessionModel.fromJson(
          row(
            await client.rpc(
              'get_qr_session_status_v2',
              params: {'p_session_id': sessionId},
            ),
          ),
        );
        if (value.protocolVersion != 2 ||
            value.id != sessionId ||
            value.userId != client.auth.currentUser?.id) {
          throw const FormatException('Foreign QR');
        }
        return value;
      });

  Future<Either<String, QrVerificationEntity>> claim({
    required String shopId,
    required String requestId,
    String? sessionToken,
    String? manualCode,
  }) => runScoped((scope) async {
    final device = await installation();
    scope.check();
    final value = QrVerificationModel.fromJson(
      row(
        await client.rpc(
          'claim_existing_qr_v2',
          params: {
            'p_shop_id': shopId,
            'p_installation_id': device,
            'p_request_id': requestId,
            'p_session_token': sessionToken,
            'p_manual_code': manualCode,
          },
        ),
      ),
    );
    if (value.protocolVersion != 2 ||
        value.shopId != shopId ||
        sessionToken != null && value.sessionToken != sessionToken) {
      throw const FormatException('Foreign claim');
    }
    return value;
  });

  Future<Either<String, QrVerificationEntity>> operation(
    String rpc,
    String claimId,
  ) => runScoped((scope) async {
    final device = await installation();
    scope.check();
    var endpoint = rpc;
    final parameters = <String, dynamic>{
      'p_claim_id': claimId,
      'p_installation_id': device,
    };
    if ((rewardEarningEnabled || couponCheckoutEnabled) &&
        rpc == 'complete_existing_qr_v2') {
      final current = QrVerificationModel.fromJson(
        row(await client.rpc('reconcile_claim_v2', params: parameters)),
      );
      scope.check();
      if (current.claimId != claimId || current.protocolVersion != 2) {
        throw const FormatException('Mismatched earning claim');
      }
      if (current.couponCheckout != null) {
        if (!couponCheckoutEnabled) {
          throw const QrProtocolFailure('CHECKOUT_CLIENT_UPDATE_REQUIRED');
        }
        final terms = current.couponCheckout!;
        endpoint = 'complete_coupon_qr_v1';
        parameters.addAll({
          'p_sale_minor': terms.sale.value.toString(),
          'p_coupon_minor': terms.coupon.value.toString(),
          'p_payment_minor': terms.payment.value.toString(),
        });
      } else if (current.rewardConfirmationRequired) {
        endpoint = 'complete_reward_qr_v1';
        parameters['p_actual_sale_minor'] = current.rewardSaleMinor;
      }
    }
    final value = QrVerificationModel.fromJson(
      row(await client.rpc(endpoint, params: parameters)),
    );
    if (value.protocolVersion != 2 || value.claimId != claimId) {
      throw const FormatException('Foreign claim');
    }
    return value;
  });

  Future<Either<String, QrVerificationEntity?>> recover(String shopId) =>
      runScoped((scope) async {
        final device = await installation();
        scope.check();
        final result = await client.rpc(
          'recover_merchant_claim_v2',
          params: {'p_shop_id': shopId, 'p_installation_id': device},
        );
        if (result == null) return null;
        final value = QrVerificationModel.fromJson(row(result));
        if (value.protocolVersion != 2 || value.shopId != shopId) {
          throw const FormatException('Foreign claim');
        }
        return value;
      });

  static String friendlyError(String code) {
    if (code.contains('CHECKOUT_CLIENT_UPDATE_REQUIRED')) {
      return 'Kuponlu işlemler için uygulamayı güncelleyin.';
    }
    if (code.contains('CHECKOUT_') || code.contains('LEDGER_OVERDRAFT')) {
      return 'Kupon onayı veya bakiye değişti. İşlem tamamlanmadı; müşteriden güncel onayla yeni QR isteyin.';
    }
    if (code.contains('QR_RATE_LIMITED')) {
      return 'Çok fazla deneme yapıldı. Bir süre sonra tekrar deneyin.';
    }
    if (code.contains('QR_CLAIMED_ELSEWHERE')) {
      return 'Bu işlem başka bir esnaf oturumunda açılmış.';
    }
    if (code.contains('QR_OTHER_CLAIM_OPEN')) {
      return 'Önce açık işlemi geri yükleyip tamamlayın veya iptal edin.';
    }
    if (code.contains('QR_QUOTE_CHANGED')) {
      return 'Sepet veya ürün bilgisi değişti. Müşteriden yeni QR isteyin.';
    }
    if (code.contains('QR_EXPIRED')) {
      return 'QR kodunun süresi doldu. Müşteriden yeni kod isteyin.';
    }
    if (code.contains('QR_V2_DISABLED')) {
      return 'Yeni QR akışı henüz kullanıma açılmadı.';
    }
    if (code.contains('QR_LEGACY_IN_PROGRESS')) {
      return 'Önce açık olan QR işlemini tamamlayın veya sepetten iptal edin.';
    }
    if (code.contains('device session limit')) {
      return 'İki esnaf oturumu zaten açık. Önce diğer cihazlardan birinde çıkış yapın.';
    }
    if (code.contains('session') || code.contains('SESSION_CHANGED')) {
      return 'Giriş veya cihaz oturumunuz değişti. Yeniden giriş yapın.';
    }
    if (code.contains('access') || code.contains('Admin')) {
      return 'Bu işlem için yetkiniz yok.';
    }
    if (code.contains('exceeds purchased')) {
      return 'İade miktarı kalan satın alma adedini aşıyor.';
    }
    if (code.contains('Legacy purchase')) {
      return 'Eski alışverişin koşulları eksik olduğu için iade kaydı açılamıyor.';
    }
    if (code.contains('mismatch')) {
      return 'İstek bilgisi değişti. Önce mevcut işlem sonucunu kontrol edin.';
    }
    if (code.contains('invalidated')) {
      return 'Bu alışveriş kaydı geçersiz olarak işaretlenmiş.';
    }
    return 'İşlem doğrulanamadı. Kodu ve mağazayı kontrol edip yeniden deneyin.';
  }
}

class QrProtocolFailure implements Exception {
  const QrProtocolFailure(this.code);
  final String code;
}
