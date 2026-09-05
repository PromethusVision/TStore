import 'package:cached_network_image/cached_network_image.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/widgets/other_same_products_list.dart';
import 'package:t_store/features/shop/presentation/widgets/product_image_fallback.dart';
import 'package:t_store/features/shop/presentation/widgets/product_image_slider.dart';
import 'package:t_store/features/shop/presentation/widgets/selected_product_image.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

import '../w48/w48_fixture.dart' show w48Fonts, w48Viewport;

ProductEntity product({List<String> images = const [], String? thumbnail}) =>
    ProductEntity(
      id: 'w50-image-product',
      name: 'Fotoğrafı henüz eklenmemiş ürün',
      price: 10,
      categoryId: 'w50-category',
      stock: 1,
      images: images,
      thumbnail: thumbnail,
    );

class _Wishlist extends MockCubit<WishlistState> implements WishlistCubit {}

Widget host(Widget child) {
  final wishlist = _Wishlist();
  whenListen(
    wishlist,
    const Stream<WishlistState>.empty(),
    initialState: WishlistLoaded(const []),
  );
  when(() => wishlist.isInWishlist(any())).thenReturn(false);
  addTearDown(wishlist.close);
  return BlocProvider<WishlistCubit>.value(
    value: wishlist,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: EsnaftaVarTheme.light,
      home: Scaffold(
        body: RepaintBoundary(key: const Key('w50-media-proof'), child: child),
      ),
    ),
  );
}

void main() {
  setUpAll(w48Fonts);

  for (final width in [320.0, 390.0]) {
    testWidgets('real default media with no photo at ${width.toInt()}px', (
      tester,
    ) async {
      w48Viewport(tester, width);
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          host(
            ProductImageSlider(
              product: product(),
              currentUserIdProvider: () => null,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ProductImageFallback), findsOneWidget);
        expect(find.byType(Image), findsNothing);
        expect(find.byType(CachedNetworkImage), findsNothing);
        expect(find.byType(OtherSameProductsList), findsNothing);
        expect(
          find.bySemanticsLabel('Ürün görseli bulunmuyor'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byKey(const Key('w50-media-proof')),
          matchesGoldenFile('goldens/w50_missing_media_${width.toInt()}.png'),
        );
      } finally {
        semantics.dispose();
      }
    });
  }

  for (final alternate in [false, true]) {
    testWidgets(
      'blank-only photo values cannot introduce sample data ($alternate)',
      (tester) async {
        await tester.pumpWidget(
          host(
            ProductImageSlider(
              product: product(images: [' ', '\t'], thumbnail: ' '),
              currentUserIdProvider: () => null,
              visualPrototype: alternate,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ProductImageFallback), findsOneWidget);
        expect(find.byType(Image), findsNothing);
        expect(find.byType(CachedNetworkImage), findsNothing);
        expect(find.textContaining('görsel'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('a real product thumbnail remains the supplied photo', (
    tester,
  ) async {
    const thumbnail = 'assets/images/products/product-shirt.png';
    await tester.pumpWidget(
      host(
        ProductImageSlider(
          product: product(thumbnail: thumbnail),
          currentUserIdProvider: () => null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SelectedProductImage>(find.byType(SelectedProductImage))
          .image,
      thumbnail,
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(ProductImageFallback), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty thumbnail strip stays empty instead of inventing photos', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const Stack(
          children: [
            OtherSameProductsList(images: [' ', '']),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsNothing);
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byType(ListView), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
