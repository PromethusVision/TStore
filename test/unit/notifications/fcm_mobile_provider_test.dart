import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/notifications/data/fcm_mobile_push_provider.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/runtime/development_push.dart';

const user = '11111111-1111-4111-8111-111111111111';
const notice = '22222222-2222-4222-8222-222222222222';
const identity = PushIdentity(user, NotificationAppRole.merchant);
const data = <String, dynamic>{
  'notification_id': notice,
  'user_id': user,
  'app_role': 'merchant',
};

class Client implements FcmMobileClient {
  final taps = StreamController<Map<String, dynamic>>.broadcast(sync: true);
  final foreground = StreamController<Map<String, dynamic>>.broadcast(
    sync: true,
  );
  final tokens = StreamController<String>.broadcast(sync: true);
  final calls = <String>[];
  final shown = <Map<String, String>>[];
  final initial = Completer<Map<String, dynamic>?>();
  bool failDelete = false;
  @override
  Stream<Map<String, dynamic>> get opens => taps.stream;
  @override
  Stream<Map<String, dynamic>> get messages => foreground.stream;
  @override
  Stream<String> get tokenChanges => tokens.stream;
  @override
  Future<Map<String, dynamic>?> initialOpen() => initial.future;
  @override
  Future<PushPermission> requestPermission() async {
    calls.add('permission');
    return PushPermission.denied;
  }

  @override
  Future<String?> getToken() async {
    calls.add('token');
    return 'synthetic';
  }

  @override
  Future<void> disableAutoInit() async {
    calls.add('auto-off');
  }

  @override
  Future<void> deleteToken() async {
    calls.add('delete');
    if (failDelete) throw StateError('fixture');
  }

  @override
  Future<void> clearNotifications() async {
    calls.add('clear');
  }

  @override
  Future<void> showGeneric(Map<String, String> data) async {
    shown.add(data);
  }
}

void main() {
  late Client client;
  late FcmMobilePushProvider provider;
  late PushIdentity? current;
  late String? session;
  setUp(() {
    client = Client();
    current = identity;
    session = 'session-1';
    provider = FcmMobilePushProvider(
      client: client,
      role: NotificationAppRole.merchant,
      currentIdentity: () => current,
      currentSessionKey: () => session,
    );
  });
  tearDown(() async {
    await provider.dispose();
    await client.taps.close();
    await client.foreground.close();
    await client.tokens.close();
  });
  test(
    'cold-start tap arrives without permission, token fetch or enrollment',
    () async {
      final taps = <PushOpenEvent>[];
      final sub = provider.opened.listen(taps.add);
      client.initial.complete(data);
      await pumpEventQueue();
      expect(taps.single.notificationId, notice);
      expect(client.calls, isEmpty);
      await sub.cancel();
    },
  );
  test(
    'pending initial tap cannot cross a same-user replacement session',
    () async {
      final taps = <PushOpenEvent>[];
      final sub = provider.opened.listen(taps.add);
      await pumpEventQueue();
      session = 'session-2';
      client.initial.complete(data);
      await pumpEventQueue();
      expect(taps, isEmpty);
      await sub.cancel();
    },
  );
  test(
    'wrong owner, wrong role and malformed payloads never open or display',
    () async {
      final taps = <PushOpenEvent>[];
      final sub = provider.opened.listen(taps.add);
      for (final payload in [
        <String, dynamic>{},
        {...data, 'user_id': '33333333-3333-4333-8333-333333333333'},
        {...data, 'app_role': 'customer'},
        {...data, 'notification_id': '/private/route'},
      ]) {
        client.taps.add(payload);
        client.foreground.add(payload);
      }
      await pumpEventQueue();
      expect(taps, isEmpty);
      expect(client.shown, isEmpty);
      await sub.cancel();
    },
  );
  test(
    'foreground presentation strips content and arbitrary route data',
    () async {
      final sub = provider.opened.listen((_) {});
      client.foreground.add({
        ...data,
        'body': 'private fixture',
        'route': 'admin',
        'token': 'not-forwarded',
      });
      await pumpEventQueue();
      expect(client.shown.single, data);
      current = null;
      client.foreground.add(data);
      await pumpEventQueue();
      expect(client.shown, hasLength(1));
      await sub.cancel();
    },
  );
  test(
    'deletion disables auto-init before SDK delete and clears tray',
    () async {
      await provider.deleteToken();
      expect(client.calls, ['auto-off', 'delete', 'clear']);
    },
  );
  test('failed SDK deletion is not treated as successful cleanup', () async {
    client.failDelete = true;
    await expectLater(provider.deleteToken(), throwsStateError);
    expect(client.calls, ['auto-off', 'delete']);
  });
  test('permission denial is explicit, never requests a token', () async {
    expect(await provider.requestPermission(), PushPermission.denied);
    expect(client.calls, ['permission']);
  });
  test(
    'only exact Development endpoint, platform and role flavor can activate',
    () {
      bool allow({
        String url = 'https://tnipyxnvhgelwdpykyez.supabase.co',
        String? flavor = 'merchantPilot',
        bool enabled = true,
        bool android = true,
        NotificationAppRole role = NotificationAppRole.merchant,
      }) => permitsDevelopmentPush(
        enabled: enabled,
        android: android,
        flavor: flavor,
        backendUrl: url,
        role: role,
      );
      expect(allow(), isTrue);
      expect(
        allow(flavor: 'development', role: NotificationAppRole.customer),
        isTrue,
      );
      for (final denied in [
        allow(enabled: false),
        allow(android: false),
        allow(flavor: 'production'),
        allow(flavor: 'merchantDevelopment'),
        allow(flavor: 'development'),
        allow(flavor: null),
        allow(url: 'https://other.supabase.co'),
        allow(url: 'http://tnipyxnvhgelwdpykyez.supabase.co'),
        allow(url: 'https://tnipyxnvhgelwdpykyez.supabase.co.evil.test'),
        allow(url: 'https://user@tnipyxnvhgelwdpykyez.supabase.co'),
        allow(url: 'https://tnipyxnvhgelwdpykyez.supabase.co:444'),
        allow(url: 'https://tnipyxnvhgelwdpykyez.supabase.co/rest/v1'),
      ]) {
        expect(denied, isFalse);
      }
    },
  );
}
