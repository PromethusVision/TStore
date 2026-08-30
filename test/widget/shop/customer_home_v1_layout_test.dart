import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/ui/components/reward_progress_card.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/core/utils/theme/theme.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_state.dart';
import 'package:t_store/features/shop/domain/entities/banner_entity.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
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

class MockHomeLayoutAuthCubit extends MockCubit<AuthState>
    implements AuthCubit {}

class MockHomeLayoutBannersCubit extends MockCubit<BannersState>
    implements BannersCubit {}

class MockHomeLayoutCategoriesCubit extends MockCubit<CategoriesState>
    implements CategoriesCubit {}

class MockHomeLayoutProductsCubit extends MockCubit<ProductsState>
    implements ProductsCubit {}

class MockHomeLayoutCustomerSearchCubit extends MockCubit<CustomerSearchState>
    implements CustomerSearchCubit {}

class MockHomeLayoutLocationsCubit
    extends MockCubit<CustomerSavedLocationsState>
    implements CustomerSavedLocationsCubit {}

class MockHomeLayoutNearbyCubit extends MockCubit<NearbyShopsState>
    implements NearbyShopsCubit {}

void main() {
  late MockHomeLayoutAuthCubit authCubit;
  late MockHomeLayoutBannersCubit bannersCubit;
  late MockHomeLayoutCategoriesCubit categoriesCubit;
  late MockHomeLayoutProductsCubit productsCubit;
  late MockHomeLayoutCustomerSearchCubit customerSearchCubit;
  late MockHomeLayoutLocationsCubit locationsCubit;
  late MockHomeLayoutNearbyCubit nearbyCubit;

  setUp(() {
    authCubit = MockHomeLayoutAuthCubit();
    bannersCubit = MockHomeLayoutBannersCubit();
    categoriesCubit = MockHomeLayoutCategoriesCubit();
    productsCubit = MockHomeLayoutProductsCubit();
    customerSearchCubit = MockHomeLayoutCustomerSearchCubit();
    locationsCubit = MockHomeLayoutLocationsCubit();
    nearbyCubit = MockHomeLayoutNearbyCubit();

    when(() => bannersCubit.getBanners()).thenAnswer((_) async {});
    when(() => categoriesCubit.getCategories()).thenAnswer((_) async {});

    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthUnauthenticated(),
    );
    whenListen(
      bannersCubit,
      const Stream<BannersState>.empty(),
      initialState: const BannersLoaded([
        BannerEntity(id: 'banner', imageUrl: TImages.promoBanner1),
      ]),
    );
    whenListen(
      categoriesCubit,
      const Stream<CategoriesState>.empty(),
      initialState: const CategoriesLoaded([
        CategoryEntity(id: '1', name: 'Market'),
        CategoryEntity(id: '2', name: 'Manav'),
        CategoryEntity(id: '3', name: 'Fırın'),
        CategoryEntity(id: '4', name: 'Kasap'),
        CategoryEntity(id: '5', name: 'Kozmetik'),
        CategoryEntity(id: '6', name: 'Ev & Yaşam'),
      ]),
    );
    whenListen(
      productsCubit,
      const Stream<ProductsState>.empty(),
      initialState: const ProductsLoaded(products: []),
    );
    whenListen(
      customerSearchCubit,
      const Stream<CustomerSearchState>.empty(),
      initialState: CustomerSearchInitial(),
    );
    when(() => customerSearchCubit.search(any())).thenAnswer((_) async {});
    when(() => customerSearchCubit.reset()).thenReturn(null);
    whenListen(
      locationsCubit,
      const Stream<CustomerSavedLocationsState>.empty(),
      initialState: const CustomerSavedLocationsLoaded(locations: []),
    );
    whenListen(
      nearbyCubit,
      const Stream<NearbyShopsState>.empty(),
      initialState: const NearbyShopsEmpty(),
    );
  });

  Future<void> pumpLayout(
    WidgetTester tester,
    double width, {
    bool rewardFeatureEnabled = false,
    RewardProgressData? rewardProgress,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<BannersCubit>.value(value: bannersCubit),
          BlocProvider<CategoriesCubit>.value(value: categoriesCubit),
          BlocProvider<ProductsCubit>.value(value: productsCubit),
          BlocProvider<CustomerSavedLocationsCubit>.value(
            value: locationsCubit,
          ),
          BlocProvider<NearbyShopsCubit>.value(value: nearbyCubit),
        ],
        child: MaterialApp(
          theme: TAppTheme.lightTheme,
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 844),
              textScaler: TextScaler.linear(textScale),
            ),
            child: Scaffold(
              body: CustomerHomeV1Content(
                searchCubit: customerSearchCubit,
                isAuthenticatedOverride: false,
                rewardFeatureEnabled: rewardFeatureEnabled,
                rewardProgress: rewardProgress,
                onSearchSubmitted: (_) {},
                onLocationTap: () {},
                onNearbyViewAll: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('$width piksel genişlikte ana sayfa taşma üretmez', (
      tester,
    ) async {
      await pumpLayout(tester, width);

      expect(find.byKey(const Key('customer-home-scroll')), findsOneWidget);
      expect(find.byKey(const Key('customer-home-hero')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('runtime Home ödül gate kapalıyken sahte veri göstermez', (
    tester,
  ) async {
    await pumpLayout(
      tester,
      390,
      rewardProgress: const RewardProgressData(
        progress: 0.5,
        title: 'Test ödül fixture verisi',
      ),
    );

    expect(find.byKey(const Key('reward-progress-slot-off')), findsOneWidget);
    expect(find.byKey(const Key('reward-progress-card')), findsNothing);
  });

  testWidgets('ödül fixture kartı arama ile kategoriler arasında yer alır', (
    tester,
  ) async {
    await pumpLayout(
      tester,
      390,
      rewardFeatureEnabled: true,
      rewardProgress: const RewardProgressData(
        progress: 0.5,
        title: 'Mahalle ödül yolculuğu',
        currentMilestone: 'Başlangıç',
        nextMilestone: 'Sıradaki adım',
      ),
    );

    final searchTop = tester.getTopLeft(
      find.byKey(const Key('home-search-bar')),
    );
    final rewardTop = tester.getTopLeft(
      find.byKey(const Key('reward-progress-card')),
    );
    final categoriesTop = tester.getTopLeft(
      find.byKey(const Key('home-categories')),
    );
    expect(rewardTop.dy, greaterThan(searchTop.dy));
    expect(categoriesTop.dy, greaterThan(rewardTop.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('390 pikselde yüzde 130 metin ölçeği taşma üretmez', (
    tester,
  ) async {
    await pumpLayout(
      tester,
      390,
      textScale: 1.3,
      rewardFeatureEnabled: true,
      rewardProgress: const RewardProgressData(
        progress: 0.95,
        title: 'ÇĞİÖŞÜ ile oldukça uzun mahalle ödül yolculuğu başlığı',
        contextualMessage: 'Sıradaki gelişme için yolculuğun devam ediyor.',
      ),
    );

    expect(find.byKey(const Key('customer-home-scroll')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
