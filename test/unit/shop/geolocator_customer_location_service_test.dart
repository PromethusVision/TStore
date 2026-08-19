import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:t_store/features/shop/data/services/geolocator_customer_location_service.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';

void main() {
  const coordinates = CustomerCoordinates(latitude: 41.043, longitude: 28.876);

  test('geçerli ana konumu cihaz izni istemeden döndürür', () async {
    const preferredLocation = CustomerPreferredLocation(
      name: 'Ev',
      coordinates: coordinates,
    );
    var deviceRequestCount = 0;
    final service = GeolocatorCustomerLocationService(
      preferredLocationLoader: () async => preferredLocation,
      coordinatesLoader: () async {
        deviceRequestCount++;
        return coordinates;
      },
    );

    final result = await service.getPreferredLocation();

    expect(result, preferredLocation);
    expect(deviceRequestCount, 0);
  });

  test('ana konum yüklenemezse cihaz konumu akışını bozmaz', () async {
    final service = GeolocatorCustomerLocationService(
      preferredLocationLoader: () => throw StateError('database details'),
      coordinatesLoader: () async => coordinates,
    );

    expect(await service.getPreferredLocation(), isNull);
    expect(
      await service.getCurrentLocation(),
      const CustomerLocationResult.success(coordinates),
    );
  });

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

  test('önce cihaz konum servisini kontrol eder', () async {
    var permissionCheckCount = 0;
    var permissionRequestCount = 0;
    var positionRequestCount = 0;
    final service = GeolocatorCustomerLocationService(
      serviceStatusLoader: () async => false,
      permissionLoader: () async {
        permissionCheckCount++;
        return LocationPermission.denied;
      },
      permissionRequester: () async {
        permissionRequestCount++;
        return LocationPermission.whileInUse;
      },
      coordinatesLoader: () async {
        positionRequestCount++;
        return coordinates;
      },
    );

    final result = await service.getCurrentLocation(forceRefresh: true);

    expect(
      result,
      const CustomerLocationResult.failed(
        CustomerLocationFailure.servicesDisabled,
      ),
    );
    expect(permissionCheckCount, 0);
    expect(permissionRequestCount, 0);
    expect(positionRequestCount, 0);
  });

  test('reddedilen izni ister ve verilince konumu alır', () async {
    var requestCount = 0;
    final service = GeolocatorCustomerLocationService(
      serviceStatusLoader: () async => true,
      permissionLoader: () async => LocationPermission.denied,
      permissionRequester: () async {
        requestCount++;
        return LocationPermission.whileInUse;
      },
      coordinatesLoader: () async => coordinates,
    );

    final result = await service.getCurrentLocation(forceRefresh: true);

    expect(result, const CustomerLocationResult.success(coordinates));
    expect(requestCount, 1);
  });

  test('tekrar reddedilen ve kalıcı reddedilen izinleri ayırır', () async {
    final deniedService = GeolocatorCustomerLocationService(
      serviceStatusLoader: () async => true,
      permissionLoader: () async => LocationPermission.denied,
      permissionRequester: () async => LocationPermission.denied,
      coordinatesLoader: () async => coordinates,
    );
    var foreverRequestCount = 0;
    final deniedForeverService = GeolocatorCustomerLocationService(
      serviceStatusLoader: () async => true,
      permissionLoader: () async => LocationPermission.deniedForever,
      permissionRequester: () async {
        foreverRequestCount++;
        return LocationPermission.deniedForever;
      },
      coordinatesLoader: () async => coordinates,
    );

    expect(
      await deniedService.getCurrentLocation(forceRefresh: true),
      const CustomerLocationResult.failed(
        CustomerLocationFailure.permissionDenied,
      ),
    );
    expect(
      await deniedForeverService.getCurrentLocation(forceRefresh: true),
      const CustomerLocationResult.failed(
        CustomerLocationFailure.permissionDeniedForever,
      ),
    );
    expect(foreverRequestCount, 0);
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

  test(
    'güncel konum zaman aşımında geçerli son bilinen konumu kullanır',
    () async {
      final pendingCoordinates = Completer<CustomerCoordinates>();
      final service = GeolocatorCustomerLocationService(
        coordinatesLoader: () => pendingCoordinates.future,
        lastKnownCoordinatesLoader: () async => coordinates,
        timeout: const Duration(milliseconds: 10),
      );

      final result = await service.getCurrentLocation(forceRefresh: true);

      expect(result, const CustomerLocationResult.success(coordinates));
      pendingCoordinates.complete(coordinates);
    },
  );

  test('uygun cihaz ayar ekranlarını güvenli opener üzerinden açar', () async {
    var appSettingsCount = 0;
    var locationSettingsCount = 0;
    final service = GeolocatorCustomerLocationService(
      coordinatesLoader: () async => coordinates,
      appSettingsOpener: () async {
        appSettingsCount++;
        return true;
      },
      locationSettingsOpener: () async {
        locationSettingsCount++;
        return true;
      },
    );

    expect(await service.openAppSettings(), isTrue);
    expect(await service.openLocationSettings(), isTrue);
    expect(appSettingsCount, 1);
    expect(locationSettingsCount, 1);
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
