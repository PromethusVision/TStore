import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/features/notifications/data/repositories/notification_preferences_repository.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/shared_preferences');
  const owner = PushIdentity('fixture', NotificationAppRole.merchant);
  final storage = <String, Object>{};
  late Future<bool> Function(MethodCall) write;
  var writes = 0;
  setUp(() {
    SharedPreferences.resetStatic();
    storage.clear();
    writes = 0;
    write = (call) async {
      storage[call.arguments['key'] as String] =
          call.arguments['value'] as String;
      return true;
    };
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getAll') return Map<String, Object>.from(storage);
          if (call.method == 'setString') {
            writes++;
            return write(call);
          }
          throw StateError('Unexpected storage method ${call.method}');
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    SharedPreferences.resetStatic();
  });

  test(
    'failed native write never becomes confirmed consent through SDK cache',
    () async {
      final repo = LocalNotificationPreferencesRepository();
      expect((await repo.read(owner)).marketing, isFalse);
      write = (_) async => false;
      await expectLater(
        repo.save(owner, const NotificationPreferences(marketing: true)),
        throwsStateError,
      );
      expect(storage, isEmpty);
      expect(
        (await LocalNotificationPreferencesRepository().read(owner)).marketing,
        isFalse,
      );
    },
  );

  test(
    'fresh read observes native changes instead of a previous cached value',
    () async {
      final repo = LocalNotificationPreferencesRepository();
      await repo.read(owner);
      storage['flutter.notification_preferences_v1_merchant_fixture'] =
          jsonEncode({'service': false, 'marketing': true});
      final result = await repo.read(owner);
      expect(result.service, isFalse);
      expect(result.marketing, isTrue);
    },
  );

  test(
    'reopened adapter read waits for the current native write to settle',
    () async {
      final gate = Completer<bool>();
      write = (call) async {
        final accepted = await gate.future;
        if (accepted) {
          storage[call.arguments['key'] as String] =
              call.arguments['value'] as String;
        }
        return accepted;
      };
      final saving = LocalNotificationPreferencesRepository().save(
        owner,
        const NotificationPreferences(marketing: true),
      );
      await pumpEventQueue();
      var readSettled = false;
      final reading = LocalNotificationPreferencesRepository().read(owner).then(
        (value) {
          readSettled = true;
          return value;
        },
      );
      await pumpEventQueue();
      final premature = readSettled;
      gate.complete(true);
      await saving;
      final result = await reading;
      expect(premature, isFalse);
      expect(result.marketing, isTrue);
      expect(writes, 1);
    },
  );

  test(
    'overlapping same-owner saves are rejected, not queued or replayed',
    () async {
      final gate = Completer<bool>();
      write = (_) => gate.future;
      final saving = LocalNotificationPreferencesRepository().save(
        owner,
        const NotificationPreferences(marketing: true),
      );
      await pumpEventQueue();
      final second = LocalNotificationPreferencesRepository().save(
        owner,
        const NotificationPreferences(marketing: false),
      );
      final expectation = expectLater(second, throwsStateError);
      await pumpEventQueue();
      gate.complete(true);
      await saving;
      await expectation;
      expect(writes, 1);
    },
  );
  test(
    'failed pending write releases read to the previous persistent value',
    () async {
      final gate = Completer<bool>();
      write = (_) => gate.future;
      final saved = expectLater(
        LocalNotificationPreferencesRepository().save(
          owner,
          const NotificationPreferences(marketing: true),
        ),
        throwsStateError,
      );
      await pumpEventQueue();
      final reading = LocalNotificationPreferencesRepository().read(owner);
      gate.complete(false);
      await saved;
      expect((await reading).marketing, isFalse);
      expect(writes, 1);
    },
  );
  test('a pending owner does not block another account or role', () async {
    final gate = Completer<bool>();
    final persist = write;
    write = (call) =>
        call.arguments['key'] ==
            'flutter.notification_preferences_v1_merchant_fixture'
        ? gate.future
        : persist(call);
    final repo = LocalNotificationPreferencesRepository();
    final saved = repo.save(
      owner,
      const NotificationPreferences(marketing: true),
    );
    await pumpEventQueue();
    for (final independent in [
      const PushIdentity('other', NotificationAppRole.merchant),
      const PushIdentity('fixture', NotificationAppRole.customer),
    ]) {
      await repo.save(
        independent,
        const NotificationPreferences(service: false, marketing: true),
      );
      final result = await repo.read(independent);
      expect(result.marketing, isTrue);
      expect(result.service, isFalse);
    }
    gate.complete(false);
    await expectLater(saved, throwsStateError);
    expect((await repo.read(owner)).marketing, isFalse);
    expect(writes, 3);
  });
  test(
    'malformed persistent data is not silently replaced by defaults',
    () async {
      storage['flutter.notification_preferences_v1_merchant_fixture'] =
          '{broken';
      await expectLater(
        LocalNotificationPreferencesRepository().read(owner),
        throwsFormatException,
      );
      expect(writes, 0);
    },
  );
}
