import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/personalization/domain/entities/customer_saved_location_entity.dart';
import 'package:t_store/features/personalization/domain/repositories/customer_saved_location_repository.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_state.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';

class CustomerSavedLocationsCubit extends Cubit<CustomerSavedLocationsState> {
  CustomerSavedLocationsCubit({
    required this.repository,
    required this.customerLocationService,
  }) : super(const CustomerSavedLocationsInitial());

  final CustomerSavedLocationRepository repository;
  final CustomerLocationService customerLocationService;

  List<CustomerSavedLocationEntity> _locations = [];

  Future<void> loadLocations() async {
    final currentState = state;
    if (currentState is CustomerSavedLocationsLoaded && currentState.isBusy) {
      return;
    }

    emit(const CustomerSavedLocationsLoading());
    final result = await repository.getLocations();

    result.fold(
      (_) => emit(
        const CustomerSavedLocationsError(
          'Kayıtlı konumların şu anda yüklenemiyor. Lütfen tekrar dene.',
        ),
      ),
      (locations) {
        _locations = List.of(locations);
        emit(CustomerSavedLocationsLoaded(locations: _locations));
      },
    );
  }

  Future<CustomerLocationResult> captureCurrentLocation() {
    return customerLocationService.getCurrentLocation(forceRefresh: true);
  }

  Future<bool> addLocation({
    required String name,
    required String addressText,
    required CustomerCoordinates coordinates,
  }) async {
    if (state is! CustomerSavedLocationsLoaded) return false;
    final previousState = state as CustomerSavedLocationsLoaded;
    if (previousState.isBusy) return false;

    emit(previousState.copyWith(isBusy: true, clearBusyLocationId: true));
    final result = await repository.addLocation(
      name: name.trim(),
      addressText: addressText.trim(),
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
      isDefault: _locations.isEmpty,
    );

    return result.fold(
      (_) {
        emit(previousState);
        return false;
      },
      (location) {
        _locations = _defaultFirst([location, ..._locations]);
        emit(CustomerSavedLocationsLoaded(locations: _locations));
        return true;
      },
    );
  }

  Future<bool> setDefaultLocation(String locationId) async {
    if (state is! CustomerSavedLocationsLoaded) return false;
    final previousState = state as CustomerSavedLocationsLoaded;
    if (previousState.isBusy ||
        _locations.any(
          (location) => location.id == locationId && location.isDefault,
        )) {
      return false;
    }

    emit(previousState.copyWith(isBusy: true, busyLocationId: locationId));
    final result = await repository.setDefaultLocation(locationId);

    return result.fold(
      (_) {
        emit(previousState);
        return false;
      },
      (_) {
        _locations = _defaultFirst(
          _locations.map(
            (location) =>
                location.copyWith(isDefault: location.id == locationId),
          ),
        );
        emit(CustomerSavedLocationsLoaded(locations: _locations));
        return true;
      },
    );
  }

  Future<bool> deleteLocation(String locationId) async {
    if (state is! CustomerSavedLocationsLoaded) return false;
    final previousState = state as CustomerSavedLocationsLoaded;
    if (previousState.isBusy) return false;

    emit(previousState.copyWith(isBusy: true, busyLocationId: locationId));
    final result = await repository.deleteLocation(locationId);

    return result.fold(
      (_) {
        emit(previousState);
        return false;
      },
      (_) {
        final removedLocation = _locations.firstWhere(
          (location) => location.id == locationId,
        );
        _locations = _locations
            .where((location) => location.id != locationId)
            .toList(growable: false);
        if (removedLocation.isDefault && _locations.isNotEmpty) {
          _locations = [
            _locations.first.copyWith(isDefault: true),
            ..._locations.skip(1),
          ];
        }
        emit(CustomerSavedLocationsLoaded(locations: _locations));
        return true;
      },
    );
  }

  List<CustomerSavedLocationEntity> _defaultFirst(
    Iterable<CustomerSavedLocationEntity> locations,
  ) {
    final sortedLocations = locations.toList(growable: false);
    sortedLocations.sort((first, second) {
      if (first.isDefault == second.isDefault) return 0;
      return first.isDefault ? -1 : 1;
    });
    return sortedLocations;
  }
}
