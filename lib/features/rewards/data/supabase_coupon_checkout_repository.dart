import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/cart/data/models/qr_session_model.dart';
import 'package:t_store/features/cart/data/qr_protocol_v2.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';
import 'package:t_store/features/rewards/domain/coupon_checkout.dart';
import 'package:t_store/features/rewards/data/supabase_reward_program_repository.dart';

class SupabaseCouponCheckoutRepository implements CouponCheckoutRepository {
  SupabaseCouponCheckoutRepository(
    SupabaseClient client, {
    RewardRpc? rpc,
    String? Function()? identity,
    String? Function()? user,
    Stream<void>? sessions,
    Duration timeout = const Duration(seconds: 15),
  }) : _rpc = rpc ?? ((name, args) => client.rpc(name, params: args)),
       _identity =
           identity ??
           (() => QrProtocolV2.authenticatedSessionIdentity(client)),
       _user = user ?? (() => client.auth.currentUser?.id),
       sessionChanges =
           sessions ??
           client.auth.onAuthStateChange
               .map((_) => QrProtocolV2.authenticatedSessionIdentity(client))
               .distinct()
               .map((_) {}),
       _timeout = timeout;
  final RewardRpc _rpc;
  final String? Function() _identity, _user;
  final Duration _timeout;
  @override
  final Stream<void> sessionChanges;

  Future<Either<String, T>> _run<T>(
    String name,
    Map<String, dynamic> args,
    T Function(Map<String, dynamic>) parse,
  ) async {
    final identity = _identity(), user = _user();
    if (identity == null || user == null) {
      return const Left('Yeniden giriş yapın.');
    }
    var changed = false;
    final subscription = sessionChanges.listen(
      (_) {
        if (_identity() != identity || _user() != user) changed = true;
      },
      onError: (Object _) {
        changed = true;
      },
    );
    try {
      final raw = await _rpc(name, args).timeout(_timeout);
      if (changed || _identity() != identity || _user() != user) {
        return const Left('Oturum değişti. Onayı yeniden başlatın.');
      }
      if (raw is! Map<String, dynamic>) throw const FormatException();
      return Right(parse(raw));
    } on PostgrestException catch (e) {
      if (e.code == '28000' || e.code == '42501') {
        return const Left('Oturum doğrulanamadı. Yeniden giriş yapın.');
      }
      if (e.message.contains('CHECKOUT_EXISTING_QR')) {
        return const Left(
          'Açık QR işlemini tamamlayın veya sepetten iptal edin.',
        );
      }
      if (e.message.contains('CHECKOUT_DISABLED')) {
        return const Left('Kupon kullanımı henüz açılmadı.');
      }
      return const Left(
        'Sepet veya kupon durumu değişti. Bilgileri yenileyin.',
      );
    } on FormatException {
      return const Left(
        'Alışveriş tutarları doğrulanamadı. Bilgileri yenileyin.',
      );
    } catch (_) {
      return const Left(
        'Sonuç doğrulanamadı. Aynı onayla tekrar kontrol edin.',
      );
    } finally {
      await subscription.cancel();
    }
  }

  @override
  Future<Either<String, CouponCheckoutPreview>> preview(String cartId) =>
      _run('preview_coupon_checkout_v1', {'p_cart': cartId}, (row) {
        final result = CouponCheckoutPreview.fromJson(row);
        if (result.cartId != cartId) throw const FormatException();
        if (row['existing_qr'] != null) {
          if (row['existing_qr'] is! Map<String, dynamic>) {
            throw const FormatException();
          }
          final existing = QrSessionModel.fromJson(
            row['existing_qr'] as Map<String, dynamic>,
          );
          if (existing.cartId != cartId ||
              existing.shopId != result.shopId ||
              existing.userId != _user() ||
              existing.protocolVersion != 2 ||
              existing.couponCheckout == null ||
              !const {'active', 'claimed', 'used'}.contains(existing.status)) {
            throw const FormatException();
          }
          return result.withExistingSession(existing);
        }
        return result;
      });
  @override
  Future<Either<String, QrSessionEntity>> approve(
    CouponCheckoutPreview preview,
    String requestId,
    LedgerMinorUnits coupon,
  ) {
    if (!preview.enabled ||
        coupon.value <= BigInt.zero ||
        coupon.value > preview.maximum.value) {
      return Future.value(
        const Left('Kupon tutarı kullanılabilir sınır içinde olmalı.'),
      );
    }
    return _run(
      'create_coupon_qr_v1',
      {
        'p_cart': preview.cartId,
        'p_request': requestId,
        'p_fingerprint': preview.fingerprint,
        'p_coupon_minor': coupon.value.toString(),
      },
      (row) {
        final qr = QrSessionModel.fromJson(row), terms = qr.couponCheckout;
        if (qr.protocolVersion != 2 ||
            qr.cartId != preview.cartId ||
            qr.shopId != preview.shopId ||
            qr.userId != _user() ||
            terms == null ||
            terms.fingerprint != preview.fingerprint ||
            terms.sale.value != preview.sale.value ||
            terms.coupon.value != coupon.value) {
          throw const FormatException();
        }
        return qr;
      },
    );
  }
}
