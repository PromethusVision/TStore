import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/view_models/circular_icon_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/common/widgets/circular_icon.dart';
import 'package:t_store/core/common/widgets/curved_widget.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/widgets/other_same_products_list.dart';
import 'package:t_store/features/shop/presentation/widgets/selected_product_image.dart';

class ProductImageSlider extends StatelessWidget {
  const ProductImageSlider({
    super.key,
    required this.product,
  });

  final ProductEntity product;

//ProductImageSlider >> product_image_slider.dart
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
                appBarModel: AppBarModel(hasArrowBack: true, actions: [
              CircularIcon(
                circularIconModel:
                    CircularIconModel(icon: Iconsax.heart5, color: Colors.red),
              ),
            ]))
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
