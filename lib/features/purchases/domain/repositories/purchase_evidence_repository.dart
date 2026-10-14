import 'package:dartz/dartz.dart';

class PurchaseEvidenceItem {
  const PurchaseEvidenceItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.returnedQuantity,
  });
  final String id, name;
  final int quantity, returnedQuantity;
  int get remaining => quantity - returnedQuantity;
}

class PurchaseReturnReference {
  const PurchaseReturnReference(this.id, this.occurredAt, this.isCorrection);
  final String id;
  final DateTime occurredAt;
  final bool isCorrection;
}

class PurchaseEvidence {
  const PurchaseEvidence({
    required this.id,
    required this.shopId,
    required this.confirmedAt,
    required this.items,
    required this.returns,
    this.finalSaleMinor,
    required this.classification,
    required this.invalidated,
  });
  final String id, shopId, classification;
  final DateTime confirmedAt;
  final int? finalSaleMinor;
  final bool invalidated;
  final List<PurchaseEvidenceItem> items;
  final List<PurchaseReturnReference> returns;
  bool get canRecordReturn =>
      classification == 'quote_only_b_v1' &&
      !invalidated &&
      items.any((i) => i.remaining > 0);

  factory PurchaseEvidence.fromJson(Map<String, dynamic> j) {
    String requiredString(Map row, String key) {
      final value = row[key];
      if (value is! String || value.isEmpty) {
        throw FormatException('Missing $key');
      }
      return value;
    }

    int integer(dynamic value) {
      if (value is! int || value < 0) {
        throw const FormatException('Invalid quantity');
      }
      return value;
    }

    final classification = requiredString(j, 'terms_classification');
    if (!const {
      'legacy_unclassified',
      'quote_only_b_v1',
    }.contains(classification)) {
      throw const FormatException('Unknown purchase terms');
    }
    final finalSale = j['final_sale_minor'];
    if (classification == 'quote_only_b_v1' &&
        (finalSale is! int ||
            finalSale < 0 ||
            j['ev_coupon_minor'] != 0 ||
            j['customer_payment_minor'] != finalSale)) {
      throw const FormatException('Invalid purchase amounts');
    }
    final items = <PurchaseEvidenceItem>[];
    for (final raw in j['items'] as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      final quantity = integer(row['quantity']),
          returned = integer(row['returned_quantity']);
      if (quantity == 0 || returned > quantity) {
        throw const FormatException('Invalid return quantity');
      }
      items.add(
        PurchaseEvidenceItem(
          id: requiredString(row, 'id'),
          name: requiredString(row, 'product_name'),
          quantity: quantity,
          returnedQuantity: returned,
        ),
      );
    }
    if (items.isEmpty ||
        items.map((i) => i.id).toSet().length != items.length) {
      throw const FormatException('Invalid purchase items');
    }
    final returns = <PurchaseReturnReference>[];
    for (final raw in j['returns'] as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      if (row['refund_executed'] != false ||
          !const {
            'genuine',
            'administrative_correction',
          }.contains(row['return_kind'])) {
        throw const FormatException('Invalid return evidence');
      }
      returns.add(
        PurchaseReturnReference(
          requiredString(row, 'id'),
          DateTime.parse(requiredString(row, 'occurred_at')),
          row['return_kind'] == 'administrative_correction',
        ),
      );
    }
    if (j['invalidated'] is! bool) {
      throw const FormatException('Missing purchase validity');
    }
    return PurchaseEvidence(
      id: requiredString(j, 'id'),
      shopId: requiredString(j, 'shop_id'),
      confirmedAt: DateTime.parse(requiredString(j, 'confirmed_at')),
      items: List.unmodifiable(items),
      returns: List.unmodifiable(returns),
      finalSaleMinor: finalSale as int?,
      classification: classification,
      invalidated: j['invalidated'] as bool,
    );
  }
}

abstract interface class PurchaseEvidenceRepository {
  Future<Either<String, List<PurchaseEvidence>>> list(
    String shopId, {
    int offset = 0,
  });
  Future<Either<String, PurchaseEvidence>> read(String purchaseId);
  Future<Either<PurchaseReturnFailure, PurchaseEvidence>> recordReturn({
    required String purchaseId,
    required String requestId,
    required Map<String, int> quantities,
    required String reason,
  });
}

class PurchaseReturnFailure {
  const PurchaseReturnFailure(this.message, {this.definitelyRejected = false});
  final String message;

  /// Only a known rolled-back server validation error permits editing the draft.
  final bool definitelyRejected;
}
