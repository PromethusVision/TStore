import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/sizes.dart';

// LEGACY ORDER BOUNDARY: Kept only with the disconnected legacy screen.
class LegacyOrdersList extends StatelessWidget {
  const LegacyOrdersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Legacy sipariş ekranı aktif değil',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              'Doğrulanmış mağaza alışverişleri Alışverişlerim alanında gösterilir.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
