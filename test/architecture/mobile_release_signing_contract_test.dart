import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mobile release identity and signing contract', () {
    test('temporary identifiers remain explicit until the owner decides', () {
      final androidGradle = File('android/app/build.gradle').readAsStringSync();
      final xcodeProject = File(
        'ios/Runner.xcodeproj/project.pbxproj',
      ).readAsStringSync();

      expect(androidGradle, contains('namespace = "com.example.t_store"'));
      expect(androidGradle, contains('applicationId = "com.example.t_store"'));
      expect(
        xcodeProject,
        contains('PRODUCT_BUNDLE_IDENTIFIER = com.example.tStore;'),
      );
    });

    test('Android release packaging never falls back to debug signing', () {
      final androidGradle = File('android/app/build.gradle').readAsStringSync();
      final gradleProperties = File(
        'android/gradle.properties',
      ).readAsStringSync();

      expect(
        androidGradle,
        isNot(contains('signingConfig = signingConfigs.debug')),
      );
      expect(androidGradle, contains('signingConfigs.release'));
      expect(androidGradle, contains('releaseSigningReady'));
      expect(androidGradle, contains('(assemble|bundle|package).*release'));
      expect(
        androidGradle,
        contains('Production release signing is not configured'),
      );
      expect(
        gradleProperties,
        isNot(contains('org.gradle.java.home=')),
        reason:
            'CI and Flutter must select a valid JDK without a machine path.',
      );
    });

    test('mobile signing material stays outside source control', () {
      final rootGitignore = File('.gitignore').readAsStringSync();
      final androidGitignore = File('android/.gitignore').readAsStringSync();

      for (final rule in const [
        '/ios/Flutter/ReleaseSigning.xcconfig',
        '**/*.mobileprovision',
        '**/*.p12',
        '**/*.pfx',
      ]) {
        expect(rootGitignore, contains(rule));
      }
      expect(androidGitignore, contains('key.properties'));
      expect(androidGitignore, contains('**/*.keystore'));
      expect(androidGitignore, contains('**/*.jks'));
      expect(File('android/key.properties.example').existsSync(), isTrue);
      expect(
        File('ios/Flutter/ReleaseSigning.xcconfig.example').existsSync(),
        isTrue,
      );
    });

    test(
      'iOS Release uses distribution signing without embedded owner data',
      () {
        final xcodeProject = File(
          'ios/Runner.xcodeproj/project.pbxproj',
        ).readAsStringSync();
        final releaseConfig = File(
          'ios/Flutter/Release.xcconfig',
        ).readAsStringSync();

        expect(
          xcodeProject,
          contains(
            '"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "Apple Distribution";',
          ),
        );
        expect(xcodeProject, contains('CODE_SIGN_STYLE = Manual;'));
        expect(releaseConfig, contains('#include? "ReleaseSigning.xcconfig"'));
        expect(xcodeProject, isNot(contains('DEVELOPMENT_TEAM = ')));
        expect(
          xcodeProject,
          isNot(contains('PROVISIONING_PROFILE_SPECIFIER = ')),
        );
      },
    );

    test('store labels use the canonical product name', () {
      final androidGradle = File('android/app/build.gradle').readAsStringSync();
      final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();

      expect(
        androidGradle,
        contains('resValue "string", "app_name", "EsnaftaVar"'),
      );
      expect(infoPlist, contains('<string>EsnaftaVar</string>'));
      expect(infoPlist, isNot(contains('<string>T Store</string>')));
    });
  });
}
