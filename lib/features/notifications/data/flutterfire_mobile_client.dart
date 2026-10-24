import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import '../domain/push_contract.dart';
import 'fcm_mobile_push_provider.dart';

class FlutterFireMobileClient implements FcmMobileClient {
  FlutterFireMobileClient(this.messaging) {
    _native.setMethodCallHandler((call) async {
      if (call.method == 'notificationOpened' && call.arguments is Map) {
        _opens.add(Map<String, dynamic>.from(call.arguments as Map));
      }
    });
  }
  final FirebaseMessaging messaging;
  static const _native = MethodChannel('esnaftavar/development_push');
  final _opens = StreamController<Map<String, dynamic>>.broadcast();
  @override
  Stream<Map<String, dynamic>> get opens => Stream.multi((controller) {
    final fcm = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => controller.add(message.data),
      onError: controller.addError,
    );
    final native = _opens.stream.listen(
      controller.add,
      onError: controller.addError,
    );
    controller.onCancel = () async {
      await fcm.cancel();
      await native.cancel();
    };
  });
  @override
  Stream<Map<String, dynamic>> get messages =>
      FirebaseMessaging.onMessage.map((m) => m.data);
  @override
  Future<Map<String, dynamic>?> initialOpen() async {
    final message = await messaging.getInitialMessage();
    final native = await _native.invokeMapMethod<String, dynamic>(
      'initialOpen',
    );
    return message?.data ?? native;
  }

  @override
  Future<PushPermission> requestPermission() async {
    final settings = await messaging.requestPermission(provisional: false);
    return settings.authorizationStatus == AuthorizationStatus.authorized
        ? PushPermission.granted
        : PushPermission.denied;
  }

  @override
  Future<String?> getToken() => messaging.getToken();
  @override
  Stream<String> get tokenChanges => messaging.onTokenRefresh;
  @override
  Future<void> deleteToken() => messaging.deleteToken();
  @override
  Future<void> disableAutoInit() => messaging.setAutoInitEnabled(false);
  @override
  Future<void> showGeneric(Map<String, String> data) =>
      _native.invokeMethod<void>('showGeneric', data);
  @override
  Future<void> clearNotifications() => _native.invokeMethod<void>('clear');
}
