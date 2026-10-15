import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';

typedef CommerceLedgerRpc =
    Future<dynamic> Function(String name, Map<String, dynamic> parameters);

/// Read-only H0 adapter. H1 may inject it later; current app hosts do not bind it.
class SupabaseCommerceLedgerRepository implements CommerceLedgerRepository {
  SupabaseCommerceLedgerRepository(
    SupabaseClient client, {
    CommerceLedgerRpc? rpc,
    String? Function()? currentUserId,
    Stream<String?>? sessionChanges,
    Duration timeout = const Duration(seconds: 15),
  }) : _rpc = rpc ?? ((name, args) => client.rpc(name, params: args)),
       _user = currentUserId ?? (() => client.auth.currentUser?.id),
       _sessions =
           sessionChanges ??
           client.auth.onAuthStateChange.map((e) => e.session?.user.id),
       _timeout = timeout;
  final CommerceLedgerRpc _rpc;
  final String? Function() _user;
  final Stream<String?> _sessions;
  final Duration _timeout;
  static final _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  Future<Either<CommerceLedgerFailure, T>> _read<T>(
    String name,
    Map<String, dynamic> args,
    T Function(Map<String, dynamic>) decode, {
    required bool private,
  }) async {
    final actor = _user();
    if (private && actor == null) {
      return const Left(CommerceLedgerFailure.sessionChanged);
    }
    var changed = false;
    final subscription = private
        ? _sessions.listen(
            (id) {
              if (id != actor) changed = true;
            },
            onError: (Object _) {
              changed = true;
            },
          )
        : null;
    try {
      final raw = await _rpc(name, args).timeout(_timeout);
      if (private && (changed || _user() != actor)) {
        return const Left(CommerceLedgerFailure.sessionChanged);
      }
      if (raw is! Map<String, dynamic>) {
        return const Left(CommerceLedgerFailure.invalidResponse);
      }
      return Right(decode(raw));
    } on FormatException {
      return const Left(CommerceLedgerFailure.invalidResponse);
    } on PostgrestException catch (e) {
      if (e.code == '28000' || e.code == '42501') {
        return const Left(CommerceLedgerFailure.sessionChanged);
      }
      return const Left(CommerceLedgerFailure.unavailable);
    } catch (_) {
      if (private && (changed || _user() != actor)) {
        return const Left(CommerceLedgerFailure.sessionChanged);
      }
      return const Left(CommerceLedgerFailure.unavailable);
    } finally {
      await subscription?.cancel();
    }
  }

  @override
  Future<Either<CommerceLedgerFailure, CommerceLedgerCapabilities>>
  capabilities() => _read('commerce_ledger_capabilities_v1', {}, (r) {
    final version = r['policy_version'];
    if (r['version'] != 1 ||
        r['enabled'] is! bool ||
        version is! int ||
        version < 1 ||
        r['currency'] != 'TRY' ||
        r['funding_enabled'] != false ||
        r['rewards_enabled'] != false ||
        r['settlement_enabled'] != false) {
      throw const FormatException('Unsupported accounting capability');
    }
    return CommerceLedgerCapabilities(
      enabled: r['enabled'] as bool,
      policyVersion: version,
    );
  }, private: false);

  @override
  Future<Either<CommerceLedgerFailure, CommerceLedgerSnapshot>>
  readOwnAccounts({String? shopId}) async {
    if (shopId != null && !_uuid.hasMatch(shopId)) {
      return const Left(CommerceLedgerFailure.invalidRequest);
    }
    return _read('read_my_commerce_accounts_v1', {'p_shop_id': shopId}, (r) {
      if (r['enabled'] is! bool ||
          r['currency'] != 'TRY' ||
          r['settlement_enabled'] != false ||
          r['accounts'] is! List) {
        throw const FormatException('Invalid accounting projection');
      }
      final enabled = r['enabled'] as bool;
      final rows = r['accounts'] as List;
      if ((!enabled && rows.isNotEmpty) ||
          rows.length > LedgerAccountKind.values.length ||
          (enabled && r['shop_id'] != shopId)) {
        throw const FormatException('Mismatched accounting scope');
      }
      final seen = <LedgerAccountKind>{};
      final accounts = <LedgerAccountBalance>[];
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          throw const FormatException('Invalid account');
        }
        final types = LedgerAccountKind.values.where(
          (k) => k.code == row['code'],
        );
        if (types.length != 1) throw const FormatException('Unknown account');
        final kind = types.single;
        if (kind.isMerchant != (shopId != null) || !seen.add(kind)) {
          throw const FormatException('Mismatched account');
        }
        accounts.add(
          LedgerAccountBalance(
            kind,
            LedgerMinorUnits.fromWire(row['amount_minor']),
          ),
        );
      }
      return CommerceLedgerSnapshot(
        enabled: enabled,
        shopId: shopId,
        accounts: accounts,
      );
    }, private: true);
  }
}
