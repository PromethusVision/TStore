import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/widgets/product_image_slider.dart';
import 'package:t_store/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MockWishlistCubit extends MockCubit<WishlistState>
    implements WishlistCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

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
  late MockAuthCubit authCubit;
  late StreamController<WishlistState> stateController;
  late bool isFavorite;

  setUp(() async {
    await sl.reset();

    wishlistCubit = MockWishlistCubit();
    authCubit = MockAuthCubit();
    stateController = StreamController<WishlistState>.broadcast();
    isFavorite = false;

    when(() => wishlistCubit.getWishlist()).thenAnswer((_) async {});
    when(() => wishlistCubit.toggleWishlist(any())).thenAnswer((_) async {});
    when(() => wishlistCubit.isInWishlist(any())).thenAnswer((_) => isFavorite);

    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    when(() => authCubit.close()).thenAnswer((_) async {});
    sl.registerFactory<AuthCubit>(() => authCubit);
  });

  tearDown(() async {
    await stateController.close();
    await sl.reset();
  });

  Widget buildSubject({
    required WishlistState initialState,
    String? currentUserId = 'customer-1',
  }) {
    whenListen(
      wishlistCubit,
      stateController.stream,
      initialState: initialState,
    );

    return BlocProvider<WishlistCubit>.value(
      value: wishlistCubit,
      child: MaterialApp(
        home: Scaffold(
          body: ProductImageSlider(
            product: product,
            currentUserIdProvider: () => currentUserId,
          ),
        ),
      ),
    );
  }

  testWidgets('favoride olmayan ürün için boş kalp gösterip ürünü ekler', (
    tester,
  ) async {
    when(() => wishlistCubit.toggleWishlist(product.id)).thenAnswer((_) async {
      isFavorite = true;
      stateController.add(WishlistLoaded(const [wishlistItem]));
      await Future<void>.delayed(Duration.zero);
    });

    await tester.pumpWidget(
      buildSubject(initialState: WishlistLoaded(const [])),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Iconsax.heart), findsOneWidget);
    expect(find.byTooltip('Favorilere ekle'), findsOneWidget);

    await tester.tap(find.byKey(const Key('product-details-favorite-action')));
    await tester.pumpAndSettle();

    verify(() => wishlistCubit.toggleWishlist(product.id)).called(1);
    expect(find.byIcon(Iconsax.heart5), findsOneWidget);
    expect(find.text('Ürün favorilere eklendi.'), findsOneWidget);
  });

  testWidgets('favorideki ürün için dolu kalp gösterip ürünü çıkarır', (
    tester,
  ) async {
    isFavorite = true;
    when(() => wishlistCubit.toggleWishlist(product.id)).thenAnswer((_) async {
      isFavorite = false;
      stateController.add(WishlistLoaded(const []));
      await Future<void>.delayed(Duration.zero);
    });

    await tester.pumpWidget(
      buildSubject(initialState: WishlistLoaded(const [wishlistItem])),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Iconsax.heart5), findsOneWidget);
    expect(find.byTooltip('Favorilerden çıkar'), findsOneWidget);

    await tester.tap(find.byKey(const Key('product-details-favorite-action')));
    await tester.pumpAndSettle();

    verify(() => wishlistCubit.toggleWishlist(product.id)).called(1);
    expect(find.byIcon(Iconsax.heart), findsOneWidget);
    expect(find.text('Ürün favorilerden çıkarıldı.'), findsOneWidget);
  });

  testWidgets('favori durumu hazır değilken yükler ve işlemi bekletir', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(initialState: WishlistInitial()));
    await tester.pump();

    verify(() => wishlistCubit.getWishlist()).called(1);
    expect(
      find.byKey(const Key('product-details-favorite-loading')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('product-details-favorite-action')),
      findsNothing,
    );
  });

  testWidgets('art arda dokunmada yalnızca bir favori işlemi başlatır', (
    tester,
  ) async {
    final operation = Completer<void>();
    when(
      () => wishlistCubit.toggleWishlist(product.id),
    ).thenAnswer((_) => operation.future);

    await tester.pumpWidget(
      buildSubject(initialState: WishlistLoaded(const [])),
    );
    await tester.pumpAndSettle();

    final action = find.byKey(const Key('product-details-favorite-action'));
    await tester.tap(action);
    await tester.tap(action);
    await tester.pump();

    verify(() => wishlistCubit.toggleWishlist(product.id)).called(1);
    expect(
      find.byKey(const Key('product-details-favorite-loading')),
      findsOneWidget,
    );

    operation.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('teknik hata ayrıntısını göstermeden güvenli mesaj verir', (
    tester,
  ) async {
    when(() => wishlistCubit.toggleWishlist(product.id)).thenAnswer((_) async {
      stateController.add(
        const WishlistError('PostgrestException: gizli teknik ayrıntı'),
      );
      await Future<void>.delayed(Duration.zero);
    });

    await tester.pumpWidget(
      buildSubject(initialState: WishlistLoaded(const [])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('product-details-favorite-action')));
    await tester.pumpAndSettle();

    expect(
      find.text('Favoriler şu anda güncellenemedi. Lütfen tekrar deneyin.'),
      findsOneWidget,
    );
    expect(find.textContaining('PostgrestException'), findsNothing);
  });

  testWidgets('giriş yapmayan müşteriyi giriş ekranına yönlendirir', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(initialState: WishlistLoaded(const []), currentUserId: null),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('product-details-favorite-action')));
    await tester.pumpAndSettle();

    verifyNever(() => wishlistCubit.toggleWishlist(any()));
    verifyNever(() => wishlistCubit.getWishlist());
    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('önceki yükleme hatasında yalnızca favori durumunu yeniler', (
    tester,
  ) async {
    when(() => wishlistCubit.getWishlist()).thenAnswer((_) async {
      stateController.add(WishlistLoaded(const []));
      await Future<void>.delayed(Duration.zero);
    });

    await tester.pumpWidget(
      buildSubject(
        initialState: const WishlistError('PostgrestException: gizli ayrıntı'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('product-details-favorite-action')));
    await tester.pumpAndSettle();

    verify(() => wishlistCubit.getWishlist()).called(1);
    verifyNever(() => wishlistCubit.toggleWishlist(any()));
    expect(
      find.text('Favori durumu yenilendi. Kalbe tekrar dokunabilirsin.'),
      findsOneWidget,
    );
  });
}
