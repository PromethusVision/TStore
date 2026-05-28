import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/view_models/brand_title_with_verification_view_model.dart';
import 'package:t_store/core/common/view_models/product_price_text_view_model.dart';
import 'package:t_store/core/common/view_models/product_title_text_view_model.dart';
import 'package:t_store/core/common/view_models/rounded_image_view_model.dart';
import 'package:t_store/core/common/widgets/brand_title_with_verification.dart';
import 'package:t_store/core/common/widgets/product_price_text.dart';
import 'package:t_store/core/common/widgets/product_title_text.dart';
import 'package:t_store/core/common/widgets/rounded_image.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:t_store/features/cart/domain/entities/cart_item_entity.dart';

class CartItem extends StatelessWidget {
  const CartItem({
    super.key,
    required this.item,
  });

  final CartItemEntity item;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final product = item.product;
    final image = _productImage;
    final brandName = product?.brandName;

    return Row(
      children: [
        RoundedImage(
          roundedImageModel: RoundedImageModel(
            image: image,
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(TSizes.sm),
            backgroundColor: dark ? TColors.darkerGrey : TColors.light,
            isNetworkImage: _isNetworkImage(image),
          ),
        ),
        const SizedBox(
          width: TSizes.spaceBtwItems,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (brandName != null && brandName.isNotEmpty)
                BrandTitleWithVerification(
                    brandTitleWithVerificationModel:
                        BrandTitleWithVerificationModel(
                  brandName: brandName,
                )),
              Flexible(
                child: ProductTitleText(
                    productTitleTextModel: ProductTitleTextModel(
                        title: product?.name ?? 'Ürün bilgisi bulunamadı',
                        maxLines: 1)),
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Adet: ${item.quantity}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  ProductPriceText(
                    productPriceTextModel: ProductPriceTextModel(
                      price: (product?.effectivePrice ?? 0).toStringAsFixed(2),
                      smallSize: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            context.read<CartCubit>().removeFromCart(item.id);
          },
          icon: const Icon(Icons.delete_outline),
          color: Colors.redAccent,
          tooltip: 'Sepetten cikar',
        ),
      ],
    );
  }

  String get _productImage {
    final product = item.product;
    if (product == null) return TImages.productImage5;

    final images = product.images
        .where((image) => image.trim().isNotEmpty)
        .toList(growable: false);

    if (images.isNotEmpty) return images.first;

    final thumbnail = product.thumbnail;
    if (thumbnail != null && thumbnail.trim().isNotEmpty) {
      return thumbnail;
    }

    return TImages.productImage5;
  }

  bool _isNetworkImage(String image) {
    return image.startsWith('http://') || image.startsWith('https://');
  }
}
