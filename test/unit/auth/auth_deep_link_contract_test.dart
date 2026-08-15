import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth deep-link platform contract', () {
    test('Android production manifest accepts the Supabase callback', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();

      expect(
        manifest,
        contains('android.permission.INTERNET'),
        reason: 'Release Auth requests require Android internet permission.',
      );
      expect(manifest, contains('android:scheme="io.supabase.tstore"'));
      expect(manifest, contains('android:host="login-callback"'));
      expect(manifest, contains('android.intent.category.BROWSABLE'));
    });

    test('iOS registers the same Supabase callback scheme', () {
      final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();

      expect(infoPlist, contains('<key>CFBundleURLTypes</key>'));
      expect(infoPlist, contains('<string>io.supabase.tstore</string>'));
    });
  });
}
