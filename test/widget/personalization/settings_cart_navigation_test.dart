import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_conversations_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_conversations_state.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_state.dart';
import 'package:t_store/features/chat/presentation/views/conversations_view.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:t_store/features/notifications/presentation/views/customer_notifications_view.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_state.dart';
import 'package:t_store/features/personalization/presentation/views/customer_coupons_view.dart';
import 'package:t_store/features/personalization/presentation/views/customer_saved_locations_view.dart';
import 'package:t_store/features/personalization/presentation/views/help_and_support_view.dart';
import 'package:t_store/features/personalization/presentation/views/privacy_and_permissions_view.dart';
import 'package:t_store/features/personalization/presentation/views/profile_view.dart';
import 'package:t_store/features/personalization/presentation/views/settings_view.dart';
import 'package:t_store/features/personalization/presentation/widgets/settings_menu_tile.dart';
import 'package:t_store/features/personalization/presentation/widgets/user_profile_tile.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_cubit.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_state.dart';
import 'package:t_store/features/purchases/presentation/views/customer_ratings_view.dart';
import 'package:t_store/features/purchases/presentation/views/purchases_view.dart';
import 'package:t_store/features/shop/presentation/cubit/recently_viewed_products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/recently_viewed_products_state.dart';
import 'package:t_store/features/shop/presentation/views/recently_viewed_products_view.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockCartV2Cubit extends MockCubit<CartV2State> implements CartV2Cubit {}

class MockChatUnreadCubit extends MockCubit<ChatUnreadState>
    implements ChatUnreadCubit {}

class MockChatConversationsCubit extends MockCubit<ChatConversationsState>
    implements ChatConversationsCubit {}

class MockPurchaseHistoryCubit extends MockCubit<PurchaseHistoryState>
    implements PurchaseHistoryCubit {}

class MockRecentlyViewedProductsCubit
    extends MockCubit<RecentlyViewedProductsState>
    implements RecentlyViewedProductsCubit {}

class MockNotificationsCubit extends MockCubit<NotificationsState>
    implements NotificationsCubit {}

class MockCustomerSavedLocationsCubit
    extends MockCubit<CustomerSavedLocationsState>
    implements CustomerSavedLocationsCubit {}

