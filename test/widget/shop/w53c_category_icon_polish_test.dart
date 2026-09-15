import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/theme/theme.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_state.dart';
import 'package:t_store/features/shop/presentation/helpers/home_category_visual_catalog.dart';
import 'package:t_store/features/shop/presentation/helpers/category_symbols.dart';
import 'package:t_store/features/shop/presentation/helpers/taxonomy_category_visual_resolver.dart';
import 'package:t_store/features/shop/presentation/widgets/home_categories.dart';

import '../../helpers/canonical_taxonomy_test_support.dart';
import '../../helpers/category_icon_font_test_support.dart';

class _CategoryCubit extends MockCubit<CategoriesState>
    implements CategoriesCubit {}

const _tag = 'after';

Future<void> _loadFonts() async {
  final poppins = FontLoader('Poppins')
    ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'));
  final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
  final material = FontLoader('MaterialIcons')
    ..addFont(
      File(
        '${artifacts.path}/material_fonts/MaterialIcons-Regular.otf',
      ).readAsBytes().then(ByteData.sublistView),
    );
  await Future.wait([poppins.load(), material.load(), loadCategoryIconFont()]);
}

void main() {
  setUpAll(_loadFonts);
  final renderedPixels = <String, List<int>>{};

  test('W53C canonical visual coverage matches repository taxonomy roots', () {
    final roots =
        File('docs/TAXONOMY_W36_CATEGORY_IMPORT.csv')
            .readAsLinesSync()
            .skip(1)
            .map(
              (line) => RegExp(r'"((?:[^"]|"")*)"')
                  .allMatches(line)
                  .map((m) => m[1]!.replaceAll('""', '"'))
                  .toList(),
            )
            .where((fields) => fields[7] == '1')
            .toList()
          ..sort((a, b) => int.parse(a[3]).compareTo(int.parse(b[3])));
    expect(roots.map((row) => row[1]).toList(), canonicalRootNames);
    expect(canonicalRootNames, hasLength(24));
    expect(HomeCategoryVisualCatalog.canonicalVisuals, hasLength(24));
    expect(
      HomeCategoryVisualCatalog.canonicalVisuals
          .map((v) => v.categoryName)
          .toSet(),
      hasLength(24),
    );
    expect(
      HomeCategoryVisualCatalog.canonicalVisuals
          .map((v) => v.icon.codePoint)
          .toSet(),
      hasLength(24),
    );
    for (final name in canonicalRootNames.reversed) {
      final visual = HomeCategoryVisualCatalog.resolve(
        categoryId: 'unrelated-id',
        categoryName: name,
      );
      expect(visual.isCanonical, isTrue, reason: name);
      expect(
        visual,
        isNot(same(HomeCategoryVisualCatalog.unknownVisual)),
        reason: name,
      );
      expect(visual.icon.fontFamily, CategorySymbols.fontFamily);
      expect(TaxonomyCategoryVisualResolver.resolve(name), visual.icon);
      expect(
        TaxonomyCategoryVisualResolver.resolveSurface(name),
        visual.surfaceColor,
      );
      expect(
        HomeCategoryVisualCatalog.canonicalForName('  ${name.toUpperCase()}  '),
        same(visual),
      );
      final foreground = CustomerHomeV1Tokens.navy.computeLuminance();
      final background = visual.surfaceColor.computeLuminance();
      expect(
        (background + .05) / (foreground + .05),
        greaterThanOrEqualTo(4.5),
      );
    }
    expect(
      HomeCategoryVisualCatalog.resolve(
        categoryId: 'unknown',
        categoryName: 'Beklenmedik kategori',
      ),
      same(HomeCategoryVisualCatalog.unknownVisual),
    );
    expect(
      HomeCategoryVisualCatalog.resolve(
        categoryId: 'gozluk-optik',
        categoryName: '',
      ).icon,
      CategorySymbols.eyeglasses,
    );
    expect(
      HomeCategoryVisualCatalog.resolve(
        categoryId: 'giyim-moda',
        categoryName: '',
      ).icon,
      CategorySymbols.apparel,
    );
  });

  for (final os in Brightness.values) {
    testWidgets('W53C $_tag actual 24 icon pixels system ${os.name}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 850);
      tester.view.devicePixelRatio = 1;
      tester.binding.platformDispatcher.platformBrightnessTestValue = os;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(
        tester.binding.platformDispatcher.clearPlatformBrightnessTestValue,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: TAppTheme.lightTheme,
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: RepaintBoundary(
            key: const Key('sheet'),
            child: Scaffold(
              backgroundColor: CustomerHomeV1Tokens.cream,
              body: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EsnaftaVar • 24 kategori',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: CustomerHomeV1Tokens.navy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'W53C • İkon V1 • Ürün sahibi görsel incelemesi',
                      style: TextStyle(
                        fontSize: 14,
                        color: CustomerHomeV1Tokens.muted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 6,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.08,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (var i = 0; i < canonicalRootNames.length; i++)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: CustomerHomeV1Tokens.border,
                                ),
                              ),
                              child: Column(
                                children: [
                                  RepaintBoundary(
                                    key: Key('icon-$i'),
                                    child: HomeCategoryVisual(
                                      icon:
                                          HomeCategoryVisualCatalog.canonicalForName(
                                            canonicalRootNames[i],
                                          )!.icon,
                                      backgroundColor:
                                          HomeCategoryVisualCatalog.canonicalForName(
                                            canonicalRootNames[i],
                                          )!.surfaceColor,
                                      visualPrototype: false,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    canonicalRootNames[i],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.25,
                                      fontWeight: FontWeight.w600,
                                      color: CustomerHomeV1Tokens.navy,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final audit = <Map<String, Object>>[];
      final glyphShapes = <String>{};
      for (var i = 0; i < canonicalRootNames.length; i++) {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(Key('icon-$i')),
        );
        expect(boundary.size, const Size(52, 52));
        final data = await tester.runAsync(() async {
          final image = await boundary.toImage();
          final bytes = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          image.dispose();
          return bytes!;
        });
        var ink = 0;
        var minX = 52, minY = 52, maxX = 0, maxY = 0;
        final bytes = data!.buffer.asUint8List();
        final mask = <int>[];
        for (var p = 0; p < bytes.length; p += 4) {
          final painted =
              bytes[p] < 90 &&
              bytes[p + 1] < 120 &&
              bytes[p + 2] < 130 &&
              bytes[p + 3] > 200;
          mask.add(painted ? 1 : 0);
          if (painted) {
            ink++;
            final x = (p ~/ 4) % 52, y = (p ~/ 4) ~/ 52;
            if (x < minX) minX = x;
            if (x > maxX) maxX = x;
            if (y < minY) minY = y;
            if (y > maxY) maxY = y;
          }
        }
        glyphShapes.add(mask.join());
        expect(minX, greaterThan(3));
        expect(minY, greaterThan(3));
        expect(maxX, lessThan(48));
        expect(maxY, lessThan(48));
        expect(maxX - minX, greaterThan(8));
        expect(maxY - minY, greaterThan(8));
        final previous = renderedPixels[canonicalRootNames[i]];
        if (previous != null) {
          expect(
            bytes,
            orderedEquals(previous),
            reason: 'OS light/dark must render identical icon pixels',
          );
        }
        renderedPixels[canonicalRootNames[i]] = bytes.toList();
        audit.add({
          'category': canonicalRootNames[i],
          'asset': HomeCategoryVisualCatalog.canonicalForName(
            canonicalRootNames[i],
          )!.assetLabel,
          'visible_ink_pixels': ink,
        });
        expect(
          ink,
          greaterThan(30),
          reason: 'Actual rendered foreground: ${canonicalRootNames[i]}',
        );
      }
      expect(
        glyphShapes,
        hasLength(24),
        reason:
            '24 distinct glyph silhouettes; missing-glyph boxes cannot pass',
      );
      await expectLater(
        find.byKey(const Key('sheet')),
        matchesGoldenFile(
          'goldens/w53c_${_tag}_canonical_24_contact_sheet.png',
        ),
      );
      await tester.runAsync(() async {
        final dir = Directory('build/w53c');
        await dir.create(recursive: true);
        await File(
          '${dir.path}/${_tag}_${os.name}_pixel_audit.json',
        ).writeAsString(const JsonEncoder.withIndent('  ').convert(audit));
      });
    });
  }

  testWidgets('W53C full category route renders all 24 actual cards', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final cubit = _CategoryCubit();
    addTearDown(cubit.close);
    whenListen(
      cubit,
      const Stream<CategoriesState>.empty(),
      initialState: CategoriesLoaded([
        for (final root in canonicalRoots())
          CategoryEntity(id: root.id, name: root.displayName),
      ]),
    );
    when(() => cubit.getCategories()).thenAnswer((_) async {});
    await tester.pumpWidget(
      MaterialApp(
        theme: TAppTheme.lightTheme,
        themeMode: ThemeMode.light,
        home: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BlocProvider<CategoriesCubit>.value(
                value: cubit,
                child: const HomeCategories(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomeCategoryVisual), findsNWidgets(8));
    for (final visual in tester.widgetList<HomeCategoryVisual>(
      find.byType(HomeCategoryVisual),
    )) {
      expect(visual.icon.fontFamily, CategorySymbols.fontFamily);
      expect(visual.imageUrl, isEmpty);
    }
    await tester.tap(find.byKey(const Key('home-all-categories')));
    await tester.pumpAndSettle();
    expect(find.byType(HomeCategoryVisual), findsNWidgets(24));
    await expectLater(
      find.byKey(const Key('all-categories-root')),
      matchesGoldenFile('goldens/w53c_all_categories_24_390.png'),
    );
    for (final root in canonicalRoots()) {
      final card = find.byKey(Key('home-category-${root.id}'));
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      expect(card.hitTestable(), findsOneWidget);
      final visual = find.descendant(
        of: card,
        matching: find.byType(HomeCategoryVisual),
      );
      expect(visual, findsOneWidget);
      expect(tester.getSize(visual), const Size(52, 52));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'W53C canonical and legacy aliases cannot be hidden by image overrides',
    (tester) async {
      final cubit = _CategoryCubit();
      addTearDown(cubit.close);
      whenListen(
        cubit,
        const Stream<CategoriesState>.empty(),
        initialState: const CategoriesLoaded([
          CategoryEntity(
            id: 'a',
            name: 'Gözlük & Optik',
            imageUrl: 'assets/transparent-category.png',
          ),
          CategoryEntity(
            id: 'b',
            name: 'Giyim & Moda',
            imageUrl: 'https://example.invalid/unrelated-category.png',
          ),
          CategoryEntity(
            id: 'c',
            name: 'Market',
            imageUrl: 'assets/icons/categories/groceries.png',
          ),
        ]),
      );
      when(() => cubit.getCategories()).thenAnswer((_) async {});
      await tester.pumpWidget(
        MaterialApp(
          theme: TAppTheme.lightTheme,
          home: Scaffold(
            body: BlocProvider<CategoriesCubit>.value(
              value: cubit,
              child: const HomeCategories(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(CategorySymbols.eyeglasses), findsOneWidget);
      expect(find.byIcon(CategorySymbols.apparel), findsOneWidget);
      expect(find.byIcon(CategorySymbols.grocery), findsOneWidget);
      for (final visual in tester.widgetList<HomeCategoryVisual>(
        find.byType(HomeCategoryVisual),
      )) {
        expect(visual.imageUrl, isEmpty);
      }
      expect(tester.takeException(), isNull);
    },
  );
}
