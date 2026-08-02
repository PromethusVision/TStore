import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/sizes.dart';

enum ProductSellerPriceSummaryStatus { loading, available, empty, error }

@immutable
class ProductSellerPriceSummary {
  final ProductSellerPriceSummaryStatus status;
  final double? minimumPrice;
  final double? maximumPrice;

  const ProductSellerPriceSummary.loading()
    : status = ProductSellerPriceSummaryStatus.loading,
      minimumPrice = null,
      maximumPrice = null;

  const ProductSellerPriceSummary.available({
    required this.minimumPrice,
    required this.maximumPrice,
  }) : status = ProductSellerPriceSummaryStatus.available,
       assert(minimumPrice != null),
       assert(maximumPrice != null);

  const ProductSellerPriceSummary.empty()
    : status = ProductSellerPriceSummaryStatus.empty,
      minimumPrice = null,
      maximumPrice = null;

  const ProductSellerPriceSummary.error()
    : status = ProductSellerPriceSummaryStatus.error,
      minimumPrice = null,
      maximumPrice = null;

  bool get hasPriceRange {
    final minimum = minimumPrice;
    final maximum = maximumPrice;
    if (minimum == null || maximum == null) return false;
    return (maximum - minimum).abs() > 0.005;
  }

  @override
  bool operator ==(Object other) {
    return other is ProductSellerPriceSummary &&
        other.status == status &&
        other.minimumPrice == minimumPrice &&
        other.maximumPrice == maximumPrice;
  }

  @override
  int get hashCode => Object.hash(status, minimumPrice, maximumPrice);
}

class ProductSellerPriceSummaryView extends StatelessWidget {
  final ProductSellerPriceSummary summary;

  const ProductSellerPriceSummaryView({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = _contentFor(summary);

    return Container(
      key: const Key('product-seller-price-summary'),
      width: double.infinity,
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summary.status == ProductSellerPriceSummaryStatus.loading)
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Icon(content.icon, color: colorScheme.onPrimaryContainer),
          const SizedBox(width: TSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (content.priceText != null) ...[
                  const SizedBox(height: TSizes.xs),
                  Text(
                    content.priceText!,
                    key: const Key('product-seller-price-value'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                if (content.description != null) ...[
                  const SizedBox(height: TSizes.xs),
                  Text(
                    content.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _PriceSummaryContent _contentFor(ProductSellerPriceSummary summary) {
    switch (summary.status) {
      case ProductSellerPriceSummaryStatus.loading:
        return const _PriceSummaryContent(
          icon: Icons.hourglass_top,
          title: 'Mağaza fiyatları yükleniyor',
        );
      case ProductSellerPriceSummaryStatus.available:
        final minimum = summary.minimumPrice!;
        final maximum = summary.maximumPrice!;
        return _PriceSummaryContent(
          icon: Icons.sell_outlined,
          title: summary.hasPriceRange
              ? 'Mağaza fiyat aralığı'
              : 'Mağaza fiyatı',
          priceText: summary.hasPriceRange
              ? '${_formatPrice(minimum)} – ${_formatPrice(maximum)}'
              : _formatPrice(minimum),
          description: 'Sepette seçtiğin mağazanın fiyatı kullanılır.',
        );
      case ProductSellerPriceSummaryStatus.empty:
        return const _PriceSummaryContent(
          icon: Icons.storefront_outlined,
          title: 'Mağaza fiyatı henüz yok',
          description: 'Satıcı eklendiğinde fiyat burada görünecek.',
        );
      case ProductSellerPriceSummaryStatus.error:
        return const _PriceSummaryContent(
          icon: Icons.info_outline,
          title: 'Mağaza fiyatları alınamadı',
          description: 'Satıcı listesinden tekrar deneyebilirsin.',
        );
    }
  }

  String _formatPrice(double price) {
    return '₺${price.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

class _PriceSummaryContent {
  final IconData icon;
  final String title;
  final String? priceText;
  final String? description;

  const _PriceSummaryContent({
    required this.icon,
    required this.title,
    this.priceText,
    this.description,
  });
}
