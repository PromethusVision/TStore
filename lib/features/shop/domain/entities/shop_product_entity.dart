import 'package:equatable/equatable.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';

class ShopProductEntity extends Equatable {
  final String id;
  final String shopId;
  final String productId;
  final double price;
  final bool isAvailable;
  final String? description;
  final List<String> images;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ProductEntity? product;
  final ShopEntity? shop;

  const ShopProductEntity({
    required this.id,
    required this.shopId,
    required this.productId,
    required this.price,
    this.isAvailable = true,
    this.description,
    this.images = const [],
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.product,
    this.shop,
  });

  bool get hasImages => images.isNotEmpty;

  double get displayPrice => price;

  @override
  List<Object?> get props => [
        id,
        shopId,
        productId,
        price,
        isAvailable,
        description,
        images,
        isActive,
        createdAt,
        updatedAt,
        product,
        shop,
      ];

  ShopProductEntity copyWith({
    String? id,
    String? shopId,
    String? productId,
    double? price,
    bool? isAvailable,
    String? description,
    List<String>? images,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProductEntity? product,
    ShopEntity? shop,
  }) {
    return ShopProductEntity(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      productId: productId ?? this.productId,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      description: description ?? this.description,
      images: images ?? this.images,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      product: product ?? this.product,
      shop: shop ?? this.shop,
    );
  }
}
