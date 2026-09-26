import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/domain/push_coordinator.dart';
import 'package:t_store/features/notifications/data/repositories/notification_preferences_repository.dart';

class _Provider implements MobilePushProvider {
  @override
  bool configured = true;
  PushPermission permission = PushPermission.granted;
  int requests = 0, deleted = 0;
  final tokens = StreamController<String>.broadcast();
  final opens = StreamController<PushOpenEvent>.broadcast();
  @override
  Future<PushPermission> requestPermission() async {
    requests++;
    return permission;
  }

  @override
  Future<String?> getToken() async => 'test-only-opaque-device-token';
  @override
  Stream<String> get tokenChanges => tokens.stream;
  @override
  Stream<PushOpenEvent> get opened => opens.stream;
  @override
  Future<void> deleteToken() async {
    deleted++;
  }
}

class _Registry implements PushDeviceRegistry {
  @override
  bool deployed = true;
  final tokens = <String>[];
  final disabled = <PushIdentity>[];
  Completer<void>? slow;
  bool fail = false;
  @override
  Future<void> register(PushDeviceRegistration registration) async {
    await slow?.future;
    if (fail) throw StateError('fixture_failure');
    tokens.add(registration.token);
  }

  @override
  Future<void> disable(PushIdentity identity, String installationId) async {
    disabled.add(identity);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const customer = PushIdentity(
    'fixture-customer',
    NotificationAppRole.customer,
  );
  const merchant = PushIdentity(
    'fixture-merchant',
    NotificationAppRole.merchant,
  );
  late _Provider provider;
  late _Registry registry;
  late PushCoordinator coordinator;
  PushIdentity? current;
  final opened = <NotificationEntity>[];
  NotificationEntity record(String user, {String? role}) => NotificationEntity(
    id: 'fixture-notification',
    userId: user,
    title: 'Fixture',
    body: 'Fixture',
    type: NotificationType.system,
    data: {if (role != null) 'app_role': role},
  );
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    provider = _Provider();
    registry = _Registry();
    current = customer;
    opened.clear();
    coordinator = PushCoordinator(
      provider: provider,
      registry: registry,
      currentIdentity: () => current,
      lookup: (_) async => record(current!.userId),
      onOpen: opened.add,
      installationId: 'fixture-install',
      platform: PushPlatform.android,
    );
  });
  tearDown(() async {
    await coordinator.disable();
    await provider.tokens.close();
    await provider.opens.close();
  });

  test(
    'missing SDK or undeployed schema performs no permission or token request',
    () async {
      provider.configured = false;
      expect(
        await coordinator.enable(),
        PushRegistrationResult.pendingConfiguration,
      );
      provider.configured = true;
      registry.deployed = false;
      expect(
        await coordinator.enable(),
        PushRegistrationResult.pendingConfiguration,
      );
      expect(provider.requests, 0);
      expect(registry.tokens, isEmpty);
    },
  );
  test('guest and denied permission do not register devices', () async {
    current = null;
    expect(await coordinator.enable(), PushRegistrationResult.denied);
    expect(provider.requests, 0);
    current = customer;
    provider.permission = PushPermission.denied;
    expect(await coordinator.enable(), PushRegistrationResult.denied);
    expect(registry.tokens, isEmpty);
  });
  test(
    'both customer and merchant share enrollment and revoke before switch',
    () async {
      expect(await coordinator.enable(), PushRegistrationResult.registered);
      await coordinator.disable();
      current = merchant;
      expect(await coordinator.enable(), PushRegistrationResult.registered);
      expect(registry.tokens.length, 2);
      expect(registry.disabled.single.role, NotificationAppRole.customer);
    },
  );
  test(
    'rotation is serialized and account changes reject late tokens',
    () async {
      await coordinator.enable();
      provider.tokens.add('rotation-1');
      provider.tokens.add('rotation-2');
      await Future<void>.delayed(Duration.zero);
      expect(registry.tokens.skip(1), ['rotation-1', 'rotation-2']);
      current = merchant;
      provider.tokens.add('stale-account-token');
      await Future<void>.delayed(Duration.zero);
      expect(registry.tokens, isNot(contains('stale-account-token')));
    },
  );
  test(
    'disable waits for pending initial registration before revoking it',
    () async {
      registry.slow = Completer<void>();
      final enabling = coordinator.enable();
      await Future<void>.delayed(Duration.zero);
      final disabling = coordinator.disable();
      registry.slow!.complete();
      expect(await enabling, PushRegistrationResult.denied);
      await disabling;
      expect(registry.disabled.length, 1);
      expect(registry.tokens.length, 1);
    },
  );
  test(
    'registration failure is reported with no raw token error exposure',
    () async {
      registry.fail = true;
      expect(await coordinator.enable(), PushRegistrationResult.failed);
      expect(
        PushDeviceRegistration(
          identity: customer,
          installationId: 'private-install',
          token: 'private-token',
          platform: PushPlatform.ios,
        ).toString(),
        'PushDeviceRegistration(redacted)',
      );
      expect(customer.toString(), 'PushIdentity(redacted)');
    },
  );
  test('tap uses authoritative notification and exact account', () async {
    await coordinator.open(
      const PushOpenEvent(
        notificationId: 'fixture-notification',
        identity: customer,
      ),
    );
    expect(opened.length, 1);
    await coordinator.open(
      const PushOpenEvent(
        notificationId: 'fixture-notification',
        identity: merchant,
      ),
    );
    expect(opened.length, 1);
  });
  test('account switch during lookup rejects delayed notification', () async {
    final result = Completer<NotificationEntity?>();
    coordinator = PushCoordinator(
      provider: provider,
      registry: registry,
      currentIdentity: () => current,
      lookup: (_) => result.future,
      onOpen: opened.add,
      installationId: 'fixture-install',
      platform: PushPlatform.ios,
    );
    final opening = coordinator.open(
      const PushOpenEvent(
        notificationId: 'fixture-notification',
        identity: customer,
      ),
    );
    current = merchant;
    result.complete(record(customer.userId));
    await opening;
    expect(opened, isEmpty);
  });
  test('wrong owner or role in authoritative row cannot be opened', () async {
    for (final row in [
      record('someone-else'),
      record(customer.userId, role: 'merchant'),
    ]) {
      coordinator = PushCoordinator(
        provider: provider,
        registry: registry,
        currentIdentity: () => current,
        lookup: (_) async => row,
        onOpen: opened.add,
        installationId: 'fixture-install',
        platform: PushPlatform.ios,
      );
      await coordinator.open(
        const PushOpenEvent(
          notificationId: 'fixture-notification',
          identity: customer,
        ),
      );
    }
    expect(opened, isEmpty);
  });
  test(
    'preferences persist opt-out, isolate account/role, and remain explicitly local',
    () async {
      final repo = LocalNotificationPreferencesRepository();
      expect(repo.serverBacked, isFalse);
      expect((await repo.read(customer)).marketing, isFalse);
      expect((await repo.read(customer)).service, isTrue);
      await repo.save(customer, const NotificationPreferences(marketing: true));
      expect((await repo.read(merchant)).marketing, isFalse);
      expect(
        (await repo.read(
          PushIdentity(customer.userId, NotificationAppRole.merchant),
        )).marketing,
        isFalse,
      );
      await repo.save(customer, const NotificationPreferences(service: false));
      final restored = await LocalNotificationPreferencesRepository().read(
        customer,
      );
      expect(restored.marketing, isFalse);
      expect(restored.service, isFalse);
    },
  );
  test(
    'notification target contract rejects privileged or malformed routes',
    () {
      NotificationEntity target(String type, String value) => record(
        customer.userId,
      ).copyWith(data: {'target_type': type, 'target_value': value});
      expect(target('search', 'USB').engagementTarget!.value, 'USB');
      expect(target('reward', '').engagementTarget, isNotNull);
      expect(target('admin', '').engagementTarget, isNull);
      expect(
        target('product', 'https://example.invalid').engagementTarget,
        isNull,
      );
      expect(target('messages', 'other-user').engagementTarget, isNull);
    },
  );
}
