import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';

typedef CustomerCoordinatesLoader = Future<CustomerCoordinates> Function();

class GeolocatorCustomerLocationService implements CustomerLocationService {
  static const Duration defaultTimeout = Duration(seconds: 30);

  final CustomerCoordinatesLoader _coordinatesLoader;
  final Duration timeout;
  Future<CustomerCoordinates>? _activeCoordinatesRequest;
  CustomerCoordinates? _cachedCoordinates;

  GeolocatorCustomerLocationService({
    CustomerCoordinatesLoader? coordinatesLoader,
    this.timeout = defaultTimeout,
  }) : _coordinatesLoader =
           coordinatesLoader ?? (() => _loadCoordinates(timeout));

  @override
  CustomerCoordinates? get cachedCoordinates => _cachedCoordinates;

  @override
  Future<CustomerLocationResult> getCurrentLocation() async {
    final cachedCoordinates = _cachedCoordinates;
    if (cachedCoordinates != null) {
      return CustomerLocationResult.success(cachedCoordinates);
    }

    try {
      final coordinates =
          await (_activeCoordinatesRequest ??= _startCoordinatesRequest())
              .timeout(timeout);

      if (!coordinates.isValid) {
        return const CustomerLocationResult.failed(
          CustomerLocationFailure.unavailable,
        );
      }

      _cachedCoordinates = coordinates;
      return CustomerLocationResult.success(coordinates);
    } on PermissionDeniedException {
      return const CustomerLocationResult.failed(
        CustomerLocationFailure.permissionDenied,
      );
    } on LocationServiceDisabledException {
      return const CustomerLocationResult.failed(
        CustomerLocationFailure.servicesDisabled,
      );
    } on TimeoutException {
      return const CustomerLocationResult.failed(
        CustomerLocationFailure.timedOut,
      );
    } catch (_) {
      return const CustomerLocationResult.failed(
        CustomerLocationFailure.unavailable,
      );
    }
  }

  Future<CustomerCoordinates> _startCoordinatesRequest() {
    final request = _coordinatesLoader();

    unawaited(
      request.then<void>(
        (coordinates) {
          if (coordinates.isValid) {
            _cachedCoordinates = coordinates;
          }
          _clearActiveRequest(request);
        },
        onError: (Object _, StackTrace _) {
          _clearActiveRequest(request);
        },
      ),
    );

    return request;
  }

  void _clearActiveRequest(Future<CustomerCoordinates> request) {
    if (identical(_activeCoordinatesRequest, request)) {
      _activeCoordinatesRequest = null;
    }
  }

  static Future<CustomerCoordinates> _loadCoordinates(Duration timeout) async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: timeout,
      ),
    );

    return CustomerCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
