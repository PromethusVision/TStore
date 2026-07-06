import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  static const String customerRole = 'customer';
  static const String merchantRole = 'merchant';
  static const String adminRole = 'admin';

  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String role;

  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
    this.role = customerRole,
  });

  bool get isCustomer => role == customerRole;

  bool get isMerchant => role == merchantRole;

  bool get isAdmin => role == adminRole;

  bool get canManageShop => isMerchant || isAdmin;

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phone,
        avatarUrl,
        createdAt,
        updatedAt,
        role,
      ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? role,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
    );
  }
}
