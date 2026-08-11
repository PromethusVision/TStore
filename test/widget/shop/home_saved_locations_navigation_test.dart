import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_state.dart';
import 'package:t_store/features/shop/domain/services/recent_product_searches_storage.dart';
import 'package:t_store/features/shop/presentation/cubit/banners_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/banners_state.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_state.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_state.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_state.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';
import 'package:t_store/features/shop/presentation/views/home_view.dart';

class MockProductsCubit extends MockCubit<ProductsState>
    implements ProductsCubit {}

class MockCategoriesCubit extends MockCubit<CategoriesState>
    implements CategoriesCubit {}

class MockBannersCubit extends MockCubit<BannersState>
    implements BannersCubit {}

class MockCustomerSavedLocationsCubit
    extends MockCubit<CustomerSavedLocationsState>
    implements CustomerSavedLocationsCubit {}

class MockNearbyShopsCubit extends MockCubit<NearbyShopsState>
    implements NearbyShopsCubit {}

class MockCustomerSearchCubit extends MockCubit<CustomerSearchState>
    implements CustomerSearchCubit {}

class MockNavigationMenuCubit extends MockCubit<NavigationMenuState>
    implements NavigationMenuCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockRecentProductSearchesStorage extends Mock
    implements RecentProductSearchesStorage {}

