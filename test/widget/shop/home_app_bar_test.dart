import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/common/widgets/cart_counter_icon.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:t_store/features/shop/presentation/widgets/home_app_bar.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockNotificationsCubit extends MockCubit<NotificationsState>
    implements NotificationsCubit {}

void main() {
  late MockAuthCubit authCubit;
  late MockNotificationsCubit notificationsCubit;

  setUp(() {
    authCubit = MockAuthCubit();
    notificationsCubit = MockNotificationsCubit();

    whenListen(
      notificationsCubit,
      const Stream<NotificationsState>.empty(),
      initialState: const NotificationsLoaded(
        notifications: [],
        unreadCount: 3,
      ),
    );
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

  testWidgets('giriş yapan müşterinin gerçek adını gösterir', (tester) async {
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

    expect(find.text('Ayşe Yılmaz'), findsOneWidget);
    expect(find.text('Eski Oturum Adı'), findsNothing);
    expect(find.text('Mahmoud Hamdy'), findsNothing);
  });

  testWidgets('oturumdaki adı güvenli yedek olarak gösterir', (tester) async {
    await tester.pumpWidget(
      buildAppBar(authState: AuthInitial(), sessionFullName: 'Mehmet Demir'),
    );

    expect(find.text('Mehmet Demir'), findsOneWidget);
    expect(find.text(TTexts.homeAppbarSubTitle), findsNothing);
  });

  testWidgets('ad bulunmadığında karşılama metnini gösterir', (tester) async {
    await tester.pumpWidget(
      buildAppBar(authState: AuthUnauthenticated(), sessionFullName: ''),
    );

    expect(find.text(TTexts.homeAppbarSubTitle), findsOneWidget);
    expect(find.text('Mahmoud Hamdy'), findsNothing);
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
}
