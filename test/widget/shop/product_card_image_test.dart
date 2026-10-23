import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/listing_hero_media_repository.dart';
import 'package:t_store/features/shop/presentation/helpers/product_card_media_loader.dart';
import 'package:t_store/features/shop/presentation/widgets/product_card_image.dart';

class _Media implements ListingHeroMediaRepository {
  final Future<List<ListingHeroPhoto>> Function(List<ShopProductEntity>) answer;
  _Media(this.answer);
  @override
  Future<List<ListingHeroPhoto>> photos(List<ShopProductEntity> rows) =>
      answer(rows);
}

const fallback = ColoredBox(key: Key('empty-photo'), color: Colors.grey);
ListingHeroPhoto photo(String id, {String? source}) => ListingHeroPhoto(
  listingId: id,
  shopName: 'Shop $id',
  source: source ?? 'https://example.invalid/$id.png',
);
ShopProductEntity listing(String id) => ShopProductEntity(
  id: id,
  shopId: id,
  productId: id,
  price: 990,
  shop: ShopEntity(id: id, name: 'Shop $id'),
);
Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: SizedBox(width: 120, height: 100, child: child)),
);

void main() {
  testWidgets('old product response cannot repaint a reused card', (t) async {
    final a = Completer<List<ListingHeroPhoto>>(),
        b = Completer<List<ListingHeroPhoto>>();
    final loader = ProductCardMediaLoader(
      media: _Media((rows) => rows.single.id == 'a' ? a.future : b.future),
    );
    Widget card(String id) => host(
      ProductCardImage(
        productId: id,
        listings: [listing(id)],
        loader: loader,
        fallback: fallback,
      ),
    );
    await t.pumpWidget(card('a'));
    await t.pump();
    await t.pumpWidget(card('b'));
    await t.pump();
    b.complete([photo('b')]);
    await t.pumpAndSettle();
    a.complete([photo('a')]);
    await t.pumpAndSettle();
    expect(
      t.widget<CachedNetworkImage>(find.byType(CachedNetworkImage)).imageUrl,
      endsWith('/b.png'),
    );
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'refresh clears prior photo while waiting, then removes retired media',
    (t) async {
      final next = Completer<List<ListingHeroPhoto>>();
      var calls = 0;
      final loader = ProductCardMediaLoader(
        media: _Media((_) async => ++calls == 1 ? [photo('a')] : next.future),
      );
      Widget card(int revision) => host(
        ProductCardImage(
          productId: 'a',
          listings: [listing('a')],
          refreshKey: revision,
          loader: loader,
          fallback: fallback,
        ),
      );
      await t.pumpWidget(card(1));
      await t.pumpAndSettle();
      expect(find.byType(CachedNetworkImage), findsOneWidget);
      await t.pumpWidget(card(2));
      await t.pump();
      expect(find.byType(CachedNetworkImage), findsNothing);
      next.complete([]);
      await t.pumpAndSettle();
      expect(find.byKey(const Key('empty-photo')), findsOneWidget);
    },
  );
  testWidgets(
    'failed primary advances same-listing photos then next seller then placeholder',
    (t) async {
      final loader = ProductCardMediaLoader(
        media: _Media(
          (_) async => [
            photo('a', source: 'https://example.invalid/primary.png'),
            photo('a', source: 'https://example.invalid/secondary.png'),
            photo('b'),
          ],
        ),
      );
      final other = listing('b').copyWith(productId: 'a');
      await t.pumpWidget(
        host(
          ProductCardImage(
            productId: 'a',
            listings: [listing('a'), other],
            loader: loader,
            fallback: fallback,
          ),
        ),
      );
      await t.pumpAndSettle();
      for (final expected in ['primary.png', 'secondary.png', 'b.png']) {
        final f = find.byType(CachedNetworkImage);
        final w = t.widget<CachedNetworkImage>(f);
        expect(w.imageUrl, endsWith(expected));
        final next = w.errorWidget!(
          t.element(f),
          w.imageUrl,
          StateError('decode failed'),
        );
        await t.pumpWidget(host(next));
        await t.pump();
      }
      expect(find.byKey(const Key('empty-photo')), findsOneWidget);
    },
  );
  testWidgets('late result after disposal has no UI side effect', (t) async {
    final result = Completer<List<ListingHeroPhoto>>();
    final loader = ProductCardMediaLoader(media: _Media((_) => result.future));
    await t.pumpWidget(
      host(
        ProductCardImage(
          productId: 'a',
          listings: [listing('a')],
          loader: loader,
          fallback: fallback,
        ),
      ),
    );
    await t.pump();
    await t.pumpWidget(host(const Text('closed')));
    result.complete([photo('a')]);
    await t.pumpAndSettle();
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'timeout ends in placeholder and does not adopt eventual response',
    (t) async {
      final result = Completer<List<ListingHeroPhoto>>();
      final loader = ProductCardMediaLoader(
        media: _Media((_) => result.future),
      );
      await t.pumpWidget(
        host(
          ProductCardImage(
            productId: 'a',
            listings: [listing('a')],
            loader: loader,
            fallback: fallback,
          ),
        ),
      );
      await t.pump();
      await t.pump(const Duration(seconds: 16));
      await t.pump();
      result.complete([photo('a')]);
      await t.pumpAndSettle();
      expect(find.byKey(const Key('empty-photo')), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    },
  );
  testWidgets(
    'multiple cards share one media lookup and retain accessible photo source',
    (t) async {
      var calls = 0;
      final loader = ProductCardMediaLoader(
        media: _Media((rows) async {
          calls++;
          return [
            for (final row in rows)
              photo(row.id, source: 'assets/images/products/product-shirt.png'),
          ];
        }),
        loadListings: (ids) async => Right([for (final id in ids) listing(id)]),
      );
      final semantics = t.ensureSemantics();
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepaintBoundary(
              key: const Key('card-photo-proof'),
              child: SizedBox(
                width: 200,
                height: 100,
                child: Row(
                  children: [
                    for (final id in ['a', 'b'])
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: ProductCardImage(
                          productId: id,
                          loader: loader,
                          fallback: fallback,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(calls, 1);
      await t.runAsync(
        () => precacheImage(
          const AssetImage('assets/images/products/product-shirt.png'),
          t.element(find.byType(Scaffold)),
        ),
      );
      await t.pumpAndSettle();
      expect(find.bySemanticsLabel('Ürün fotoğrafı: Shop a'), findsOneWidget);
      expect(find.bySemanticsLabel('Ürün fotoğrafı: Shop b'), findsOneWidget);
      await expectLater(
        find.byKey(const Key('card-photo-proof')),
        matchesGoldenFile('goldens/product_card_published_photos.png'),
      );
      semantics.dispose();
    },
  );
}
