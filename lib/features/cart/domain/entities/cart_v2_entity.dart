import 'package:equatable/equatable.dart';

class CartV2Entity extends Equatable {
  final String id;
  final String userId;
  final String shopId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CartV2Entity({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 'active';

  @override
  List<Object?> get props => [
        id,
        userId,
        shopId,
        status,
        createdAt,
        updatedAt,
      ];

  CartV2Entity copyWith({
    String? id,
    String? userId,
    String? shopId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartV2Entity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopId: shopId ?? this.shopId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
