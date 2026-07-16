import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/recently_viewed_products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/recently_viewed_products_state.dart';
import 'package:t_store/features/shop/presentation/views/recently_viewed_products_view.dart';

class MockRecentlyViewedProductsCubit
    extends MockCubit<RecentlyViewedProductsState>
    implements RecentlyViewedProductsCubit {}

void main() {
  const firstProduct = ProductEntity(
    id: 'p1',
    name: 'Kahve Makinesi',
    price: 1500,
    categoryId: 'category-1',
    stock: 2,
    images: [],
    brandName: 'Örnek Marka',
  );
  const secondProduct = ProductEntity(
    id: 'p2',
    name: 'Çelik Termos',
    price: 499.9,
    categoryId: 'category-1',
    stock: 5,
    images: [],
  );

  late MockRecentlyViewedProductsCubit cubit;

  setUp(() {
    cubit = MockRecentlyViewedProductsCubit();
    when(() => cubit.load(any())).thenAnswer((_) async {});
    when(() => cubit.close()).thenAnswer((_) async {});
  });

  Widget buildSubject({VoidCallback? onExplore}) {
    return MaterialApp(
      home: RecentlyViewedProductsView(
        customerId: 'customer-1',
        recentlyViewedProductsCubit: cubit,
        onExplore: onExplore,
      ),
    );
  }

  testWidgets('ürünleri kayıt sırasıyla ve güncel bilgileriyle gösterir', (
    tester,
  ) async {
    whenListen(
      cubit,
      const Stream<RecentlyViewedProductsState>.empty(),
      initialState: const RecentlyViewedProductsLoaded([
        secondProduct,
        firstProduct,
      ]),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Son Görüntülediklerim'), findsOneWidget);
    expect(find.text('Çelik Termos'), findsOneWidget);
    expect(find.text('Kahve Makinesi'), findsOneWidget);
    expect(find.text('₺499,90'), findsOneWidget);
    expect(find.text('Örnek Marka'), findsOneWidget);
    expect(find.text('Ürünü İncele'), findsNWidgets(2));
    verify(() => cubit.load('customer-1')).called(1);
  });

  testWidgets('boş durumda ürün keşfine yönlendiren eylemi gösterir', (
    tester,
  ) async {
    var didRequestExplore = false;
    whenListen(
      cubit,
      const Stream<RecentlyViewedProductsState>.empty(),
      initialState: const RecentlyViewedProductsLoaded([]),
    );

    await tester.pumpWidget(
      buildSubject(onExplore: () => didRequestExplore = true),
    );
    await tester.pumpAndSettle();

    expect(find.text('Henüz görüntülediğin ürün yok'), findsOneWidget);
    expect(find.text('Ürünleri Keşfet'), findsOneWidget);

    await tester.tap(find.text('Ürünleri Keşfet'));
    await tester.pump();

    expect(didRequestExplore, isTrue);
  });

  testWidgets('geçmişi yalnızca kullanıcı onayından sonra temizler', (
    tester,
  ) async {
    whenListen(
      cubit,
      const Stream<RecentlyViewedProductsState>.empty(),
      initialState: const RecentlyViewedProductsLoaded([firstProduct]),
    );
    when(() => cubit.clear('customer-1')).thenAnswer((_) async => true);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Geçmişi temizle'));
    await tester.pumpAndSettle();

    expect(find.text('Görüntüleme geçmişi silinsin mi?'), findsOneWidget);
    verifyNever(() => cubit.clear(any()));

    await tester.tap(find.text('Tümünü Temizle'));
    await tester.pumpAndSettle();

    verify(() => cubit.clear('customer-1')).called(1);
  });
}
