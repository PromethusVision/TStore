import 'package:flutter/material.dart';
import 'package:t_store/core/common/view_models/rounded_image_view_model.dart';
import 'package:t_store/core/common/widgets/rounded_image.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/core/utils/constants/sizes.dart';

class SelectedProductImage extends StatelessWidget {
  const SelectedProductImage({
    super.key,
    required this.image,
  });

  final String image;

  @override
  Widget build(BuildContext context) {
    final displayImage = image.trim().isEmpty ? TImages.productImage13 : image;

    return SizedBox(
        height: 400,
        child: Padding(
          padding: const EdgeInsets.all(TSizes.productImageRadius * 3),
          child: Center(
            child: RoundedImage(
              roundedImageModel: RoundedImageModel(
                image: displayImage,
                width: 300,
                height: 300,
                backgroundColor: Colors.transparent,
                isNetworkImage: _isNetworkImage(displayImage),
              ),
            ),
          ),
        ));
  }

  bool _isNetworkImage(String image) {
    return image.startsWith('http://') || image.startsWith('https://');
  }
}
