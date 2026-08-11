import 'package:t_store/features/shop/domain/entities/banner_entity.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.imageUrl,
    super.title,
    super.subtitle,
    super.actionUrl,
    super.actionType,
    super.sortOrder,
    super.isActive,
    super.startDate,
    super.endDate,
    super.createdAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    final model = BannerModel.tryFromJson(json);
    if (model == null) {
      throw const FormatException('Invalid banner payload.');
    }
    return model;
  }

  static BannerModel? tryFromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']);
    final imageUrl = _readString(json['image_url']);
    final startDate = _readDate(json['start_date']);
    final endDate = _readDate(json['end_date']);
    final sortOrder = _readInt(json['sort_order']);
    final isActive = _readBool(json['is_active']);

    if (id.isEmpty || imageUrl.isEmpty) return null;
    if (sortOrder == null || isActive == null) return null;
    if (_hasInvalidDate(json['start_date'], startDate) ||
        _hasInvalidDate(json['end_date'], endDate)) {
      return null;
    }
    if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
      return null;
    }

    return BannerModel(
      id: id,
      imageUrl: imageUrl,
      title: _readNullableString(json['title']),
      subtitle: _readNullableString(json['subtitle']),
      actionUrl: _readNullableString(json['action_url']),
      actionType: _readNullableString(json['action_type']),
      sortOrder: sortOrder,
      isActive: isActive,
      startDate: startDate,
      endDate: endDate,
      createdAt: _readDate(json['created_at']),
    );
  }

  static String _readString(Object? value) =>
      value is String ? value.trim() : '';

  static String? _readNullableString(Object? value) {
    final text = _readString(value);
    return text.isEmpty ? null : text;
  }

  static int? _readInt(Object? value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num && value == value.toInt()) return value.toInt();
    return value is String ? int.tryParse(value) : null;
  }

  static bool? _readBool(Object? value) {
    if (value == null) return true;
    if (value is bool) return value;
    if (value is String) {
      if (value.toLowerCase() == 'false') return false;
      if (value.toLowerCase() == 'true') return true;
    }
    return null;
  }

  static DateTime? _readDate(Object? value) {
    if (value is DateTime) return value;
    if (value is! String || value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }

  static bool _hasInvalidDate(Object? rawValue, DateTime? parsedValue) =>
      rawValue != null &&
      (!(rawValue is String && rawValue.trim().isEmpty)) &&
      parsedValue == null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'title': title,
      'subtitle': subtitle,
      'action_url': actionUrl,
      'action_type': actionType,
      'sort_order': sortOrder,
      'is_active': isActive,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }

  factory BannerModel.fromEntity(BannerEntity entity) {
    return BannerModel(
      id: entity.id,
      imageUrl: entity.imageUrl,
      title: entity.title,
      subtitle: entity.subtitle,
      actionUrl: entity.actionUrl,
      actionType: entity.actionType,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
      startDate: entity.startDate,
      endDate: entity.endDate,
      createdAt: entity.createdAt,
    );
  }
}
