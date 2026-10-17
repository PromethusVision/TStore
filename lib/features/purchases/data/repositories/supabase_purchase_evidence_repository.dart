import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/cart/data/qr_protocol_v2.dart';
import 'package:t_store/features/cart/domain/repositories/qr_claim_repository.dart';
import 'package:t_store/features/purchases/domain/repositories/purchase_evidence_repository.dart';

class SupabasePurchaseEvidenceRepository
    implements PurchaseEvidenceRepository, QrSessionIdentity {
  SupabasePurchaseEvidenceRepository(
    SupabaseClient client, {
    QrProtocolV2? transport,
  }) : _transport = transport ?? QrProtocolV2(client);
  final QrProtocolV2 _transport;
  @override
  String? get currentQrSessionIdentity => _transport.sessionIdentity();
  @override
  Future<Either<String, List<PurchaseEvidence>>> list(
    String shopId, {
    int offset = 0,
  }) => _transport.run(() async {
    final rows = await _transport.client.rpc(
      'list_merchant_purchases_v2',
      params: {'p_shop_id': shopId, 'p_offset': offset, 'p_limit': 20},
    );
    return List.unmodifiable(
      (rows as List).map((row) {
        final result = PurchaseEvidence.fromJson(_transport.row(row));
        if (result.shopId != shopId) {
          throw const FormatException('Foreign purchase');
        }
        return result;
      }),
    );
  });
  @override
  Future<Either<String, PurchaseEvidence>> read(String purchaseId) =>
      _transport.run(() async {
        final value = PurchaseEvidence.fromJson(
          _transport.row(
            await _transport.client.rpc(
              'read_purchase_evidence_v2',
              params: {'p_purchase_id': purchaseId},
            ),
          ),
        );
        if (value.id != purchaseId) {
          throw const FormatException('Foreign purchase');
        }
        return value;
      });
  @override
  Future<Either<PurchaseReturnFailure, PurchaseEvidence>> recordReturn({
    required String purchaseId,
    required String requestId,
    required Map<String, int> quantities,
    required String reason,
  }) async {
    var rejected = false;
    final result = await _transport.run(
      () async {
        final identity = _transport.sessionIdentity();
        final device = await _transport.installation();
        if (identity != _transport.sessionIdentity()) {
          throw const QrProtocolFailure('SESSION_CHANGED');
        }
        final value = PurchaseEvidence.fromJson(
          _transport.row(
            await _transport.client.rpc(
              'record_purchase_return_v2',
              params: {
                'p_purchase_id': purchaseId,
                'p_request_id': requestId,
                'p_reason': reason,
                'p_installation_id': device,
                'p_items': [
                  for (final entry in quantities.entries)
                    {'purchase_item_id': entry.key, 'quantity': entry.value},
                ],
              },
            ),
          ),
        );
        if (value.id != purchaseId) {
          throw const FormatException('Foreign purchase');
        }
        return value;
      },
      onServerError: (e) {
        rejected =
            e.code == 'P0001' &&
            const {
              'Return exceeds purchased quantity',
              'Invalid return item',
              'Foreign purchase item',
              'Duplicate return item',
              'Invalid return request',
              'Legacy purchase terms are unclassified',
              'Purchase invalidated',
            }.contains(e.message);
      },
    );
    return result.fold(
      (e) => Left(PurchaseReturnFailure(e, definitelyRejected: rejected)),
      Right.new,
    );
  }
}
