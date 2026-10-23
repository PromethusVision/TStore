import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/features/notifications/data/repositories/push_installation_store.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/domain/push_coordinator.dart';
import 'package:t_store/features/notifications/domain/push_installation.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import '../../support/push_client_fakes.dart';

const owner = PushIdentity('synthetic-owner', NotificationAppRole.merchant);
const event = PushOpenEvent(notificationId: 'notice-1', identity: owner);
const notice = NotificationEntity(
  id: 'notice-1',
  userId: 'synthetic-owner',
  title: 'Fixture',
  body: 'Fixture',
  type: NotificationType.system,
  data: {'app_role': 'merchant'},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakePushProvider provider;
  late FakePushRegistry registry;
  late FakePushInstallationStore store;
  late PushCoordinator coordinator;
  late String? session;
  late PushIdentity? identity;
  late Future<NotificationEntity?> Function(String) lookup;
  late List<NotificationEntity> opened;
  PushCoordinator create() => PushCoordinator(
    provider: provider,
    registry: registry,
    currentIdentity: () => identity,
    currentSessionKey: () => session,
    lookup: (id) => lookup(id),
    onOpen: opened.add,
    installationId: 'not-loaded',
    installations: store,
    platform: PushPlatform.android,
    lookupTimeout: const Duration(milliseconds: 10),
  );
  Future<void> flush() => pumpEventQueue(times: 10);
  setUp(() {
    provider = FakePushProvider();
    registry = FakePushRegistry();
    store = FakePushInstallationStore();
    session = 'session-1';
    identity = owner;
    opened = [];
    lookup = (_) async => notice;
    coordinator = create();
  });
  tearDown(() async {
    coordinator.dispose();
    await provider.close();
  });

  test(
    'default off has no permission, token, local storage or network effect',
    () async {
      provider.configured = false;
      expect(
        await coordinator.enable(),
        PushRegistrationResult.pendingConfiguration,
      );
      expect(
        [provider.permissions, provider.fetched, provider.deleted, store.reads],
        [0, 0, 0, 0],
      );
      expect(registry.registrations, isEmpty);
    },
  );
  test(
    'authenticated cold-start tap does not enroll or request permission',
    () async {
      coordinator.observeOpens();
      coordinator.observeOpens();
      provider.taps.add(event);
      await flush();
      expect(opened, [notice]);
      expect([provider.permissions, provider.fetched, store.reads], [0, 0, 0]);
      expect(registry.registrations, isEmpty);
    },
  );
  test(
    'cold-start lookup cannot cross a same-user replacement login',
    () async {
      final pending = Completer<NotificationEntity?>();
      lookup = (_) => pending.future;
      coordinator.observeOpens();
      provider.taps.add(event);
      session = 'replacement';
      coordinator.invalidate();
      pending.complete(notice);
      await flush();
      expect(opened, isEmpty);
      lookup = (_) async => notice;
      coordinator.observeOpens();
      provider.taps.add(event);
      await flush();
      expect(opened, [notice]);
    },
  );
  test(
    'synchronous status observer can request logout without overlapping SDK work',
    () async {
      final permission = Completer<PushPermission>();
      provider.permission = () => permission.future;
      Future<void>? exit;
      coordinator.addListener(() {
        if (coordinator.status == PushClientStatus.enabling && exit == null) {
          exit = coordinator.disable();
        }
      });
      final enrollment = coordinator.enable();
      await flush();
      permission.complete(PushPermission.granted);
      await enrollment;
      await exit;
      expect(registry.registrations, isEmpty);
      expect(provider.fetched, 0);
      expect(coordinator.busy, isFalse);
    },
  );
  test(
    'account replacement during permission resolves to a retryable status',
    () async {
      final permission = Completer<PushPermission>();
      provider.permission = () => permission.future;
      final enrollment = coordinator.enable();
      await flush();
      session = 'replacement';
      permission.complete(PushPermission.granted);
      expect(await enrollment, PushRegistrationResult.denied);
      expect(coordinator.status, PushClientStatus.denied);
      expect(registry.registrations, isEmpty);
    },
  );
  test(
    'cleanup marker remains when local acknowledgement fails after token deletion',
    () async {
      await coordinator.enable();
      store.failSave = true;
      await expectLater(coordinator.disable(), throwsStateError);
      expect(provider.deleted, 1);
      expect(store.value.cleanupRequired, isTrue);
      expect(await coordinator.enable(), PushRegistrationResult.failed);
      store.failSave = false;
      await coordinator.disable();
      expect(store.value.cleanupRequired, isFalse);
    },
  );
  test('installation failure prevents even opening OS permission', () async {
    store.failRead = true;
    expect(await coordinator.enable(), PushRegistrationResult.failed);
    expect(provider.permissions, 0);
    expect(coordinator.status, PushClientStatus.cleanupRequired);
  });
  test(
    'dispose before enrollment starts performs no SDK or persistence operations',
    () async {
      final enrollment = coordinator.enable();
      coordinator.dispose();
      expect(await enrollment, PushRegistrationResult.denied);
      expect(store.reads, 0);
      expect(provider.permissions, 0);
      coordinator = create();
    },
  );
  test(
    'notification burst has a bounded number of authoritative lookups',
    () async {
      final pending = Completer<NotificationEntity?>();
      var reads = 0;
      lookup = (_) {
        reads++;
        return pending.future;
      };
      final opens = [
        for (var i = 0; i < 40; i++)
          coordinator.open(
            PushOpenEvent(notificationId: 'burst-$i', identity: owner),
          ),
      ];
      expect(reads, 16);
      pending.complete(null);
      await Future.wait(opens);
      expect(opened, isEmpty);
    },
  );
  test(
    'durable marker failure prevents token acquisition and registration',
    () async {
      store.failSave = true;
      expect(await coordinator.enable(), PushRegistrationResult.failed);
      expect(provider.fetched, 0);
      expect(registry.registrations, isEmpty);
    },
  );
  test('denied permission leaves no uncertain binding', () async {
    provider.permission = () async => PushPermission.denied;
    expect(await coordinator.enable(), PushRegistrationResult.denied);
    expect(store.value.cleanupRequired, isFalse);
    expect(provider.fetched, 0);
  });
  test(
    'duplicate enrollment and reentrant observer cannot request twice',
    () async {
      final permission = Completer<PushPermission>();
      provider.permission = () => permission.future;
      final rejected = <Future<PushRegistrationResult>>[];
      coordinator.addListener(() {
        if (coordinator.status == PushClientStatus.enabling) {
          rejected.add(coordinator.enable());
        }
      });
      final first = coordinator.enable();
      await flush();
      expect(await coordinator.enable(), PushRegistrationResult.failed);
      permission.complete(PushPermission.granted);
      expect(await first, PushRegistrationResult.registered);
      expect(
        await Future.wait(rejected),
        everyElement(PushRegistrationResult.failed),
      );
      expect(provider.permissions, 1);
    },
  );
  test(
    'logout during permission waits and never fetches a late token',
    () async {
      final permission = Completer<PushPermission>();
      provider.permission = () => permission.future;
      final enrollment = coordinator.enable();
      await flush();
      var complete = false;
      final revoke = coordinator.disable().then((_) => complete = true);
      await flush();
      expect(complete, isFalse);
      expect(await coordinator.enable(), PushRegistrationResult.failed);
      permission.complete(PushPermission.granted);
      expect(await enrollment, PushRegistrationResult.denied);
      await revoke;
      expect(provider.fetched, 0);
      expect(registry.registrations, isEmpty);
    },
  );
  test('logout during token acquisition waits before deleting token', () async {
    final token = Completer<String?>();
    provider.token = () => token.future;
    final enrollment = coordinator.enable();
    await flush();
    final revoke = coordinator.disable();
    await flush();
    expect(provider.deleted, 0);
    token.complete('late-token');
    await enrollment;
    await revoke;
    expect(registry.registrations, isEmpty);
    expect(provider.deleted, 1);
    expect(store.value.cleanupRequired, isFalse);
  });
  test(
    'rotation during token fetch supersedes the fetched stale value',
    () async {
      final token = Completer<String?>();
      provider.token = () => token.future;
      final enrollment = coordinator.enable();
      await flush();
      provider.tokens.add('newest-token');
      token.complete('stale-token');
      await enrollment;
      expect(registry.registrations.map((r) => r.token), ['newest-token']);
    },
  );
  test(
    'rotation during first registration is drained before success',
    () async {
      final first = Completer<void>();
      registry.registering = (r) async {
        if (r.token == 'synthetic-token-1') await first.future;
      };
      final enrollment = coordinator.enable();
      await flush();
      provider.tokens.add('during-first');
      first.complete();
      await enrollment;
      expect(registry.registrations.map((r) => r.token), [
        'synthetic-token-1',
        'during-first',
      ]);
    },
  );
  test(
    'rotation writes are serialized; cleanup waits and rejects new enrollment',
    () async {
      await coordinator.enable();
      final slow = Completer<void>();
      registry.registering = (_) => slow.future;
      provider.tokens.add('rotation-1');
      await flush();
      provider.tokens.add('rotation-2');
      final revoke = coordinator.disable();
      await flush();
      expect(registry.disabled, isEmpty);
      expect(await coordinator.enable(), PushRegistrationResult.failed);
      slow.complete();
      await revoke;
      expect(registry.registrations.map((r) => r.token), [
        'synthetic-token-1',
        'rotation-1',
      ]);
      expect(registry.disabled, hasLength(1));
      expect(provider.deleted, 1);
    },
  );
  test(
    'failed rotation freezes later writes and requires explicit cleanup',
    () async {
      await coordinator.enable();
      registry.registering = (_) async =>
          throw StateError('synthetic-private-error');
      provider.tokens.add('rotation-1');
      provider.tokens.add('rotation-2');
      await flush();
      expect(coordinator.status, PushClientStatus.cleanupRequired);
      expect(registry.registrations, hasLength(2));
      expect(await coordinator.enable(), PushRegistrationResult.failed);
      registry.registering = null;
      await coordinator.disable();
      expect(await coordinator.enable(), PushRegistrationResult.registered);
    },
  );
  test(
    'token stream failure is visible and prevents stale event navigation',
    () async {
      await coordinator.enable();
      provider.tokens.addError(StateError('fixture'));
      provider.taps.add(event);
      await flush();
      expect(coordinator.status, PushClientStatus.cleanupRequired);
      expect(opened, isEmpty);
    },
  );
  test('same user new Auth session rejects old rotation and tap', () async {
    await coordinator.enable();
    session = 'session-2';
    provider.tokens.add('wrong-session');
    provider.taps.add(event);
    await flush();
    expect(registry.registrations, hasLength(1));
    expect(opened, isEmpty);
    await coordinator.disable();
    expect(registry.disabled, isEmpty);
    expect(provider.deleted, 1);
    expect(store.value.id, 'install-2');
  });
  test(
    'lost registration acknowledgement keeps cleanup marker across restart',
    () async {
      registry.registering = (_) async => throw StateError('response-lost');
      expect(await coordinator.enable(), PushRegistrationResult.failed);
      expect(store.value.cleanupRequired, isTrue);
      coordinator.dispose();
      coordinator = create();
      registry.registering = null;
      expect(await coordinator.enable(), PushRegistrationResult.registered);
      expect(provider.deleted, 1);
      expect(registry.disabled, isEmpty);
      expect(registry.registrations.map((r) => r.installationId), [
        'install-1',
        'install-2',
      ]);
    },
  );
  test(
    'restart recovery failure never registers or clears dirty record',
    () async {
      store.value = const PushInstallation(
        'old-install',
        cleanupRequired: true,
      );
      provider.deletion = () async => throw StateError('delete-uncertain');
      expect(await coordinator.enable(), PushRegistrationResult.failed);
      expect(store.value.id, 'old-install');
      expect(store.value.cleanupRequired, isTrue);
      expect(provider.permissions, 0);
      expect(registry.registrations, isEmpty);
    },
  );
  test(
    'failed server revocation blocks token reuse until same-session retry succeeds',
    () async {
      await coordinator.enable();
      registry.disabling = () async => throw StateError('offline');
      await expectLater(coordinator.disable(), throwsStateError);
      expect(provider.deleted, 0);
      expect(store.value.cleanupRequired, isTrue);
      expect(await coordinator.enable(), PushRegistrationResult.failed);
      registry.disabling = null;
      await coordinator.disable();
      expect(provider.deleted, 1);
      expect(store.value.cleanupRequired, isFalse);
    },
  );
  test(
    'failed provider deletion after server disable remains retryable',
    () async {
      await coordinator.enable();
      provider.deletion = () async => throw StateError('offline');
      await expectLater(coordinator.disable(), throwsStateError);
      expect(store.value.cleanupRequired, isTrue);
      provider.deletion = null;
      await coordinator.disable();
      expect(store.value.cleanupRequired, isFalse);
    },
  );
  test('duplicate disable uses one revoke and one delete', () async {
    await coordinator.enable();
    final slow = Completer<void>();
    registry.disabling = () => slow.future;
    final a = coordinator.disable();
    final b = coordinator.disable();
    await flush();
    slow.complete();
    await Future.wait([a, b]);
    expect(registry.disabled, hasLength(1));
    expect(provider.deleted, 1);
  });
  test(
    'dispose during registration leaves durable marker and does not delete underneath it',
    () async {
      final slow = Completer<void>();
      registry.registering = (_) => slow.future;
      final enrollment = coordinator.enable();
      await flush();
      coordinator.dispose();
      slow.complete();
      await enrollment;
      expect(provider.deleted, 0);
      expect(store.value.cleanupRequired, isTrue);
      coordinator = create();
    },
  );
  test(
    'lookup timeout frees duplicate guard; late result cannot navigate',
    () async {
      final delayed = Completer<NotificationEntity?>();
      lookup = (_) => delayed.future;
      await coordinator.open(event);
      delayed.complete(notice);
      await flush();
      expect(opened, isEmpty);
      lookup = (_) async => notice;
      await coordinator.open(event);
      expect(opened, [notice]);
    },
  );
  test(
    'duplicate sequential and concurrent taps open at most once per scope',
    () async {
      final delayed = Completer<NotificationEntity?>();
      lookup = (_) => delayed.future;
      final a = coordinator.open(event);
      final b = coordinator.open(event);
      delayed.complete(notice);
      await Future.wait([a, b]);
      await coordinator.open(event);
      expect(opened, hasLength(1));
      coordinator.invalidate();
      await coordinator.open(event);
      expect(opened, hasLength(2));
    },
  );
  test('A logout A cannot revive old pending lookup', () async {
    final delayed = Completer<NotificationEntity?>();
    lookup = (_) => delayed.future;
    final a = coordinator.open(event);
    coordinator.invalidate();
    delayed.complete(notice);
    await a;
    expect(opened, isEmpty);
  });
  for (final token in ['', 'contains space', 'contains\nline', 'x' * 4097]) {
    test(
      'invalid token length ${token.length} is rejected without server call',
      () async {
        provider.token = () async => token;
        expect(await coordinator.enable(), PushRegistrationResult.failed);
        expect(registry.registrations, isEmpty);
        expect(store.value.cleanupRequired, isTrue);
      },
    );
  }
  test(
    'installation survives new repository instance; roles have different IDs',
    () async {
      SharedPreferences.setMockInitialValues({});
      final a = LocalPushInstallationStore(NotificationAppRole.merchant);
      final initial = await a.read();
      await a.save(PushInstallation(initial.id, cleanupRequired: true));
      final restored = await LocalPushInstallationStore(
        NotificationAppRole.merchant,
      ).read();
      expect(restored.id, initial.id);
      expect(restored.cleanupRequired, isTrue);
      expect(
        (await LocalPushInstallationStore(
          NotificationAppRole.customer,
        ).read()).id,
        isNot(initial.id),
      );
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString('push_installation_v1_merchant'),
        isNot(contains(owner.userId)),
      );
    },
  );
  test(
    'corrupt installation fails closed instead of silently discarding uncertain ownership',
    () async {
      SharedPreferences.setMockInitialValues({
        'push_installation_v1_merchant': '{bad',
      });
      await expectLater(
        LocalPushInstallationStore(NotificationAppRole.merchant).read(),
        throwsStateError,
      );
    },
  );
}