void main() {
  late MockProductsCubit productsCubit;
  late MockCategoriesCubit categoriesCubit;
  late MockBannersCubit bannersCubit;
  late MockCustomerSavedLocationsCubit savedLocationsCubit;
  late MockNearbyShopsCubit nearbyShopsCubit;
  late MockCustomerSearchCubit searchCubit;
  late MockNavigationMenuCubit navigationCubit;
  late MockAuthCubit authCubit;
  late MockAuthCubit loginAuthCubit;
  late MockRecentProductSearchesStorage recentSearchesStorage;

  setUp(() async {
    await sl.reset();

    productsCubit = MockProductsCubit();
    categoriesCubit = MockCategoriesCubit();
    bannersCubit = MockBannersCubit();
    savedLocationsCubit = MockCustomerSavedLocationsCubit();
    nearbyShopsCubit = MockNearbyShopsCubit();
    searchCubit = MockCustomerSearchCubit();
    navigationCubit = MockNavigationMenuCubit();
    authCubit = MockAuthCubit();
    loginAuthCubit = MockAuthCubit();
    recentSearchesStorage = MockRecentProductSearchesStorage();

    whenListen(
      productsCubit,
      const Stream<ProductsState>.empty(),
      initialState: const ProductsLoaded(products: []),
    );
    whenListen(
      categoriesCubit,
      const Stream<CategoriesState>.empty(),
      initialState: const CategoriesLoaded([]),
    );
    whenListen(
      bannersCubit,
      const Stream<BannersState>.empty(),
      initialState: const BannersLoaded([]),
    );
    whenListen(
      savedLocationsCubit,
      const Stream<CustomerSavedLocationsState>.empty(),
      initialState: const CustomerSavedLocationsLoaded(locations: []),
    );
    whenListen(
      nearbyShopsCubit,
      const Stream<NearbyShopsState>.empty(),
      initialState: const NearbyShopsEmpty(),
    );
    whenListen(
      searchCubit,
      const Stream<CustomerSearchState>.empty(),
      initialState: CustomerSearchInitial(),
    );
    whenListen(
      navigationCubit,
      const Stream<NavigationMenuState>.empty(),
      initialState: NavigationMenuInitial(),
    );
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthUnauthenticated(),
    );
    whenListen(
      loginAuthCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );

    when(
      () => productsCubit.getProducts(
        isFeatured: true,
        sortBy: 'rating',
        ascending: false,
        refresh: true,
      ),
    ).thenAnswer((_) async {});
    when(() => savedLocationsCubit.loadLocations()).thenAnswer((_) async {});
    when(() => nearbyShopsCubit.loadShops()).thenAnswer((_) async {});
    when(() => bannersCubit.getBanners()).thenAnswer((_) async {});
    when(() => recentSearchesStorage.getQueries()).thenAnswer((_) async => []);

    sl.registerFactory<CustomerSavedLocationsCubit>(() => savedLocationsCubit);
    sl.registerFactory<NearbyShopsCubit>(() => nearbyShopsCubit);
    sl.registerFactory<CustomerSearchCubit>(() => searchCubit);
    sl.registerFactory<AuthCubit>(() => loginAuthCubit);
    sl.registerLazySingleton<RecentProductSearchesStorage>(
      () => recentSearchesStorage,
    );
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildSubject({required HomeCurrentUserIdProvider userIdProvider}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductsCubit>.value(value: productsCubit),
        BlocProvider<CategoriesCubit>.value(value: categoriesCubit),
        BlocProvider<BannersCubit>.value(value: bannersCubit),
        BlocProvider<NavigationMenuCubit>.value(value: navigationCubit),
        BlocProvider<AuthCubit>.value(value: authCubit),
      ],
      child: MaterialApp(
        home: HomeView(
          currentUserIdProvider: userIdProvider,
          savedLocationsDestinationBuilder: (_) => const Scaffold(
            key: Key('saved-locations-destination'),
            body: SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  testWidgets('misafir giristen sonra kayitli konumlara devam eder', (
    tester,
  ) async {
    String? currentUserId;
    await tester.pumpWidget(buildSubject(userIdProvider: () => currentUserId));
    await tester.pump();
    clearInteractions(savedLocationsCubit);
    clearInteractions(nearbyShopsCubit);

    await tester.tap(find.byKey(const Key('home-location-bar')));
    await tester.pumpAndSettle();

    final loginView = tester.widget<LoginView>(find.byType(LoginView));
    expect(loginView.returnToCallerAfterCustomerLogin, isTrue);
    expect(find.byKey(const Key('saved-locations-destination')), findsNothing);

    currentUserId = 'customer-1';
    Navigator.of(tester.element(find.byType(LoginView))).pop(true);
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsNothing);
    expect(
      find.byKey(const Key('saved-locations-destination')),
      findsOneWidget,
    );

    Navigator.of(
      tester.element(find.byKey(const Key('saved-locations-destination'))),
    ).pop();
    await tester.pumpAndSettle();

    verify(() => savedLocationsCubit.loadLocations()).called(1);
    verify(() => nearbyShopsCubit.loadShops()).called(1);
  });

  testWidgets('misafir giristen vazgecerse ana sayfada kalir', (tester) async {
    await tester.pumpWidget(buildSubject(userIdProvider: () => null));
    await tester.pump();
    clearInteractions(savedLocationsCubit);
    clearInteractions(nearbyShopsCubit);

    await tester.tap(find.byKey(const Key('home-location-bar')));
    await tester.pumpAndSettle();

    Navigator.of(tester.element(find.byType(LoginView))).pop(false);
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsNothing);
    expect(find.byKey(const Key('saved-locations-destination')), findsNothing);
    expect(find.byKey(const Key('home-location-bar')), findsOneWidget);
    verifyNever(() => savedLocationsCubit.loadLocations());
    verifyNever(() => nearbyShopsCubit.loadShops());
  });

  testWidgets('hizli iki dokunmada tek giris ekrani acar', (tester) async {
    await tester.pumpWidget(buildSubject(userIdProvider: () => null));
    await tester.pump();

    final locationBar = find.byKey(const Key('home-location-bar'));
    final locationInkWell = tester.widget<InkWell>(
      find.descendant(of: locationBar, matching: find.byType(InkWell)),
    );
    locationInkWell.onTap!();
    locationInkWell.onTap!();
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);

    Navigator.of(tester.element(find.byType(LoginView))).pop(false);
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsNothing);
    expect(find.byKey(const Key('saved-locations-destination')), findsNothing);
  });

  testWidgets('eski oturumun konum dönüşü yeni oturuma yenileme uygulamaz', (
    tester,
  ) async {
    String? currentUserId = 'customer-1';
    await tester.pumpWidget(buildSubject(userIdProvider: () => currentUserId));
    await tester.pump();
    clearInteractions(savedLocationsCubit);
    clearInteractions(nearbyShopsCubit);

    await tester.tap(find.byKey(const Key('home-location-bar')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('saved-locations-destination')),
      findsOneWidget,
    );

    currentUserId = 'customer-2';
    Navigator.of(
      tester.element(find.byKey(const Key('saved-locations-destination'))),
    ).pop();
    await tester.pumpAndSettle();

    verifyNever(() => savedLocationsCubit.loadLocations());
    verifyNever(() => nearbyShopsCubit.loadShops());
    expect(find.byKey(const Key('home-location-bar')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dispose sonrası yavaş konum yenileme hatası ekrana taşınmaz', (
    tester,
  ) async {
    final refreshCompletion = Completer<void>();
    when(
      () => savedLocationsCubit.loadLocations(),
    ).thenAnswer((_) => refreshCompletion.future);
    await tester.pumpWidget(buildSubject(userIdProvider: () => 'customer-1'));
    await tester.pump();
    clearInteractions(savedLocationsCubit);
    clearInteractions(nearbyShopsCubit);

    await tester.tap(find.byKey(const Key('home-location-bar')));
    await tester.pumpAndSettle();
    Navigator.of(
      tester.element(find.byKey(const Key('saved-locations-destination'))),
    ).pop();
    await tester.pump();

    verify(() => savedLocationsCubit.loadLocations()).called(1);

    await tester.pumpWidget(const SizedBox.shrink());
    refreshCompletion.completeError(StateError('Cubit already closed'));
    await tester.pump();

    verifyNever(() => nearbyShopsCubit.loadShops());
    expect(tester.takeException(), isNull);
  });
}
