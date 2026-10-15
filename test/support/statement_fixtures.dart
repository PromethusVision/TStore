import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:t_store/features/commerce_ledger/data/merchant_statement_decoder.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';
import 'package:t_store/features/commerce_ledger/domain/merchant_statement.dart';

const statementShop = '22222222-2222-4222-8222-222222222222';
const statementUser = '11111111-1111-4111-8111-111111111111';
const statementId = '33333333-3333-4333-8333-333333333333';
const statementOlderId = '44444444-4444-4444-8444-444444444444';
Map<String, dynamic> statementEntry({
  String id = statementId,
  String stamp = '2026-10-15T10:00:00Z',
  String kind = 'coupon_redemption',
  String amount = '150000',
  String? reverses,
}) => {
  'id': id,
  'recorded_at': stamp,
  'kind': kind,
  'reverses': reverses,
  'net_minor': amount,
  'movements': [
    if (kind == 'coupon_redemption' && amount == '150000') ...[
      {'code': 'merchant_reserve', 'amount_minor': '100000'},
      {'code': 'merchant_coupon_pending', 'amount_minor': '50000'},
    ] else
      {'code': 'merchant_unused_pending', 'amount_minor': amount},
  ],
};
Map<String, dynamic> statementWire({
  bool enabled = true,
  List<Map<String, dynamic>>? entries,
  String? next,
  String revision = '1',
  Map<String, String> amounts = const {},
}) => {
  'version': 1,
  'shop_id': statementShop,
  'enabled': enabled,
  'currency': 'TRY',
  'settlement_enabled': false,
  'settlement_status': 'policy_pending',
  'reserve_cap_minor': enabled ? '100000' : null,
  'revision': enabled ? revision : null,
  'next_before': enabled ? next : null,
  'accounts': enabled
      ? [
          for (final kind in LedgerAccountKind.values.where(
            (k) => k.isMerchant,
          ))
            {'code': kind.code, 'amount_minor': amounts[kind.code] ?? '0'},
        ]
      : [],
  'entries': enabled ? (entries ?? [statementEntry()]) : [],
};
MerchantStatement statementValue({
  bool enabled = true,
  List<Map<String, dynamic>>? entries,
  String? next,
  String revision = '1',
  Map<String, String> amounts = const {},
}) => decodeMerchantStatement(
  statementWire(
    enabled: enabled,
    entries: entries,
    next: next,
    revision: revision,
    amounts: amounts,
  ),
  statementShop,
  next == null ? 20 : 1,
  null,
  null,
);

class StatementFake implements MerchantStatementRepository {
  MerchantStatement value = statementValue(
    revision: '3',
    entries: [
      {
        ...statementEntry(
          id: '55555555-5555-4555-8555-555555555555',
          stamp: '2026-10-15T12:00:00Z',
          kind: 'receivable_release',
          amount: '0',
        ),
        'movements': [
          {'code': 'merchant_unused_pending', 'amount_minor': '-10000'},
          {'code': 'merchant_unused_available', 'amount_minor': '10000'},
        ],
      },
      statementEntry(
        id: statementOlderId,
        stamp: '2026-10-15T11:00:00Z',
        kind: 'unused_package_fund',
        amount: '35000',
      ),
      statementEntry(),
    ],
    amounts: {
      'merchant_reserve': '100000',
      'merchant_coupon_pending': '50000',
      'merchant_unused_pending': '25000',
      'merchant_unused_available': '10000',
    },
  );
  CommerceLedgerFailure? error;
  Completer<Either<CommerceLedgerFailure, MerchantStatement>>? wait;
  final requests = <({String shop, String? before, String? revision})>[];
  @override
  Future<Either<CommerceLedgerFailure, MerchantStatement>> readStatement({
    required String shopId,
    int limit = 20,
    String? before,
    String? revision,
  }) async {
    requests.add((shop: shopId, before: before, revision: revision));
    if (wait != null) return wait!.future;
    if (error != null) return Left(error!);
    return Right(value);
  }
}
