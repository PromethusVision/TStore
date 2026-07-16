import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:t_store/features/shop/data/services/geolocator_customer_location_service.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';

void main() {
  const coordinates = CustomerCoordinates(latitude: 41.043, longitude: 28.876);

  test('geçerli koordinatı güvenli sonuç olarak döndürür', () async {
    var invocationCount = 0;
    final service = GeolocatorCustomerLocationService(
      coordinatesLoader: () async {
        invocationCount++;
        return coordinates;
      },
    );

    final result = await service.getCurrentLocation();
    final cachedResult = await service.getCurrentLocation();

    expect(result, const CustomerLocationResult.success(coordinates));
    expect(cachedResult, const CustomerLocationResult.success(coordinates));
    expect(service.cachedCoordinates, coordinates);
    expect(invocationCount, 1);
  });

  test('istenirse önbellek yerine güncel konumu yeniden alır', () async {
    var invocationCount = 0;
    final service = GeolocatorCustomerLocationService(
      coordinatesLoader: () async {
        invocationCount++;
        return coordinates;
      },
    );

    await service.getCurrentLocation();
    final refreshed = await service.getCurrentLocation(forceRefresh: true);

    expect(refreshed, const CustomerLocationResult.success(coordinates));
    expect(invocationCount, 2);
  });

  test('izin reddini teknik ayrıntı taşımadan bildirir', () async {
    final service = GeolocatorCustomerLocationService(
      coordinatesLoader: () =>
          throw const PermissionDeniedException('browser details'),
    );

    final result = await service.getCurrentLocation();

    expect(
      result,
      const CustomerLocationResult.failed(
        CustomerLocationFailure.permissionDenied,
      ),
    );
  });

  test(
    'kapalı konum hizmetini ayrı bir güvenli sonuç olarak bildirir',
    () async {
      final service = GeolocatorCustomerLocationService(
        coordinatesLoader: () => throw const LocationServiceDisabledException(),
      );

      final result = await service.getCurrentLocation();

      expect(
        result,
        const CustomerLocationResult.failed(
          CustomerLocationFailure.servicesDisabled,
        ),
      );
    },
  );

  test('uzun süren konum isteğini zaman aşımıyla sonlandırır', () async {
    final pendingCoordinates = Completer<CustomerCoordinates>();
    var invocationCount = 0;
    final service = GeolocatorCustomerLocationService(
      coordinatesLoader: () {
        invocationCount++;
        return pendingCoordinates.future;
      },
      timeout: const Duration(milliseconds: 10),
    );

    final result = await service.getCurrentLocation();
    final retry = service.getCurrentLocation();

    expect(
      result,
      const CustomerLocationResult.failed(CustomerLocationFailure.timedOut),
    );
    expect(invocationCount, 1);

    pendingCoordinates.complete(coordinates);

    expect(await retry, const CustomerLocationResult.success(coordinates));
    expect(service.cachedCoordinates, coordinates);
    expect(invocationCount, 1);
  });

  test('geçersiz koordinatı mesafe hesabına taşımaz', () async {
    final service = GeolocatorCustomerLocationService(
      coordinatesLoader: () async =>
          const CustomerCoordinates(latitude: 120, longitude: 28.876),
    );

    final result = await service.getCurrentLocation();

    expect(
      result,
      const CustomerLocationResult.failed(CustomerLocationFailure.unavailable),
    );
  });

  test('beklenmeyen konum hatasını güvenli sonuca dönüştürür', () async {
    final service = GeolocatorCustomerLocationService(
      coordinatesLoader: () => throw StateError('sensitive details'),
    );

    final result = await service.getCurrentLocation();

    expect(
      result,
      const CustomerLocationResult.failed(CustomerLocationFailure.unavailable),
    );
  });

  test('konum bulunamaması ayrıntısını güvenli sonuca dönüştürür', () async {
    final service = GeolocatorCustomerLocationService(
      coordinatesLoader: () =>
          throw const PositionUpdateException('browser details'),
    );

    final result = await service.getCurrentLocation();

    expect(
      result,
      const CustomerLocationResult.failed(CustomerLocationFailure.unavailable),
    );
  });
}
