import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth deep-link platform contract', () {
    test('Android flavors own separate Supabase callback schemes', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
      final gradle = File('android/app/build.gradle').readAsStringSync();

      expect(
        manifest,
        contains('android.permission.INTERNET'),
        reason: 'Release Auth requests require Android internet permission.',
      );
      expect(manifest, contains('android:scheme="\${authCallbackScheme}"'));
      expect(manifest, contains('android:host="login-callback"'));
      expect(manifest, contains('android.intent.category.BROWSABLE'));
      expect(gradle, contains('authCallbackScheme: "com.esnaftavar.app"'));
      expect(gradle, contains('authCallbackScheme: "io.supabase.tstore"'));
    });

    test('iOS release and debug configs keep separate callback schemes', () {
      final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();
      final debugConfig = File('ios/Flutter/Debug.xcconfig').readAsStringSync();
      final releaseConfig = File(
        'ios/Flutter/Release.xcconfig',
      ).readAsStringSync();

      expect(infoPlist, contains('<key>CFBundleURLTypes</key>'));
      expect(infoPlist, contains('<string>\$(AUTH_CALLBACK_SCHEME)</string>'));
      expect(debugConfig, contains('AUTH_CALLBACK_SCHEME=io.supabase.tstore'));
      expect(
        releaseConfig,
        contains('AUTH_CALLBACK_SCHEME=com.esnaftavar.app'),
      );
    });
  });
}
