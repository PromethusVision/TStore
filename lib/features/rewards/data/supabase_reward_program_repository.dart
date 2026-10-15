import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/cart/data/qr_protocol_v2.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';
import 'package:t_store/features/rewards/domain/reward_program.dart';
import 'package:t_store/features/rewards/domain/reward_progress.dart';

typedef RewardRpc =
    Future<dynamic> Function(String name, Map<String, dynamic> arguments);

class SupabaseRewardProgramRepository implements RewardProgramRepository {
  SupabaseRewardProgramRepository(
    SupabaseClient client, {
    RewardRpc? rpc,
    String? Function()? currentUserId,
    String? Function()? sessionIdentity,
    Stream<String?>? sessionChanges,
    Duration timeout = const Duration(seconds: 15),
    Duration pollInterval = const Duration(seconds: 30),
  }) : _rpc = rpc ?? ((name, args) => client.rpc(name, params: args)),
       _user = currentUserId ?? (() => client.auth.currentUser?.id),
       _identity =
           sessionIdentity ??
           (() => QrProtocolV2.authenticatedSessionIdentity(client)),
       _sessions =
           sessionChanges ??
           client.auth.onAuthStateChange.map((event) => event.session?.user.id),
       _timeout = timeout,
       _poll = pollInterval;
  final RewardRpc _rpc;
  final String? Function() _user, _identity;
  final Stream<String?> _sessions;
  final Duration _timeout, _poll;
  final _refresh = StreamController<void>.broadcast();
  static final _uuid = RegExp(
    r'^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$',
  );
  static const _sessionError =
      'Oturumunuz değişti. Bilgileri yeniden yükleyin.';

  Future<Either<String, T>> _run<T>(
    String name,
    Map<String, dynamic> args,
    T Function(Map<String, dynamic>) parse, {
    bool private = true,
  }) async {
    final identity = _identity();
    if (private && (identity == null || _user() == null)) {
      return const Left(_sessionError);
    }
    var changed = false;
    final subscription = private
        ? _sessions.listen(
            (_) {
              if (_identity() != identity) changed = true;
            },
            onError: (Object _) {
              changed = true;
            },
          )
        : null;
    try {
      final raw = await _rpc(name, args).timeout(_timeout);
      if (private && (changed || _identity() != identity)) {
        return const Left(_sessionError);
      }
      if (raw is! Map<String, dynamic>) throw const FormatException();
      return Right(parse(raw));
    } on FormatException {
      return const Left('Ödül bilgileri doğrulanamadı. Yeniden yükleyin.');
    } on PostgrestException catch (error) {
      if (error.code == '28000' || error.code == '42501') {
        return const Left(_sessionError);
      }
      if (error.message.contains('REWARD_ACCEPTANCE_LOCKED')) {
        return const Left(
          'Paket veya açık rezervasyon varken kupon kabulü kapatılamaz.',
        );
      }
      if (error.code == '40001') {
        return const Left(
          'Bilgiler değişti. Güncel durumu yükleyip tekrar deneyin.',
        );
      }
      if (error.message.contains('REWARD_DISABLED')) {
        return const Left('Ödül programı henüz kullanıma açılmadı.');
      }
      return const Left('İşlem tamamlanamadı. Güncel durumu kontrol edin.');
    } catch (_) {
      return Left(
        private && (changed || _identity() != identity)
            ? _sessionError
            : 'Bağlantı kurulamadı. Güncel durumu yeniden kontrol edin.',
      );
    } finally {
      await subscription?.cancel();
    }
  }

