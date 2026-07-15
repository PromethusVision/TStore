import 'package:equatable/equatable.dart';
import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';

abstract class PurchaseHistoryState extends Equatable {
  const PurchaseHistoryState();

  @override
  List<Object?> get props => [];
}

class PurchaseHistoryInitial extends PurchaseHistoryState {}

class PurchaseHistoryLoading extends PurchaseHistoryState {}

class PurchaseHistoryLoaded extends PurchaseHistoryState {
  final List<VerifiedPurchaseEntity> purchases;

  const PurchaseHistoryLoaded(this.purchases);

  @override
  List<Object?> get props => [purchases];
}

class PurchaseHistoryError extends PurchaseHistoryState {
  final String message;

  const PurchaseHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
