import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/common/widgets/customer_bottom_navigation.dart';
import 'package:t_store/features/cart/domain/entities/cart_item_v2_entity.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';

class MockCartV2Cubit extends MockCubit<CartV2State> implements CartV2Cubit {}

void main() {
  late MockCartV2Cubit cartCubit;

  setUp(() {
    cartCubit = MockCartV2Cubit();
  });

  Widget buildSubject({
    required CartV2State cartState,
    required ValueChanged<int> onSelected,
    int selectedIndex = 0,
    int unreadMessageCount = 0,
    bool visualPrototype = false,
    double textScale = 1,
  }) {
    whenListen(
      cartCubit,
      const Stream<CartV2State>.empty(),
      initialState: cartState,
    );

    return BlocProvider<CartV2Cubit>.value(
      value: cartCubit,
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(
            bottomNavigationBar: CustomerBottomNavigation(
              selectedIndex: selectedIndex,
              onSelected: onSelected,
              unreadMessageCount: unreadMessageCount,
              visualPrototype: visualPrototype,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('mobil genişlikte beş müşteri hedefini taşmadan gösterir', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildSubject(cartState: const CartV2Loaded([]), onSelected: (_) {}),
    );

    expect(find.text('Ana Sayfa'), findsOneWidget);
    expect(find.text('Yakındakiler'), findsOneWidget);
    expect(find.text('Sepet'), findsOneWidget);
    expect(find.text('Favoriler'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.byKey(const Key('customer-nav-profile-badge')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gerçek sepet adedini rozette gösterir ve üçüncü hedefi açar', (
    tester,
  ) async {
    var selectedIndex = -1;
    const item = CartItemV2Entity(
      id: 'item-1',
      cartId: 'cart-1',
      shopProductId: 'shop-product-1',
      quantity: 3,
    );

    await tester.pumpWidget(
      buildSubject(
        cartState: const CartV2Loaded([item]),
        onSelected: (index) => selectedIndex = index,
      ),
    );

    expect(find.byKey(const Key('customer-nav-cart-badge')), findsWidgets);
    expect(find.text('3'), findsWidgets);

    await tester.tap(find.byKey(const Key('customer-nav-cart')));
    await tester.pump();

    expect(selectedIndex, 2);
  });

  testWidgets('okunmamış mesaj sayısını Profil simgesinde gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        cartState: const CartV2Loaded([]),
        unreadMessageCount: 7,
        onSelected: (_) {},
      ),
    );

    expect(find.byKey(const Key('customer-nav-profile-badge')), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('yüksek okunmamış mesaj sayısını 99+ olarak sınırlar', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        cartState: const CartV2Loaded([]),
        unreadMessageCount: 125,
        onSelected: (_) {},
      ),
    );

    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('görsel prototip kabuğu aynı beş hedefi korur', (tester) async {
    var selectedIndex = -1;
    await tester.pumpWidget(
      buildSubject(
        cartState: const CartV2Loaded([]),
        visualPrototype: true,
        onSelected: (index) => selectedIndex = index,
      ),
    );

    const destinations = [
      Key('customer-nav-home'),
      Key('customer-nav-nearby'),
      Key('customer-nav-cart'),
      Key('customer-nav-wishlist'),
      Key('customer-nav-profile'),
    ];
    for (var index = 0; index < destinations.length; index++) {
      await tester.tap(find.byKey(destinations[index]));
      await tester.pump();
      expect(selectedIndex, index);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('görsel prototip yüzde 130 metin ölçeğinde taşma üretmez', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildSubject(
        cartState: const CartV2Loaded([]),
        visualPrototype: true,
        textScale: 1.3,
        onSelected: (_) {},
      ),
    );

    expect(find.text('Ana Sayfa'), findsOneWidget);
    expect(find.text('Yakındakiler'), findsOneWidget);
    expect(find.text('Sepet'), findsOneWidget);
    expect(find.text('Favoriler'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
