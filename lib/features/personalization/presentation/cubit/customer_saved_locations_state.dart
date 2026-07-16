import 'package:equatable/equatable.dart';
import 'package:t_store/features/personalization/domain/entities/customer_saved_location_entity.dart';

abstract class CustomerSavedLocationsState extends Equatable {
  const CustomerSavedLocationsState();

  @override
  List<Object?> get props => [];
}

class CustomerSavedLocationsInitial extends CustomerSavedLocationsState {
  const CustomerSavedLocationsInitial();
}

class CustomerSavedLocationsLoading extends CustomerSavedLocationsState {
  const CustomerSavedLocationsLoading();
}

class CustomerSavedLocationsLoaded extends CustomerSavedLocationsState {
  const CustomerSavedLocationsLoaded({
    required this.locations,
    this.isBusy = false,
    this.busyLocationId,
  });

  final List<CustomerSavedLocationEntity> locations;
  final bool isBusy;
  final String? busyLocationId;

  CustomerSavedLocationsLoaded copyWith({
    List<CustomerSavedLocationEntity>? locations,
    bool? isBusy,
    String? busyLocationId,
    bool clearBusyLocationId = false,
  }) {
    return CustomerSavedLocationsLoaded(
      locations: locations ?? this.locations,
      isBusy: isBusy ?? this.isBusy,
      busyLocationId: clearBusyLocationId
          ? null
          : busyLocationId ?? this.busyLocationId,
    );
  }

  @override
  List<Object?> get props => [locations, isBusy, busyLocationId];
}

class CustomerSavedLocationsError extends CustomerSavedLocationsState {
  const CustomerSavedLocationsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
