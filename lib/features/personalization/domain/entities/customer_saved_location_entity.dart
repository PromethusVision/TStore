import 'package:equatable/equatable.dart';

class CustomerSavedLocationEntity extends Equatable {
  const CustomerSavedLocationEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.addressText,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final String addressText;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerSavedLocationEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? addressText,
    double? latitude,
    double? longitude,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerSavedLocationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      addressText: addressText ?? this.addressText,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    addressText,
    latitude,
    longitude,
    isDefault,
    createdAt,
    updatedAt,
  ];
}
