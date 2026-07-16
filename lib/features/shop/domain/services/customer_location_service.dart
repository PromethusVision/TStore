import 'package:equatable/equatable.dart';

class CustomerCoordinates extends Equatable {
  final double latitude;
  final double longitude;

  const CustomerCoordinates({required this.latitude, required this.longitude});

  bool get isValid =>
      latitude.isFinite &&
      longitude.isFinite &&
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  @override
  List<Object?> get props => [latitude, longitude];
}

class CustomerPreferredLocation extends Equatable {
  final String name;
  final CustomerCoordinates coordinates;

  const CustomerPreferredLocation({
    required this.name,
    required this.coordinates,
  });

  bool get isValid => name.trim().isNotEmpty && coordinates.isValid;

  @override
  List<Object?> get props => [name, coordinates];
}

enum CustomerLocationFailure {
  permissionDenied,
  servicesDisabled,
  timedOut,
  unavailable,
}

class CustomerLocationResult extends Equatable {
  final CustomerCoordinates? coordinates;
  final CustomerLocationFailure? failure;

  const CustomerLocationResult.success(CustomerCoordinates value)
    : coordinates = value,
      failure = null;

  const CustomerLocationResult.failed(CustomerLocationFailure value)
    : coordinates = null,
      failure = value;

  bool get isSuccess => coordinates != null && failure == null;

  @override
  List<Object?> get props => [coordinates, failure];
}

abstract class CustomerLocationService {
  CustomerCoordinates? get cachedCoordinates;

  Future<CustomerPreferredLocation?> getPreferredLocation();

  Future<CustomerLocationResult> getCurrentLocation({
    bool forceRefresh = false,
  });
}
