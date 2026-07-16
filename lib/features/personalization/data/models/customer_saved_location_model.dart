import 'package:t_store/features/personalization/domain/entities/customer_saved_location_entity.dart';

class CustomerSavedLocationModel extends CustomerSavedLocationEntity {
  const CustomerSavedLocationModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.addressText,
    required super.latitude,
    required super.longitude,
    super.isDefault,
    super.createdAt,
    super.updatedAt,
  });

  factory CustomerSavedLocationModel.fromJson(Map<String, dynamic> json) {
    return CustomerSavedLocationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      addressText: json['address_text'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );
  }
}
