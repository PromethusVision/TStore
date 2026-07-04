import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/my_shop_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/my_shop_state.dart';

class MyShopView extends StatelessWidget {
  const MyShopView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MyShopCubit>()..loadMyShop(),
      child: Scaffold(
        appBar: CustomAppBar(
          appBarModel: AppBarModel(
            title: const Text('Mağazam'),
            hasArrowBack: true,
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<MyShopCubit, MyShopState>(
            builder: (context, state) {
              if (state is MyShopLoading || state is MyShopInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is MyShopError) {
                return _MyShopMessage(
                  title: 'Mağaza bilgileri yüklenemedi',
                  message: state.message,
                  actionLabel: 'Tekrar Dene',
                  onAction: () => context.read<MyShopCubit>().loadMyShop(),
                );
              }

              if (state is MyShopEmpty) {
                return _MyShopMessage(
                  title: 'Henüz mağazanız yok',
                  message:
                      'Mağaza oluşturma akışı yakında buradan yönetilecek.',
                  actionLabel: 'Mağaza oluştur',
                  onAction: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Mağaza oluşturma bir sonraki adımda eklenecek.',
                        ),
                      ),
                    );
                  },
                );
              }

              if (state is MyShopLoaded) {
                return _MyShopDetails(shop: state.shop);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _MyShopDetails extends StatelessWidget {
  final ShopEntity shop;

  const _MyShopDetails({required this.shop});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(TSizes.md),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                      child: const Icon(Icons.storefront_outlined, size: 30),
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: TSizes.xs),
                          Wrap(
                            spacing: TSizes.xs,
                            runSpacing: TSizes.xs,
                            children: [
                              _InfoChip(
                                icon: Icons.star_rounded,
                                label: shop.rating > 0
                                    ? shop.rating.toStringAsFixed(1)
                                    : 'Yeni',
                              ),
                              if (shop.isActive)
                                const _InfoChip(
                                  icon: Icons.verified_outlined,
                                  label: 'Aktif Mağaza',
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  _textOrFallback(
                    shop.description,
                    'Bu mağaza için açıklama eklenmemiş.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _hasText(shop.description)
                            ? null
                            : colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwSections),
          _InfoLine(
            label: 'Adres',
            value: _textOrFallback(shop.address, 'Adres bilgisi eklenmemiş.'),
            isMissing: !_hasText(shop.address),
          ),
          _InfoLine(
            label: 'Telefon',
            value: _textOrFallback(shop.phone, 'Telefon bilgisi eklenmemiş.'),
            isMissing: !_hasText(shop.phone),
          ),
          _InfoLine(
            label: 'Çalışma saatleri',
            value: shop.openingHours.isNotEmpty
                ? _formatOpeningHours(shop.openingHours)
                : 'Çalışma saatleri eklenmemiş.',
            isMissing: shop.openingHours.isEmpty,
          ),
          const SizedBox(height: TSizes.spaceBtwSections),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Düzenleme bir sonraki adımda eklenecek.'),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Düzenle'),
            ),
          ),
        ],
      ),
    );
  }

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  static String _textOrFallback(String? value, String fallback) {
    return _hasText(value) ? value!.trim() : fallback;
  }

  static String _formatOpeningHours(Map<String, dynamic> openingHours) {
    return openingHours.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      avatar: Icon(icon, size: 17, color: colorScheme.primary),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: colorScheme.outlineVariant),
      backgroundColor: colorScheme.surface,
      padding: EdgeInsets.zero,
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isMissing;

  const _InfoLine({
    required this.label,
    required this.value,
    this.isMissing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: TSizes.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isMissing
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : null,
                ),
          ),
        ],
      ),
    );
  }
}

class _MyShopMessage extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _MyShopMessage({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: TSizes.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            FilledButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
