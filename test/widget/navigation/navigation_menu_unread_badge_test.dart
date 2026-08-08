import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/common/widgets/navigation_menu.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_state.dart';

class MockNavigationMenuCubit extends MockCubit<NavigationMenuState>
    implements NavigationMenuCubit {}

class MockCartV2Cubit extends MockCubit<CartV2State> implements CartV2Cubit {}

class MockChatUnreadCubit extends MockCubit<ChatUnreadState>
    implements ChatUnreadCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockNavigationMenuCubit navigationCubit;
  late MockCartV2Cubit cartCubit;
  late MockChatUnreadCubit chatUnreadCubit;
  late MockAuthCubit authCubit;

  setUp(() async {
    await sl.reset();
    navigationCubit = MockNavigationMenuCubit();
    cartCubit = MockCartV2Cubit();
    chatUnreadCubit = MockChatUnreadCubit();
    authCubit = MockAuthCubit();

    whenListen(
      navigationCubit,
      const Stream<NavigationMenuState>.empty(),
      initialState: NavigationMenuInitial(),
    );
    when(() => navigationCubit.selectedIndex).thenReturn(0);
    when(
      () => navigationCubit.getScreen(),
    ).thenReturn(const SizedBox(key: Key('navigation-body')));

    whenListen(
      cartCubit,
      const Stream<CartV2State>.empty(),
      initialState: const CartV2Loaded([]),
    );

    whenListen(
      chatUnreadCubit,
      const Stream<ChatUnreadState>.empty(),
      initialState: const ChatUnreadLoaded(4),
    );
    when(
      () => chatUnreadCubit.refreshUnreadCountSilently(),
    ).thenAnswer((_) async {});
    when(() => chatUnreadCubit.resetUnreadCount()).thenAnswer((_) {});

    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    sl.registerFactory<AuthCubit>(() => authCubit);
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildSubject({
    Duration refreshInterval = const Duration(seconds: 15),
    String? currentUserId = 'customer-1',
    NavigationCurrentUserIdProvider? currentUserIdProvider,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationMenuCubit>.value(value: navigationCubit),
        BlocProvider<CartV2Cubit>.value(value: cartCubit),
      ],
      child: MaterialApp(
        home: NavigationMenu(
          chatUnreadCubit: chatUnreadCubit,
          unreadAutoRefreshInterval: refreshInterval,
          currentUserIdProvider: currentUserIdProvider ?? () => currentUserId,
        ),
      ),
    );
  }

  testWidgets('okunmamış mesaj sayısını alt Profil hedefinde gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byKey(const Key('customer-nav-profile-badge')), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('misafir kullanıcıda mesaj rozetini ve yenilemeyi kapatır', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        currentUserId: null,
        refreshInterval: const Duration(seconds: 1),
      ),
    );
    await tester.pump();
    clearInteractions(chatUnreadCubit);

    expect(find.byKey(const Key('customer-nav-profile-badge')), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    verifyNever(() => chatUnreadCubit.refreshUnreadCountSilently());
    verify(() => chatUnreadCubit.resetUnreadCount()).called(1);
  });

  testWidgets('ekran açıkken okunmamış mesaj sayısını sessizce yeniler', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(refreshInterval: const Duration(seconds: 1)),
    );
    await tester.pump();
    clearInteractions(chatUnreadCubit);

    await tester.pump(const Duration(seconds: 1));

    verify(() => chatUnreadCubit.refreshUnreadCountSilently()).called(1);
  });

  testWidgets('uygulama arka plandayken alt menü sayacını yenilemez', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(refreshInterval: const Duration(seconds: 1)),
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

  for (final destination in const [
    (key: Key('customer-nav-cart'), index: 2, label: 'Sepet'),
    (key: Key('customer-nav-wishlist'), index: 3, label: 'Favoriler'),
    (key: Key('customer-nav-profile'), index: 4, label: 'Profil'),
  ]) {
    testWidgets('misafir ${destination.label} hedefini girişten sonra açar', (
      tester,
    ) async {
      String? currentUserId;
      await tester.pumpWidget(
        buildSubject(currentUserIdProvider: () => currentUserId),
      );

      await tester.tap(find.byKey(destination.key));
      await tester.pumpAndSettle();

      final loginView = tester.widget<LoginView>(find.byType(LoginView));
      expect(loginView.returnToCallerAfterCustomerLogin, isTrue);
      verifyNever(() => navigationCubit.changeIndex(destination.index));

      currentUserId = 'customer-1';
      Navigator.of(tester.element(find.byType(LoginView))).pop(true);
      await tester.pumpAndSettle();

      verify(() => navigationCubit.changeIndex(destination.index)).called(1);
    });
  }

  testWidgets('misafir girişten vazgeçerse mevcut hedefte kalır', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(currentUserId: null));

    await tester.tap(find.byKey(const Key('customer-nav-wishlist')));
    await tester.pumpAndSettle();

    Navigator.of(tester.element(find.byType(LoginView))).pop(false);
    await tester.pumpAndSettle();

    verifyNever(() => navigationCubit.changeIndex(any()));
  });
}
