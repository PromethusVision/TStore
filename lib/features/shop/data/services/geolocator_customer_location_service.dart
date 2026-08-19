import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';

typedef CustomerCoordinatesLoader = Future<CustomerCoordinates> Function();
typedef CustomerCoordinatesFallbackLoader =
    Future<CustomerCoordinates?> Function();
typedef CustomerPreferredLocationLoader =
    Future<CustomerPreferredLocation?> Function();
typedef CustomerLocationServiceStatusLoader = Future<bool> Function();
typedef CustomerLocationPermissionLoader =
    Future<LocationPermission> Function();
typedef CustomerLocationSettingsOpener = Future<bool> Function();

class GeolocatorCustomerLocationService implements CustomerLocationService {
  static const Duration defaultTimeout = Duration(seconds: 30);

  final CustomerCoordinatesLoader _coordinatesLoader;
  final CustomerCoordinatesFallbackLoader _lastKnownCoordinatesLoader;
  final CustomerPreferredLocationLoader? _preferredLocationLoader;
  final CustomerLocationServiceStatusLoader _serviceStatusLoader;
  final CustomerLocationPermissionLoader _permissionLoader;
  final CustomerLocationPermissionLoader _permissionRequester;
  final CustomerLocationSettingsOpener _appSettingsOpener;
  final CustomerLocationSettingsOpener _locationSettingsOpener;
  final Duration timeout;
  Future<CustomerCoordinates>? _activeCoordinatesRequest;
  CustomerCoordinates? _cachedCoordinates;

  GeolocatorCustomerLocationService({
    CustomerCoordinatesLoader? coordinatesLoader,
    CustomerCoordinatesFallbackLoader? lastKnownCoordinatesLoader,
    CustomerPreferredLocationLoader? preferredLocationLoader,
    CustomerLocationServiceStatusLoader? serviceStatusLoader,
    CustomerLocationPermissionLoader? permissionLoader,
    CustomerLocationPermissionLoader? permissionRequester,
    CustomerLocationSettingsOpener? appSettingsOpener,
    CustomerLocationSettingsOpener? locationSettingsOpener,
    this.timeout = defaultTimeout,
  }) : _coordinatesLoader =
           coordinatesLoader ?? (() => _loadCoordinates(timeout)),
       _lastKnownCoordinatesLoader =
           lastKnownCoordinatesLoader ??
           (coordinatesLoader == null
               ? _loadLastKnownCoordinates
               : (() async => null)),
       _preferredLocationLoader = preferredLocationLoader,
       _serviceStatusLoader =
           serviceStatusLoader ??
           (coordinatesLoader == null
               ? Geolocator.isLocationServiceEnabled
               : (() async => true)),
       _permissionLoader =
           permissionLoader ??
           (coordinatesLoader == null
               ? Geolocator.checkPermission
               : (() async => LocationPermission.always)),
       _permissionRequester =
           permissionRequester ??
           (coordinatesLoader == null
               ? Geolocator.requestPermission
               : (() async => LocationPermission.always)),
       _appSettingsOpener = appSettingsOpener ?? Geolocator.openAppSettings,
       _locationSettingsOpener =
           locationSettingsOpener ?? Geolocator.openLocationSettings;

  @override
  CustomerCoordinates? get cachedCoordinates => _cachedCoordinates;

  @override
  Future<CustomerPreferredLocation?> getPreferredLocation() async {
    final loader = _preferredLocationLoader;
    if (loader == null) return null;

    try {
      final location = await loader();
      return location?.isValid == true ? location : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<CustomerLocationResult> getCurrentLocation({
    bool forceRefresh = false,
  }) async {
    final cachedCoordinates = _cachedCoordinates;
    if (!forceRefresh && cachedCoordinates != null) {
      return CustomerLocationResult.success(cachedCoordinates);
    }

    try {
      if (!await _serviceStatusLoader()) {
        return const CustomerLocationResult.failed(
          CustomerLocationFailure.servicesDisabled,
        );
      }

      var permission = await _permissionLoader();
      if (permission == LocationPermission.denied) {
        permission = await _permissionRequester();
      }
      if (permission == LocationPermission.deniedForever) {
        return const CustomerLocationResult.failed(
          CustomerLocationFailure.permissionDeniedForever,
        );
      }
      if (!_isGranted(permission)) {
        return const CustomerLocationResult.failed(
          CustomerLocationFailure.permissionDenied,
        );
      }

      final coordinatesAfterPermissionCheck = _cachedCoordinates;
      if (!forceRefresh && coordinatesAfterPermissionCheck != null) {
        return CustomerLocationResult.success(coordinatesAfterPermissionCheck);
      }

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
      return _fallbackOrFailure(CustomerLocationFailure.timedOut);
    } catch (_) {
      return _fallbackOrFailure(CustomerLocationFailure.unavailable);
    }
  }

  @override
  Future<bool> openAppSettings() => _appSettingsOpener();

  @override
  Future<bool> openLocationSettings() => _locationSettingsOpener();

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

  Future<CustomerLocationResult> _fallbackOrFailure(
    CustomerLocationFailure failure,
  ) async {
    try {
      final coordinates = await _lastKnownCoordinatesLoader();
      if (coordinates != null && coordinates.isValid) {
        _cachedCoordinates = coordinates;
        return CustomerLocationResult.success(coordinates);
      }
    } catch (_) {
      // A missing/stale fallback must not replace the classified primary error.
    }
    return CustomerLocationResult.failed(failure);
  }

  static bool _isGranted(LocationPermission permission) {
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
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

  static Future<CustomerCoordinates?> _loadLastKnownCoordinates() async {
    final position = await Geolocator.getLastKnownPosition();
    if (position == null) return null;

    return CustomerCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