void main() {
  const user = UserEntity(
    id: 'customer-1',
    email: 'customer@example.com',
    fullName: 'Müşteri Kullanıcı',
  );

  late MockAuthCubit authCubit;
  late MockAuthCubit loginAuthCubit;
  late MockCartV2Cubit cartV2Cubit;
  late MockChatUnreadCubit chatUnreadCubit;
  late MockChatConversationsCubit chatConversationsCubit;
  late MockPurchaseHistoryCubit purchaseHistoryCubit;
  late MockRecentlyViewedProductsCubit recentlyViewedProductsCubit;
  late MockNotificationsCubit notificationsCubit;
  late MockCustomerSavedLocationsCubit customerSavedLocationsCubit;

  setUp(() async {
    await sl.reset();

    authCubit = MockAuthCubit();
    loginAuthCubit = MockAuthCubit();
    cartV2Cubit = MockCartV2Cubit();
    chatUnreadCubit = MockChatUnreadCubit();
    chatConversationsCubit = MockChatConversationsCubit();
    purchaseHistoryCubit = MockPurchaseHistoryCubit();
    recentlyViewedProductsCubit = MockRecentlyViewedProductsCubit();
    notificationsCubit = MockNotificationsCubit();
    customerSavedLocationsCubit = MockCustomerSavedLocationsCubit();

    whenListen(
      cartV2Cubit,
      const Stream<CartV2State>.empty(),
      initialState: const CartV2Loaded([]),
    );
    when(() => cartV2Cubit.getActiveCartItems()).thenAnswer((_) async {});

    whenListen(
      chatUnreadCubit,
      const Stream<ChatUnreadState>.empty(),
      initialState: const ChatUnreadLoaded(0),
    );
    when(() => chatUnreadCubit.loadUnreadCount()).thenAnswer((_) async {});
    when(
      () => chatUnreadCubit.refreshUnreadCountSilently(),
    ).thenAnswer((_) async {});
    when(() => chatUnreadCubit.close()).thenAnswer((_) async {});

    whenListen(
      chatConversationsCubit,
      const Stream<ChatConversationsState>.empty(),
      initialState: const ChatConversationsLoaded([]),
    );
    when(
      () => chatConversationsCubit.loadConversations(),
    ).thenAnswer((_) async {});
    when(
      () => chatConversationsCubit.refreshConversationsSilently(),
    ).thenAnswer((_) async {});
    when(() => chatConversationsCubit.close()).thenAnswer((_) async {});

    whenListen(
      purchaseHistoryCubit,
      const Stream<PurchaseHistoryState>.empty(),
      initialState: const PurchaseHistoryLoaded([]),
    );
    when(() => purchaseHistoryCubit.loadPurchases()).thenAnswer((_) async {});
    when(() => purchaseHistoryCubit.close()).thenAnswer((_) async {});

    whenListen(
      recentlyViewedProductsCubit,
      const Stream<RecentlyViewedProductsState>.empty(),
      initialState: const RecentlyViewedProductsLoaded([]),
    );
    when(
      () => recentlyViewedProductsCubit.load(any()),
    ).thenAnswer((_) async {});
    when(() => recentlyViewedProductsCubit.close()).thenAnswer((_) async {});

    whenListen(
      notificationsCubit,
      const Stream<NotificationsState>.empty(),
      initialState: const NotificationsLoaded(
        notifications: [],
        hasReachedMax: true,
      ),
    );
    when(
      () => notificationsCubit.getNotifications(refresh: any(named: 'refresh')),
    ).thenAnswer((_) async {});
    when(() => notificationsCubit.close()).thenAnswer((_) async {});

    whenListen(
      customerSavedLocationsCubit,
      const Stream<CustomerSavedLocationsState>.empty(),
      initialState: const CustomerSavedLocationsLoaded(locations: []),
    );
    when(
      () => customerSavedLocationsCubit.loadLocations(),
    ).thenAnswer((_) async {});
    when(() => customerSavedLocationsCubit.close()).thenAnswer((_) async {});

    whenListen(
      loginAuthCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    when(() => authCubit.checkAuthStatus()).thenAnswer((_) async {});
    when(() => loginAuthCubit.close()).thenAnswer((_) async {});

    sl.registerFactory<ChatUnreadCubit>(() => chatUnreadCubit);
    sl.registerFactory<ChatConversationsCubit>(() => chatConversationsCubit);
    sl.registerFactory<PurchaseHistoryCubit>(() => purchaseHistoryCubit);
    sl.registerFactory<RecentlyViewedProductsCubit>(
      () => recentlyViewedProductsCubit,
    );
    sl.registerFactory<NotificationsCubit>(() => notificationsCubit);
    sl.registerFactory<CustomerSavedLocationsCubit>(
      () => customerSavedLocationsCubit,
    );
    sl.registerFactory<AuthCubit>(() => loginAuthCubit);
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildSubject({
    required AuthState authState,
    required String? currentUserId,
    SettingsCurrentUserIdProvider? currentUserIdProvider,
    Duration unreadAutoRefreshInterval = const Duration(seconds: 15),
    bool useInheritedChatUnreadCubit = false,
  }) {
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: authState,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<CartV2Cubit>.value(value: cartV2Cubit),
        if (useInheritedChatUnreadCubit)
          BlocProvider<ChatUnreadCubit>.value(value: chatUnreadCubit),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SettingsView(
            currentUserIdProvider: currentUserIdProvider ?? () => currentUserId,
            locationPermissionLoader: () async =>
                CustomerLocationPermissionStatus.notAllowed,
            unreadAutoRefreshInterval: unreadAutoRefreshInterval,
            useInheritedChatUnreadCubit: useInheritedChatUnreadCubit,
          ),
        ),
      ),
    );
  }

  testWidgets(
    'hesap ekranında sektör standardındaki müşteri seçeneklerini gösterir',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(
          authState: const AuthAuthenticated(user),
          currentUserId: user.id,
        ),
      );
      await tester.pumpAndSettle();

      for (final visibleOption in [
        'Mesajlarım',
        'Alışverişlerim',
        'Kuponlarım',
        'Son Görüntülediklerim',
        'Değerlendirmelerim',
        'Bildirimlerim',
        'Kayıtlı Konumlarım',
        'Hesap Bilgilerim',
        'Yardım ve Destek',
        'Gizlilik ve İzinler',
      ]) {
        expect(find.text(visibleOption), findsOneWidget);
      }

      expect(find.text('Çıkış Yap'), findsOneWidget);
      expect(find.text('Sepetim'), findsNothing);
      expect(find.text('Profilim'), findsOneWidget);
      expect(find.text('Alışveriş ve iletişim'), findsOneWidget);
      expect(find.text('Hesap ve destek'), findsOneWidget);
      expect(
        find.byKey(const Key('customer-profile-identity-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('customer-profile-activity-section')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('customer-profile-account-section')),
        findsOneWidget,
      );

      for (final hiddenOption in [
        'Adreslerim',
        'Esnaf Ol',
        'Mağazam',
        'İşlemlerim',
        'Banka Hesabı',
        'Bildirimler',
        'Hesap Gizliliği',
        'Uygulama Ayarları',
        'Veri Yükleme',
        'Konum',
        'Güvenli Mod',
        'HD Görsel Kalitesi',
      ]) {
        expect(find.text(hiddenOption), findsNothing);
      }
    },
  );

  testWidgets('profil ekranı 320 piksel genişlikte taşma yapmaz', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 820);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      buildSubject(
        authState: const AuthAuthenticated(user),
        currentUserId: user.id,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-profile-content')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('çıkış düğmesi beklerken ikinci isteği başlatmaz', (
    tester,
  ) async {
    final signOutCompleter = Completer<void>();
    when(() => authCubit.signOut()).thenAnswer((_) => signOutCompleter.future);

    await tester.pumpWidget(
      buildSubject(
        authState: const AuthAuthenticated(user),
        currentUserId: user.id,
      ),
    );
    await tester.pumpAndSettle();

    final signOutButton = find.byKey(const Key('customer-sign-out'));
    await tester.ensureVisible(signOutButton);
    await tester.tap(signOutButton);
    await tester.pump();
    await tester.tap(signOutButton);
    await tester.pump();

    verify(() => authCubit.signOut()).called(1);
    expect(find.byKey(const Key('customer-sign-out-progress')), findsOneWidget);

    signOutCompleter.complete();
    await tester.pump();
    await tester.pump();

    expect(find.text('Çıkış Yap'), findsOneWidget);
  });

  testWidgets('Alışverişlerim yeni müşteri geçmişi ekranını açar', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        authState: const AuthAuthenticated(user),
        currentUserId: user.id,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Alışverişlerim'));
    await tester.tap(find.text('Alışverişlerim'));
    await tester.pumpAndSettle();

    expect(find.byType(PurchasesView), findsOneWidget);
    expect(find.text('İade Taleplerim'), findsOneWidget);
    expect(find.text('İade Talebi Oluştur'), findsOneWidget);
    verify(() => purchaseHistoryCubit.loadPurchases()).called(1);
  });

  testWidgets('Hesap Bilgilerim mevcut profil ekranını açar', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        authState: const AuthAuthenticated(user),
        currentUserId: user.id,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Hesap Bilgilerim'));
    await tester.tap(find.text('Hesap Bilgilerim'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileView), findsOneWidget);
    expect(find.text('customer@example.com'), findsOneWidget);
  });

  testWidgets('Değerlendirmelerim gerçek müşteri puanları ekranını açar', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        authState: const AuthAuthenticated(user),
        currentUserId: user.id,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Değerlendirmelerim'));
    await tester.tap(find.text('Değerlendirmelerim'));
    await tester.pumpAndSettle();

    expect(find.byType(CustomerRatingsView), findsOneWidget);
    expect(find.text('Henüz değerlendirme yapmadınız'), findsOneWidget);
    verify(() => purchaseHistoryCubit.loadPurchases()).called(1);
  });

  testWidgets('Son Görüntülediklerim gerçek ürün geçmişi ekranını açar', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        authState: const AuthAuthenticated(user),
        currentUserId: user.id,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Son Görüntülediklerim'));
    await tester.tap(find.text('Son Görüntülediklerim'));
    await tester.pumpAndSettle();

    expect(find.byType(RecentlyViewedProductsView), findsOneWidget);
    expect(find.text('Henüz görüntülediğin ürün yok'), findsOneWidget);
    verify(() => recentlyViewedProductsCubit.load(user.id)).called(1);
  });

  testWidgets('Bildirimlerim gerçek müşteri bildirimleri ekranını açar', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        authState: const AuthAuthenticated(user),
        currentUserId: user.id,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Bildirimlerim'));
    await tester.tap(find.text('Bildirimlerim'));
    await tester.pumpAndSettle();

    expect(find.byType(CustomerNotificationsView), findsOneWidget);
    expect(find.text('Henüz bildirimin yok'), findsOneWidget);
    verify(() => notificationsCubit.getNotifications(refresh: true)).called(1);
  });

  testWidgets('Kayıtlı Konumlarım gerçek müşteri konumları ekranını açar', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        authState: const AuthAuthenticated(user),
        currentUserId: user.id,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Kayıtlı Konumlarım'));
    await tester.tap(find.text('Kayıtlı Konumlarım'));
    await tester.pumpAndSettle();

    expect(find.byType(CustomerSavedLocationsView), findsOneWidget);
    expect(find.text('Henüz kayıtlı konumun yok'), findsOneWidget);
    verify(() => customerSavedLocationsCubit.loadLocations()).called(1);
  });

  testWidgets('Yardım ve Destek müşteri yardım merkezini açar', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        authState: const AuthAuthenticated(user),
        currentUserId: user.id,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Yardım ve Destek'));
    await tester.tap(find.text('Yardım ve Destek'));
    await tester.pumpAndSettle();

    expect(find.byType(HelpAndSupportView), findsOneWidget);
    expect(find.text('Nasıl yardımcı olabiliriz?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('help-purchases-action')));
    await tester.pumpAndSettle();

    expect(find.byType(PurchasesView), findsOneWidget);
    verify(() => purchaseHistoryCubit.loadPurchases()).called(1);
  });

  testWidgets('Gizlilik ve İzinler müşteri gizlilik ekranını açar', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        authState: const AuthAuthenticated(user),
        currentUserId: user.id,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Gizlilik ve İzinler'));
    await tester.tap(find.text('Gizlilik ve İzinler'));
    await tester.pumpAndSettle();

    expect(find.byType(PrivacyAndPermissionsView), findsOneWidget);
    expect(find.text('Gizliliğin ve kontrolün sende'), findsOneWidget);
  });

  for (final destination in const [
    (label: 'Yardım ve Destek', viewType: HelpAndSupportView),
    (label: 'Gizlilik ve İzinler', viewType: PrivacyAndPermissionsView),
  ]) {
    testWidgets(
      '${destination.label} hızlı dokunmada bir kez açılır ve dönüşte yeniden çalışır',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            authState: const AuthAuthenticated(user),
            currentUserId: user.id,
          ),
        );
        await tester.pumpAndSettle();

        final destinationTile = tester.widget<SettingsMenuTile>(
          find.byWidgetPredicate(
            (widget) =>
                widget is SettingsMenuTile &&
                widget.settingsMenuTileModel.title == destination.label,
          ),
        );
        destinationTile.settingsMenuTileModel.onTap();
        destinationTile.settingsMenuTileModel.onTap();
        await tester.pumpAndSettle();

        expect(
          find.byType(destination.viewType, skipOffstage: false),
          findsOneWidget,
        );

        Navigator.of(tester.element(find.byType(destination.viewType))).pop();
        await tester.pumpAndSettle();

        expect(find.byType(SettingsView), findsOneWidget);
        final reopenedTile = tester.widget<SettingsMenuTile>(
          find.byWidgetPredicate(
            (widget) =>
                widget is SettingsMenuTile &&
                widget.settingsMenuTileModel.title == destination.label,
          ),
        );
        reopenedTile.settingsMenuTileModel.onTap();
        await tester.pumpAndSettle();

        expect(find.byType(destination.viewType), findsOneWidget);
      },
    );
  }

  testWidgets('Kuponlarım müşteri kuponları ekranını açar', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        authState: const AuthAuthenticated(user),
        currentUserId: user.id,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Kuponlarım'));
    await tester.tap(find.text('Kuponlarım'));
    await tester.pumpAndSettle();

    expect(find.byType(CustomerCouponsView), findsOneWidget);
    expect(find.text('Henüz kullanılabilir kuponun yok'), findsOneWidget);
  });

  testWidgets(
    'profil üst kartı girişten sonra profilde kalıp bilgileri yeniler',
    (tester) async {
      String? currentUserId;
      await tester.pumpWidget(
        buildSubject(
          authState: AuthUnauthenticated(),
          currentUserId: null,
          currentUserIdProvider: () => currentUserId,
          useInheritedChatUnreadCubit: true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Giriş yap'));
      await tester.pumpAndSettle();

      final loginView = tester.widget<LoginView>(find.byType(LoginView));
      expect(loginView.returnToCallerAfterCustomerLogin, isTrue);

      currentUserId = user.id;
      when(() => authCubit.state).thenReturn(const AuthAuthenticated(user));
      Navigator.of(tester.element(find.byType(LoginView))).pop(true);
      await tester.pumpAndSettle();

      expect(find.byType(SettingsView), findsOneWidget);
      expect(find.byType(LoginView), findsNothing);
      expect(find.text('Müşteri Kullanıcı'), findsOneWidget);
      expect(find.text('customer@example.com'), findsOneWidget);
      verify(() => authCubit.checkAuthStatus()).called(1);
    },
  );

  testWidgets('profil üst kartında girişten vazgeçerse misafir profili korur', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        authState: AuthUnauthenticated(),
        currentUserId: null,
        useInheritedChatUnreadCubit: true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Giriş yap'));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(LoginView))).pop(false);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsView), findsOneWidget);
    expect(find.text('Giriş yap'), findsOneWidget);
    verifyNever(() => authCubit.checkAuthStatus());
  });

  testWidgets('profil üst kartına hızlı dokununca tek giriş ekranı açar', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        authState: AuthUnauthenticated(),
        currentUserId: null,
        useInheritedChatUnreadCubit: true,
      ),
    );
    await tester.pumpAndSettle();

    final signInTile = tester.widget<UserProfileTile>(
      find.byWidgetPredicate(
        (widget) =>
            widget is UserProfileTile &&
            widget.userProfileTileModel.title == 'Giriş yap',
      ),
    );
    signInTile.userProfileTileModel.onTap?.call();
    signInTile.userProfileTileModel.onTap?.call();
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('giriş yapmayan müşteriyi kuponlardan önce girişe yönlendirir', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(authState: AuthUnauthenticated(), currentUserId: null),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Kuponlarım'));
    await tester.tap(find.text('Kuponlarım'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(CustomerCouponsView), findsNothing);
    expect(
      tester
          .widget<LoginView>(find.byType(LoginView))
          .returnToCallerAfterCustomerLogin,
      isTrue,
    );
  });

  for (final destination in const [
    (label: 'Mesajlarım', viewType: ConversationsView),
    (label: 'Alışverişlerim', viewType: PurchasesView),
    (label: 'Kuponlarım', viewType: CustomerCouponsView),
    (label: 'Son Görüntülediklerim', viewType: RecentlyViewedProductsView),
    (label: 'Değerlendirmelerim', viewType: CustomerRatingsView),
    (label: 'Bildirimlerim', viewType: CustomerNotificationsView),
    (label: 'Kayıtlı Konumlarım', viewType: CustomerSavedLocationsView),
    (label: 'Hesap Bilgilerim', viewType: ProfileView),
  ]) {
    testWidgets('misafir ${destination.label} seçimini girişten sonra açar', (
      tester,
    ) async {
      String? currentUserId;
      await tester.pumpWidget(
        buildSubject(
          authState: AuthUnauthenticated(),
          currentUserId: null,
          currentUserIdProvider: () => currentUserId,
          useInheritedChatUnreadCubit: true,
        ),
      );
      await tester.pumpAndSettle();

      final destinationTile = find.text(destination.label);
      await tester.ensureVisible(destinationTile);
      await tester.tap(destinationTile);
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsOneWidget);
      expect(find.byType(destination.viewType), findsNothing);

      currentUserId = user.id;
      when(() => authCubit.state).thenReturn(const AuthAuthenticated(user));
      Navigator.of(tester.element(find.byType(LoginView))).pop(true);
      await tester.pumpAndSettle();

      expect(find.byType(destination.viewType), findsOneWidget);
    });
  }

  testWidgets('misafir girişten vazgeçerse profil ekranında kalır', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        authState: AuthUnauthenticated(),
        currentUserId: null,
        useInheritedChatUnreadCubit: true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Alışverişlerim'));
    await tester.tap(find.text('Alışverişlerim'));
    await tester.pumpAndSettle();

    Navigator.of(tester.element(find.byType(LoginView))).pop(false);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsView), findsOneWidget);
    expect(find.byType(PurchasesView), findsNothing);
  });

  testWidgets('misafir hızlı dokunsa da tek giriş ekranı açar', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        authState: AuthUnauthenticated(),
        currentUserId: null,
        useInheritedChatUnreadCubit: true,
      ),
    );
    await tester.pumpAndSettle();

    final couponsTile = tester.widget<SettingsMenuTile>(
      find.byWidgetPredicate(
        (widget) =>
            widget is SettingsMenuTile &&
            widget.settingsMenuTileModel.title == 'Kuponlarım',
      ),
    );
    couponsTile.settingsMenuTileModel.onTap();
    couponsTile.settingsMenuTileModel.onTap();
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
  });

  for (final destination in const [
    (
      actionKey: Key('help-purchases-action'),
      label: 'Alışverişlerim',
      viewType: PurchasesView,
    ),
    (
      actionKey: Key('help-messages-action'),
      label: 'Mesajlarım',
      viewType: ConversationsView,
    ),
    (
      actionKey: Key('help-saved-locations-action'),
      label: 'Kayıtlı Konumlarım',
      viewType: CustomerSavedLocationsView,
    ),
  ]) {
    testWidgets(
      'misafir Yardım içindeki ${destination.label} seçimini girişten sonra açar',
      (tester) async {
        String? currentUserId;
        await tester.pumpWidget(
          buildSubject(
            authState: AuthUnauthenticated(),
            currentUserId: null,
            currentUserIdProvider: () => currentUserId,
            useInheritedChatUnreadCubit: true,
          ),
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Yardım ve Destek'));
        await tester.tap(find.text('Yardım ve Destek'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(destination.actionKey));
        await tester.tap(find.byKey(destination.actionKey));
        await tester.pumpAndSettle();

        expect(find.byType(LoginView), findsOneWidget);
        expect(find.byType(destination.viewType), findsNothing);

        currentUserId = user.id;
        when(() => authCubit.state).thenReturn(const AuthAuthenticated(user));
        Navigator.of(tester.element(find.byType(LoginView))).pop(true);
        await tester.pumpAndSettle();

        expect(find.byType(destination.viewType), findsOneWidget);
      },
    );
  }

  testWidgets('Yardım kısayolunda girişten vazgeçerse Yardım ekranında kalır', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        authState: AuthUnauthenticated(),
        currentUserId: null,
        useInheritedChatUnreadCubit: true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Yardım ve Destek'));
    await tester.tap(find.text('Yardım ve Destek'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('help-purchases-action')));
    await tester.pumpAndSettle();

    Navigator.of(tester.element(find.byType(LoginView))).pop(false);
    await tester.pumpAndSettle();

    expect(find.byType(HelpAndSupportView), findsOneWidget);
    expect(find.byType(PurchasesView), findsNothing);
  });

  testWidgets('profil açıkken okunmamış mesaj sayısını sessizce yeniler', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        authState: const AuthAuthenticated(user),
        currentUserId: user.id,
        unreadAutoRefreshInterval: const Duration(seconds: 1),
      ),
    );
    await tester.pump();

    verify(() => chatUnreadCubit.loadUnreadCount()).called(1);
    clearInteractions(chatUnreadCubit);

    await tester.pump(const Duration(seconds: 1));

    verify(() => chatUnreadCubit.refreshUnreadCountSilently()).called(1);
  });

  testWidgets('uygulama arka plandayken mesaj sayısını yenilemez', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        authState: const AuthAuthenticated(user),
        currentUserId: user.id,
        unreadAutoRefreshInterval: const Duration(seconds: 1),
      ),
    );
    await tester.pump();
    clearInteractions(chatUnreadCubit);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 2));

    verifyNever(() => chatUnreadCubit.refreshUnreadCountSilently());

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    verify(() => chatUnreadCubit.refreshUnreadCountSilently()).called(1);
  });
}