  static Map<String, dynamic> _map(Object? value) =>
      value is Map<String, dynamic> ? value : throw const FormatException();
  static String _id(Object? value) => value is String && _uuid.hasMatch(value)
      ? value
      : throw const FormatException();
  static bool _bool(Object? value) =>
      value is bool ? value : throw const FormatException();
  static int _int(Object? value) =>
      value is int && value >= 0 && value <= 1000000000
      ? value
      : throw const FormatException();
  static DateTime _date(Object? value) =>
      value is String &&
          (value.endsWith('Z') || RegExp(r'[+-]\d\d:\d\d$').hasMatch(value))
      ? DateTime.parse(value).toUtc()
      : throw const FormatException();
  static List<dynamic> _rows(Object? value, int max) =>
      value is List && value.length <= max
      ? value
      : throw const FormatException();
  static void _closed(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      if (row[key] != false) throw const FormatException();
    }
  }

  static LedgerMinorUnits _money(Object? value) =>
      LedgerMinorUnits.fromWire(value);

  @override
  Future<Either<String, RewardProgramCapabilities>> capabilities() =>
      _run('reward_capabilities_v1', {}, (r) {
        if (r['version'] != 1 || r['goal'] != 5 || r['currency'] != 'TRY') {
          throw const FormatException();
        }
        _closed(r, [
          'package_purchase_enabled',
          'redemption_enabled',
          'settlement_enabled',
        ]);
        final result = RewardProgramCapabilities(
          enabled: _bool(r['enabled']),
          minimum: _money(r['minimum_minor']),
          contribution: _money(r['contribution_minor']),
          coupon: _money(r['coupon_minor']),
          packageFund: _money(r['package_fund_minor']),
          packageFee: _money(r['package_fee_minor']),
          packageSlots: _int(r['package_slots']),
          packageSeconds: _int(r['package_seconds']),
          reservationSeconds: _int(r['reservation_seconds']),
          maturitySeconds: _int(r['minimum_maturity_seconds']),
        );
        if (result.packageSlots == 0 ||
            result.contribution.value <= BigInt.zero ||
            result.minimum.value <= BigInt.zero ||
            result.packageSeconds == 0 ||
            result.reservationSeconds == 0 ||
            result.maturitySeconds == 0 ||
            result.coupon.value != result.contribution.value * BigInt.from(5) ||
            result.packageFund.value !=
                result.contribution.value * BigInt.from(result.packageSlots)) {
          throw const FormatException();
        }
        return result;
      }, private: false);

  @override
  Future<Either<String, MerchantRewardState>> readMerchant(String shopId) {
    if (!_uuid.hasMatch(shopId)) {
      return Future.value(const Left('Mağaza bilgisi geçersiz.'));
    }
    return _run('read_merchant_reward_v1', {
      'p_shop': shopId,
    }, (r) => _merchant(r, shopId));
  }

  @override
  Future<Either<String, MerchantRewardState>> setAcceptance(
    String shopId,
    bool preferred,
    int expectedRevision,
  ) {
    if (!_uuid.hasMatch(shopId) || expectedRevision < 0) {
      return Future.value(const Left('Mağaza bilgisi geçersiz.'));
    }
    return _run('set_merchant_reward_preference_v1', {
      'p_shop': shopId,
      'p_preferred': preferred,
      'p_expected_revision': expectedRevision,
    }, (r) => _merchant(r, shopId));
  }

  static MerchantRewardState _merchant(Map<String, dynamic> r, String shopId) {
    if (_id(r['shop_id']) != shopId) throw const FormatException();
    _closed(r, ['package_purchase_enabled', 'redemption_enabled']);
    final preferred = _bool(r['preferred_acceptance']),
        forced = _bool(r['forced_acceptance']),
        effective = _bool(r['effective_acceptance']);
    if (effective != (preferred || forced)) throw const FormatException();
    final ids = <String>{};
    final packages = _rows(r['packages'], 20).map((item) {
      final p = _map(item), c = _map(p['capacity']), id = _id(p['id']);
      if (!ids.add(id)) throw const FormatException();
      final result = ReferralPackage(
        id: id,
        activatedAt: _date(p['activated_at']),
        expiresAt: _date(p['expires_at']),
        expired: _bool(p['expired']),
        free: _int(c['free']),
        held: _int(c['held']),
        consumed: _int(c['consumed']),
        refunded: _int(c['expired']),
        totalSlots: _int(p['total_slots']),
        fund: _money(p['fund_minor']),
        fee: _money(p['service_fee_minor']),
      );
      if (!result.expiresAt.isAfter(result.activatedAt) ||
          result.free + result.held + result.consumed + result.refunded !=
              result.totalSlots) {
        throw const FormatException();
      }
      return result;
    }).toList();
    return MerchantRewardState(
      shopId: shopId,
      enabled: _bool(r['enabled']),
      serverNow: _date(r['server_now']),
      preferred: preferred,
      forced: forced,
      effective: effective,
      revision: _int(r['preference_revision']),
      packages: packages,
    );
  }

  @override
  Future<Either<String, RewardProgramState>> readCustomer() =>
      _run('read_reward_state_v1', {}, (r) {
        if (r['goal'] != 5 || r['currency'] != 'TRY') {
          throw const FormatException();
        }
        _closed(r, ['redemption_enabled']);
        final couponIds = <String>{},
            purchaseIds = <String>{},
            merchantIds = <String>{};
        final coupons = _rows(r['coupons'], 50).map((item) {
          final c = _map(item),
              id = _id(c['id']),
              face = _money(c['face_minor']),
              remaining = _money(c['remaining_minor']);
          if (!couponIds.add(id) ||
              c['expires_at'] != null ||
              remaining.value > face.value) {
            throw const FormatException();
          }
          return RewardCoupon(
            id: id,
            issuedAt: _date(c['issued_at']),
            face: face,
            remaining: remaining,
          );
        }).toList();
        final history = _rows(r['history'], 50).map((item) {
          final e = _map(item), id = _id(e['purchase_id']);
          if (!purchaseIds.add(id)) throw const FormatException();
          final result = RewardEarning(
            purchaseId: id,
            earnedAt: _date(e['earned_at']),
            maturesAt: _date(e['matures_at']),
            valid: _bool(e['valid']),
            issued: _bool(e['issued']),
          );
          if (!result.maturesAt.isAfter(result.earnedAt)) {
            throw const FormatException();
          }
          return result;
        }).toList();
        final merchants = _rows(r['merchants'], 50).map((item) {
          final m = _map(item), id = _id(m['id']), name = m['name'];
          if (!merchantIds.add(id) ||
              name is! String ||
              name.trim().isEmpty ||
              name.length > 300) {
            throw const FormatException();
          }
          return RewardEligibleMerchant(id: id, name: name);
        }).toList();
        return RewardProgramState(
          enabled: _bool(r['enabled']),
          serverNow: _date(r['server_now']),
          pendingCount: _int(r['pending_count']),
          pending: _money(r['pending_minor']),
          couponValue: _money(r['coupon_minor']),
          coupons: coupons,
          history: history,
          merchants: merchants,
        );
      });

  @override
  Future<Either<String, RewardReservation>> reserve(
    String cartId, {
    bool startNew = false,
  }) {
    if (!_uuid.hasMatch(cartId)) {
      return Future.value(const Left('Sepet bilgisi geçersiz.'));
    }
    return _run(
      'ensure_reward_reservation_v1',
      {'p_cart': cartId, 'p_start_new': startNew},
      (r) {
        const statuses = {
          'disabled': RewardReservationStatus.disabled,
          'below_threshold': RewardReservationStatus.belowThreshold,
          'no_capacity': RewardReservationStatus.noCapacity,
          'reserved': RewardReservationStatus.reserved,
          'checkout_hold': RewardReservationStatus.checkoutHold,
          'attempt_expired': RewardReservationStatus.attemptExpired,
        };
        final status = statuses[r['status']];
        if (status == null) throw const FormatException();
        final result = RewardReservation(
          status: status,
          serverNow: _date(r['server_now']),
          attemptId: r['attempt_id'] == null ? null : _id(r['attempt_id']),
          expiresAt: r['expires_at'] == null ? null : _date(r['expires_at']),
        );
        if ((result.holdsCapacity ||
                status == RewardReservationStatus.attemptExpired) &&
            (result.expiresAt == null || result.attemptId == null)) {
          throw const FormatException();
        }
        return result;
      },
    );
  }

  @override
  void refresh() => _refresh.add(null);

  @override
  Stream<RewardProgress> watchProgress(String? customerId) {
    if (customerId == null) return Stream.value(const RewardProgress());
    late StreamController<RewardProgress> controller;
    StreamSubscription<String?>? auth;
    StreamSubscription<void>? refresh;
    Timer? timer;
    var stopped = false, busy = false, generation = 0;
    var identity = _identity();
    Future<void> read() async {
      if (stopped || busy) return;
      if (_user() != customerId || _identity() != identity) {
        controller.add(const RewardProgress(error: _sessionError));
        return;
      }
      busy = true;
      final ticket = generation;
      final result = await readCustomer();
      if (stopped || ticket != generation) return;
      busy = false;
      if (_user() != customerId || _identity() != identity) {
        controller.add(const RewardProgress(error: _sessionError));
        return;
      }
      controller.add(
        result.fold(
          (error) => RewardProgress(error: error),
          (s) => RewardProgress(
            steps: s.progressSteps,
            available: s.enabled,
            merchants: s.merchants,
            program: s,
          ),
        ),
      );
    }

    controller = StreamController<RewardProgress>(
      onListen: () {
        controller.add(const RewardProgress(loading: true));
        auth = _sessions.listen(
          (_) {
            final nextIdentity = _identity();
            if (_user() != customerId || nextIdentity != identity) {
              generation++;
              busy = false;
              identity = nextIdentity;
              final current = _user() == customerId && identity != null;
              controller.add(
                current
                    ? const RewardProgress(loading: true)
                    : const RewardProgress(error: _sessionError),
              );
              if (current) {
                read();
              }
            } else {
              read();
            }
          },
          onError: (Object _) {
            generation++;
            busy = false;
            controller.add(const RewardProgress(error: _sessionError));
          },
        );
        refresh = _refresh.stream.listen((_) => read());
        timer = Timer.periodic(_poll, (_) => read());
        read();
      },
      onCancel: () async {
        stopped = true;
        generation++;
        timer?.cancel();
        await auth?.cancel();
        await refresh?.cancel();
      },
    );
    return controller.stream;
  }
}
