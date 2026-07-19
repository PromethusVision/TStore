import 'package:flutter/material.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/common/widgets/curved_widget.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/widgets/other_same_products_list.dart';
import 'package:t_store/features/shop/presentation/widgets/selected_product_image.dart';
import 'package:t_store/features/wishlist/presentation/widgets/product_favorite_button.dart';

class ProductImageSlider extends StatelessWidget {
  const ProductImageSlider({
    super.key,
    required this.product,
    this.currentUserIdProvider,
  });

  final ProductEntity product;
  final ProductFavoriteCurrentUserIdProvider? currentUserIdProvider;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final productImages = _productImages;

    return CurvedWidget(
      child: Container(
        decoration: BoxDecoration(
          color: dark ? TColors.darkGrey : TColors.light,
        ),
        child: Stack(
          children: [
            SelectedProductImage(image: productImages.first),
            OtherSameProductsList(images: productImages),
            CustomAppBar(
              appBarModel: AppBarModel(
                hasArrowBack: true,
                actions: [
                  ProductFavoriteButton(
                    productId: product.id,
                    keyPrefix: 'product-details-favorite',
                    currentUserIdProvider: currentUserIdProvider,
                  ),
                ],
              ),
            ),
          ],
        ),
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
