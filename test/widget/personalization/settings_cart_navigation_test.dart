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
import 'package:t_store/features/chat/presentation/cubit/chat_unread_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_state.dart';
import 'package:t_store/features/personalization/presentation/views/settings_view.dart';
import 'package:t_store/features/shop/presentation/views/cart_v2_view.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockCartV2Cubit extends MockCubit<CartV2State> implements CartV2Cubit {}

class MockChatUnreadCubit extends MockCubit<ChatUnreadState>
    implements ChatUnreadCubit {}

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

  setUp(() async {
    await sl.reset();

    authCubit = MockAuthCubit();
    loginAuthCubit = MockAuthCubit();
    cartV2Cubit = MockCartV2Cubit();
    chatUnreadCubit = MockChatUnreadCubit();

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
    when(() => chatUnreadCubit.close()).thenAnswer((_) async {});

    whenListen(
      loginAuthCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    when(() => loginAuthCubit.close()).thenAnswer((_) async {});

    sl.registerFactory<ChatUnreadCubit>(() => chatUnreadCubit);
    sl.registerFactory<AuthCubit>(() => loginAuthCubit);
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildSubject({
    required AuthState authState,
    required String? currentUserId,
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
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SettingsView(currentUserIdProvider: () => currentUserId),
        ),
      ),
    );
  }

  Future<void> tapCartTile(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Sepetim'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sepetim'));
    await tester.pumpAndSettle();
  }

  testWidgets('Sepetim seçeneği güncel müşteri sepetini açar', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        authState: const AuthAuthenticated(user),
        currentUserId: user.id,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CartV2 Test'), findsNothing);

    await tapCartTile(tester);

    expect(find.byType(CartV2View), findsOneWidget);
    expect(find.text('Mağaza Sepeti'), findsOneWidget);
    verify(() => cartV2Cubit.getActiveCartItems()).called(1);
  });

  testWidgets('oturumu olmayan kullanıcıyı sepetten önce girişe yönlendirir', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(authState: AuthUnauthenticated(), currentUserId: null),
    );
    await tester.pumpAndSettle();

    await tapCartTile(tester);

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(CartV2View), findsNothing);
    verifyNever(() => cartV2Cubit.getActiveCartItems());
  });
}
