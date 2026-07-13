import 'package:equatable/equatable.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';

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

  const NearbyShopsLoaded(this.shops);

  @override
  List<Object?> get props => [shops];
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
