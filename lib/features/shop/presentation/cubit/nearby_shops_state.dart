import 'package:equatable/equatable.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';

enum NearbyLocationStatus {
  idle,
  requesting,
  ready,
  permissionDenied,
  servicesDisabled,
  timedOut,
  unavailable,
}

abstract class NearbyShopsState extends Equatable {
  const NearbyShopsState();

  @override
  List<Object?> get props => [];
}

class NearbyShopsInitial extends NearbyShopsState {
  const NearbyShopsInitial();
}

class NearbyShopsLoading extends NearbyShopsState {
  const NearbyShopsLoading();
}

class NearbyShopsLoaded extends NearbyShopsState {
  final List<ShopEntity> shops;
  final NearbyLocationStatus locationStatus;
  final Map<String, double> distanceMetersByShopId;

  const NearbyShopsLoaded(
    this.shops, {
    this.locationStatus = NearbyLocationStatus.idle,
    this.distanceMetersByShopId = const <String, double>{},
  });

  double? distanceForShop(String shopId) => distanceMetersByShopId[shopId];

  NearbyShopsLoaded copyWith({
    List<ShopEntity>? shops,
    NearbyLocationStatus? locationStatus,
    Map<String, double>? distanceMetersByShopId,
  }) {
    return NearbyShopsLoaded(
      shops ?? this.shops,
      locationStatus: locationStatus ?? this.locationStatus,
      distanceMetersByShopId:
          distanceMetersByShopId ?? this.distanceMetersByShopId,
    );
  }

  @override
  List<Object?> get props => [shops, locationStatus, distanceMetersByShopId];
}

class NearbyShopsEmpty extends NearbyShopsState {
  const NearbyShopsEmpty();
}

class NearbyShopsError extends NearbyShopsState {
  final String message;

  const NearbyShopsError(this.message);

  @override
  List<Object?> get props => [message];
}
