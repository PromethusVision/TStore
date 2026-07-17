import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/sizes.dart';

class CustomerCouponsView extends StatelessWidget {
  const CustomerCouponsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kuponlarım'),
          bottom: const TabBar(
            tabs: [
              Tab(key: Key('available-coupons-tab'), text: 'Kullanılabilir'),
              Tab(key: Key('coupon-history-tab'), text: 'Geçmiş'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _CouponEmptyState(
              key: Key('available-coupons-empty-state'),
              icon: Icons.local_offer_outlined,
              title: 'Henüz kullanılabilir kuponun yok',
              description:
                  'Sana tanımlanan ve kullanıma açılan kuponlar burada '
                  'görünecek.',
            ),
            _CouponEmptyState(
              key: Key('coupon-history-empty-state'),
              icon: Icons.history_outlined,
              title: 'Kupon geçmişin boş',
              description:
                  'Kullandığın veya süresi dolan kuponları daha sonra '
                  'buradan görebileceksin.',
            ),
          ],
        ),
      ),
    );
  }
}

class _CouponEmptyState extends StatelessWidget {
  const _CouponEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - (TSizes.defaultSpace * 2))
                  .clamp(0, double.infinity)
                  .toDouble(),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        size: 36,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: TSizes.sm),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
