import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:t_store/features/notifications/presentation/views/customer_notifications_view.dart';
import 'package:t_store/features/personalization/presentation/views/customer_coupons_view.dart';
import 'package:t_store/features/shop/presentation/cubit/recently_viewed_products_state.dart';
import 'package:t_store/features/shop/presentation/views/recently_viewed_products_view.dart';
import 'package:t_store/features/shop/presentation/views/wishlist_view.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';
import 'w48_fixture.dart';

void main() {
  setUpAll(w48Fonts);
  for (final width in [320.0, 390.0, 430.0]) {
    for (final state in ['loaded', 'empty', 'error', 'loading']) {
      testWidgets('W48 wishlist $state $width 130% accessible', (tester) async {
        w48Viewport(tester, width);
        final fixture = W48Fixture(
          favorites: switch (state) {
            'empty' => WishlistLoaded(const []),
            'error' => WishlistError('fixture error'),
            'loading' => WishlistLoading(),
            _ => null,
          },
        );
        await tester.pumpWidget(fixture.host(const WishlistView()));
        await tester.pump(const Duration(milliseconds: 250));
        await w48Accessibility(tester);
        if (state == 'loaded' && width == 390) {
          await w48Golden(tester, 'wishlist_390_130');
        }
        if (state == 'loaded' && width == 320) {
          await w48Golden(tester, 'wishlist_320_130');
        }
        if (state == 'error' && width == 390) {
          await w48Golden(tester, 'wishlist_error_390_130');
        }
      });
      testWidgets('W48 recent $state $width 130% accessible', (tester) async {
        w48Viewport(tester, width);
        final fixture = W48Fixture(
          history: switch (state) {
            'empty' => const RecentlyViewedProductsLoaded([]),
            'error' => const RecentlyViewedProductsError(
              'Bağlantını kontrol edip yeniden deneyebilirsin. Görüntüleme geçmişin bu cihazda saklanır.',
            ),
            'loading' => const RecentlyViewedProductsLoading(),
            _ => null,
          },
        );
        await tester.pumpWidget(
          fixture.host(
            RecentlyViewedProductsView(
              customerId: 'fixture-customer',
              recentlyViewedProductsCubit: fixture.recent,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 250));
        await w48Accessibility(tester);
        if (state == 'loaded' && width == 390) {
          await w48Golden(tester, 'recent_390_130');
        }
      });
      testWidgets('W48 notifications $state $width 130% accessible', (
        tester,
      ) async {
        w48Viewport(tester, width);
        final fixture = W48Fixture(
          activity: switch (state) {
            'empty' => const NotificationsLoaded(notifications: []),
            'error' => const NotificationsError(
              'Bağlantını kontrol edip yeniden deneyebilirsin.',
            ),
            'loading' => NotificationsLoading(),
            _ => null,
          },
        );
        await tester.pumpWidget(
          fixture.host(
            CustomerNotificationsView(
              notificationsCubit: fixture.notifications,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 250));
        await w48Accessibility(tester);
        if (state == 'loaded' && width == 390) {
          await w48Golden(tester, 'notifications_390_130');
        }
      });
    }
    for (final history in [false, true]) {
      testWidgets('W48 coupons history=$history $width 130% truthful', (
        tester,
      ) async {
        w48Viewport(tester, width);
        final fixture = W48Fixture();
        await tester.pumpWidget(fixture.host(const CustomerCouponsView()));
        await tester.pumpAndSettle();
        if (history) {
          await tester.tap(find.text('Geçmiş'));
          await tester.pumpAndSettle();
        }
        expect(find.text('Kupon kullanımı henüz açık değil.'), findsOneWidget);
        expect(find.byType(FilledButton), findsNothing);
        await w48Accessibility(tester);
        if (!history && width == 390) {
          await w48Golden(tester, 'coupons_390_130');
        }
      });
    }
    testWidgets('W48 recent clear modal $width 130% keyboard', (tester) async {
      w48Viewport(tester, width);
      final fixture = W48Fixture();
      await tester.pumpWidget(
        fixture.host(
          RecentlyViewedProductsView(
            customerId: 'fixture-customer',
            recentlyViewedProductsCubit: fixture.recent,
          ),
          keyboard: 280,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Geçmişi temizle'));
      await tester.pumpAndSettle();
      expect(find.text('Görüntüleme geçmişi silinsin mi?'), findsOneWidget);
      await w48Accessibility(tester);
      if (width == 320) await w48Golden(tester, 'recent_clear_320_keyboard');
      await tester.tap(find.text('Vazgeç'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
    testWidgets('W48 recent action menu $width 130%', (tester) async {
      w48Viewport(tester, width);
      final fixture = W48Fixture();
      await tester.pumpWidget(
        fixture.host(
          RecentlyViewedProductsView(
            customerId: 'fixture-customer',
            recentlyViewedProductsCubit: fixture.recent,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Ürün işlemleri'));
      await tester.pumpAndSettle();
      expect(find.text('Geçmişten kaldır'), findsOneWidget);
      await w48Accessibility(tester);
      if (width == 390) await w48Golden(tester, 'recent_menu_390_130');
    });
  }
}
