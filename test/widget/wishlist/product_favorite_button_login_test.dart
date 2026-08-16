import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/utils/constants/iconsax_compat.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';
import 'package:t_store/features/wishlist/presentation/widgets/product_favorite_button.dart';

class MockWishlistCubit extends MockCubit<WishlistState>
    implements WishlistCubit {}

void main() {
  const product = ProductEntity(
    id: 'product-1',
    name: 'Mahalle Kahvesi',
    price: 125,
    categoryId: 'category-1',
    stock: 5,
    images: [],
  );
  const wishlistItem = WishlistItemEntity(
    id: 'wishlist-1',
    userId: 'customer-1',
    productId: 'product-1',
    product: product,
  );

  late MockWishlistCubit wishlistCubit;
  late StreamController<WishlistState> stateController;
  late String? currentUserId;
  late bool isFavorite;

  setUp(() {
    wishlistCubit = MockWishlistCubit();
    stateController = StreamController<WishlistState>.broadcast();
    currentUserId = null;
    isFavorite = false;

    whenListen(
      wishlistCubit,
      stateController.stream,
      initialState: WishlistLoaded(const []),
    );
    when(
      () => wishlistCubit.isInWishlist(product.id),
    ).thenAnswer((_) => isFavorite);
    when(() => wishlistCubit.getWishlist()).thenAnswer((_) async {
      stateController.add(
        WishlistLoaded(isFavorite ? const [wishlistItem] : const []),
      );
      await Future<void>.delayed(Duration.zero);
    });
    when(() => wishlistCubit.toggleWishlist(product.id)).thenAnswer((_) async {
      isFavorite = true;
      stateController.add(WishlistLoaded(const [wishlistItem]));
      await Future<void>.delayed(Duration.zero);
    });
  });

  tearDown(() async {
    await stateController.close();
  });

  Widget buildSubject({
    required ProductFavoriteSignInRequester signInRequester,
  }) {
    return BlocProvider<WishlistCubit>.value(
      value: wishlistCubit,
      child: MaterialApp(
        home: Scaffold(
          body: ProductFavoriteButton(
            productId: product.id,
            keyPrefix: 'login-favorite',
            currentUserIdProvider: () => currentUserId,
            signInRequester: signInRequester,
          ),
        ),
      ),
    );
  }

  testWidgets('başarılı girişten sonra bekleyen ürünü favorilere ekler', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        signInRequester: (_) async {
          currentUserId = 'customer-1';
          return true;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('login-favorite-action')));
    await tester.pumpAndSettle();

    verify(() => wishlistCubit.getWishlist()).called(1);
    verify(() => wishlistCubit.toggleWishlist(product.id)).called(1);
    expect(find.byIcon(Iconsax.heart5), findsOneWidget);
    expect(find.text('Ürün favorilere eklendi.'), findsOneWidget);
  });

  testWidgets('girişten vazgeçilirse favori durumunu değiştirmez', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(signInRequester: (_) async => false));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('login-favorite-action')));
    await tester.pumpAndSettle();

    verifyNever(() => wishlistCubit.getWishlist());
    verifyNever(() => wishlistCubit.toggleWishlist(any()));
    expect(find.byIcon(Iconsax.heart), findsOneWidget);
  });

  testWidgets('giriş sonrası zaten favoride olan ürünü yanlışlıkla çıkarmaz', (
    tester,
  ) async {
    when(() => wishlistCubit.getWishlist()).thenAnswer((_) async {
      isFavorite = true;
      stateController.add(WishlistLoaded(const [wishlistItem]));
      await Future<void>.delayed(Duration.zero);
    });

    await tester.pumpWidget(
      buildSubject(
        signInRequester: (_) async {
          currentUserId = 'customer-1';
          return true;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('login-favorite-action')));
    await tester.pumpAndSettle();

    verify(() => wishlistCubit.getWishlist()).called(1);
    verifyNever(() => wishlistCubit.toggleWishlist(any()));
    expect(find.byIcon(Iconsax.heart5), findsOneWidget);
    expect(find.text('Ürün zaten favorilerinde.'), findsOneWidget);
  });

  testWidgets('giriş beklerken art arda dokunma ikinci isteği başlatmaz', (
    tester,
  ) async {
    final signInResult = Completer<bool?>();
    var signInRequestCount = 0;

    await tester.pumpWidget(
      buildSubject(
        signInRequester: (_) {
          signInRequestCount++;
          return signInResult.future;
        },
      ),
    );
    await tester.pumpAndSettle();

    final action = find.byKey(const Key('login-favorite-action'));
    await tester.tap(action);
    await tester.tap(action);
    await tester.pump();

    expect(signInRequestCount, 1);
    expect(find.byKey(const Key('login-favorite-loading')), findsOneWidget);

    signInResult.complete(false);
    await tester.pumpAndSettle();

    verifyNever(() => wishlistCubit.getWishlist());
    verifyNever(() => wishlistCubit.toggleWishlist(any()));
    expect(find.byKey(const Key('login-favorite-action')), findsOneWidget);
  });
}
