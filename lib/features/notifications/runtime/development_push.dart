import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show appFlavor;
import '../../../core/supabase/supabase_service.dart';
import '../../../core/supabase/authenticated_session_key.dart';
import '../data/fcm_mobile_push_provider.dart';
import '../data/flutterfire_mobile_client.dart';
import '../domain/push_contract.dart';

const developmentPushEnabled = bool.fromEnvironment(
  'ESNAFTAVAR_DEVELOPMENT_PUSH_ENABLED',
  defaultValue: false,
);

bool permitsDevelopmentPush({
  required bool enabled,
  required bool android,
  required String? flavor,
  required String backendUrl,
  required NotificationAppRole role,
}) {
  if (!enabled || !android) return false;
  final uri = Uri.tryParse(backendUrl);
  return uri?.scheme == 'https' &&
      uri?.userInfo == '' &&
      uri?.host == 'tnipyxnvhgelwdpykyez.supabase.co' &&
      (!uri!.hasPort || uri.port == 443) &&
      uri.query.isEmpty &&
      uri.fragment.isEmpty &&
      (uri.path.isEmpty || uri.path == '/') &&
      flavor ==
          (role == NotificationAppRole.customer
              ? 'development'
              : 'merchantPilot');
}

Future<MobilePushProvider> createDevelopmentPush({
  required SupabaseService service,
  required String backendUrl,
  required NotificationAppRole role,
}) async {
  if (!developmentPushEnabled) return const UnconfiguredMobilePushProvider();
  if (!permitsDevelopmentPush(
    enabled: true,
    android: !kIsWeb && defaultTargetPlatform == TargetPlatform.android,
    flavor: appFlavor,
    backendUrl: backendUrl,
    role: role,
  )) {
    throw StateError('development_push_environment_denied');
  }
  // Native resources come from the external reviewed Android client file.
  // No privileged key or default Production Firebase options exist in Dart.
  final app = await Firebase.initializeApp();
  if (app.options.projectId != 'esnaftavar-development' ||
      app.options.messagingSenderId != '1003286439273') {
    throw StateError('development_push_project_denied');
  }
  final client = FlutterFireMobileClient(FirebaseMessaging.instance);
  await client.disableAutoInit();
  return FcmMobilePushProvider(
    client: client,
    role: role,
    currentSessionKey: () => authenticatedSessionKey(service.client),
    currentIdentity: () => service.currentUser == null
        ? null
        : PushIdentity(service.currentUser!.id, role),
  );
}
