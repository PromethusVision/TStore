import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/widgets/other_same_products_list.dart';
import 'package:t_store/features/shop/presentation/widgets/selected_product_image.dart';
import 'package:t_store/features/wishlist/presentation/widgets/product_favorite_button.dart';

class ProductImageSlider extends StatelessWidget {
  const ProductImageSlider({
    super.key,
    required this.product,
    this.currentUserIdProvider,
    this.visualPrototype = false,
  });

  final ProductEntity product;
  final ProductFavoriteCurrentUserIdProvider? currentUserIdProvider;
  final bool visualPrototype;

  @override
  Widget build(BuildContext context) {
    final productImages = _productImages;
    if (visualPrototype) {
      return _buildVisualPrototype(productImages);
    }

    return Container(
      key: const Key('product-details-media'),
      height: 340,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.mint,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius24),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: SelectedProductImage(
              image: productImages.first,
              height: 340,
              imageExtent: 245,
              padding: const EdgeInsets.fromLTRB(30, 38, 30, 54),
            ),
          ),
          if (productImages.length > 1)
            OtherSameProductsList(images: productImages),
          Positioned(
            left: 12,
            top: 12,
            child: Material(
              color: CustomerHomeV1Tokens.surface,
              shape: const CircleBorder(),
              child: IconButton(
                key: const Key('product-details-back-button'),
                tooltip: 'Geri',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: CustomerHomeV1Tokens.navy,
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: ProductFavoriteButton(
              productId: product.id,
              keyPrefix: 'product-details-favorite',
              currentUserIdProvider: currentUserIdProvider,
              height: 44,
              width: 44,
              iconSize: 21,
              backgroundColor: CustomerHomeV1Tokens.surface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualPrototype(List<String> productImages) {
    return Container(
      key: const Key('product-details-media'),
      height: 224,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surface,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.xxLarge),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
        boxShadow: EsnaftaVarElevation.xs,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: SelectedProductImage(
              image: productImages.first,
              height: 224,
              imageExtent: 184,
              padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
            ),
          ),
          if (productImages.length > 1)
            Positioned(
              right: EsnaftaVarSpacing.sm,
              bottom: EsnaftaVarSpacing.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: EsnaftaVarSpacing.sm,
                  vertical: EsnaftaVarSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: EsnaftaVarColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(EsnaftaVarRadii.pill),
                  border: Border.all(color: EsnaftaVarColors.borderDefault),
                ),
                child: Text(
                  '${productImages.length} görsel',
                  style: const TextStyle(
                    color: EsnaftaVarColors.textSecondary,
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<String> get _productImages {
    final images = product.images
        .where((image) => image.trim().isNotEmpty)
        .toList(growable: false);

    if (images.isNotEmpty) return images;

    final thumbnail = product.thumbnail;
    if (thumbnail != null && thumbnail.trim().isNotEmpty) {
      return [thumbnail];
    }

    return const [TImages.productImage13];
  }
}
