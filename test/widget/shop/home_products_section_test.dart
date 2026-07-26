import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';
import 'package:t_store/features/shop/presentation/widgets/home_products_section.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class MockHomeProductsCubit extends MockCubit<ProductsState>
    implements ProductsCubit {}

class MockHomeWishlistCubit extends MockCubit<WishlistState>
    implements WishlistCubit {}

void main() {
  late MockHomeProductsCubit productsCubit;
  late MockHomeWishlistCubit wishlistCubit;

  setUp(() {
    productsCubit = MockHomeProductsCubit();
    wishlistCubit = MockHomeWishlistCubit();
    when(
      () => productsCubit.getProducts(
        isFeatured: any(named: 'isFeatured'),
        sortBy: any(named: 'sortBy'),
        ascending: any(named: 'ascending'),
        refresh: any(named: 'refresh'),
      ),
    ).thenAnswer((_) async {});
    when(() => wishlistCubit.isInWishlist(any())).thenReturn(false);
    whenListen(
      wishlistCubit,
      const Stream<WishlistState>.empty(),
      initialState: WishlistLoaded(const []),
    );
  });

  Widget buildSubject(ProductsState state) {
    whenListen(
      productsCubit,
      const Stream<ProductsState>.empty(),
      initialState: state,
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductsCubit>.value(value: productsCubit),
        BlocProvider<WishlistCubit>.value(value: wishlistCubit),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: HomeProductsSection(
            currentUserIdProvider: () => null,
            destinationBuilder: (product) =>
                Scaffold(key: Key('product-detail-${product.id}')),
          ),
        ),
      ),
    );
  }

  testWidgets('yükleme durumunda sahte ürün göstermez', (tester) async {
    await tester.pumpWidget(buildSubject(ProductsLoading()));

    expect(find.byKey(const Key('home-products-loading')), findsOneWidget);
    expect(find.byKey(const Key('home-products-loaded')), findsNothing);
  });

  testWidgets('boş durumu açıkça gösterir', (tester) async {
    await tester.pumpWidget(buildSubject(const ProductsLoaded(products: [])));

    expect(find.byKey(const Key('home-products-empty')), findsOneWidget);
    expect(find.text('Şu anda gösterilecek ürün bulunamadı'), findsOneWidget);
  });

  testWidgets('hata durumunda gerçek sorguyu yeniden dener', (tester) async {
    await tester.pumpWidget(
      buildSubject(const ProductsError('Teknik ayrıntı')),
    );

    expect(find.byKey(const Key('home-products-error')), findsOneWidget);
    expect(find.text('Teknik ayrıntı'), findsNothing);

    await tester.tap(find.text('Tekrar Dene'));
    await tester.pump();

    verify(
      () => productsCubit.getProducts(
        isFeatured: true,
        sortBy: 'rating',
        ascending: false,
        refresh: true,
      ),
    ).called(1);
  });

  testWidgets('gerçek ürün bilgisini gösterip ürün detayını açar', (
    tester,
  ) async {
    const product = ProductEntity(
      id: 'product-1',
      name: 'Taze Domates',
      price: 29.90,
      salePrice: 24.90,
      categoryId: 'market',
      stock: 12,
      images: [],
      brandName: 'Nihat Manav',
    );

    await tester.pumpWidget(
      buildSubject(const ProductsLoaded(products: [product])),
    );

    expect(find.byKey(const Key('home-products-loaded')), findsOneWidget);
    expect(find.byKey(const Key('home-product-product-1')), findsOneWidget);
    expect(find.text('Taze Domates'), findsOneWidget);
    expect(find.text('Nihat Manav'), findsOneWidget);
    expect(find.text('24,90 TL'), findsOneWidget);
    expect(find.text('%17 indirim'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-product-product-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('product-detail-product-1')), findsOneWidget);
  });
}
