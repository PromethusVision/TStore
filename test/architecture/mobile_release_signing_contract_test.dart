import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mobile release identity and signing contract', () {
    test('final mobile identifiers match the product-owner decision', () {
      final androidGradle = File('android/app/build.gradle').readAsStringSync();
      final fastlaneAppfile = File(
        'android/fastlane/Appfile',
      ).readAsStringSync();
      final xcodeProject = File(
        'ios/Runner.xcodeproj/project.pbxproj',
      ).readAsStringSync();

      expect(androidGradle, contains('namespace = "com.esnaftavar.app"'));
      expect(androidGradle, contains('applicationId = "com.esnaftavar.app"'));
      expect(fastlaneAppfile, contains('package_name("com.esnaftavar.app")'));
      expect(
        RegExp(
          r'PRODUCT_BUNDLE_IDENTIFIER = com\.esnaftavar\.app;',
        ).allMatches(xcodeProject),
        hasLength(3),
      );
      expect(
        RegExp(
          r'PRODUCT_BUNDLE_IDENTIFIER = com\.esnaftavar\.app\.RunnerTests;',
        ).allMatches(xcodeProject),
        hasLength(3),
      );
    });

    test('MainActivity follows the final Android namespace path', () {
      final mainActivity = File(
        'android/app/src/main/kotlin/com/esnaftavar/app/MainActivity.kt',
      );

      expect(mainActivity.existsSync(), isTrue);
      expect(
        mainActivity.readAsStringSync(),
        contains('package com.esnaftavar.app'),
      );
      expect(
        File(
          'android/app/src/main/kotlin/com/example/t_store/MainActivity.kt',
        ).existsSync(),
        isFalse,
      );
    });

    test('legacy demo identifiers are absent from runtime platform files', () {
      final runtimeFiles = [
        'android/app/build.gradle',
        'android/fastlane/Appfile',
        'android/app/src/main/kotlin/com/esnaftavar/app/MainActivity.kt',
        'ios/Runner.xcodeproj/project.pbxproj',
        'linux/CMakeLists.txt',
        'macos/Runner/Configs/AppInfo.xcconfig',
        'macos/Runner.xcodeproj/project.pbxproj',
        'windows/runner/Runner.rc',
      ];
      final runtimeIdentity = runtimeFiles
          .map((path) => File(path).readAsStringSync())
          .join('\n');

      expect(runtimeIdentity, isNot(contains('com.example.t_store')));
      expect(runtimeIdentity, isNot(contains('com.example.tStore')));
      expect(runtimeIdentity, isNot(contains('com.example')));
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
