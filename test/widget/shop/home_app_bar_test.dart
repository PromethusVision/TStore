import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/common/widgets/cart_counter_icon.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:t_store/features/notifications/presentation/views/customer_notifications_view.dart';
import 'package:t_store/features/shop/presentation/widgets/home_app_bar.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockNotificationsCubit extends MockCubit<NotificationsState>
    implements NotificationsCubit {}

void main() {
  late MockAuthCubit authCubit;
  late MockAuthCubit loginAuthCubit;
  late MockNotificationsCubit notificationsCubit;
  late MockNotificationsCubit destinationNotificationsCubit;

  setUp(() async {
    await sl.reset();
    authCubit = MockAuthCubit();
    loginAuthCubit = MockAuthCubit();
    notificationsCubit = MockNotificationsCubit();
    destinationNotificationsCubit = MockNotificationsCubit();

    whenListen(
      notificationsCubit,
      const Stream<NotificationsState>.empty(),
      initialState: const NotificationsLoaded(
        notifications: [],
        unreadCount: 3,
      ),
    );
    whenListen(
      loginAuthCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    whenListen(
      destinationNotificationsCubit,
      const Stream<NotificationsState>.empty(),
      initialState: const NotificationsLoaded(notifications: []),
    );
    when(
      () => destinationNotificationsCubit.getNotifications(
        refresh: any(named: 'refresh'),
      ),
    ).thenAnswer((_) async {});

    sl.registerFactory<AuthCubit>(() => loginAuthCubit);
    sl.registerFactory<NotificationsCubit>(() => destinationNotificationsCubit);
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildAppBar({required AuthState authState, String? sessionFullName}) {
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: authState,
    );

    return BlocProvider<AuthCubit>.value(
      value: authCubit,
      child: MaterialApp(
        home: Scaffold(
          body: HomeAppBar(
            sessionFullName: sessionFullName,
            notificationsCubit: notificationsCubit,
          ),
        ),
      ),
    );
  }

  testWidgets('wordmark ve gerçek kullanıcı karşılama bilgisini gösterir', (
    tester,
  ) async {
    const user = UserEntity(
      id: 'customer-1',
      email: 'ayse@example.com',
      fullName: 'Ayşe Yılmaz',
    );

    await tester.pumpWidget(
      buildAppBar(
        authState: const AuthAuthenticated(user),
        sessionFullName: 'Eski Oturum Adı',
      ),
    );

    expect(find.byKey(const Key('home-wordmark')), findsOneWidget);
    expect(find.text('Merhaba, Ayşe'), findsOneWidget);
    expect(find.text('Ayşe Yılmaz'), findsNothing);
    expect(find.text('Eski Oturum Adı'), findsNothing);
  });

  testWidgets('oturumdaki gerçek adı erişilebilir başlıkta korur', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      buildAppBar(authState: AuthInitial(), sessionFullName: 'Mehmet Demir'),
    );

    expect(find.bySemanticsLabel(RegExp('Mehmet Demir')), findsOneWidget);
    expect(find.text('Merhaba, Mehmet'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('ad bulunmadığında erişilebilir karşılama bilgisini korur', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      buildAppBar(authState: AuthUnauthenticated(), sessionFullName: ''),
    );

    expect(
      find.bySemanticsLabel(RegExp(TTexts.homeAppbarSubTitle)),
      findsOneWidget,
    );
    expect(find.text('Mahallendeki esnafı keşfet'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('bildirim rozetini gösterir ve üst sepet ikonunu kaldırır', (
    tester,
  ) async {
    const user = UserEntity(
      id: 'customer-1',
      email: 'ayse@example.com',
      fullName: 'Ayşe Yılmaz',
    );

    await tester.pumpWidget(
      buildAppBar(authState: const AuthAuthenticated(user)),
    );

    expect(find.byKey(const Key('home-notifications-button')), findsOneWidget);
    expect(find.byKey(const Key('home-notifications-badge')), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.byType(CartCounterIcon), findsNothing);
  });

  testWidgets('giris yapmis kullanici bildirimleri dogrudan acar', (
    tester,
  ) async {
    const user = UserEntity(
      id: 'customer-1',
      email: 'ayse@example.com',
      fullName: 'Ayse Yilmaz',
    );

    await tester.pumpWidget(
      buildAppBar(authState: const AuthAuthenticated(user)),
    );

    await tester.tap(find.byKey(const Key('home-notifications-button')));
    await tester.pumpAndSettle();

    expect(find.byType(CustomerNotificationsView), findsOneWidget);
    verify(
      () => destinationNotificationsCubit.getNotifications(refresh: true),
    ).called(1);
  });

  testWidgets('misafir giristen sonra bildirimlere devam eder', (tester) async {
    await tester.pumpWidget(buildAppBar(authState: AuthUnauthenticated()));

    await tester.tap(find.byKey(const Key('home-notifications-button')));
    await tester.pumpAndSettle();

    final loginView = tester.widget<LoginView>(find.byType(LoginView));
    expect(loginView.returnToCallerAfterCustomerLogin, isTrue);
    expect(find.byType(CustomerNotificationsView), findsNothing);

    Navigator.of(tester.element(find.byType(LoginView))).pop(true);
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsNothing);
    expect(find.byType(CustomerNotificationsView), findsOneWidget);
  });

  testWidgets('misafir giristen vazgecerse ana sayfada kalir', (tester) async {
    await tester.pumpWidget(buildAppBar(authState: AuthUnauthenticated()));

    await tester.tap(find.byKey(const Key('home-notifications-button')));
    await tester.pumpAndSettle();

    Navigator.of(tester.element(find.byType(LoginView))).pop(false);
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsNothing);
    expect(find.byType(CustomerNotificationsView), findsNothing);
    expect(find.byKey(const Key('home-notifications-button')), findsOneWidget);
  });

  testWidgets('hizli iki dokunmada tek giris ekrani acar', (tester) async {
    await tester.pumpWidget(buildAppBar(authState: AuthUnauthenticated()));

    final notificationButton = find.byKey(
      const Key('home-notifications-button'),
    );
    final notificationInkWell = tester.widget<InkWell>(notificationButton);
    notificationInkWell.onTap!();
    notificationInkWell.onTap!();
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);

    Navigator.of(tester.element(find.byType(LoginView))).pop(false);
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsNothing);
    expect(find.byType(CustomerNotificationsView), findsNothing);
  });
}
