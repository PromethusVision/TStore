import 'package:flutter/material.dart';
import 'package:t_store/core/common/view_models/rounded_image_view_model.dart';
import 'package:t_store/core/common/widgets/rounded_image.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';

class OtherSameProductsList extends StatelessWidget {
  const OtherSameProductsList({
    super.key,
    required this.images,
  });

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final displayImages = images.isEmpty ? const [TImages.productImage5] : images;

    return Positioned(
      right: 0,
      bottom: 30,
      left: TSizes.defaultSpace,
      child: SizedBox(
        height: 80,
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final image = displayImages[index];

              return RoundedImage(
                  roundedImageModel: RoundedImageModel(
                    image: image,
                    width: 80,
                    border: Border.all(
                      color: TColors.primary,
                    ),
                    backgroundColor: dark ? TColors.dark : TColors.white,
                    padding: const EdgeInsets.all(TSizes.sm),
                    isNetworkImage: _isNetworkImage(image),
                  ));
            },
            separatorBuilder: (context, index) => const SizedBox(
                  width: TSizes.spaceBtwItems,
                ),
            itemCount: displayImages.length),
      ),
    );
  }

  bool _isNetworkImage(String image) {
    return image.startsWith('http://') || image.startsWith('https://');
  }
}
