import 'dart:math' as math;

import 'package:t_store/features/shop/domain/services/customer_location_service.dart';

class CustomerProximityHelper {
  const CustomerProximityHelper._();

  static bool hasValidCoordinates(double? latitude, double? longitude) {
    return latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  static double? distanceInMeters({
    required CustomerCoordinates from,
    required double? latitude,
    required double? longitude,
  }) {
    if (!from.isValid || !hasValidCoordinates(latitude, longitude)) {
      return null;
    }

    const earthRadiusMeters = 6371000.0;
    final latitudeDelta = _toRadians(latitude! - from.latitude);
    final longitudeDelta = _toRadians(longitude! - from.longitude);
    final firstLatitude = _toRadians(from.latitude);
    final secondLatitude = _toRadians(latitude);

    final haversine =
        math.pow(math.sin(latitudeDelta / 2), 2).toDouble() +
        math.cos(firstLatitude) *
            math.cos(secondLatitude) *
            math.pow(math.sin(longitudeDelta / 2), 2).toDouble();
    final normalizedHaversine = haversine.clamp(0.0, 1.0).toDouble();

    return 2 *
        earthRadiusMeters *
        math.atan2(
          math.sqrt(normalizedHaversine),
          math.sqrt(1 - normalizedHaversine),
        );
  }

  static String formatDistance(double distanceMeters) {
    if (distanceMeters < 10) {
      return "10 m'den az";
    }

    if (distanceMeters < 1000) {
      final roundedMeters = (distanceMeters / 10).round() * 10;
      return 'Yaklaşık $roundedMeters m';
    }

    final kilometers = (distanceMeters / 1000)
        .toStringAsFixed(1)
        .replaceAll('.', ',');
    return 'Yaklaşık $kilometers km';
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}
