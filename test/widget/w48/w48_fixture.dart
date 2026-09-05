import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_state.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/recently_viewed_products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/recently_viewed_products_state.dart';
import 'package:t_store/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class W48Wishlist extends MockCubit<WishlistState> implements WishlistCubit {}

class W48Recent extends MockCubit<RecentlyViewedProductsState>
    implements RecentlyViewedProductsCubit {}

class W48Notifications extends MockCubit<NotificationsState>
    implements NotificationsCubit {}

class W48Qr extends MockCubit<QrSessionState> implements QrSessionCubit {}

const w48Product = ProductEntity(
  id: 'w48-product',
  name: 'El yapımı desenli seramik kahve fincanı ve porselen sunum tabağı',
  price: 1249.90,
  salePrice: 999.90,
  categoryId: 'fixture-category',
  stock: 3,
  images: [],
  brandName: 'Şükran Çiçekçi Tasarım Atölyesi',
);
const w48Favorite = WishlistItemEntity(
  id: 'w48-favorite',
  userId: 'fixture-customer',
  productId: 'w48-product',
  product: w48Product,
);
const w48Notification = NotificationEntity(
  id: 'w48-notification',
  userId: 'fixture-customer',
  title: 'Alışverişin doğrulandı: Şükran Çiçekçi Tasarım Atölyesi',
  body:
      'Mahallendeki esnafla yaptığın alışverişin ayrıntılarını görüntüleyebilir, ürün bilgilerini ve mağazanın açıklamalarını inceleyebilirsin.',
  type: NotificationType.order,
  data: {'action_type': 'order_detail', 'action_id': 'fixture-purchase'},
);

QrSessionEntity w48Session({int? count = 2, double? total = 249.90}) =>
    QrSessionEntity(
      id: 'fixture-session',
      sessionToken: 'local-widget-fixture',
      userId: 'fixture-customer',
      cartId: 'fixture-cart',
      shopId: 'fixture-shop',
      status: 'active',
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      itemCount: count,
      totalAmount: total,
    );

class W48Fixture {
  final wishlist = W48Wishlist();
  final recent = W48Recent();
  final notifications = W48Notifications();
  final qr = W48Qr();
  final navigation = NavigationMenuCubit();
  W48Fixture({
    WishlistState? favorites,
    RecentlyViewedProductsState? history,
    NotificationsState? activity,
    QrSessionState? session,
  }) {
    whenListen(
      wishlist,
      const Stream<WishlistState>.empty(),
      initialState: favorites ?? WishlistLoaded(const [w48Favorite]),
    );
    whenListen(
      recent,
      const Stream<RecentlyViewedProductsState>.empty(),
      initialState: history ?? const RecentlyViewedProductsLoaded([w48Product]),
    );
    whenListen(
      notifications,
      const Stream<NotificationsState>.empty(),
      initialState:
          activity ??
          const NotificationsLoaded(
            notifications: [w48Notification],
            unreadCount: 1,
            hasReachedMax: true,
          ),
    );
    whenListen(
      qr,
      const Stream<QrSessionState>.empty(),
      initialState: session ?? QrSessionCreated(w48Session()),
    );
    when(() => wishlist.getWishlist()).thenAnswer((_) async {});
    when(() => wishlist.removeFromWishlist(any())).thenAnswer((_) async {});
    when(() => wishlist.isInWishlist(any())).thenReturn(true);
    when(() => wishlist.toggleWishlist(any())).thenAnswer((_) async {});
    when(() => recent.load(any())).thenAnswer((_) async {});
    when(() => recent.clear(any())).thenAnswer((_) async => true);
    when(() => recent.close()).thenAnswer((_) async {});
    when(
      () => notifications.getNotifications(refresh: any(named: 'refresh')),
    ).thenAnswer((_) async {});
    when(() => notifications.markAllAsRead()).thenAnswer((_) async {});
    when(() => notifications.markAsRead(any())).thenAnswer((_) async {});
    when(() => notifications.loadMoreNotifications()).thenAnswer((_) async {});
    when(() => notifications.close()).thenAnswer((_) async {});
    when(() => qr.createQrSession(any())).thenAnswer((_) async {});
    addTearDown(navigation.close);
  }
  Widget host(Widget child, {double scale = 1.3, double keyboard = 0}) =>
      MultiBlocProvider(
        providers: [
          BlocProvider<WishlistCubit>.value(value: wishlist),
          BlocProvider<NavigationMenuCubit>.value(value: navigation),
          BlocProvider<QrSessionCubit>.value(value: qr),
        ],
        child: RepaintBoundary(
          key: const Key('w48-proof'),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: EsnaftaVarTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
                viewInsets: EdgeInsets.only(bottom: keyboard),
              ),
              child: child!,
            ),
            home: child,
          ),
        ),
      );
}

Future<void> w48Fonts() async {
  final font = FontLoader('Poppins');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    font.addFont(rootBundle.load('assets/fonts/Poppins-$weight.ttf'));
  }
  final material = FontLoader('MaterialIcons')
    ..addFont(
      File(
        '${File(Platform.resolvedExecutable).parent.parent.parent.path}/material_fonts/MaterialIcons-Regular.otf',
      ).readAsBytes().then(ByteData.sublistView),
    );
  final iconsax = FontLoader('packages/iconsax_flutter/FlutterIconsax')
    ..addFont(
      rootBundle.load('packages/iconsax_flutter/fonts/FlutterIconsax.ttf'),
    );
  await Future.wait([font.load(), material.load(), iconsax.load()]);
}

void w48Viewport(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> w48Accessibility(WidgetTester tester, {Finder? within}) async {
  expect(tester.takeException(), isNull);
  final semantics = tester.ensureSemantics();
  try {
    final targets = find.byWidgetPredicate(
      (w) =>
          w is ButtonStyleButton && w.onPressed != null ||
          w is IconButton && w.onPressed != null ||
          w is InkWell && w.onTap != null,
    );
    // Modal checks measure only the assigned surface; covered background
    // controls belong to the existing screen and cannot be interacted with.
    final scoped = within == null
        ? targets
        : find.descendant(of: within, matching: targets);
    for (final element in scoped.evaluate()) {
      final size = tester.getSize(
        find.byElementPredicate((e) => identical(e, element)),
      );
      expect(
        size.width,
        greaterThanOrEqualTo(44),
        reason: '${element.widget.runtimeType} width',
      );
      expect(
        size.height,
        greaterThanOrEqualTo(44),
        reason: '${element.widget.runtimeType} height',
      );
    }
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  } finally {
    semantics.dispose();
  }
}

Future<void> w48Golden(WidgetTester tester, String name) => expectLater(
  find.byKey(const Key('w48-proof')),
  matchesGoldenFile('goldens/w48_$name.png'),
);
