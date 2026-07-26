import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/shop/presentation/widgets/home_search_bar.dart';

void main() {
  testWidgets('gerçek arama eylemini tek dokunuşla çağırır', (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HomeSearchBar(onTap: () => tapCount++)),
      ),
    );

    expect(find.text('Ürün, kategori veya mağaza ara'), findsOneWidget);
    await tester.tap(find.byKey(const Key('home-search-bar')));
    await tester.pump();

    expect(tapCount, 1);
  });
}
