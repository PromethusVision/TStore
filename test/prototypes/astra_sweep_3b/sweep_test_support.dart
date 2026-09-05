import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';
import 'package:t_store/features/reviews/domain/entities/review_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import '../../widget/w47_prototype_support.dart';
export '../../widget/w47_prototype_support.dart' show loadW47Fonts;

const sweepProductId = 'fixture-sweep-product';
const sweepEligibility = ProductReviewEligibility(
  productId: sweepProductId,
  eligible: true,
  canSubmit: true,
  verifiedTransactionId: 'fixture-transaction',
  verifiedTransactionItemId: 'fixture-evidence',
);
final sweepOwnReview = ReviewEntity(
  id: 'fixture-review',
  productId: sweepProductId,
  userId: 'fixture-customer',
  rating: 5,
  title: 'Kumaşı çok rahat',
  comment: 'Mağazada deneyerek aldım. Kalıbı çok güzel.',
  isVerifiedPurchase: true,
  canEdit: true,
  createdAt: DateTime(2026, 9, 4),
);
final sweepPurchases = [
  VerifiedPurchaseEntity(
    id: 'fixture-purchase-1',
    sourceQrSessionId: 'fixture-qr-1',
    shopId: 'fixture-shop-1',
    shopName: 'Mahalle Giyim',
    itemCount: 2,
    totalAmount: 799.80,
    confirmedAt: DateTime(2026, 9, 4, 14, 30),
    customerRating: 5,
    customerRatedAt: DateTime(2026, 9, 4, 15),
    items: const [],
  ),
  VerifiedPurchaseEntity(
    id: 'fixture-purchase-2',
    sourceQrSessionId: 'fixture-qr-2',
    shopId: 'fixture-shop-2',
    shopName: 'Çınar Teknoloji',
    itemCount: 1,
    totalAmount: 1499.90,
    confirmedAt: DateTime(2026, 9, 2, 11),
    customerRating: 4,
    customerRatedAt: DateTime(2026, 9, 2, 12),
    items: const [],
  ),
];
final sweepUnrated = VerifiedPurchaseEntity(
  id: 'fixture-unrated',
  sourceQrSessionId: 'fixture-qr-unrated',
  shopId: 'fixture-shop-1',
  shopName: 'Mahalle Giyim',
  itemCount: 1,
  totalAmount: 399.90,
  confirmedAt: DateTime(2026, 9, 5, 11),
  items: const [],
);
final sweepThreads = [
  ChatThreadEntity(
    otherUserId: 'fixture-merchant-1',
    displayName: 'Mahalle Giyim',
    lastMessage:
        'Elbette, gelip deneyebilirsiniz. İki rengi de görebilirsiniz.',
    lastMessageAt: DateTime(2026, 9, 4, 14, 24),
    unreadCount: 2,
  ),
  ChatThreadEntity(
    otherUserId: 'fixture-merchant-2',
    displayName: 'Çınar Teknoloji',
    lastMessage: 'Teşekkürler, mağazanıza uğrayacağım.',
    lastMessageIsMine: true,
    lastMessageIsRead: true,
    lastMessageAt: DateTime(2026, 9, 3, 16, 10),
  ),
  ChatThreadEntity(
    otherUserId: 'fixture-merchant-3',
    displayName: 'Komşu Ayakkabı',
    lastMessage: 'Merhaba, 38 numarası şu an mağazada var.',
    lastMessageAt: DateTime(2026, 9, 2, 11, 5),
  ),
];
const sweepProducts = [
  ProductEntity(
    id: sweepProductId,
    name: 'Günlük pamuklu tişört',
    price: 399.90,
    categoryId: 'fixture-category',
    stock: 10,
    images: ['assets/images/products/product-shirt.png'],
    brandName: 'Basic',
    rating: 4.7,
    reviewsCount: 36,
  ),
  ProductEntity(
    id: 'fixture-product-2',
    name: 'Rahat ev terliği',
    price: 219.90,
    categoryId: 'fixture-category',
    stock: 8,
    images: ['assets/images/products/slipper-product-1.png'],
    rating: 4.5,
    reviewsCount: 18,
  ),
  ProductEntity(
    id: 'fixture-product-3',
    name: 'Samsung Galaxy S9',
    price: 7499,
    categoryId: 'fixture-category',
    stock: 4,
    images: ['assets/images/products/samsung_s9_mobile.png'],
    brandName: 'Samsung',
    rating: 4.6,
    reviewsCount: 24,
  ),
  ProductEntity(
    id: 'fixture-product-4',
    name: 'Mavi polo tişört',
    price: 699.90,
    categoryId: 'fixture-category',
    stock: 5,
    images: ['assets/images/products/product-shirt_blue_1.png'],
    rating: 4.8,
    reviewsCount: 12,
  ),
];

Future<void> pumpSweep(WidgetTester tester, Widget child) async {
  setW47Viewport(tester);
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('sweep-evidence'),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: EsnaftaVarTheme.light,
        home: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> openSweepModal(
  WidgetTester tester,
  WidgetBuilder builder, {
  bool dialog = false,
  bool purchases = false,
}) async {
  final path = purchases
      ? 'test/widget/purchases/goldens/w47_purchases_390.png'
      : 'test/widget/shop/goldens/w47_reviews_390.png';
  final bytes = File(path).readAsBytesSync();
  await pumpSweep(
    tester,
    Builder(
      builder: (context) => Scaffold(
        body: GestureDetector(
          key: const Key('open-modal'),
          onTap: () {
            if (dialog) {
              showDialog<void>(context: context, builder: builder);
            } else {
              showModalBottomSheet<void>(
                context: context,
                useSafeArea: true,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: builder,
              );
            }
          },
          child: Image.memory(bytes, width: 390, height: 844, fit: BoxFit.fill),
        ),
      ),
    ),
  );
  await tester.runAsync(
    () => precacheImage(
      MemoryImage(bytes),
      tester.element(find.byKey(const Key('open-modal'))),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('open-modal')));
  await tester.pumpAndSettle();
}

Future<void> captureSweep(WidgetTester tester, String file) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  await expectLater(
    find.byKey(const Key('sweep-evidence')),
    matchesGoldenFile('goldens/$file'),
  );
}
