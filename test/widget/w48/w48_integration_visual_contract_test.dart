import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:t_store/features/notifications/presentation/views/customer_notifications_view.dart';
import 'package:t_store/features/personalization/presentation/views/customer_coupons_view.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/recently_viewed_products_state.dart';
import 'package:t_store/features/shop/presentation/views/recently_viewed_products_view.dart';
import 'package:t_store/features/shop/presentation/views/wishlist_view.dart';
import 'package:t_store/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';
import 'w48_fixture.dart';

// Real runtime views, synthetic entities and existing assets; no W3B imports.
final _products = [
  for (final entry in [
    ('shirt', 'Günlük pamuklu tişört', 399.90, 'product-shirt.png'),
    ('slippers', 'Rahat ev terliği', 219.90, 'product-slippers.png'),
    ('phone', 'Samsung Galaxy S9', 7499.0, 'samsung_s9_mobile.png'),
    ('shirt-2', 'Yumuşak pamuklu tişört', 699.90, 'product-shirt.png'),
  ])
    ProductEntity(
      id: 'w48i-${entry.$1}',
      name: entry.$2,
      price: entry.$3,
      categoryId: 'local-category',
      stock: 3,
      images: ['assets/images/products/${entry.$4}'],
    ),
];
final _notifications = [
  NotificationEntity(
    id: 'w48i-purchase',
    userId: 'fixture-customer',
    title: 'Alışverişin doğrulandı',
    body: 'Mağazadaki alışveriş kaydını görüntüleyebilirsin.',
    type: NotificationType.order,
    data: const {'action_type': 'order_detail', 'action_id': 'local-purchase'},
    createdAt: DateTime(2026, 9, 4, 14, 30),
  ),
  NotificationEntity(
    id: 'w48i-chat',
    userId: 'fixture-customer',
    title: 'Mağaza mesaj gönderdi',
    body: 'Elbette, gelip deneyebilirsiniz.',
    type: NotificationType.chat,
    data: const {'action_type': 'chat_detail', 'action_id': 'local-shop'},
    createdAt: DateTime(2026, 9, 4, 14, 24),
  ),
  NotificationEntity(
    id: 'w48i-system',
    userId: 'fixture-customer',
    title: 'EsnaftaVar uygulamasına hoş geldin',
    body: 'Yakınındaki mağazaları ve ürünleri keşfet.',
    type: NotificationType.system,
    isRead: true,
    createdAt: DateTime(2026, 9, 2, 10),
  ),
];
Future<void> _settleProductImages(WidgetTester tester) async {
  final context = tester.element(find.byType(MaterialApp));
  await tester.runAsync(() async {
    for (final product in _products) {
      await precacheImage(AssetImage(product.images.single), context);
    }
  });
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(w48Fonts);
  testWidgets(
    'W48 integration 09 real wishlist contains images and separates removal',
    (tester) async {
      w48Viewport(tester, 390);
      final fixture = W48Fixture(
        favorites: WishlistLoaded([
          for (final product in _products)
            WishlistItemEntity(
              id: 'favorite-${product.id}',
              userId: 'fixture-customer',
              productId: product.id,
              product: product,
            ),
        ]),
      );
      final opened = <ProductEntity>[];
      await tester.pumpWidget(
        fixture.host(
          WishlistView(
            destinationBuilder: (product) {
              opened.add(product);
              return const Scaffold(body: Text('Yerel ürün hedefi'));
            },
          ),
          scale: 1,
        ),
      );
      await _settleProductImages(tester);
      final grid = tester.widget<SliverGrid>(
        find.byKey(const Key('wishlist-products-grid')),
      );
      expect(
        (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
            .crossAxisCount,
        2,
      );
      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      expect(images, hasLength(4));
      expect(images.every((image) => image.fit == BoxFit.contain), isTrue);
      await w48Golden(tester, 'integration_09_wishlist_390_100');
      await tester.tap(
        find.byKey(Key('favorite-action-${_products.first.id}')),
      );
      await tester.pumpAndSettle();
      verify(
        () => fixture.wishlist.removeFromWishlist(_products.first.id),
      ).called(1);
      expect(opened, isEmpty);
      await tester.tap(
        find.byKey(Key('wishlist-product-link-${_products[1].id}')),
      );
      await tester.pumpAndSettle();
      expect(opened, [_products[1]]);
      expect(find.text('Yerel ürün hedefi'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('W48 integration 10 real recent horizontal product actions', (
    tester,
  ) async {
    w48Viewport(tester, 390);
    final fixture = W48Fixture(
      history: RecentlyViewedProductsLoaded(_products),
    );
    await tester.pumpWidget(
      fixture.host(
        RecentlyViewedProductsView(
          customerId: 'fixture-customer',
          recentlyViewedProductsCubit: fixture.recent,
        ),
        scale: 1,
      ),
    );
    await _settleProductImages(tester);
    expect(find.text('Geçmişi temizle'), findsOneWidget);
    expect(find.byTooltip('Ürün işlemleri'), findsNWidgets(4));
    await w48Golden(tester, 'integration_10_recent_390_100');
    expect(tester.takeException(), isNull);
  });
  testWidgets('W48 integration 11 marks reflect actual notification targets', (
    tester,
  ) async {
    w48Viewport(tester, 390);
    final fixture = W48Fixture(
      activity: NotificationsLoaded(
        notifications: _notifications,
        unreadCount: 2,
        hasReachedMax: true,
      ),
    );
    await tester.pumpWidget(
      fixture.host(
        CustomerNotificationsView(notificationsCubit: fixture.notifications),
        scale: 1,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('notification-destination-w48i-purchase')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('notification-destination-w48i-chat')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('notification-destination-w48i-system')),
      findsNothing,
    );
    expect(find.text('Tümünü oku'), findsOneWidget);
    await w48Golden(tester, 'integration_11_notifications_390_100');
    expect(tester.takeException(), isNull);
  });
  testWidgets('W48 integration 12 coupon tabs retain truthful empty states', (
    tester,
  ) async {
    w48Viewport(tester, 390);
    final fixture = W48Fixture();
    await tester.pumpWidget(
      fixture.host(const CustomerCouponsView(), scale: 1),
    );
    await tester.pumpAndSettle();
    expect(find.text('Henüz kullanılabilir kuponun yok'), findsOneWidget);
    expect(find.text('Kupon kullanımı henüz açık değil.'), findsOneWidget);
    await w48Golden(tester, 'integration_12_coupons_390_100');
    await tester.tap(find.byKey(const Key('coupon-history-tab')));
    await tester.pumpAndSettle();
    expect(find.text('Kupon geçmişin boş'), findsOneWidget);
    expect(find.text('Kupon kullanımı henüz açık değil.'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(tester.takeException(), isNull);
  });
  for (final scenario in [
    ('unread-system', NotificationType.system, false, false, false),
    ('read-system', NotificationType.system, true, false, false),
    ('suppressed-order', NotificationType.order, false, true, false),
    ('custom-target', NotificationType.system, true, true, true),
  ]) {
    testWidgets('W48 destination indicator ${scenario.$1}', (tester) async {
      w48Viewport(tester, 320);
      final notification = w48Notification.copyWith(
        id: 'w48i-target',
        type: scenario.$2,
        isRead: scenario.$3,
      );
      final fixture = W48Fixture(
        activity: NotificationsLoaded(
          notifications: [notification],
          unreadCount: notification.isRead ? 0 : 1,
          hasReachedMax: true,
        ),
      );
      await tester.pumpWidget(
        fixture.host(
          CustomerNotificationsView(
            notificationsCubit: fixture.notifications,
            notificationDestinationBuilder: scenario.$4
                ? (_) => scenario.$5
                      ? const Scaffold(body: Text('Yerel bildirim hedefi'))
                      : null
                : null,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('notification-destination-w48i-target')),
        scenario.$5 ? findsOneWidget : findsNothing,
      );
      final card = tester.widget<InkWell>(
        find.byKey(const Key('notification-card-w48i-target')),
      );
      if (notification.isRead && !scenario.$5) {
        expect(card.onTap, isNull);
        verifyNever(() => fixture.notifications.markAsRead(any()));
      } else {
        expect(card.onTap, isNotNull);
        await tester.tap(
          find.byKey(const Key('notification-card-w48i-target')),
        );
        await tester.pumpAndSettle();
        if (notification.isRead) {
          verifyNever(() => fixture.notifications.markAsRead(any()));
        } else {
          verify(
            () => fixture.notifications.markAsRead('w48i-target'),
          ).called(1);
        }
        expect(
          find.text('Yerel bildirim hedefi'),
          scenario.$5 ? findsOneWidget : findsNothing,
        );
      }
      expect(tester.takeException(), isNull);
    });
  }
}
