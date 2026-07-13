import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';
import 'package:t_store/features/shop/domain/usecases/get_shops_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_state.dart';
import 'package:t_store/features/shop/presentation/helpers/customer_proximity_helper.dart';

class NearbyShopsCubit extends Cubit<NearbyShopsState> {
  final GetShopsUsecase getShopsUsecase;
  final CustomerLocationService customerLocationService;

  int _activeRequestId = 0;
  int _locationRequestId = 0;
  bool _isLocationRequestInProgress = false;
  CustomerCoordinates? _lastCoordinates;

  NearbyShopsCubit({
    required this.getShopsUsecase,
    required this.customerLocationService,
  }) : _lastCoordinates = customerLocationService.cachedCoordinates,
       super(const NearbyShopsInitial());

  Future<void> loadShops() async {
    if (_isLocationRequestInProgress) return;

    final requestId = ++_activeRequestId;
    emit(const NearbyShopsLoading());

    final result = await getShopsUsecase(const NoParams());

    if (isClosed || requestId != _activeRequestId) return;

    result.fold((error) => emit(NearbyShopsError(error)), (shops) {
      if (shops.isEmpty) {
        emit(const NearbyShopsEmpty());
        return;
      }

      final coordinates = _lastCoordinates;
      emit(
        coordinates == null
            ? NearbyShopsLoaded(shops)
            : _buildLocationReadyState(shops, coordinates),
      );
    });
  }

  Future<void> useCurrentLocation() async {
    final currentState = state;
    if (_isLocationRequestInProgress ||
        currentState is! NearbyShopsLoaded ||
        currentState.locationStatus == NearbyLocationStatus.ready) {
      return;
    }

    final requestId = ++_locationRequestId;
    _isLocationRequestInProgress = true;
    emit(
      currentState.copyWith(
        locationStatus: NearbyLocationStatus.requesting,
        distanceMetersByShopId: const <String, double>{},
      ),
    );

    final result = await customerLocationService.getCurrentLocation();

    if (isClosed || requestId != _locationRequestId) return;
    _isLocationRequestInProgress = false;

    final latestState = state;
    if (latestState is! NearbyShopsLoaded) return;

    final coordinates = result.coordinates;
    if (result.isSuccess && coordinates != null && coordinates.isValid) {
      _lastCoordinates = coordinates;
      emit(_buildLocationReadyState(latestState.shops, coordinates));
      return;
    }

    emit(
      latestState.copyWith(
        locationStatus: _statusForFailure(result.failure),
        distanceMetersByShopId: const <String, double>{},
      ),
    );
  }

  NearbyShopsLoaded _buildLocationReadyState(
    List<ShopEntity> shops,
    CustomerCoordinates customerCoordinates,
  ) {
    final rankedShops = <_RankedShop>[];
    final distances = <String, double>{};

    for (var index = 0; index < shops.length; index++) {
      final shop = shops[index];
      final distance = CustomerProximityHelper.distanceInMeters(
        from: customerCoordinates,
        latitude: shop.latitude,
        longitude: shop.longitude,
      );

      if (distance != null) {
        distances[shop.id] = distance;
      }

      rankedShops.add(
        _RankedShop(shop: shop, originalIndex: index, distanceMeters: distance),
      );
    }

    rankedShops.sort((first, second) {
      final firstDistance = first.distanceMeters;
      final secondDistance = second.distanceMeters;

      if (firstDistance == null && secondDistance == null) {
        return first.originalIndex.compareTo(second.originalIndex);
      }
      if (firstDistance == null) return 1;
      if (secondDistance == null) return -1;

      final distanceComparison = firstDistance.compareTo(secondDistance);
      return distanceComparison != 0
          ? distanceComparison
          : first.originalIndex.compareTo(second.originalIndex);
    });

    return NearbyShopsLoaded(
      rankedShops.map((rankedShop) => rankedShop.shop).toList(growable: false),
      locationStatus: NearbyLocationStatus.ready,
      distanceMetersByShopId: Map<String, double>.unmodifiable(distances),
    );
  }

  static NearbyLocationStatus _statusForFailure(
    CustomerLocationFailure? failure,
  ) {
    return switch (failure) {
      CustomerLocationFailure.permissionDenied =>
        NearbyLocationStatus.permissionDenied,
      CustomerLocationFailure.servicesDisabled =>
        NearbyLocationStatus.servicesDisabled,
      CustomerLocationFailure.timedOut => NearbyLocationStatus.timedOut,
      CustomerLocationFailure.unavailable ||
      null => NearbyLocationStatus.unavailable,
    };
  }
}

class _RankedShop {
  final ShopEntity shop;
  final int originalIndex;
  final double? distanceMeters;

  const _RankedShop({
    required this.shop,
    required this.originalIndex,
    required this.distanceMeters,
  });
}
