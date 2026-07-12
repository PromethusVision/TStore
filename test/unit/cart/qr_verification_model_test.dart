import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/cart/data/models/qr_session_model.dart';
import 'package:t_store/features/cart/data/models/qr_verification_model.dart';

void main() {
  group('QrVerificationModel', () {
    final validJson = <String, dynamic>{
      'session_id': 'session-1',
      'session_token': 'token-1',
      'status': 'active',
      'expires_at': '2099-01-01T00:00:00Z',
      'used_at': null,
      'shop_id': 'shop-1',
      'shop_name': 'Test Mağaza',
      'item_count': 3,
      'total_amount': '124.50',
      'items': <Map<String, dynamic>>[
        {
          'id': 'item-1',
          'shop_product_id': 'shop-product-1',
          'product_name': 'Test Ürün',
          'quantity': 3,
          'unit_price': '41.50',
          'line_total': '124.50',
        },
      ],
    };

    test('parses a consistent server snapshot', () {
      final model = QrVerificationModel.fromJson(validJson);

      expect(model.itemCount, 3);
      expect(model.totalAmount, 124.50);
      expect(model.items.single.productName, 'Test Ürün');
      expect(model.items.single.lineTotal, 124.50);
    });

    test('rejects a snapshot whose total does not match its items', () {
      final invalidJson = <String, dynamic>{
        ...validJson,
        'total_amount': '125.50',
      };

      expect(
        () => QrVerificationModel.fromJson(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects an item whose line total is inconsistent', () {
      final invalidJson = <String, dynamic>{
        ...validJson,
        'items': <Map<String, dynamic>>[
          {
            ...(validJson['items'] as List<Map<String, dynamic>>).single,
            'line_total': '123.00',
          },
        ],
      };

      expect(
        () => QrVerificationModel.fromJson(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects an empty item snapshot', () {
      final invalidJson = <String, dynamic>{
        ...validJson,
        'item_count': 0,
        'total_amount': 0,
        'items': <Map<String, dynamic>>[],
      };

      expect(
        () => QrVerificationModel.fromJson(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });
  });

  test('QrSessionModel reads the server-side item count and total', () {
    final model = QrSessionModel.fromJson({
      'id': 'session-1',
      'session_token': 'token-1',
      'user_id': 'user-1',
      'cart_id': 'cart-1',
      'shop_id': 'shop-1',
      'status': 'active',
      'expires_at': '2099-01-01T00:00:00Z',
      'used_at': null,
      'created_at': '2098-12-31T23:58:00Z',
      'updated_at': '2098-12-31T23:58:00Z',
      'item_count': 3,
      'total_amount': '124.50',
    });

    expect(model.itemCount, 3);
    expect(model.totalAmount, 124.50);
  });
}
