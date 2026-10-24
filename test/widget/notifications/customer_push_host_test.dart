import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/domain/push_coordinator.dart';
import 'package:t_store/features/notifications/runtime/customer_push_binding.dart';
import 'package:t_store/features/notifications/presentation/customer_push_host.dart';

class Auth extends MockCubit<AuthState> implements AuthCubit {}

class Service extends Mock implements SupabaseService {}

class Binding extends Mock implements CustomerPushBinding {}

class Coordinator extends Mock implements PushCoordinator {}

class AuthorityRevision extends ValueNotifier<int> {
  AuthorityRevision() : super(0);
  bool get hasAttachedListeners => hasListeners;
}

void main() {
  const id = '11111111-1111-4111-8111-111111111111';
  const notice = NotificationEntity(
    id: 'notice',
    userId: id,
    title: 'Generic',
    body: 'Generic',
    type: NotificationType.chat,
  );
  late Auth auth;
  late Service service;
  late Binding binding;
  late Coordinator coordinator;
  late StreamController<NotificationEntity> opens;
  late AuthorityRevision revision;
  late String session;
  late AuthState state;
  int builds = 0;
  setUp(() {
    auth = Auth();
    service = Service();
    binding = Binding();
    coordinator = Coordinator();
    opens = StreamController.broadcast(sync: true);
    revision = AuthorityRevision();
    session = 'first';
    state = const AuthAuthenticated(
      UserEntity(id: id, email: 'fixture@example.invalid'),
    );
    builds = 0;
    when(() => auth.state).thenAnswer((_) => state);
    when(() => auth.stream).thenAnswer((_) => const Stream.empty());
    when(() => service.currentUser).thenReturn(
      sb.User(
        id: id,
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '',
      ),
    );
    when(() => binding.service).thenReturn(service);
    when(() => binding.coordinator).thenReturn(coordinator);
    when(() => binding.opens).thenAnswer((_) => opens.stream);
    when(() => binding.authority).thenReturn(revision);
    when(() => binding.session).thenAnswer((_) => session);
  });
  tearDown(() async {
    await opens.close();
    revision.dispose();
    await auth.close();
  });
  Future<void> host(WidgetTester tester) async {
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: auth,
        child: CustomerPushHost(
          binding: binding,
          navigatorKey: key,
          destinationBuilder: (_) {
            builds++;
            return const Scaffold(body: Text('Private conversation'));
          },
          child: MaterialApp(
            navigatorKey: key,
            home: const Scaffold(body: Text('Home')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Customer host starts tap observation silently once workspace is ready',
    (tester) async {
      await host(tester);
      verify(() => coordinator.observeOpens()).called(1);
      opens.add(notice);
      await tester.pumpAndSettle();
      expect(find.text('Private conversation'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'same user replacement between tap and first frame blocks private route',
    (tester) async {
      await host(tester);
      opens.add(notice);
      session = 'replacement';
      revision.value++;
      await tester.pumpAndSettle();
      expect(builds, 0);
      expect(find.text('Private conversation'), findsNothing);
      expect(find.textContaining('yeniden giriş'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('visible push route expires after session change', (
    tester,
  ) async {
    await host(tester);
    opens.add(notice);
    await tester.pumpAndSettle();
    expect(find.text('Private conversation'), findsOneWidget);
    session = 'replacement';
    revision.value++;
    await tester.pumpAndSettle();
    expect(find.text('Private conversation'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('unauthenticated Customer cannot start observation or navigate', (
    tester,
  ) async {
    state = AuthUnauthenticated();
    await host(tester);
    opens.add(notice);
    await tester.pumpAndSettle();
    verifyNever(() => coordinator.observeOpens());
    expect(builds, 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'replacing the host binding detaches its previous authority listener',
    (tester) async {
      final oldBinding = binding;
      final oldRevision = revision;
      await host(tester);
      verify(() => coordinator.observeOpens()).called(1);
      final replacement = Binding();
      final nextRevision = AuthorityRevision();
      when(() => replacement.service).thenReturn(service);
      when(() => replacement.coordinator).thenReturn(coordinator);
      when(() => replacement.opens).thenAnswer((_) => opens.stream);
      when(() => replacement.authority).thenReturn(nextRevision);
      when(() => replacement.session).thenReturn('replacement');
      binding = replacement;
      await host(tester);
      verify(() => coordinator.observeOpens()).called(1);
      expect(oldRevision.hasAttachedListeners, false);
      oldRevision.value++;
      await tester.pumpAndSettle();
      verifyNever(() => coordinator.observeOpens());
      nextRevision.value++;
      await tester.pumpAndSettle();
      verify(() => coordinator.observeOpens()).called(1);
      await tester.pumpWidget(const SizedBox());
      expect(nextRevision.hasAttachedListeners, false);
      nextRevision.dispose();
      binding = oldBinding;
    },
  );
}
