import 'package:equatable/equatable.dart';

class QrSessionEntity extends Equatable {
  final String id;
  final String sessionToken;
  final String userId;
  final String cartId;
  final String shopId;
  final String status;
  final DateTime expiresAt;
  final DateTime? usedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? itemCount;
  final double? totalAmount;

  const QrSessionEntity({
    required this.id,
    required this.sessionToken,
    required this.userId,
    required this.cartId,
    required this.shopId,
    required this.status,
    required this.expiresAt,
    this.usedAt,
    required this.createdAt,
    required this.updatedAt,
    this.itemCount,
    this.totalAmount,
  });

  bool get isActive => status == 'active' && expiresAt.isAfter(DateTime.now());

  @override
  List<Object?> get props => [
    id,
    sessionToken,
    userId,
    cartId,
    shopId,
    status,
    expiresAt,
    usedAt,
    createdAt,
    updatedAt,
    itemCount,
    totalAmount,
  ];
}
