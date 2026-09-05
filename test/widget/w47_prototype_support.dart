// Fonts and viewport scoped only to the three W47 owner-review test files.
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> loadW47Fonts() async {
  final poppins = FontLoader('Poppins');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    poppins.addFont(rootBundle.load('assets/fonts/Poppins-$weight.ttf'));
  }
  final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
  final material = FontLoader('MaterialIcons')
    ..addFont(
      File(
        '${artifacts.path}/material_fonts/MaterialIcons-Regular.otf',
      ).readAsBytes().then(ByteData.sublistView),
    );
  final iconsax = FontLoader('packages/iconsax_flutter/FlutterIconsax')
    ..addFont(
      rootBundle.load('packages/iconsax_flutter/fonts/FlutterIconsax.ttf'),
    );
  await Future.wait([poppins.load(), material.load(), iconsax.load()]);
}

void setW47Viewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
