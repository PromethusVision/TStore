import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_cubit.dart';
import 'package:t_store/features/personalization/presentation/views/customer_saved_locations_view.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/views/all_products_view.dart';
import 'package:t_store/features/shop/presentation/widgets/home_app_bar.dart';
import 'package:t_store/features/shop/presentation/widgets/home_categories.dart';
import 'package:t_store/features/shop/presentation/widgets/home_location_bar.dart';
import 'package:t_store/features/shop/presentation/widgets/home_nearby_shops_section.dart';
import 'package:t_store/features/shop/presentation/widgets/home_products_section.dart';
import 'package:t_store/features/shop/presentation/widgets/home_search_bar.dart';
import 'package:t_store/features/shop/presentation/widgets/promo_banner_carousel_slider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().getProducts(
      isFeatured: true,
      sortBy: 'rating',
      ascending: false,
      refresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CustomerSavedLocationsCubit>(
          create: (_) {
            final cubit = sl<CustomerSavedLocationsCubit>();
            if (SupabaseService.instance.currentUser != null) {
              cubit.loadLocations();
            }
            return cubit;
          },
        ),
        BlocProvider<NearbyShopsCubit>(
          create: (_) => sl<NearbyShopsCubit>()..loadShops(),
        ),
      ],
      child: Builder(
        builder: (contentContext) => Scaffold(
          backgroundColor: CustomerHomeV1Tokens.cream,
          body: SafeArea(
            bottom: false,
            child: CustomerHomeV1Content(
              onSearchTap: () => _openAllProductsSearch(contentContext),
              onLocationTap: () => _openSavedLocations(contentContext),
              onNearbyViewAll: () =>
                  contentContext.read<NavigationMenuCubit>().changeIndex(1),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSavedLocations(BuildContext context) async {
    if (SupabaseService.instance.currentUser == null) {
      THelperFunctions.navigateToScreen(context, const LoginView());
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const CustomerSavedLocationsView(),
      ),
    );

    if (!context.mounted) return;
    await context.read<CustomerSavedLocationsCubit>().loadLocations();
    if (!context.mounted) return;
    await context.read<NearbyShopsCubit>().loadShops();
  }

  void _openAllProductsSearch(BuildContext context) {
    THelperFunctions.navigateToScreen(
      context,
      const AllProductsView(autoFocusSearch: true, isSearchMode: true),
    );
  }
}

class CustomerHomeV1Content extends StatelessWidget {
  const CustomerHomeV1Content({
    super.key,
    required this.onSearchTap,
    required this.onLocationTap,
    required this.onNearbyViewAll,
    this.isAuthenticatedOverride,
    this.categoryDestinationBuilder,
    this.productDestinationBuilder,
    this.shopDestinationBuilder,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onLocationTap;
  final VoidCallback onNearbyViewAll;
  final bool? isAuthenticatedOverride;
  final HomeCategoryDestinationBuilder? categoryDestinationBuilder;
  final HomeProductDestinationBuilder? productDestinationBuilder;
  final HomeShopDestinationBuilder? shopDestinationBuilder;

  @override
  Widget build(BuildContext context) {
    final isAuthenticated =
        isAuthenticatedOverride ?? _hasAuthenticatedSession();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: SingleChildScrollView(
          key: const Key('customer-home-scroll'),
          padding: const EdgeInsets.fromLTRB(
            CustomerHomeV1Tokens.space16,
            CustomerHomeV1Tokens.space8,
            CustomerHomeV1Tokens.space16,
            CustomerHomeV1Tokens.space24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeAppBar(),
              const SizedBox(height: CustomerHomeV1Tokens.space8),
              HomeLocationBar(
                isAuthenticated: isAuthenticated,
                onTap: onLocationTap,
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space8),
              HomeSearchBar(onTap: onSearchTap),
              const SizedBox(height: CustomerHomeV1Tokens.space12),
              HomeCategories(destinationBuilder: categoryDestinationBuilder),
              const SizedBox(height: CustomerHomeV1Tokens.space12),
              const PromoBannerCarouselSlider(),
              const SizedBox(height: CustomerHomeV1Tokens.space12),
              HomeProductsSection(
                destinationBuilder: productDestinationBuilder,
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space16),
              HomeNearbyShopsSection(
                onViewAll: onNearbyViewAll,
                shopDestinationBuilder: shopDestinationBuilder,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasAuthenticatedSession() {
    try {
      return SupabaseService.instance.currentUser != null;
    } catch (_) {
      return false;
    }
  }
}
