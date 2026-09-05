import 'package:flutter/material.dart';
import 'package:t_store/core/common/view_models/rounded_image_view_model.dart';
import 'package:t_store/core/common/widgets/rounded_image.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/shop/presentation/widgets/product_image_fallback.dart';

class SelectedProductImage extends StatelessWidget {
  const SelectedProductImage({
    super.key,
    required this.image,
    this.height = 400,
    this.imageExtent = 300,
    this.padding = const EdgeInsets.all(TSizes.productImageRadius * 3),
  });

  final String image;
  final double height;
  final double imageExtent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final displayImage = image.trim();

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Padding(
        padding: padding,
        child: Center(
          child: displayImage.isEmpty
              ? Semantics(
                  image: true,
                  label: 'Ürün görseli bulunmuyor',
                  child: SizedBox.square(
                    dimension: imageExtent,
                    child: const ProductImageFallback(
                      key: Key('selected-product-image-fallback'),
                      iconSize: 52,
                    ),
                  ),
                )
              : RoundedImage(
                  roundedImageModel: RoundedImageModel(
                    image: displayImage,
                    width: imageExtent,
                    height: imageExtent,
                    backgroundColor: Colors.transparent,
                    isNetworkImage: _isNetworkImage(displayImage),
                    errorWidget: const ProductImageFallback(
                      key: Key('selected-product-image-fallback'),
                      iconSize: 52,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  bool _isNetworkImage(String image) {
    return image.startsWith('http://') || image.startsWith('https://');
  }
}
