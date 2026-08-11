import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _legacyOrderPackage = 'package:t_store/features/orders/';
const _legacyOrdersViewImport =
    'package:t_store/features/shop/presentation/views/orders_view.dart';

void main() {
  group('legacy order boundary', () {
    test('legacy order package is absent from active app wiring', () {
      final references =
          _libDartFiles()
              .where(
                (file) =>
                    !_relativePath(file).startsWith('lib/features/orders/') &&
                    file.readAsStringSync().contains(_legacyOrderPackage),
              )
              .map(_relativePath)
              .toList()
            ..sort();

      expect(
        references,
        isEmpty,
        reason:
            'Legacy order code must not be imported outside its own module, '
            'including by the active dependency injection graph.',
      );
    });

    test('legacy order screen is not imported by another library', () {
      final references =
          _libDartFiles()
              .where(
                (file) =>
                    file.readAsStringSync().contains(_legacyOrdersViewImport),
              )
              .map(_relativePath)
              .toList()
            ..sort();

      expect(references, isEmpty);
    });

    test(
      'main customer navigation exposes only the current product journey',
      () {
        final navigation = _source(
          'lib/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart',
        );

        for (final destination in const [
          'HomeView',
          'NearbyView',
          'CartV2View',
          'WishlistView',
          'SettingsView',
        ]) {
          expect(navigation, contains('const $destination('));
        }
        _expectNoLegacyOrderConnection(navigation);
      },
    );

    test('Cart V2 remains QR verification, not legacy checkout', () {
      final cart = _source(
        'lib/features/shop/presentation/views/cart_v2_view.dart',
      );

      expect(cart, contains('_CartV2VerificationPanel'));
      expect(cart, contains('CartQrSessionBottomSheet'));
      expect(cart, contains('PurchasesView'));
      expect(cart.toLowerCase(), isNot(contains('checkout')));
      _expectNoLegacyOrderConnection(cart);
    });

    test('product and shop discovery do not navigate to legacy orders', () {
      for (final path in const [
        'lib/features/shop/presentation/views/home_view.dart',
        'lib/features/shop/presentation/views/nearby_view.dart',
        'lib/features/shop/presentation/views/product_details_view.dart',
        'lib/features/shop/presentation/views/shop_profile_view.dart',
        'lib/features/shop/presentation/widgets/product_sellers_section.dart',
      ]) {
        _expectNoLegacyOrderConnection(_source(path), reason: path);
      }
    });

    test('disconnected placeholder is explicitly named as legacy', () {
      final legacyView = _source(
        'lib/features/shop/presentation/views/orders_view.dart',
      );
      final legacyList = _source(
        'lib/features/shop/presentation/widgets/orders_list.dart',
      );

      expect(legacyView, contains('LEGACY ORDER BOUNDARY'));
      expect(legacyView, contains('class LegacyOrdersView'));
      expect(legacyList, contains('class LegacyOrdersList'));
    });
  });
}

void _expectNoLegacyOrderConnection(String source, {String? reason}) {
  for (final forbidden in const [
    _legacyOrderPackage,
    _legacyOrdersViewImport,
    'OrdersCubit',
    'OrdersView(',
    'CreateOrderUsecase',
    'LegacyOrdersView(',
  ]) {
    expect(source, isNot(contains(forbidden)), reason: reason);
  }
}

List<File> _libDartFiles() => Directory('lib')
    .listSync(recursive: true)
    .whereType<File>()
    .where((file) => file.path.endsWith('.dart'))
    .toList();

String _source(String path) => File(path).readAsStringSync();

String _relativePath(File file) => file.path.replaceAll('\\', '/');
