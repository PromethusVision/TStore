import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifest = File(
    'android/app/src/main/AndroidManifest.xml',
  ).readAsStringSync();

  test('Android Auth callbacks have a single app-owned route handler', () {
    expect(
      manifest,
      matches(
        r'<meta-data\s+android:name="flutter_deeplinking_enabled"\s+'
        r'android:value="false"\s*/>',
      ),
    );
    final service = File(
      'lib/core/supabase/supabase_service.dart',
    ).readAsStringSync();
    expect(service, contains('detectSessionInUri: false'));
    expect(service, contains('AppLinks().uriLinkStream.listen'));
    expect(service, contains('exchangeValidatedPkceCallback'));
  });

  test('release disallows backup and cleartext traffic explicitly', () {
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:usesCleartextTraffic="false"'));
    expect(manifest, contains('android:fullBackupContent="@xml/backup_rules"'));
    expect(
      manifest,
      contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
    );
  });

  const domains = [
    'root',
    'file',
    'database',
    'sharedpref',
    'external',
    'device_root',
    'device_file',
    'device_database',
    'device_sharedpref',
  ];
  final legacy = File(
    'android/app/src/main/res/xml/backup_rules.xml',
  ).readAsStringSync();
  final modern = File(
    'android/app/src/main/res/xml/data_extraction_rules.xml',
  ).readAsStringSync();
  for (final mode in ['legacy', 'cloud-backup', 'device-transfer']) {
    test('$mode excludes every persistent session/cache storage domain', () {
      final source = mode == 'legacy'
          ? legacy
          : RegExp('<$mode>([\\s\\S]*?)</$mode>').firstMatch(modern)!.group(1)!;
      expect(source, isNot(contains('<include')));
      for (final domain in domains) {
        expect(source, contains('<exclude domain="$domain" path="." />'));
      }
    });
  }

  test('displaying Customer QR never requires camera hardware to install', () {
    expect(
      manifest,
      contains(
        '<uses-feature android:name="android.hardware.camera" '
        'android:required="false" />',
      ),
    );
    final cart = File(
      'lib/features/shop/presentation/views/cart_v2_view.dart',
    ).readAsStringSync();
    expect(cart, isNot(contains('MerchantQrScannerView')));
    expect(cart, contains('CartQrSessionBottomSheet'));
  });
}
