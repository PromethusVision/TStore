import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/presentation/views/customer_notifications_view.dart';
import 'package:t_store/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:t_store/prototypes/astra_sweep_3b/library_prototypes.dart';
import 'sweep_test_support.dart';

final _items = sweepProducts
    .map(
      (product) => WishlistItemEntity(
        id: 'fixture-wishlist-${product.id}',
        userId: 'fixture-customer',
        productId: product.id,
        product: product,
      ),
    )
    .toList();
final _notifications = [
  NotificationEntity(
    id: 'fixture-notification-1',
    userId: 'fixture-customer',
    title: 'Alışverişin doğrulandı',
    body:
        'Mahalle Giyim alışverişin doğrulandı. Alışveriş kaydını görüntüleyebilirsin.',
    type: NotificationType.order,
    data: const {
      'action_type': 'order_detail',
      'action_id': 'fixture-purchase-1',
    },
    createdAt: DateTime(2026, 9, 4, 14, 30),
  ),
  NotificationEntity(
    id: 'fixture-notification-2',
    userId: 'fixture-customer',
    title: 'Mahalle Giyim mesaj gönderdi',
    body: 'Elbette, gelip deneyebilirsiniz.',
    type: NotificationType.chat,
    data: const {
      'action_type': 'chat_detail',
      'action_id': 'fixture-merchant-1',
      'action_name': 'Mahalle Giyim',
    },
    createdAt: DateTime(2026, 9, 4, 14, 24),
  ),
  NotificationEntity(
    id: 'fixture-notification-3',
    userId: 'fixture-customer',
    title: 'Esnafta Var’a hoş geldin',
    body: 'Yakınındaki mağazaları ve ürünleri keşfet.',
    type: NotificationType.system,
    isRead: true,
    createdAt: DateTime(2026, 9, 2, 10),
  ),
];

Future<void> _primeImages(WidgetTester tester) async {
  await tester.runAsync(
    () => Future.wait(
      sweepProducts.map(
        (product) => precacheImage(
          AssetImage(product.images.first),
          tester.element(find.byKey(const Key('sweep-evidence'))),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadW47Fonts);
  testWidgets(
    '09 wishlist 390: distinct product navigation and remove callbacks',
    (tester) async {
      String? removed;
      await pumpSweep(
        tester,
        Builder(
          builder: (context) => SweepWishlist(
            items: _items,
            onRemove: (item) => removed = item.productId,
            onOpen: (product) => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(),
                  body: Text('Ürün: ${product.id}'),
                ),
              ),
            ),
          ),
        ),
      );
      await _primeImages(tester);
      await captureSweep(tester, '09_wishlist_390.png');
      await tester.tap(
        find.byKey(Key('sweep-wishlist-remove-${sweepProducts.first.id}')),
      );
      await tester.pumpAndSettle();
      expect(removed, sweepProducts.first.id);
      expect(find.text('Ürün: $sweepProductId'), findsNothing);
      await tester.tap(
        find.byKey(const Key('sweep-wishlist-open-fixture-sweep-product')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ürün: $sweepProductId'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Favorilerim'), findsOneWidget);
    },
  );
  testWidgets(
    '10 recent 390: product, favorite, item menu and deliberate clear',
    (tester) async {
      String? favorite;
      String? removed;
      var clears = 0;
      await pumpSweep(
        tester,
        Builder(
          builder: (context) => SweepRecentProducts(
            products: sweepProducts,
            favoriteIds: const {sweepProductId},
            onFavorite: (product) => favorite = product.id,
            onRemove: (product) => removed = product.id,
            onClear: () => clears++,
            onOpen: (product) => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(),
                  body: Text('Ürün: ${product.id}'),
                ),
              ),
            ),
          ),
        ),
      );
      await _primeImages(tester);
      await captureSweep(tester, '10_recently_viewed_390.png');
      await tester.tap(
        find.byKey(const Key('sweep-recent-favorite-fixture-sweep-product')),
      );
      await tester.pumpAndSettle();
      expect(favorite, sweepProductId);
      await tester.tap(
        find.byKey(const Key('sweep-recent-menu-fixture-sweep-product')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Geçmişten kaldır'));
      await tester.pumpAndSettle();
      expect(removed, sweepProductId);
      await tester.tap(find.byKey(const Key('sweep-recent-clear')));
      await tester.pumpAndSettle();
      expect(clears, 0);
      await tester.tap(find.byKey(const Key('sweep-recent-clear-confirm')));
      await tester.pumpAndSettle();
      expect(clears, 1);
      await tester.tap(
        find.byKey(const Key('sweep-recent-open-fixture-sweep-product')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ürün: $sweepProductId'), findsOneWidget);
    },
  );
  testWidgets(
    '11 notifications 390: real destination contract, inert read system item',
    (tester) async {
      NotificationEntity? selected;
      var bulk = 0;
      await pumpSweep(
        tester,
        SweepNotifications(
          notifications: _notifications,
          hasDestination: (notification) =>
              buildCustomerNotificationDestination(notification) != null,
          onTap: (notification) => selected = notification,
          onReadAll: () => bulk++,
        ),
      );
      expect(find.text('2 okunmamış bildirim'), findsOneWidget);
      await captureSweep(tester, '11_notifications_390.png');
      await tester.tap(
        find.byKey(const Key('sweep-notification-fixture-notification-3')),
      );
      expect(selected, isNull);
      await tester.tap(
        find.byKey(const Key('sweep-notification-fixture-notification-1')),
      );
      expect(selected?.actionId, 'fixture-purchase-1');
      expect(selected?.actionType, 'order_detail');
      expect(
        buildCustomerNotificationDestination(selected!).runtimeType.toString(),
        'PurchasesView',
      );
      await tester.tap(find.byKey(const Key('sweep-notifications-read-all')));
      expect(bulk, 1);
    },
  );
  testWidgets(
    '12 coupons 390: truthful empty state, two existing views and back',
    (tester) async {
      await pumpSweep(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SweepCoupons()),
              ),
              child: const Text('Kuponları aç'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Kuponları aç'));
      await tester.pumpAndSettle();
      expect(find.text('Henüz kullanılabilir kuponun yok'), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
      await captureSweep(tester, '12_coupons_390.png');
      await tester.tap(find.text('Geçmiş'));
      await tester.pumpAndSettle();
      expect(find.text('Kupon geçmişin boş'), findsOneWidget);
      await tester.tap(find.byKey(const Key('sweep-back')));
      await tester.pumpAndSettle();
      expect(find.text('Kuponları aç'), findsOneWidget);
    },
  );
}
