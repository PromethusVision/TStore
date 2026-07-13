import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';
import 'package:t_store/features/shop/presentation/helpers/customer_proximity_helper.dart';

void main() {
  group('CustomerProximityHelper', () {
    const customer = CustomerCoordinates(latitude: 41, longitude: 29);

    test('aynı konum için sıfır mesafe döndürür', () {
      final distance = CustomerProximityHelper.distanceInMeters(
        from: customer,
        latitude: 41,
        longitude: 29,
      );

      expect(distance, closeTo(0, 0.001));
    });

    test('geçersiz mağaza veya müşteri konumunda mesafe üretmez', () {
      expect(
        CustomerProximityHelper.distanceInMeters(
          from: customer,
          latitude: null,
          longitude: 29,
        ),
        isNull,
      );
      expect(
        CustomerProximityHelper.distanceInMeters(
          from: customer,
          latitude: 91,
          longitude: 29,
        ),
        isNull,
      );
      expect(
        CustomerProximityHelper.distanceInMeters(
          from: const CustomerCoordinates(latitude: double.nan, longitude: 29),
          latitude: 41,
          longitude: 29,
        ),
        isNull,
      );
    });

    test('mesafeyi müşteri için okunabilir biçimde gösterir', () {
      expect(CustomerProximityHelper.formatDistance(0), "10 m'den az");
      expect(CustomerProximityHelper.formatDistance(114), 'Yaklaşık 110 m');
      expect(CustomerProximityHelper.formatDistance(1250), 'Yaklaşık 1,3 km');
    });
  });
}
