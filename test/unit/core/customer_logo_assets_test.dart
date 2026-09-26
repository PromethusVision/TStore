import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/common/widgets/customer_brand_logo.dart';

Future<ui.Image> _decode(String path) async {
  final codec = await ui.instantiateImageCodec(File(path).readAsBytesSync());
  try {
    return (await codec.getNextFrame()).image;
  } finally {
    codec.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('official PNG is bundled unchanged with transparent margins', () async {
    final bytes = (await rootBundle.load(
      CustomerBrandLogo.assetPath,
    )).buffer.asUint8List();
    expect(bytes.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
    expect(
      sha256.convert(bytes).toString(),
      'a87dc38bcd50dd2650c71257e664c744ad28982f8eddd452f50029c6fe25fb30',
    );
    final image = await _decode(CustomerBrandLogo.assetPath);
    addTearDown(image.dispose);
    expect(image.width, 2172);
    expect(image.height, 724);
    final rgba = (await image.toByteData())!.buffer.asUint8List();
    expect(rgba[3], 0);
    expect(rgba[(image.width - 1) * 4 + 3], 0);
    expect(rgba[(image.height - 1) * image.width * 4 + 3], 0);
    expect(rgba.last, 0);
  });

  const densities = {
    'mdpi': 1.0,
    'hdpi': 1.5,
    'xhdpi': 2.0,
    'xxhdpi': 3.0,
    'xxxhdpi': 4.0,
  };
  for (final entry in densities.entries) {
    test(
      'Android ${entry.key} splash retains ratio and fits Android 12 mask',
      () async {
        const root = 'android/app/src/main/res';
        for (final name in ['splash', 'android12splash']) {
          final path = '$root/drawable-${entry.key}/$name.png';
          expect(
            File(
              '$root/drawable-night-${entry.key}/$name.png',
            ).readAsBytesSync(),
            File(path).readAsBytesSync(),
          );
          final image = await _decode(path);
          addTearDown(image.dispose);
          final density = entry.value;
          if (name == 'splash') {
            expect(image.width, 228 * density);
            expect(image.height, 76 * density);
          } else {
            expect(image.width, 288 * density);
            expect(image.height, image.width);
            final rgba = (await image.toByteData())!.buffer.asUint8List();
            var visible = 0;
            for (var y = 0; y < image.height; y++) {
              for (var x = 0; x < image.width; x++) {
                if (rgba[(y * image.width + x) * 4 + 3] == 0) continue;
                visible++;
                final dx = x + 0.5 - image.width / 2;
                final dy = y + 0.5 - image.height / 2;
                expect(
                  dx * dx + dy * dy,
                  lessThan(96 * 96 * density * density),
                );
              }
            }
            expect(visible, greaterThan(0));
          }
        }
      },
    );
  }

  test('iOS splash preserves ratio and identical light/dark artwork', () async {
    const root = 'ios/Runner/Assets.xcassets/LaunchImage.imageset';
    for (final scale in [1, 2, 3]) {
      final suffix = scale == 1 ? '' : '@${scale}x';
      final path = '$root/LaunchImage$suffix.png';
      expect(
        File('$root/LaunchImageDark$suffix.png').readAsBytesSync(),
        File(path).readAsBytesSync(),
      );
      final image = await _decode(path);
      addTearDown(image.dispose);
      expect(image.width, 228 * scale);
      expect(image.height, 76 * scale);
    }
  });

  test(
    'native launch resolves official resources on a light background',
    () async {
      const root = 'android/app/src/main/res';
      for (final directory in [
        'drawable',
        'drawable-v21',
        'drawable-night',
        'drawable-night-v21',
      ]) {
        final xml = File(
          '$root/$directory/launch_background.xml',
        ).readAsStringSync();
        expect(
          xml,
          contains('android:gravity="center" android:src="@drawable/splash"'),
        );
        final image = await _decode('$root/$directory/background.png');
        addTearDown(image.dispose);
        expect((await image.toByteData())!.buffer.asUint8List(), [
          255,
          255,
          255,
          255,
        ]);
      }
      for (final directory in ['values-v31', 'values-night-v31']) {
        final xml = File('$root/$directory/styles.xml').readAsStringSync();
        expect(
          xml,
          contains(
            'name="android:windowSplashScreenAnimatedIcon">@drawable/android12splash',
          ),
        );
        expect(
          xml,
          contains('name="android:windowSplashScreenBackground">#FFFFFF'),
        );
      }
      final config = File('splash.yaml').readAsStringSync();
      expect(config, isNot(contains('t-store')));
      expect(config, isNot(contains('Desktop')));
      final ios = File(
        'ios/Runner/Base.lproj/LaunchScreen.storyboard',
      ).readAsStringSync();
      expect(ios, contains('contentMode="center" image="LaunchImage"'));
    },
  );
}
