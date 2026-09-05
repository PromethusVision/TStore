import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_state.dart';

import 'w45b_discovery_fixture.dart';

void main() {
  setUpAll(loadDiscoveryFonts);
  setUp(() async => sl.reset());
  tearDown(() async => sl.reset());

  for (final width in [320.0, 390.0, 430.0]) {
    for (final scale in [1.0, 1.3]) {
      for (final scenario in [
        'history',
        'loaded',
        'loading',
        'empty',
        'error',
        'partial',
        'partialEmpty',
      ]) {
        testWidgets('inline $scenario ${width.toInt()} at $scale text', (
          tester,
        ) async {
          discoveryViewport(tester, width);
          final state = switch (scenario) {
            'loading' => const CustomerSearchLoading(discoveryQuery),
            'empty' => discoveryResults(empty: true),
            'error' => const CustomerSearchError('Offline fixture'),
            'partial' => discoveryResults(
              partial: true,
              longContent: scale > 1,
            ),
            'partialEmpty' => discoveryResults(partial: true, empty: true),
            _ => discoveryResults(longContent: scale > 1),
          };
          final fixture = DiscoveryFixture(
            searchState: state,
            history: List.generate(8, (i) => '$discoveryLongText $i'),
          );
          await tester.pumpWidget(
            fixture.app(child: fixture.inlineSearch(), scale: scale),
          );
          final field = find.byType(TextField);
          await tester.tap(field);
          if (scenario != 'history') {
            await tester.enterText(field, discoveryQuery);
          }
          await tester.pump(const Duration(milliseconds: 350));
          await tester.pump(const Duration(milliseconds: 200));
          expect(tester.takeException(), isNull);

          if (scenario == 'history') {
            final remove = find.byKey(
              const ValueKey('remove-home-recent-search-0'),
            );
            expect(
              tester.getSize(remove).shortestSide,
              greaterThanOrEqualTo(44),
            );
          } else if (scenario == 'partial') {
            expect(
              find.byKey(const Key('home-search-suggestions-warning')),
              findsOneWidget,
            );
          } else if (scenario == 'partialEmpty') {
            expect(find.text('Öneriler tam yüklenemedi.'), findsOneWidget);
            expect(
              find.text('Bu aramayla eşleşen öneri bulunamadı.'),
              findsNothing,
            );
          }
          if (width == 390 && scale == 1 ||
              width == 320 &&
                  scale == 1.3 &&
                  ['history', 'loaded', 'error'].contains(scenario)) {
            await expectLater(
              find.byKey(const Key('w45b-evidence')),
              matchesGoldenFile(
                'goldens/w45b_inline_${scenario}_${width.toInt()}_${(scale * 100).round()}.png',
              ),
            );
          }

          final list = find.byKey(const Key('home-search-suggestions-list'));
          if (list.evaluate().isNotEmpty) {
            await tester.drag(list, const Offset(0, -600));
            await tester.pump(const Duration(milliseconds: 300));
            expect(tester.takeException(), isNull);
          }
          await tester.pumpWidget(
            fixture.app(
              child: fixture.inlineSearch(),
              scale: scale,
              keyboard: 320,
            ),
          );
          await tester.pump(const Duration(milliseconds: 200));
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }

  testWidgets('long view-all query submits exact text at narrow large text', (
    tester,
  ) async {
    discoveryViewport(tester, 320);
    final fixture = DiscoveryFixture(
      searchState: const CustomerSearchLoaded(
        query: discoveryLongText,
        products: [discoveryProduct],
        categories: [],
        shops: [],
      ),
    );
    await tester.pumpWidget(
      fixture.app(child: fixture.inlineSearch(), scale: 1.3),
    );
    await tester.enterText(find.byType(TextField), discoveryLongText);
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('view-all-home-search-results')),
    );
    await tester.tap(find.byKey(const Key('view-all-home-search-results')));
    await tester.pump();
    expect(fixture.submittedQueries, [discoveryLongText]);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'inline retry preserves query and recent removal does not submit',
    (tester) async {
      final fixture = DiscoveryFixture(
        searchState: const CustomerSearchError('Offline fixture'),
        history: ['kahve'],
      );
      await tester.pumpWidget(fixture.app(child: fixture.inlineSearch()));
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('remove-home-recent-search-0')),
      );
      await tester.pumpAndSettle();
      expect(fixture.history.queries, isEmpty);
      expect(fixture.submittedQueries, isEmpty);
      await tester.enterText(find.byType(TextField), discoveryQuery);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tekrar Dene'));
      await tester.pump();
      verify(() => fixture.search.search(discoveryQuery)).called(2);
    },
  );
}
