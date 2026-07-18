import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/widgets/customer_session_listener.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

class MockCartV2Cubit extends Mock implements CartV2Cubit {}

class MockWishlistCubit extends Mock implements WishlistCubit {}

class MockNavigationMenuCubit extends Mock implements NavigationMenuCubit {}

void main() {
  late MockAuthCubit authCubit;
  late MockCartV2Cubit cartCubit;
  late MockWishlistCubit wishlistCubit;
  late MockNavigationMenuCubit navigationCubit;
  late StreamController<supabase.AuthState> authStateController;
  late GlobalKey<NavigatorState> navigatorKey;
  late GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const authenticatedUser = UserEntity(
    id: 'customer-1',
    email: 'customer@example.com',
  );

  setUp(() {
    authCubit = MockAuthCubit();
    cartCubit = MockCartV2Cubit();
    wishlistCubit = MockWishlistCubit();
    navigationCubit = MockNavigationMenuCubit();
    authStateController = StreamController<supabase.AuthState>.broadcast(
      sync: true,
    );
    navigatorKey = GlobalKey<NavigatorState>();
    scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

    when(() => authCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => cartCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => wishlistCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => navigationCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => cartCubit.clearLocalCart()).thenReturn(null);
    when(() => wishlistCubit.clearLocalWishlist()).thenReturn(null);
    when(() => cartCubit.getActiveCartItems()).thenAnswer((_) async {});
    when(() => wishlistCubit.getWishlist()).thenAnswer((_) async {});
    when(() => navigationCubit.changeIndex(0)).thenReturn(null);
  });

  tearDown(() async {
    await authStateController.close();
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    required bool initiallyAuthenticated,
    String? initialUserId,
  }) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<CartV2Cubit>.value(value: cartCubit),
          BlocProvider<WishlistCubit>.value(value: wishlistCubit),
          BlocProvider<NavigationMenuCubit>.value(value: navigationCubit),
        ],
        child: CustomerSessionListener(
          authStateChanges: authStateController.stream,
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: scaffoldMessengerKey,
          initiallyAuthenticated: initiallyAuthenticated,
          initialUserId: initialUserId,
          signedOutDestinationBuilder: (_) =>
              const Scaffold(body: Center(child: Text('Ana sayfa'))),
          child: MaterialApp(
            navigatorKey: navigatorKey,
            scaffoldMessengerKey: scaffoldMessengerKey,
            home: const Scaffold(
              body: Center(child: Text('Korumalı müşteri ekranı')),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'automatic session expiry clears customer data and returns home',
    (tester) async {
      when(
        () => authCubit.state,
      ).thenReturn(const AuthAuthenticated(authenticatedUser));
      when(() => authCubit.handleSignedOutEvent()).thenReturn(false);
      await pumpApp(
        tester,
        initiallyAuthenticated: true,
        initialUserId: authenticatedUser.id,
      );

      authStateController.add(
        const supabase.AuthState(supabase.AuthChangeEvent.signedOut, null),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Ana sayfa'), findsOneWidget);
      expect(find.text('Korumalı müşteri ekranı'), findsNothing);
      expect(
        find.text(
          'Oturumunuz sona erdi. Devam etmek için yeniden giriş yapın.',
        ),
        findsOneWidget,
      );
      verify(() => authCubit.handleSignedOutEvent()).called(1);
      verify(() => cartCubit.clearLocalCart()).called(1);
      verify(() => wishlistCubit.clearLocalWishlist()).called(1);
      verify(() => navigationCubit.changeIndex(0)).called(1);
    },
  );

  testWidgets('user initiated sign out does not show expiry warning', (
    tester,
  ) async {
    when(
      () => authCubit.state,
    ).thenReturn(const AuthAuthenticated(authenticatedUser));
    when(() => authCubit.handleSignedOutEvent()).thenReturn(true);
    await pumpApp(
      tester,
      initiallyAuthenticated: true,
      initialUserId: authenticatedUser.id,
    );

    authStateController.add(
      const supabase.AuthState(supabase.AuthChangeEvent.signedOut, null),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Korumalı müşteri ekranı'), findsOneWidget);
    expect(find.text('Ana sayfa'), findsNothing);
    expect(
      find.text('Oturumunuz sona erdi. Devam etmek için yeniden giriş yapın.'),
      findsNothing,
    );
    verify(() => cartCubit.clearLocalCart()).called(1);
    verify(() => wishlistCubit.clearLocalWishlist()).called(1);
    verify(() => navigationCubit.changeIndex(0)).called(1);
  });

  testWidgets('switching customer account clears previous local data', (
    tester,
  ) async {
    await pumpApp(
      tester,
      initiallyAuthenticated: true,
      initialUserId: authenticatedUser.id,
    );

    authStateController.add(
      supabase.AuthState(
        supabase.AuthChangeEvent.signedIn,
        _sessionFor('customer-2'),
      ),
    );
    await tester.pump();

    verify(() => cartCubit.clearLocalCart()).called(1);
    verify(() => wishlistCubit.clearLocalWishlist()).called(1);
    verify(() => cartCubit.getActiveCartItems()).called(1);
    verify(() => wishlistCubit.getWishlist()).called(1);
    verify(() => navigationCubit.changeIndex(0)).called(1);
    verifyNever(() => authCubit.handleSignedOutEvent());
  });

  testWidgets('refreshing the same customer session keeps local data', (
    tester,
  ) async {
    await pumpApp(
      tester,
      initiallyAuthenticated: true,
      initialUserId: authenticatedUser.id,
    );

    authStateController.add(
      supabase.AuthState(
        supabase.AuthChangeEvent.tokenRefreshed,
        _sessionFor(authenticatedUser.id),
      ),
    );
    await tester.pump();

    verifyNever(() => cartCubit.clearLocalCart());
    verifyNever(() => wishlistCubit.clearLocalWishlist());
    verifyNever(() => navigationCubit.changeIndex(0));
  });

  testWidgets('signed out event for a guest stays silent', (tester) async {
    when(() => authCubit.state).thenReturn(AuthInitial());
    when(() => authCubit.handleSignedOutEvent()).thenReturn(false);
    await pumpApp(tester, initiallyAuthenticated: false);

    authStateController.add(
      const supabase.AuthState(supabase.AuthChangeEvent.signedOut, null),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Korumalı müşteri ekranı'), findsOneWidget);
    expect(find.text('Ana sayfa'), findsNothing);
    expect(
      find.text('Oturumunuz sona erdi. Devam etmek için yeniden giriş yapın.'),
      findsNothing,
    );
    verify(() => cartCubit.clearLocalCart()).called(1);
    verify(() => wishlistCubit.clearLocalWishlist()).called(1);
    verify(() => navigationCubit.changeIndex(0)).called(1);
  });
}

supabase.Session _sessionFor(String userId) {
  return supabase.Session(
    accessToken: 'test-access-token',
    tokenType: 'bearer',
    user: supabase.User(
      id: userId,
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00.000Z',
    ),
  );
}
