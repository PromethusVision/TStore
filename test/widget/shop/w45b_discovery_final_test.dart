import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_state.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';

import 'w45b_discovery_fixture.dart';

void main() {
  setUpAll(loadDiscoveryFonts);
  setUp(() async => sl.reset());
  tearDown(() async => sl.reset());

  const scenarios = [
    'catalog',
    'catalogLoading',
    'catalogEmpty',
    'catalogError',
    'catalogPageLoading',
    'catalogPageError',
    'catalogQuery',
    'searchInitial',
    'searchLoading',
    'searchResults',
    'searchEmpty',
    'searchError',
    'searchPartial',
    'searchPartialEmpty',
  ];
  for (final width in [320.0, 390.0, 430.0]) {
    for (final scale in [1.0, 1.3]) {
      for (final scenario in scenarios) {
        testWidgets('$scenario ${width.toInt()} at $scale text', (
          tester,
        ) async {
          discoveryViewport(tester, width);
          final searchMode = scenario.startsWith('search');
          final productsState = switch (scenario) {
            'catalogLoading' => ProductsLoading(),
            'catalogEmpty' => const ProductsLoaded(
              products: [],
              hasReachedMax: true,
              currentPage: 1,
            ),
            'catalogError' => const ProductsError('Offline fixture'),
            'catalogPageLoading' => DiscoveryFixture.loadedCatalog().copyWith(
              isLoadingMore: true,
            ),
            'catalogPageError' => DiscoveryFixture.loadedCatalog().copyWith(
              loadMoreError: 'Offline fixture',
            ),
            'catalogQuery' => const ProductsSearchResult(
              products: [discoveryProduct],
              query: discoveryQuery,
            ),
            _ => DiscoveryFixture.loadedCatalog(longContent: scale > 1),
          };
          final searchState = switch (scenario) {
            'searchLoading' => const CustomerSearchLoading(discoveryQuery),
            'searchEmpty' => discoveryResults(empty: true),
            'searchError' => const CustomerSearchError(
              'Arama tamamlanamadı. Lütfen tekrar deneyin.',
            ),
            'searchPartial' => discoveryResults(partial: true),
            'searchPartialEmpty' => discoveryResults(
              partial: true,
              empty: true,
            ),
            _ => discoveryResults(longContent: scale > 1),
          };
          final fixture = DiscoveryFixture(
            productsState: productsState,
            searchState: searchState,
            history: scenario == 'searchInitial'
                ? List.generate(8, (index) => '$discoveryLongText $index')
                : [],
          );
          final query =
              searchMode && scenario != 'searchInitial' ||
                  scenario == 'catalogQuery'
              ? discoveryQuery
              : '';
          await tester.pumpWidget(
            fixture.app(
              child: fixture.view(searchMode: searchMode, query: query),
              scale: scale,
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);
          expect(find.byType(PopupMenuButton), findsNothing);

          if (width == 390 && scale == 1 ||
              width == 320 &&
                  scale == 1.3 &&
                  [
                    'catalog',
                    'searchResults',
                    'searchInitial',
                  ].contains(scenario)) {
            await expectLater(
              find.byKey(const Key('w45b-evidence')),
              matchesGoldenFile(
                'goldens/w45b_${scenario}_${width.toInt()}_${(scale * 100).round()}.png',
              ),
            );
          }

          // Build all lazily rendered result sections/rows and page footers.
          final scrollables = find.byType(Scrollable);
          if (scrollables.evaluate().isNotEmpty) {
            await tester.drag(scrollables.last, const Offset(0, -650));
            await tester.pump(const Duration(milliseconds: 300));
            expect(tester.takeException(), isNull);
          }
          if (scenario == 'searchPartialEmpty') {
            expect(find.text('Sonuçlar tam yüklenemedi'), findsOneWidget);
            expect(find.textContaining('için sonuç bulamadık'), findsNothing);
          }

          // The keyboard must leave long states/history scrollable and input usable.
          await tester.pumpWidget(
            fixture.app(
              child: fixture.view(searchMode: searchMode, query: query),
              scale: scale,
              keyboard: 320,
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
          expect(find.byType(TextFormField), findsOneWidget);
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }

  for (final searchMode in [false, true]) {
    testWidgets('favorite remains independent in search=$searchMode', (
      tester,
    ) async {
      discoveryViewport(tester, 390);
      final fixture = DiscoveryFixture(
        searchState: const CustomerSearchLoaded(
          query: discoveryQuery,
          products: [discoveryProduct],
          categories: [],
          shops: [],
        ),
      );
      await tester.pumpWidget(
        fixture.app(
          child: fixture.view(
            searchMode: searchMode,
            query: searchMode ? discoveryQuery : '',
            signedIn: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final favorite = find.byKey(
        const Key('all-products-favorite-w45b-product-action'),
      );
      expect(tester.getSize(favorite).shortestSide, greaterThanOrEqualTo(44));
      await tester.tap(favorite);
      await tester.pumpAndSettle();
      verify(
        () => fixture.wishlist.toggleWishlist(discoveryProduct.id),
      ).called(1);
      expect(fixture.openedProducts, isEmpty);
      expect(find.text('245,50 TL’den'), findsWidgets);
      expect(find.textContaining('987654'), findsNothing);
      expect(find.text('1,00 TL’den'), findsNothing);
    });
  }

  testWidgets('keyboard submit trims query and clear reloads the catalog', (
    tester,
  ) async {
    final fixture = DiscoveryFixture();
    await tester.pumpWidget(fixture.app(child: fixture.view(searchMode: true)));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), '  kahve  ');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    verify(() => fixture.search.search('kahve')).called(1);
    await tester.tap(find.byTooltip('Aramayı temizle'));
    await tester.pump();
    verify(() => fixture.search.reset()).called(1);
    verify(() => fixture.products.getProducts(refresh: true)).called(2);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('search error retry retains the exact query', (tester) async {
    final fixture = DiscoveryFixture(
      searchState: const CustomerSearchError('Bağlantı hatası'),
    );
    await tester.pumpWidget(
      fixture.app(
        child: fixture.view(searchMode: true, query: discoveryLongText),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EsnaftaVarStateCard), findsOneWidget);
    await tester.tap(find.text('Tekrar Dene'));
    await tester.pump();
    verify(() => fixture.search.search(discoveryLongText)).called(2);
  });

  testWidgets('full history leaves catalog reachable and removal independent', (
    tester,
  ) async {
    discoveryViewport(tester, 320);
    final fixture = DiscoveryFixture(
      history: List.generate(8, (i) => '$discoveryLongText $i'),
    );
    await tester.pumpWidget(
      fixture.app(
        child: fixture.view(searchMode: true),
        scale: 1.3,
        keyboard: 320,
      ),
    );
    await tester.pump();
    final remove = find.byTooltip('$discoveryLongText 0 aramasını sil');
    expect(tester.getSize(remove).shortestSide, greaterThanOrEqualTo(44));
    await tester.tap(remove);
    await tester.pump();
    expect(fixture.history.queries.length, 7);
    verifyNever(() => fixture.search.search(any()));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1800));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('all-products-product-w45b-product')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home submit to search to product and back preserves context', (
    tester,
  ) async {
    discoveryViewport(tester, 390);
    final fixture = DiscoveryFixture(
      searchState: const CustomerSearchLoaded(
        query: discoveryQuery,
        products: [discoveryProduct],
        categories: [],
        shops: [],
      ),
    );
    await tester.pumpWidget(
      fixture.app(
        child: Builder(
          builder: (context) => fixture.inlineSearch(
            onQuerySubmitted: (query) => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => fixture.view(searchMode: true, query: query),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), discoveryQuery);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('customer-search-results')), findsOneWidget);
    verify(() => fixture.search.search(discoveryQuery)).called(1);
    await tester.tap(
      find.byKey(const Key('all-products-product-link-w45b-product')),
    );
    await tester.pumpAndSettle();
    expect(fixture.openedProducts, [discoveryProduct]);
    expect(find.text('Product destination'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, discoveryQuery), findsOneWidget);
    await tester.tap(find.byKey(const Key('all-products-back-button')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, discoveryQuery), findsOneWidget);
    expect(find.byKey(const Key('all-products-back-button')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final searchMode in [false, true]) {
    testWidgets(
      'labeled 44px accessible discovery controls search=$searchMode',
      (tester) async {
        discoveryViewport(tester, 320);
        final semantics = tester.ensureSemantics();
        final fixture = DiscoveryFixture();
        await tester.pumpWidget(
          fixture.app(
            child: fixture.view(
              searchMode: searchMode,
              query: searchMode ? discoveryQuery : '',
            ),
            scale: 1.3,
          ),
        );
        await tester.pumpAndSettle();
        try {
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        } finally {
          semantics.dispose();
        }
      },
    );
  }
}
