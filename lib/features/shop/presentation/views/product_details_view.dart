import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/widgets/bottom_add_to_cart.dart';
import 'package:t_store/features/shop/presentation/widgets/checkout_button.dart';
import 'package:t_store/features/shop/presentation/widgets/product_image_slider.dart';
import 'package:t_store/features/shop/presentation/widgets/product_metadata.dart';
import 'package:t_store/features/shop/presentation/widgets/product_sellers_section.dart';
import 'package:t_store/features/shop/presentation/widgets/rating_and_share.dart';

class ProductDetailsView extends StatelessWidget {
  final ProductEntity product;

  const ProductDetailsView({
    super.key,
    ProductEntity? product,
  }) : product = product ?? const ProductEntity(
          id: 'demo',
          name: 'Demo Product',
          price: 0,
          categoryId: 'demo',
          stock: 0,
          images: const [],
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomAddToCart(product: product),
        body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImageSlider(product: product),
              Padding(
                padding: const EdgeInsets.fromLTRB(TSizes.defaultSpace, 0,
                    TSizes.defaultSpace, TSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    Text(
                      '\$${product.effectivePrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (product.description != null &&
                        product.description!.isNotEmpty) ...[
                      const SizedBox(height: TSizes.spaceBtwItems),
                      Text(
                        product.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: TSizes.spaceBtwSections),
                    RatingAndShare(product: product),
                    ProductMetadata(product: product),
                    const SizedBox(
                      height: TSizes.spaceBtwSections,
                    ),
                    ProductSellersSection(productId: product.id),
                    const SizedBox(
                      height: TSizes.spaceBtwSections,
                    ),
                    const CheckoutButton(),
                    const SizedBox(
                      height: TSizes.spaceBtwSections,
                    ),
                  ],
                ),
              )
            ],
          )),
        ));
  }
}
