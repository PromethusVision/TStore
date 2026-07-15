import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/purchases/data/models/verified_purchase_model.dart';

void main() {
  test('doğrulanmış alışveriş kaydını ürünleriyle birlikte okur', () {
    final purchase = VerifiedPurchaseModel.fromJson({
      'id': 'purchase-1',
      'source_qr_session_id': 'session-1',
      'shop_id': 'shop-1',
      'shop_name': 'Mahalle Marketi',
      'item_count': 2,
      'total_amount': 150.5,
      'confirmed_at': '2026-07-15T10:30:00Z',
      'shop_ratings': [
        {'rating': 4},
      ],
      'verified_transaction_items': [
        {
          'id': 'item-1',
          'shop_product_id': 'shop-product-1',
          'product_name': 'Deneme Ürünü',
          'quantity': 2,
          'unit_price': 75.25,
          'line_total': 150.5,
        },
      ],
    });

    expect(purchase.shopName, 'Mahalle Marketi');
    expect(purchase.itemCount, 2);
    expect(purchase.totalAmount, 150.5);
    expect(purchase.items.single.productName, 'Deneme Ürünü');
    expect(purchase.items.single.quantity, 2);
    expect(purchase.customerRating, 4);
  });

  test('puan verilmemiş alışverişte müşteri puanı boş kalır', () {
    final purchase = VerifiedPurchaseModel.fromJson({
      'id': 'purchase-1',
      'source_qr_session_id': 'session-1',
      'shop_id': 'shop-1',
      'shop_name': 'Mahalle Marketi',
      'item_count': 1,
      'total_amount': 75,
      'confirmed_at': '2026-07-15T10:30:00Z',
      'shop_ratings': [],
      'verified_transaction_items': [
        {
          'id': 'item-1',
          'shop_product_id': 'shop-product-1',
          'product_name': 'Deneme Ürünü',
          'quantity': 1,
          'unit_price': 75,
          'line_total': 75,
        },
      ],
    });

    expect(purchase.customerRating, isNull);
  });

  test('ürün listesi eksik alışveriş kaydını kabul etmez', () {
    expect(
      () => VerifiedPurchaseModel.fromJson({
        'id': 'purchase-1',
        'source_qr_session_id': 'session-1',
        'shop_id': 'shop-1',
        'shop_name': 'Mahalle Marketi',
        'item_count': 1,
        'total_amount': 75,
        'confirmed_at': '2026-07-15T10:30:00Z',
      }),
      throwsFormatException,
    );
  });
}
