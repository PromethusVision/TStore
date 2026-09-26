import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  final String id;
  final String imageUrl;
  final String? title;
  final String? subtitle;
  final String? actionUrl;
  final String? actionType;
  final int sortOrder;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final int contentVersion;
  final String audience;
  final String? ctaText;
  final String? city;
  final String? district;
  final String? categoryScope;

  const BannerEntity({
    required this.id,
    required this.imageUrl,
    this.title,
    this.subtitle,
    this.actionUrl,
    this.actionType,
    this.sortOrder = 0,
    this.isActive = true,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.contentVersion = 1,
    this.audience = 'general',
    this.ctaText,
    this.city,
    this.district,
    this.categoryScope,
  });

  bool isActiveAt(DateTime instant) {
    if (!isActive) return false;
    if (startDate != null && instant.isBefore(startDate!)) return false;
    if (endDate != null && instant.isAfter(endDate!)) return false;
    return true;
  }

  bool get isCurrentlyActive => isActiveAt(DateTime.now());

  @override
  List<Object?> get props => [
    id,
    imageUrl,
    title,
    subtitle,
    actionUrl,
    actionType,
    sortOrder,
    isActive,
    startDate,
    endDate,
    createdAt,
    contentVersion,
    audience,
    ctaText,
    city,
    district,
    categoryScope,
  ];

  BannerEntity copyWith({
    String? id,
    String? imageUrl,
    String? title,
    String? subtitle,
    String? actionUrl,
    String? actionType,
    int? sortOrder,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    int? contentVersion,
    String? audience,
    String? ctaText,
    String? city,
    String? district,
    String? categoryScope,
  }) {
    return BannerEntity(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      actionUrl: actionUrl ?? this.actionUrl,
      actionType: actionType ?? this.actionType,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      contentVersion: contentVersion ?? this.contentVersion,
      audience: audience ?? this.audience,
      ctaText: ctaText ?? this.ctaText,
      city: city ?? this.city,
      district: district ?? this.district,
      categoryScope: categoryScope ?? this.categoryScope,
    );
  }
}
