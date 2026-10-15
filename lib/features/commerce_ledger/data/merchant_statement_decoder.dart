import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';
import 'package:t_store/features/commerce_ledger/domain/merchant_statement.dart';

Never _bad() => throw const FormatException('Invalid merchant statement');
final _uuid = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
);
final _integer = RegExp(r'^(0|-?[1-9][0-9]*)$');
final _codes = LedgerAccountKind.values.where((k) => k.isMerchant).toList();
bool _keys(Map<String, dynamic> value, Set<String> expected) =>
    value.length == expected.length && expected.containsAll(value.keys);
BigInt _amount(Object? raw, {bool signed = false}) {
  if (raw is! String || raw.length > 100 || !_integer.hasMatch(raw)) _bad();
  final value = BigInt.parse(raw);
  if (!signed && value.isNegative) _bad();
  return value;
}

Map<LedgerAccountKind, BigInt> _accounts(
  Object? raw, {
  required bool movements,
}) {
  if (raw is! List ||
      raw.length > _codes.length ||
      (!movements && raw.length != _codes.length) ||
      (movements && raw.isEmpty)) {
    _bad();
  }
  final result = <LedgerAccountKind, BigInt>{};
  for (final row in raw) {
    if (row is! Map<String, dynamic> || !_keys(row, {'code', 'amount_minor'})) {
      _bad();
    }
    final matching = _codes.where((k) => k.code == row['code']);
    if (matching.length != 1 || result.containsKey(matching.single)) _bad();
    final value = _amount(row['amount_minor'], signed: movements);
    if (movements && value == BigInt.zero) _bad();
    result[matching.single] = value;
  }
  return result;
}

MerchantStatement decodeMerchantStatement(
  Map<String, dynamic> r,
  String shop,
  int limit,
  String? before,
  String? revision,
) {
  if (!_keys(r, {
        'version',
        'enabled',
        'shop_id',
        'currency',
        'settlement_enabled',
        'settlement_status',
        'entries',
        'accounts',
        'reserve_cap_minor',
        'revision',
        'next_before',
      }) ||
      r['version'] != 1 ||
      r['enabled'] is! bool ||
      r['shop_id'] != shop.toLowerCase() ||
      r['currency'] != 'TRY' ||
      r['settlement_enabled'] != false ||
      r['settlement_status'] != 'policy_pending' ||
      r['entries'] is! List ||
      r['accounts'] is! List) {
    _bad();
  }
  if (r['enabled'] == false) {
    if ((r['entries'] as List).isNotEmpty ||
        (r['accounts'] as List).isNotEmpty ||
        r['revision'] != null ||
        r['next_before'] != null ||
        r['reserve_cap_minor'] != null) {
      _bad();
    }
    return MerchantStatement(
      enabled: false,
      shopId: shop,
      revision: null,
      nextBefore: null,
      reserveCap: null,
      accounts: {},
      entries: [],
    );
  }
  final count = _amount(r['revision']);
  if (r['revision'] is! String ||
      (r['revision'] as String).length > 20 ||
      (revision != null && revision != r['revision'])) {
    _bad();
  }
  final accounts = _accounts(r['accounts'], movements: false);
  final cap = _amount(r['reserve_cap_minor']);
  final rows = r['entries'] as List;
  if (rows.length > limit ||
      BigInt.from(rows.length) > count ||
      (before == null && rows.isEmpty && count != BigInt.zero)) {
    _bad();
  }
  final entries = <MerchantStatementEntry>[];
  final seen = <String>{};
  for (final row in rows) {
    if (row is! Map<String, dynamic> ||
        !_keys(row, {
          'id',
          'recorded_at',
          'kind',
          'reverses',
          'net_minor',
          'movements',
        })) {
      _bad();
    }
    final id = row['id'], reverses = row['reverses'];
    if (id is! String ||
        !_uuid.hasMatch(id) ||
        id == before ||
        !seen.add(id) ||
        (reverses != null &&
            (reverses is! String ||
                !_uuid.hasMatch(reverses) ||
                reverses == id))) {
      _bad();
    }
    final kinds = StatementKind.values.where((k) => k.code == row['kind']);
    if (kinds.length != 1) _bad();
    final stamp = row['recorded_at'];
    if (stamp is! String || !RegExp(r'(Z|\+00:00)$').hasMatch(stamp)) _bad();
    final date = DateTime.tryParse(stamp);
    if (date == null || !date.isUtc) _bad();
    if (entries.isNotEmpty) {
      final previous = entries.last;
      if (date.isAfter(previous.recordedAt) ||
          (date == previous.recordedAt && id.compareTo(previous.id) >= 0)) {
        _bad();
      }
    }
    final movements = _accounts(row['movements'], movements: true);
    final net = _amount(row['net_minor'], signed: true);
    if (movements.values.fold(BigInt.zero, (a, b) => a + b) != net) _bad();
    entries.add(
      MerchantStatementEntry(
        id: id,
        recordedAt: date,
        kind: kinds.single,
        reverses: reverses as String?,
        net: net,
        movements: movements,
      ),
    );
  }
  final next = r['next_before'];
  if (next != null &&
      (next is! String ||
          entries.length != limit ||
          entries.last.id != next ||
          count <= BigInt.from(entries.length))) {
    _bad();
  }
  return MerchantStatement(
    enabled: true,
    shopId: shop,
    revision: r['revision'] as String,
    nextBefore: next as String?,
    reserveCap: cap,
    accounts: accounts,
    entries: entries,
  );
}
