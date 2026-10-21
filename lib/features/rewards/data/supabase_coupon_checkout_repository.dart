import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';
import 'package:t_store/core/supabase/authenticated_session_key.dart';
import 'package:t_store/features/cart/data/models/qr_session_model.dart';
import 'package:t_store/features/cart/data/qr_protocol_v2.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';
import 'package:t_store/features/rewards/domain/coupon_checkout.dart';
import 'package:t_store/features/rewards/data/supabase_reward_program_repository.dart';

class SupabaseCouponCheckoutRepository
    implements CouponCheckoutRepository, AuthenticatedSessionEvents {
  SupabaseCouponCheckoutRepository(
    SupabaseClient client, {
    RewardRpc? rpc,
    String? Function()? identity,
    String? Function()? user,
    Stream<void>? sessions,
    Stream<String?>? sessionKeys,
    Duration timeout = const Duration(seconds: 15),
  }) : _rpc = rpc ?? ((name, args) => client.rpc(name, params: args)),
       _identity =
           identity ??
           (() => QrProtocolV2.authenticatedSessionIdentity(client)),
       _user = user ?? (() => client.auth.currentUser?.id),
       _legacySessions = sessions,
       sessionKeyChanges =
           sessionKeys ??
           client.auth.onAuthStateChange.map(
             (event) => authenticatedSessionKeyFromSession(event.session),
           ),
       _timeout = timeout;
  final RewardRpc _rpc;
  final String? Function() _identity, _user;
  final Duration _timeout;
  final Stream<void>? _legacySessions;
  @override
  final Stream<String?> sessionKeyChanges;
  @override
  String? get currentSessionKey => _identity();
  @override
  Stream<void> get sessionChanges =>
      _legacySessions ?? sessionKeyChanges.distinct().map((_) {});
  final _approvals = <String, _CouponApproval>{};
  static const _sessionError = 'Oturum değişti. Onayı yeniden başlatın.';

  Future<Either<String, T>> _run<T>(
    String name,
    Map<String, dynamic> args,
    T Function(Map<String, dynamic>) parse, {
    bool mutation = false,
    Future<void> Function()? before,
  }) async {
    final identity = _identity(), user = _user();
    if (identity == null || user == null) {
      return const Left('Yeniden giriş yapın.');
    }
    final scope = AuthenticatedRequestScope(
      user: user,
      session: identity,
      currentUser: _user,
      currentSession: _identity,
      changes: sessionKeyChanges.map((key) => key == identity ? user : null),
      sessionKeys: sessionKeyChanges,
    );
    var changed = false;
    final subscription = _legacySessions?.listen(
      (_) {
        if (_identity() != identity || _user() != user) changed = true;
      },
      onError: (Object _) {
        changed = true;
      },
    );
    try {
      scope.check();
      await before?.call();
      scope.check();
      if (changed) return const Left(_sessionError);
      final pending = _rpc(name, args);
      final raw = await (mutation ? pending : pending.timeout(_timeout));
      scope.check();
      if (changed) return const Left(_sessionError);
      if (raw is! Map<String, dynamic>) throw const FormatException();
      return Right(parse(raw));
    } on PostgrestException catch (e) {
      if (changed || !scope.current) return const Left(_sessionError);
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
      if (changed || !scope.current) return const Left(_sessionError);
      return const Left(
        'Alışveriş tutarları doğrulanamadı. Bilgileri yenileyin.',
      );
    } catch (_) {
      if (changed || !scope.current) return const Left(_sessionError);
      return const Left(
        'Sonuç doğrulanamadı. Aynı onayla tekrar kontrol edin.',
      );
    } finally {
      await subscription?.cancel();
      await scope.close();
    }
  }

  @override
  Future<Either<String, CouponCheckoutPreview>> preview(String cartId) => _run(
    'preview_coupon_checkout_v1',
    {'p_cart': cartId},
    (row) {
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
    },
    before: () async {
      // A reopened approval waits for the already dispatched command before
      // asking the server for the existing QR. No automatic write replay.
      await _approvals['${_identity()}:$cartId']?.result;
    },
  );
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
    final key = '${_identity()}:${preview.cartId}';
    final existing = _approvals[key];
    if (existing != null) {
      if (existing.request == requestId &&
          existing.fingerprint == preview.fingerprint &&
          existing.amount == coupon.value.toString()) {
        return existing.result;
      }
      return Future.value(
        const Left('Önce gönderilen kupon onayının sonucunu bekleyin.'),
      );
    }
    final attempt = _CouponApproval(
      requestId,
      preview.fingerprint,
      coupon.value.toString(),
    );
    _approvals[key] = attempt;
    unawaited(() async {
      try {
        attempt.completer.complete(
          await _run(
            'create_coupon_qr_v1',
            {
              'p_cart': preview.cartId,
              'p_request': requestId,
              'p_fingerprint': preview.fingerprint,
              'p_coupon_minor': coupon.value.toString(),
            },
            (row) {
              final qr = QrSessionModel.fromJson(row),
                  terms = qr.couponCheckout;
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
            mutation: true,
          ),
        );
      } finally {
        if (identical(_approvals[key], attempt)) _approvals.remove(key);
      }
    }());
    return attempt.result;
  }
}

class _CouponApproval {
  _CouponApproval(this.request, this.fingerprint, this.amount);
  final String request, fingerprint, amount;
  final completer = Completer<Either<String, QrSessionEntity>>();
  Future<Either<String, QrSessionEntity>> get result => completer.future;
}
