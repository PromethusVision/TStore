import 'package:t_store/core/supabase/public_media_source_resolver.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    super.description,
    super.imageUrl,
    super.parentId,
    super.sortOrder,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory CategoryModel.fromJson(
    Map<String, dynamic> json, {
    PublicMediaSourceResolver? mediaResolver,
  }) {
    final id = json['id'] as String;
    final rawImageUrl = json['image_url'] as String?;

    return CategoryModel(
      id: id,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl:
          mediaResolver?.resolveCategory(rawImageUrl, categoryId: id) ??
          (mediaResolver == null ? rawImageUrl : null),
      parentId: json['parent_id'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'parent_id': parentId,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      imageUrl: entity.imageUrl,
      parentId: entity.parentId,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
