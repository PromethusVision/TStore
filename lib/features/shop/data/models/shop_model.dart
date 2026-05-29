import 'package:t_store/features/shop/domain/entities/shop_entity.dart';

class ShopModel extends ShopEntity {
  const ShopModel({
    required super.id,
    super.ownerUserId,
    required super.name,
    super.description,
    super.address,
    super.latitude,
    super.longitude,
    super.phone,
    super.openingHours,
    super.isActive,
    super.rating,
    super.createdAt,
    super.updatedAt,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] as String,
      ownerUserId: json['owner_user_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      latitude: _toNullableDouble(json['latitude']),
      longitude: _toNullableDouble(json['longitude']),
      phone: json['phone'] as String?,
      openingHours: _toMap(json['opening_hours']),
      isActive: json['is_active'] as bool? ?? true,
      rating: _toDouble(json['rating']),
      createdAt: _toNullableDateTime(json['created_at']),
      updatedAt: _toNullableDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_user_id': ownerUserId,
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'opening_hours': openingHours,
      'is_active': isActive,
      'rating': rating,
    };
  }

  factory ShopModel.fromEntity(ShopEntity entity) {
    return ShopModel(
      id: entity.id,
      ownerUserId: entity.ownerUserId,
      name: entity.name,
      description: entity.description,
      address: entity.address,
      latitude: entity.latitude,
      longitude: entity.longitude,
      phone: entity.phone,
      openingHours: entity.openingHours,
      isActive: entity.isActive,
      rating: entity.rating,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static double _toDouble(dynamic value) {
    return _toNullableDouble(value) ?? 0.0;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
