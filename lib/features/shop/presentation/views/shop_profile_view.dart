import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/chat/presentation/views/chat_view.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_products_by_shop_usecase.dart';
import 'package:t_store/features/shop/presentation/helpers/customer_proximity_helper.dart';
import 'package:t_store/features/shop/presentation/views/product_details_view.dart';
import 'package:url_launcher/url_launcher.dart';

typedef ShopProfileUrlLauncher =
    Future<bool> Function(Uri uri, LaunchMode mode);

typedef ShopProfileCurrentUserIdProvider = String? Function();

class ShopProfileView extends StatefulWidget {
  final ShopEntity shop;
  final ShopProfileUrlLauncher? urlLauncher;
  final ShopProfileCurrentUserIdProvider? currentUserIdProvider;

  const ShopProfileView({
    super.key,
    required this.shop,
    this.urlLauncher,
    this.currentUserIdProvider,
  });

  @override
  State<ShopProfileView> createState() => _ShopProfileViewState();
}

class _ShopProfileViewState extends State<ShopProfileView> {
  late final Future<Either<String, List<ShopProductEntity>>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = sl<GetShopProductsByShopUsecase>()(
      GetShopProductsByShopParams(shopId: widget.shop.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;
    final currentUserIdProvider =
        widget.currentUserIdProvider ?? _currentShopProfileUserId;
    final urlLauncher = widget.urlLauncher ?? _launchShopProfileUrl;

    return Scaffold(
      appBar: CustomAppBar(
        appBarModel: AppBarModel(title: Text(shop.name), hasArrowBack: true),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShopInfoSection(
                shop: shop,
                currentUserIdProvider: currentUserIdProvider,
                urlLauncher: urlLauncher,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              Text(
                'Bu mağazadaki ürünler',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              _ShopProductsSection(productsFuture: _productsFuture),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> _launchShopProfileUrl(Uri uri, LaunchMode mode) {
  return launchUrl(uri, mode: mode);
}

String? _currentShopProfileUserId() {
  return SupabaseService.instance.currentUser?.id;
}

class _ShopInfoSection extends StatelessWidget {
  final ShopEntity shop;
  final ShopProfileCurrentUserIdProvider currentUserIdProvider;
  final ShopProfileUrlLauncher urlLauncher;

  const _ShopInfoSection({
    required this.shop,
    required this.currentUserIdProvider,
    required this.urlLauncher,
  });

  @override
  Widget build(BuildContext context) {
    final hasDirections = _hasDirections;
    final ownerUserId = shop.ownerUserId?.trim();
    final phoneTarget = _phoneTarget;
    final normalizedCurrentUserId = currentUserIdProvider()?.trim();
    final hasOwnerUserId = ownerUserId != null && ownerUserId.isNotEmpty;
    final hasPhone = phoneTarget != null;
    final isOwnShop =
        normalizedCurrentUserId != null &&
        normalizedCurrentUserId.isNotEmpty &&
        normalizedCurrentUserId == ownerUserId;
    final canShowMessageButton = hasOwnerUserId && !isOwnShop;
    final hasActions = canShowMessageButton || hasPhone || hasDirections;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
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
                  _ShopAvatar(shopName: shop.name),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: TSizes.xs),
                        Wrap(
                          spacing: TSizes.xs,
                          runSpacing: TSizes.xs,
                          children: [
                            _RatingChip(rating: shop.rating),
                            if (shop.isActive) const _ActiveShopChip(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              if (_hasText(shop.description))
                Text(
                  shop.description!.trim(),
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                const _MissingInfoText('Bu mağaza için açıklama eklenmemiş.'),
            ],
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        _InfoLine(
          label: 'Adres',
          value: _hasText(shop.address)
              ? shop.address!.trim()
              : 'Adres bilgisi eklenmemiş.',
          isMissing: !_hasText(shop.address),
        ),
        _InfoLine(
          label: 'Telefon',
          value: _hasText(shop.phone)
              ? shop.phone!.trim()
              : 'Telefon bilgisi eklenmemiş.',
          isMissing: !_hasText(shop.phone),
        ),
        _InfoLine(
          label: 'Çalışma saatleri',
          value: shop.openingHours.isNotEmpty
              ? _formatOpeningHours()
              : 'Çalışma saatleri eklenmemiş.',
          isMissing: shop.openingHours.isEmpty,
        ),
        if (hasActions) ...[
          const SizedBox(height: TSizes.spaceBtwItems),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (canShowMessageButton)
                FilledButton.icon(
                  key: const Key('shop-profile-message-action'),
                  onPressed: () => _openChat(context, ownerUserId),
                  icon: const Icon(Icons.message_outlined),
                  label: const Text('Esnafa Yaz'),
                ),
              if (canShowMessageButton && (hasPhone || hasDirections))
                const SizedBox(height: TSizes.sm),
              if (hasPhone)
                OutlinedButton.icon(
                  key: const Key('shop-profile-call-action'),
                  onPressed: () => _openPhoneCall(context, phoneTarget),
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Ara'),
                ),
              if (hasPhone && hasDirections) const SizedBox(height: TSizes.sm),
              if (hasDirections)
                OutlinedButton.icon(
                  key: const Key('shop-profile-directions-action'),
                  onPressed: () => _openDirections(context),
                  icon: const Icon(Icons.directions_outlined),
                  label: const Text('Yol Tarifi Al'),
                ),
            ],
          ),
        ],
      ],
    );
  }

  bool get _hasDirections {
    return _directionsQuery != null;
  }

  String? get _directionsQuery {
    if (CustomerProximityHelper.hasValidCoordinates(
      shop.latitude,
      shop.longitude,
    )) {
      return '${shop.latitude},${shop.longitude}';
    }

    final address = shop.address?.trim();
    return address == null || address.isEmpty ? null : address;
  }

  String? get _phoneTarget {
    final rawPhone = shop.phone?.trim();
    if (rawPhone == null || rawPhone.isEmpty) return null;

    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;

    return rawPhone.startsWith('+') ? '+$digits' : digits;
  }

  String _formatOpeningHours() {
    return shop.openingHours.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

  Future<void> _openDirections(BuildContext context) async {
    final query = _directionsQuery;
    if (query == null) return;

    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });

    try {
      final didLaunch = await urlLauncher(uri, LaunchMode.externalApplication);
      if (!didLaunch && context.mounted) {
        _showActionError(context, 'Yol tarifi açılamadı');
      }
    } catch (_) {
      if (!context.mounted) return;
      _showActionError(context, 'Yol tarifi açılamadı');
    }
  }

  Future<void> _openPhoneCall(BuildContext context, String phone) async {
    try {
      final uri = Uri(scheme: 'tel', path: phone);
      final didLaunch = await urlLauncher(uri, LaunchMode.platformDefault);

      if (!didLaunch && context.mounted) {
        _showActionError(context, 'Telefon araması başlatılamadı');
      }
    } catch (_) {
      if (!context.mounted) return;

      _showActionError(context, 'Telefon araması başlatılamadı');
    }
  }

  void _showActionError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openChat(BuildContext context, String ownerUserId) {
    final normalizedCurrentUserId = currentUserIdProvider()?.trim();
    if (normalizedCurrentUserId == null || normalizedCurrentUserId.isEmpty) {
      THelperFunctions.navigateToScreen(context, const LoginView());
      return;
    }

    THelperFunctions.navigateToScreen(
      context,
      ChatView(receiverId: ownerUserId, receiverName: shop.name),
    );
  }
}

class _ShopAvatar extends StatelessWidget {
  final String shopName;

  const _ShopAvatar({required this.shopName});

  @override
  Widget build(BuildContext context) {
    final initials = _initialsFromName(shopName);
    final colorScheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: 32,
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      child: initials == null
          ? const Icon(Icons.storefront_outlined, size: 30)
          : Text(
              initials,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }

  String? _initialsFromName(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return null;

    final initials = words.take(2).map((word) => word[0].toUpperCase()).join();
    return initials.isEmpty ? null : initials;
  }
}

class _RatingChip extends StatelessWidget {
  final double rating;

  const _RatingChip({required this.rating});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final text = rating > 0 ? rating.toStringAsFixed(1) : 'Yeni';

    return Chip(
      avatar: Icon(Icons.star_rounded, size: 18, color: colorScheme.primary),
      label: Text(text),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: colorScheme.outlineVariant),
      backgroundColor: colorScheme.surface,
      padding: EdgeInsets.zero,
    );
  }
}

class _ActiveShopChip extends StatelessWidget {
  const _ActiveShopChip();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      avatar: Icon(
        Icons.verified_outlined,
        size: 17,
        color: colorScheme.primary,
      ),
      label: const Text('Aktif Mağaza'),
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
      padding: const EdgeInsets.only(bottom: TSizes.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
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

class _MissingInfoText extends StatelessWidget {
  final String text;

  const _MissingInfoText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ShopProductsSection extends StatelessWidget {
  final Future<Either<String, List<ShopProductEntity>>> productsFuture;

  const _ShopProductsSection({required this.productsFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Either<String, List<ShopProductEntity>>>(
      future: productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(TSizes.defaultSpace),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Text(
            'Mağaza ürünleri yüklenemedi. Lütfen daha sonra tekrar deneyin.',
          );
        }

        return snapshot.data!.fold((error) => Text(error), (shopProducts) {
          if (shopProducts.isEmpty) {
            return const Text('Bu mağazada şu an listelenen ürün yok.');
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shopProducts.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: TSizes.spaceBtwItems),
            itemBuilder: (context, index) {
              return _ShopProductTile(shopProduct: shopProducts[index]);
            },
          );
        });
      },
    );
  }
}

class _ShopProductTile extends StatelessWidget {
  final ShopProductEntity shopProduct;

  const _ShopProductTile({required this.shopProduct});

  @override
  Widget build(BuildContext context) {
    final product = shopProduct.product;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.all(TSizes.sm),
        title: Text(product?.name ?? 'Ürün bilgisi yok'),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: TSizes.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '₺${shopProduct.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: TSizes.xs),
              Text(
                product == null
                    ? 'Ürün detayı şu an görüntülenemiyor'
                    : 'Detayları görüntüle',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: product == null
            ? null
            : () => _openProductDetails(context, product),
      ),
    );
  }

  void _openProductDetails(BuildContext context, ProductEntity product) {
    THelperFunctions.navigateToScreen(
      context,
      ProductDetailsView(product: product),
    );
  }
}
