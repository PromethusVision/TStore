import 'package:t_store/features/shop/data/models/product_model.dart';
import 'package:t_store/features/shop/data/models/shop_model.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';

class ShopProductModel extends ShopProductEntity {
  const ShopProductModel({
    required super.id,
    required super.shopId,
    required super.productId,
    required super.price,
    super.isAvailable,
    super.description,
    super.images,
    super.isActive,
    super.createdAt,
    super.updatedAt,
    super.product,
    super.shop,
  });

  factory ShopProductModel.fromJson(Map<String, dynamic> json) {
    return ShopProductModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      productId: json['product_id'] as String,
      price: _toDouble(json['price']),
      isAvailable: json['is_available'] as bool? ?? true,
      description: json['description'] as String?,
      images: _toStringList(json['images']),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: _toNullableDateTime(json['created_at']),
      updatedAt: _toNullableDateTime(json['updated_at']),
      product: _parseProduct(json['products'] ?? json['product']),
      shop: _parseShop(json['shops'] ?? json['shop']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'product_id': productId,
      'price': price,
      'is_available': isAvailable,
      'description': description,
      'images': images,
      'is_active': isActive,
    };
  }

  factory ShopProductModel.fromEntity(ShopProductEntity entity) {
    return ShopProductModel(
      id: entity.id,
      shopId: entity.shopId,
      productId: entity.productId,
      price: entity.price,
      isAvailable: entity.isAvailable,
      description: entity.description,
      images: entity.images,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      product: entity.product,
      shop: entity.shop,
    );
  }

  static ProductEntity? _parseProduct(dynamic value) {
    if (value is Map<String, dynamic>) return ProductModel.fromJson(value);
    if (value is Map) {
      return ProductModel.fromJson(Map<String, dynamic>.from(value));
    }
    return null;
  }

  static ShopEntity? _parseShop(dynamic value) {
    if (value is Map<String, dynamic>) return ShopModel.fromJson(value);
    if (value is Map) {
      return ShopModel.fromJson(Map<String, dynamic>.from(value));
    }
    return null;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return <String>[];
  }

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
