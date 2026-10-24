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
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/domain/push_coordinator.dart';
import 'package:t_store/features/notifications/presentation/customer_push_host.dart';
import 'package:t_store/features/notifications/runtime/customer_push_binding.dart';
import '../../support/push_client_fakes.dart';

class Auth extends MockCubit<AuthState> implements AuthCubit {}

class Service extends Mock implements SupabaseService {}

class Binding extends Mock implements CustomerPushBinding {}

class AuthorityRevision extends ValueNotifier<int> {
  AuthorityRevision() : super(0);
  bool get hasAttachedListeners => hasListeners;
}

class Provider extends FakePushProvider {
  int observations = 0;
  @override
  Stream<PushOpenEvent> get opened {
    observations++;
    return super.opened;
  }
}

// Retains the Integration Agent's reproduction: real coordinator/provider
// stream, same profile, changed authority, no manual observeOpens in the action.
void main() {
  const user = '11111111-1111-4111-8111-111111111111';
  const identity = PushIdentity(user, NotificationAppRole.customer);
  const profile = AuthAuthenticated(
    UserEntity(id: user, email: 'fixture@example.invalid'),
  );
  late Auth auth;
  late Binding binding;
  late Service service;
  late Provider provider;
  late FakePushRegistry registry;
  late PushCoordinator coordinator;
  late StreamController<NotificationEntity> opens;
  late StreamController<AuthState> authEvents;
  late AuthorityRevision revision;
  late String? session;
  late AuthState state;
  late List<String> lookups;
  late List<String> accepted;
  Completer<NotificationEntity?>? oldLookup;

  NotificationEntity notification(String id) => NotificationEntity(
    id: id,
    userId: user,
    title: 'Generic',
    body: 'Generic',
    type: NotificationType.chat,
  );
  void tap(String id) =>
      provider.taps.add(PushOpenEvent(notificationId: id, identity: identity));
  void replaceSession(String? next) {
    session = next;
    coordinator.invalidate();
    revision.value++;
  }

  setUp(() {
    session = 'first-session';
    state = profile;
    oldLookup = null;
    lookups = [];
    accepted = [];
    auth = Auth();
    binding = Binding();
    service = Service();
    provider = Provider();
    registry = FakePushRegistry();
    opens = StreamController.broadcast(sync: true);
    authEvents = StreamController.broadcast(sync: true);
    revision = AuthorityRevision();
    coordinator = PushCoordinator(
      provider: provider,
      registry: registry,
      currentIdentity: () => identity,
      currentSessionKey: () => session,
      lookup: (id) async {
        lookups.add(id);
        if (id == 'old' && oldLookup != null) return oldLookup!.future;
        return notification(id);
      },
      onOpen: (notice) {
        accepted.add(notice.id);
        opens.add(notice);
      },
      installationId: 'fixture',
      platform: PushPlatform.android,
    );
    when(() => auth.state).thenAnswer((_) => state);
    when(() => auth.stream).thenAnswer((_) => authEvents.stream);
    when(() => service.currentUser).thenReturn(
      sb.User(
        id: user,
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
    coordinator.dispose();
    await provider.close();
    await opens.close();
    await authEvents.close();
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
          destinationBuilder: (notice) =>
              Scaffold(body: Text('Conversation ${notice.id}')),
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
    'same-user replacement resumes valid taps without an AuthCubit event or UI interaction',
    (tester) async {
      await host(tester);
      expect(tester.binding.hasScheduledFrame, false);
      replaceSession('replacement-session');
      expect(
        tester.binding.hasScheduledFrame,
        true,
        reason: 'Idle home must schedule its own rebind frame.',
      );
      await tester.pumpAndSettle();
      tap('fresh');
      await tester.pumpAndSettle();
      expect(lookups, ['fresh']);
      expect(accepted, ['fresh']);
      expect(find.text('Conversation fresh'), findsOneWidget);
      expect(provider.permissions, 0);
      expect(provider.fetched, 0);
      expect(registry.registrations, isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'late old-session lookup stays fenced while a new-session tap opens',
    (tester) async {
      oldLookup = Completer<NotificationEntity?>();
      await host(tester);
      tap('old');
      await tester.pump();
      expect(lookups, ['old']);
      replaceSession('replacement-session');
      await tester.pumpAndSettle();
      tap('fresh');
      await tester.pumpAndSettle();
      oldLookup!.complete(notification('old'));
      await tester.pumpAndSettle();
      expect(lookups, ['old', 'fresh']);
      expect(accepted, ['fresh']);
      expect(find.text('Conversation old'), findsNothing);
      expect(find.text('Conversation fresh'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'replacement does not bypass cleanupRequired or reenroll a registered device',
    (tester) async {
      await host(tester);
      expect(await coordinator.enable(), PushRegistrationResult.registered);
      final observations = provider.observations;
      replaceSession('replacement-session');
      await tester.pumpAndSettle();
      tap('fresh');
      await tester.pumpAndSettle();
      expect(coordinator.status, PushClientStatus.cleanupRequired);
      expect(lookups, isEmpty);
      expect(accepted, isEmpty);
      expect(provider.observations, observations);
      expect(provider.permissions, 1);
      expect(provider.fetched, 1);
      expect(registry.registrations, hasLength(1));
      expect(provider.deleted, 0);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('logout before queued rebind cannot restore tap observation', (
    tester,
  ) async {
    await host(tester);
    replaceSession('replacement-session');
    replaceSession(null);
    state = AuthUnauthenticated();
    authEvents.add(state);
    await tester.pumpAndSettle();
    tap('after-logout');
    await tester.pumpAndSettle();
    expect(provider.observations, 1);
    expect(lookups, isEmpty);
    expect(accepted, isEmpty);
    expect(provider.permissions, 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'same-session profile refresh keeps one observer and valid in-flight lookup',
    (tester) async {
      oldLookup = Completer<NotificationEntity?>();
      await host(tester);
      tap('old');
      await tester.pump();
      // Normal token renewal leaves stable session/authority unchanged. Even a
      // redundant profile emission must not invalidate the pending authorized read.
      authEvents.add(profile);
      await tester.pumpAndSettle();
      oldLookup!.complete(notification('old'));
      await tester.pumpAndSettle();
      expect(provider.observations, 1);
      expect(lookups, ['old']);
      expect(accepted, ['old']);
      expect(find.text('Conversation old'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'disposed host removes authority listener and cancels scheduled rebind',
    (tester) async {
      await host(tester);
      replaceSession('replacement-session');
      await tester.pumpWidget(const SizedBox());
      expect(revision.hasAttachedListeners, false);
      revision.value++;
      await tester.pumpAndSettle();
      expect(provider.observations, 1);
      expect(accepted, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
}
