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
import 'package:t_store/features/shop/presentation/views/product_details_view.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopProfileView extends StatefulWidget {
  final ShopEntity shop;

  const ShopProfileView({
    super.key,
    required this.shop,
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

    return Scaffold(
      appBar: CustomAppBar(
        appBarModel: AppBarModel(
          title: Text(shop.name),
          hasArrowBack: true,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShopInfoSection(shop: shop),
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

class _ShopInfoSection extends StatelessWidget {
  final ShopEntity shop;

  const _ShopInfoSection({required this.shop});

  @override
  Widget build(BuildContext context) {
    final hasDirections = _hasDirections;
    final ownerUserId = shop.ownerUserId?.trim();
    final phone = shop.phone?.trim();
    final currentUser = SupabaseService.instance.currentUser;
    final hasOwnerUserId = ownerUserId != null && ownerUserId.isNotEmpty;
    final hasPhone = phone != null && phone.isNotEmpty;
    final isOwnShop = currentUser != null && currentUser.id == ownerUserId;
    final canShowMessageButton = hasOwnerUserId && !isOwnShop;
    final hasActions = canShowMessageButton || hasPhone || hasDirections;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          shop.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        if (_hasText(shop.description))
          Text(
            shop.description!.trim(),
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          const _MissingInfoText('Bu mağaza için açıklama eklenmemiş.'),
        const SizedBox(height: TSizes.spaceBtwItems),
        _InfoLine(
          label: 'Puan',
          value: shop.rating > 0 ? shop.rating.toStringAsFixed(1) : 'Yeni',
        ),
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
                  onPressed: () => _openChat(context, ownerUserId!),
                  icon: const Icon(Icons.message_outlined),
                  label: const Text('Esnafa Yaz'),
                ),
              if (canShowMessageButton && (hasPhone || hasDirections))
                const SizedBox(height: TSizes.sm),
              if (hasPhone)
                OutlinedButton.icon(
                  onPressed: () => _openPhoneCall(context, phone),
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Ara'),
                ),
              if (hasPhone && hasDirections) const SizedBox(height: TSizes.sm),
              if (hasDirections)
                OutlinedButton.icon(
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
    final hasCoordinates = shop.latitude != null && shop.longitude != null;
    final hasAddress = shop.address != null && shop.address!.trim().isNotEmpty;
    return hasCoordinates || hasAddress;
  }

  String _formatOpeningHours() {
    return shop.openingHours.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

  Future<void> _openDirections(BuildContext context) async {
    final query = shop.latitude != null && shop.longitude != null
        ? '${shop.latitude},${shop.longitude}'
        : shop.address!.trim();

    final uri = Uri.https(
      'www.google.com',
      '/maps/search/',
      {
        'api': '1',
        'query': query,
      },
    );

    final didLaunch = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!didLaunch && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yol tarifi açılamadı')),
      );
    }
  }

  Future<void> _openPhoneCall(BuildContext context, String phone) async {
    try {
      final uri = Uri(scheme: 'tel', path: phone);
      final didLaunch = await launchUrl(uri);

      if (!didLaunch && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Telefon araması başlatılamadı')),
        );
      }
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telefon araması başlatılamadı')),
      );
    }
  }

  void _openChat(BuildContext context, String ownerUserId) {
    final user = SupabaseService.instance.currentUser;

    if (user == null) {
      THelperFunctions.navigateToScreen(context, const LoginView());
      return;
    }

    THelperFunctions.navigateToScreen(
      context,
      ChatView(
        receiverId: ownerUserId,
        receiverName: shop.name,
      ),
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

        return snapshot.data!.fold(
          (error) => Text(error),
          (shopProducts) {
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
          },
        );
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
        onTap: product == null ? null : () => _openProductDetails(context, product),
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
