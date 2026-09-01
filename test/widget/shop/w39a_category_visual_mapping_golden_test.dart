import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/theme/theme.dart';
import 'package:t_store/features/shop/presentation/helpers/home_category_visual_catalog.dart';
import 'package:t_store/features/shop/presentation/widgets/home_categories.dart';

import '../../helpers/canonical_taxonomy_test_support.dart';

void main() {
  setUpAll(() async {
    final poppins = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Bold.ttf'));
    final flutterArtifacts = File(
      Platform.resolvedExecutable,
    ).parent.parent.parent;
    final materialIcons = FontLoader('MaterialIcons')
      ..addFont(
        File(
          '${flutterArtifacts.path}${Platform.pathSeparator}material_fonts'
          '${Platform.pathSeparator}MaterialIcons-Regular.otf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await Future.wait([poppins.load(), materialIcons.load()]);
  });

  test('24 canonical roots map to 24 valid and unique semantic visuals', () {
    final visuals = canonicalRootNames
        .map(HomeCategoryVisualCatalog.canonicalForName)
        .toList(growable: false);

    expect(canonicalRootNames, hasLength(24));
    expect(HomeCategoryVisualCatalog.canonicalVisuals, hasLength(24));
    expect(visuals, everyElement(isNotNull));
    expect(
      visuals.map((visual) => visual!.categoryName).toList(growable: false),
      canonicalRootNames,
    );
    expect(visuals.map((visual) => visual!.assetLabel).toSet(), hasLength(24));
    expect(
      visuals.map((visual) => visual!.icon.codePoint).toSet(),
      hasLength(24),
    );
    expect(
      HomeCategoryVisualCatalog.canonicalForName('Giyim & Moda')?.icon,
      Icons.checkroom_rounded,
    );
  });

  test('canonical resolution is independent from list order and root id', () {
    final reversedNames = canonicalRootNames.reversed.toList(growable: false);

    for (var index = 0; index < reversedNames.length; index++) {
      final name = reversedNames[index];
      final resolved = HomeCategoryVisualCatalog.resolve(
        categoryId: 'unrelated-root-${index + 100}',
        categoryName: name,
      );
      expect(resolved.isCanonical, isTrue, reason: name);
      expect(resolved.categoryName, name, reason: name);
      expect(resolved.icon, isNot(Icons.category_rounded), reason: name);
    }
  });

  testWidgets('24 canonical category visuals render in one review sheet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: TAppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: const Key('w39a-category-contact-sheet'),
          child: Scaffold(
            backgroundColor: CustomerHomeV1Tokens.cream,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EsnaftaVar — Kanonik 24 Kategori Görsel Kontrolü',
                      style: TextStyle(
                        color: CustomerHomeV1Tokens.navy,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'W39A-R3.1 • Gerçek Home kategori görsel bileşeni • 24/24',
                      style: TextStyle(
                        color: CustomerHomeV1Tokens.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.08,
                            ),
                        itemCount:
                            HomeCategoryVisualCatalog.canonicalVisuals.length,
                        itemBuilder: (context, index) {
                          final visual =
                              HomeCategoryVisualCatalog.canonicalVisuals[index];
                          return Container(
                            key: Key('category-proof-${index + 1}'),
                            padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: CustomerHomeV1Tokens.border,
                              ),
                            ),
                            child: Column(
                              children: [
                                HomeCategoryVisual(
                                  icon: visual.icon,
                                  backgroundColor:
                                      CustomerHomeV1Tokens
                                          .categorySurfaces[index %
                                          CustomerHomeV1Tokens
                                              .categorySurfaces
                                              .length],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${index + 1}. ${visual.categoryName}',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: CustomerHomeV1Tokens.navy,
                                    fontSize: 12,
                                    height: 1.18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('category-proof-1')), findsOneWidget);
    expect(find.byKey(const Key('category-proof-24')), findsOneWidget);
    for (final categoryName in canonicalRootNames) {
      expect(find.textContaining(categoryName), findsOneWidget);
    }
    await expectLater(
      find.byKey(const Key('w39a-category-contact-sheet')),
      matchesGoldenFile(
        'goldens/w39a_r31_canonical_24_category_contact_sheet.png',
      ),
    );
  });
}
