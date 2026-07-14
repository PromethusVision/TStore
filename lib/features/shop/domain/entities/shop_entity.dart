import 'package:equatable/equatable.dart';

class ShopEntity extends Equatable {
  final String id;
  final String? ownerUserId;
  final String name;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final Map<String, dynamic> openingHours;
  final bool isActive;
  final double rating;
  final int ratingCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ShopEntity({
    required this.id,
    this.ownerUserId,
    required this.name,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.phone,
    this.openingHours = const {},
    this.isActive = true,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    ownerUserId,
    name,
    description,
    address,
    latitude,
    longitude,
    phone,
    openingHours,
    isActive,
    rating,
    ratingCount,
    createdAt,
    updatedAt,
  ];

  ShopEntity copyWith({
    String? id,
    String? ownerUserId,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    Map<String, dynamic>? openingHours,
    bool? isActive,
    double? rating,
    int? ratingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShopEntity(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      openingHours: openingHours ?? this.openingHours,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
