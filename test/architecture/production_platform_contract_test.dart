import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('production mobile platform contract', () {
    test(
      'Android release manifest declares required customer capabilities',
      () {
        final manifest = File(
          'android/app/src/main/AndroidManifest.xml',
        ).readAsStringSync();

        for (final permission in const [
          'android.permission.INTERNET',
          'android.permission.ACCESS_COARSE_LOCATION',
          'android.permission.ACCESS_FINE_LOCATION',
          'android.permission.CAMERA',
        ]) {
          expect(manifest, contains('android:name="$permission"'));
        }

        expect(manifest, contains('android:name="android.intent.action.VIEW"'));
        expect(manifest, contains('android:scheme="\${authCallbackScheme}"'));
        expect(manifest, contains('android:host="login-callback"'));

        final gradle = File('android/app/build.gradle').readAsStringSync();
        expect(gradle, contains('authCallbackScheme: "com.esnaftavar.app"'));
        expect(gradle, contains('applicationIdSuffix ".dev"'));
        expect(gradle, contains('authCallbackScheme: "io.supabase.tstore"'));
      },
    );

    test('iOS declares customer location and Auth callback contracts', () {
      final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();

      expect(
        infoPlist,
        contains('<key>NSLocationWhenInUseUsageDescription</key>'),
      );
      expect(infoPlist, contains('<key>NSCameraUsageDescription</key>'));
      expect(infoPlist, contains('<key>CFBundleURLTypes</key>'));
      expect(infoPlist, contains('<string>\$(AUTH_CALLBACK_SCHEME)</string>'));
      expect(
        File('ios/Flutter/Release.xcconfig').readAsStringSync(),
        contains('AUTH_CALLBACK_SCHEME=com.esnaftavar.app'),
      );
      expect(
        File('ios/Flutter/Debug.xcconfig').readAsStringSync(),
        contains('AUTH_CALLBACK_SCHEME=io.supabase.tstore'),
      );
    });
  });
}
