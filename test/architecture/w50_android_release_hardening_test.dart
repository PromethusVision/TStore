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

  test('release flavor and Dart entrypoint cannot silently diverge', () {
    final gradle = File('android/app/build.gradle').readAsStringSync();
    expect(gradle, contains('production: "lib/main_production.dart"'));
    expect(gradle, contains('development: "lib/main_development.dart"'));
    expect(
      gradle,
      contains('targetFile.canonicalFile != expectedTargetFile.canonicalFile'),
    );
    expect(
      gradle,
      contains('Customer release target must match its Android flavor'),
    );
  });

  test('known local release input paths and signing keys are ignored', () {
    final ignore = File('.gitignore').readAsStringSync();
    expect(ignore, contains('/tool/production_release_config.json'));
    expect(ignore, contains('/tool/production_mobile_release_config.json'));
    expect(ignore, contains('**/*.keystore'));
    expect(ignore, contains('**/*.jks'));
  });

  test(
    'Android startup attributes stay in their supported resource levels',
    () {
      for (final folder in ['values', 'values-night']) {
        final base = File(
          'android/app/src/main/res/$folder/styles.xml',
        ).readAsStringSync();
        expect(base, isNot(contains('android:forceDarkAllowed')));
        expect(
          base,
          isNot(contains('android:windowLayoutInDisplayCutoutMode')),
        );
        final android28 = File(
          'android/app/src/main/res/$folder-v28/styles.xml',
        ).readAsStringSync();
        final android29 = File(
          'android/app/src/main/res/$folder-v29/styles.xml',
        ).readAsStringSync();
        expect(android28, contains('android:windowLayoutInDisplayCutoutMode'));
        expect(android28, isNot(contains('android:forceDarkAllowed')));
        expect(android29, contains('android:forceDarkAllowed'));
        expect(android29, contains('android:windowLayoutInDisplayCutoutMode'));
      }
    },
  );

  test(
    'unused background notification lint exception cannot hide a new caller',
    () {
      final location = File(
        'lib/features/shop/data/services/geolocator_customer_location_service.dart',
      ).readAsStringSync();
      expect(location, contains('Geolocator.getCurrentPosition('));
      expect(location, contains('locationSettings: LocationSettings('));
      final dartSources = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .map((file) => file.readAsStringSync())
          .join('\n');
      expect(dartSources, isNot(contains('foregroundNotificationConfig:')));
      expect(dartSources, isNot(contains('Geolocator.getPositionStream(')));
      final lint = File('android/app/lint.xml').readAsStringSync();
      expect(
        lint,
        contains(
          'usage from com[.]baseflow[.]geolocator[.]location[.]BackgroundNotification',
        ),
      );
      expect(lint, isNot(contains('severity="ignore"')));
      expect(
        manifest,
        isNot(contains('android.permission.POST_NOTIFICATIONS')),
      );
      expect(
        manifest,
        isNot(contains('android.permission.ACCESS_BACKGROUND_LOCATION')),
      );
    },
  );
}
