import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/features/personalization/presentation/views/settings_view.dart';
import 'package:t_store/features/shop/presentation/views/home_view.dart';
import 'package:t_store/features/shop/presentation/views/nearby_view.dart';
import 'package:t_store/features/shop/presentation/views/wishlist_view.dart';

void main() {
  test('keeps the customer screen mapping at indexes 0 through 3', () async {
    final cubit = NavigationMenuCubit();

    expect(cubit.selectedIndex, 0);
    expect(cubit.getScreen(), isA<HomeView>());

    cubit.changeIndex(1);
    expect(cubit.getScreen(), isA<NearbyView>());

    cubit.changeIndex(2);
    expect(cubit.getScreen(), isA<WishlistView>());

    cubit.changeIndex(3);
    expect(cubit.getScreen(), isA<SettingsView>());

    expect(cubit.screensList, hasLength(4));
    await cubit.close();
  });
}
