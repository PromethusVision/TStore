import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/features/purchases/domain/repositories/purchase_evidence_repository.dart';

/// Existing B retry record, not an offline queue. Amounts are never persisted here.
class PendingPurchaseReturn {
  PendingPurchaseReturn({
    required this.requestId,
    required this.reason,
    required Map<String, int> quantities,
  }) : quantities = Map.unmodifiable(quantities);
  final String requestId, reason;
  final Map<String, int> quantities;

  Map<String, dynamic> toJson() => {
    'request_id': requestId,
    'reason': reason,
    'quantities': quantities,
  };

  factory PendingPurchaseReturn.decode(String raw, PurchaseEvidence purchase) {
    if (raw.length > 32768) throw const FormatException('Oversized return');
    final value = jsonDecode(raw);
    if (value is! Map ||
        value.length != 3 ||
        value['request_id'] is! String ||
        !RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
        ).hasMatch(value['request_id'] as String) ||
        value['reason'] is! String ||
        (value['reason'] as String).trim().isEmpty ||
        (value['reason'] as String).length > 500 ||
        value['quantities'] is! Map) {
      throw const FormatException('Invalid pending return');
    }
    final quantities = value['quantities'] as Map;
    if (quantities.isEmpty || quantities.length > 100) {
      throw const FormatException('Invalid pending quantities');
    }
    final items = {for (final item in purchase.items) item.id: item};
    for (final entry in quantities.entries) {
      final item = items[entry.key];
      if (entry.key is! String ||
          entry.value is! int ||
          item == null ||
          (entry.value as int) <= 0 ||
          (entry.value as int) > 999999999 ||
          (entry.value as int) > item.quantity) {
        throw const FormatException('Invalid pending item');
      }
    }
    // Validate against original quantity, not remaining: a lost acknowledgement
    // may already have consumed every remaining unit.
    return PendingPurchaseReturn(
      requestId: value['request_id'] as String,
      reason: value['reason'] as String,
      quantities: Map<String, int>.from(quantities),
    );
  }

  bool sameAs(PendingPurchaseReturn other) =>
      requestId == other.requestId &&
      reason == other.reason &&
      quantities.length == other.quantities.length &&
      quantities.entries.every((e) => other.quantities[e.key] == e.value);
}

abstract interface class PendingPurchaseReturnStore {
  Future<PendingPurchaseReturn?> read(PurchaseEvidence purchase);

  /// Existing intent wins; a second editor cannot overwrite uncertain evidence.
  Future<PendingPurchaseReturn> preserve(
    PendingPurchaseReturn value,
    PurchaseEvidence purchase,
  );
  Future<void> clear(PendingPurchaseReturn expected, PurchaseEvidence purchase);
}

class LocalPendingPurchaseReturnStore implements PendingPurchaseReturnStore {
  LocalPendingPurchaseReturnStore({
    required String userId,
    required String purchaseId,
    Future<SharedPreferences> Function()? preferences,
  }) : _key = 'pending_return_b:$userId:$purchaseId',
       _preferences = preferences ?? SharedPreferences.getInstance;
  final String _key;
  final Future<SharedPreferences> Function() _preferences;
  static final _tails = <String, Future<void>>{};

  /// Serializes this process only. SharedPreferences is not a database transaction
  /// across processes; server request idempotency remains the final authority.
  Future<T> _serial<T>(Future<T> Function() operation) async {
    final prior = _tails[_key];
    final done = Completer<void>();
    _tails[_key] = done.future;
    try {
      if (prior != null) await prior;
      return await operation();
    } finally {
      done.complete();
      if (identical(_tails[_key], done.future)) _tails.remove(_key);
    }
  }

  Future<SharedPreferences> _fresh() async {
    final prefs = await _preferences();
    await prefs.reload();
    return prefs;
  }

  PendingPurchaseReturn? _decode(SharedPreferences prefs, PurchaseEvidence p) {
    final raw = prefs.getString(_key);
    return raw == null ? null : PendingPurchaseReturn.decode(raw, p);
  }

  @override
  Future<PendingPurchaseReturn?> read(PurchaseEvidence purchase) =>
      _serial(() async => _decode(await _fresh(), purchase));

  @override
  Future<PendingPurchaseReturn> preserve(
    PendingPurchaseReturn value,
    PurchaseEvidence purchase,
  ) => _serial(() async {
    // Validate even records produced by a caller, before writing anything.
    PendingPurchaseReturn.decode(jsonEncode(value.toJson()), purchase);
    final prefs = await _fresh();
    final existing = _decode(prefs, purchase);
    if (existing != null) return existing;
    if (!await prefs.setString(_key, jsonEncode(value.toJson()))) {
      throw StateError('Pending return was not persisted');
    }
    return value;
  });

  @override
  Future<void> clear(
    PendingPurchaseReturn expected,
    PurchaseEvidence purchase,
  ) => _serial(() async {
    final prefs = await _fresh();
    final existing = _decode(prefs, purchase);
    if (existing == null) return;
    if (!existing.sameAs(expected)) {
      throw StateError('Pending return was replaced');
    }
    if (!await prefs.remove(_key)) {
      throw StateError('Pending return acknowledgement was not persisted');
    }
  });
}
