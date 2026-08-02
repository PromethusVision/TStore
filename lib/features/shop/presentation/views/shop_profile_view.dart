import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/chat/domain/services/pending_product_chat_storage.dart';
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
typedef ShopProfileChatDestinationBuilder =
    Widget Function(String receiverId, String receiverName);

class ShopProfileView extends StatefulWidget {
  final ShopEntity shop;
  final ShopProfileUrlLauncher? urlLauncher;
  final ShopProfileCurrentUserIdProvider? currentUserIdProvider;
  final ShopProfileChatDestinationBuilder? chatDestinationBuilder;
  final PendingProductChatStorage? pendingProductChatStorage;

  const ShopProfileView({
    super.key,
    required this.shop,
    this.urlLauncher,
    this.currentUserIdProvider,
    this.chatDestinationBuilder,
    this.pendingProductChatStorage,
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
      backgroundColor: CustomerHomeV1Tokens.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('shop-profile-customer-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              key: const Key('shop-profile-scroll'),
              padding: const EdgeInsets.fromLTRB(
                CustomerHomeV1Tokens.space16,
                CustomerHomeV1Tokens.space8,
                CustomerHomeV1Tokens.space16,
                CustomerHomeV1Tokens.space24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ShopProfileHeader(),
                  const SizedBox(height: CustomerHomeV1Tokens.space12),
                  _ShopInfoSection(
                    shop: shop,
                    currentUserIdProvider: currentUserIdProvider,
                    urlLauncher: urlLauncher,
                    chatDestinationBuilder: widget.chatDestinationBuilder,
                    pendingProductChatStorage: widget.pendingProductChatStorage,
                  ),
                  const SizedBox(height: CustomerHomeV1Tokens.space20),
                  const Text(
                    'Bu mağazadaki ürünler',
                    style: TextStyle(
                      color: CustomerHomeV1Tokens.navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.25,
                    ),
                  ),
                  const SizedBox(height: CustomerHomeV1Tokens.space12),
                  _ShopProductsSection(productsFuture: _productsFuture),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShopProfileHeader extends StatelessWidget {
  const _ShopProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('shop-profile-header'),
      children: [
        Material(
          color: CustomerHomeV1Tokens.surface,
          shape: const CircleBorder(
            side: BorderSide(color: CustomerHomeV1Tokens.border),
          ),
          child: IconButton(
            key: const Key('shop-profile-back'),
            tooltip: 'Geri',
            onPressed: () => Navigator.of(context).maybePop(),
            color: CustomerHomeV1Tokens.petrol,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        const SizedBox(width: CustomerHomeV1Tokens.space12),
        const Expanded(
          child: Text(
            'Mağaza Profili',
            style: TextStyle(
              color: CustomerHomeV1Tokens.navy,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.35,
            ),
          ),
        ),
      ],
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
  final ShopProfileChatDestinationBuilder? chatDestinationBuilder;
  final PendingProductChatStorage? pendingProductChatStorage;

  const _ShopInfoSection({
    required this.shop,
    required this.currentUserIdProvider,
    required this.urlLauncher,
    required this.chatDestinationBuilder,
    required this.pendingProductChatStorage,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: const Key('shop-profile-hero'),
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [CustomerHomeV1Tokens.petrol, Color(0xFF0D575B)],
            ),
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius24),
            boxShadow: CustomerHomeV1Tokens.softShadow,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -28,
                bottom: -36,
                child: Icon(
                  Icons.storefront_rounded,
                  size: 170,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  height: 10,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CustomerHomeV1Tokens.coral,
                        CustomerHomeV1Tokens.yellow,
                        CustomerHomeV1Tokens.coral,
                        CustomerHomeV1Tokens.yellow,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  CustomerHomeV1Tokens.space16,
                  CustomerHomeV1Tokens.space24,
                  CustomerHomeV1Tokens.space16,
                  CustomerHomeV1Tokens.space20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _ShopAvatar(shopName: shop.name),
                        const SizedBox(width: CustomerHomeV1Tokens.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shop.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                  letterSpacing: -0.35,
                                ),
                              ),
                              const SizedBox(
                                height: CustomerHomeV1Tokens.space8,
                              ),
                              Wrap(
                                spacing: CustomerHomeV1Tokens.space8,
                                runSpacing: CustomerHomeV1Tokens.space8,
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
                    const SizedBox(height: CustomerHomeV1Tokens.space16),
                    if (_hasText(shop.description))
                      Text(
                        shop.description!.trim(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 12,
                          height: 1.45,
                        ),
                      )
                    else
                      const _MissingInfoText(
                        'Bu mağaza için açıklama eklenmemiş.',
                        onDarkSurface: true,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: CustomerHomeV1Tokens.space12),
        Container(
          key: const Key('shop-profile-info-card'),
          width: double.infinity,
          padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
          decoration: BoxDecoration(
            color: CustomerHomeV1Tokens.surface,
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
            border: Border.all(color: CustomerHomeV1Tokens.border),
            boxShadow: CustomerHomeV1Tokens.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mağaza bilgileri',
                style: TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space12),
              _InfoLine(
                icon: Icons.location_on_outlined,
                label: 'Adres',
                value: _hasText(shop.address)
                    ? shop.address!.trim()
                    : 'Adres bilgisi eklenmemiş.',
                isMissing: !_hasText(shop.address),
              ),
              const Divider(height: CustomerHomeV1Tokens.space20),
              _InfoLine(
                icon: Icons.call_outlined,
                label: 'Telefon',
                value: _hasText(shop.phone)
                    ? shop.phone!.trim()
                    : 'Telefon bilgisi eklenmemiş.',
                isMissing: !_hasText(shop.phone),
              ),
              const Divider(height: CustomerHomeV1Tokens.space20),
              _InfoLine(
                icon: Icons.schedule_outlined,
                label: 'Çalışma saatleri',
                value: shop.openingHours.isNotEmpty
                    ? _formatOpeningHours()
                    : 'Çalışma saatleri eklenmemiş.',
                isMissing: shop.openingHours.isEmpty,
              ),
            ],
          ),
        ),
        if (hasActions) ...[
          const SizedBox(height: CustomerHomeV1Tokens.space12),
          Container(
            key: const Key('shop-profile-actions-card'),
            width: double.infinity,
            padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
            decoration: BoxDecoration(
              color: CustomerHomeV1Tokens.surface,
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius20,
              ),
              border: Border.all(color: CustomerHomeV1Tokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (canShowMessageButton)
                  FilledButton(
                    key: const Key('shop-profile-message-action'),
                    onPressed: () => _openChat(context, ownerUserId),
                    style: FilledButton.styleFrom(
                      backgroundColor: CustomerHomeV1Tokens.petrol,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          CustomerHomeV1Tokens.radius12,
                        ),
                      ),
                    ),
                    child: const Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: CustomerHomeV1Tokens.space8,
                      children: [
                        Icon(Icons.message_rounded, size: 19),
                        Text(
                          'Esnafa Yaz',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                if (canShowMessageButton && (hasPhone || hasDirections))
                  const SizedBox(height: CustomerHomeV1Tokens.space8),
                if (hasPhone)
                  _ShopOutlinedAction(
                    key: const Key('shop-profile-call-action'),
                    onPressed: () => _openPhoneCall(context, phoneTarget),
                    icon: Icons.call_rounded,
                    label: 'Ara',
                  ),
                if (hasPhone && hasDirections)
                  const SizedBox(height: CustomerHomeV1Tokens.space8),
                if (hasDirections)
                  _ShopOutlinedAction(
                    key: const Key('shop-profile-directions-action'),
                    onPressed: () => _openDirections(context),
                    icon: Icons.directions_rounded,
                    label: 'Yol Tarifi Al',
                  ),
              ],
            ),
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

  PendingProductChatStorage get _pendingChatStorage =>
      pendingProductChatStorage ?? sl<PendingProductChatStorage>();

  Future<void> _openChat(BuildContext context, String ownerUserId) async {
    final pendingIntent = PendingProductChatIntent(
      receiverId: ownerUserId,
      receiverName: shop.name,
      initialDraft: '',
      createdAt: DateTime.now(),
    );
    var pendingIntentWasSaved = false;
    var currentUserId = _currentUserId;

    if (currentUserId == null) {
      pendingIntentWasSaved = await _savePendingIntent(pendingIntent);
      if (!context.mounted) return;

      final signedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) =>
              const LoginView(returnToCallerAfterCustomerLogin: true),
        ),
      );
      if (!context.mounted) return;

      if (signedIn != true) {
        if (pendingIntentWasSaved) {
          await _clearPendingIntent();
        }
        return;
      }
      currentUserId = _currentUserId;
    }

    if (currentUserId == null) return;

    if (currentUserId == ownerUserId) {
      if (pendingIntentWasSaved) {
        await _clearPendingIntent();
      }
      if (!context.mounted) return;
      _showActionError(
        context,
        'Bu maÄŸazaya kendi hesabÄ±nÄ±zla mesaj gÃ¶nderemezsiniz.',
      );
      return;
    }

    if (pendingIntentWasSaved) {
      await _clearPendingIntent();
    }
    if (!context.mounted) return;

    final destination =
        chatDestinationBuilder?.call(ownerUserId, shop.name) ??
        ChatView(receiverId: ownerUserId, receiverName: shop.name);
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => destination));
  }

  String? get _currentUserId {
    final normalizedCurrentUserId = currentUserIdProvider()?.trim();
    return normalizedCurrentUserId == null || normalizedCurrentUserId.isEmpty
        ? null
        : normalizedCurrentUserId;
  }

  Future<bool> _savePendingIntent(PendingProductChatIntent intent) async {
    try {
      await _pendingChatStorage.save(intent);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _clearPendingIntent() async {
    try {
      await _pendingChatStorage.clear();
    } catch (_) {}
  }
}

class _ShopOutlinedAction extends StatelessWidget {
  const _ShopOutlinedAction({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: CustomerHomeV1Tokens.petrol,
        side: const BorderSide(color: CustomerHomeV1Tokens.petrol),
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius12),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: CustomerHomeV1Tokens.space8,
        children: [
          Icon(icon, size: 18),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ShopAvatar extends StatelessWidget {
  final String shopName;

  const _ShopAvatar({required this.shopName});

  @override
  Widget build(BuildContext context) {
    final initials = _initialsFromName(shopName);

    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.32)),
      ),
      child: initials == null
          ? const Icon(Icons.storefront_rounded, size: 30, color: Colors.white)
          : Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
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
    final text = rating > 0 ? rating.toStringAsFixed(1) : 'Yeni';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CustomerHomeV1Tokens.space8,
        vertical: CustomerHomeV1Tokens.space4,
      ),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.yellow,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 14,
            color: CustomerHomeV1Tokens.navy,
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space4),
          Text(
            text,
            style: const TextStyle(
              color: CustomerHomeV1Tokens.navy,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveShopChip extends StatelessWidget {
  const _ActiveShopChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CustomerHomeV1Tokens.space8,
        vertical: CustomerHomeV1Tokens.space4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radiusPill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.32)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 14, color: Colors.white),
          SizedBox(width: CustomerHomeV1Tokens.space4),
          Flexible(
            child: Text(
              'Aktif Mağaza',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isMissing;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
    this.isMissing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: CustomerHomeV1Tokens.mint,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 17, color: CustomerHomeV1Tokens.petrol),
        ),
        const SizedBox(width: CustomerHomeV1Tokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: isMissing
                      ? CustomerHomeV1Tokens.muted
                      : CustomerHomeV1Tokens.navy,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MissingInfoText extends StatelessWidget {
  final String text;
  final bool onDarkSurface;

  const _MissingInfoText(this.text, {this.onDarkSurface = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: onDarkSurface
            ? Colors.white.withValues(alpha: 0.76)
            : CustomerHomeV1Tokens.muted,
        fontSize: 12,
        height: 1.4,
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
          return const _ShopProductsStatus(
            key: Key('shop-profile-products-loading'),
            icon: Icons.inventory_2_outlined,
            message: 'Mağaza ürünleri hazırlanıyor',
            isLoading: true,
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const _ShopProductsStatus(
            key: Key('shop-profile-products-error'),
            icon: Icons.cloud_off_rounded,
            message:
                'Mağaza ürünleri yüklenemedi. Lütfen daha sonra tekrar deneyin.',
          );
        }

        return snapshot.data!.fold(
          (error) => const _ShopProductsStatus(
            key: Key('shop-profile-products-error'),
            icon: Icons.cloud_off_rounded,
            message:
                'Mağaza ürünleri yüklenemedi. Lütfen daha sonra tekrar deneyin.',
          ),
          (shopProducts) {
            if (shopProducts.isEmpty) {
              return const _ShopProductsStatus(
                key: Key('shop-profile-products-empty'),
                icon: Icons.inventory_2_outlined,
                message: 'Bu mağazada şu an listelenen ürün yok.',
              );
            }

            return ListView.separated(
              key: const Key('shop-profile-products-list'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: shopProducts.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: CustomerHomeV1Tokens.space12),
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

class _ShopProductsStatus extends StatelessWidget {
  const _ShopProductsStatus({
    super.key,
    required this.icon,
    required this.message,
    this.isLoading = false,
  });

  final IconData icon;
  final String message;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space20),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
      ),
      child: Column(
        children: [
          if (isLoading)
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: CustomerHomeV1Tokens.petrol,
              ),
            )
          else
            Icon(icon, size: 30, color: CustomerHomeV1Tokens.petrol),
          const SizedBox(height: CustomerHomeV1Tokens.space12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CustomerHomeV1Tokens.muted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopProductTile extends StatelessWidget {
  final ShopProductEntity shopProduct;

  const _ShopProductTile({required this.shopProduct});

  @override
  Widget build(BuildContext context) {
    final product = shopProduct.product;

    return Material(
      key: ValueKey('shop-profile-product-${shopProduct.id}'),
      color: CustomerHomeV1Tokens.surface,
      borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
      child: InkWell(
        onTap: product == null
            ? null
            : () => _openProductDetails(context, product),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        child: Container(
          padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
            border: Border.all(color: CustomerHomeV1Tokens.border),
            boxShadow: CustomerHomeV1Tokens.softShadow,
          ),
          child: Row(
            children: [
              _ShopProductVisual(shopProduct: shopProduct),
              const SizedBox(width: CustomerHomeV1Tokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.name ?? 'Ürün bilgisi yok',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space8),
                    Text(
                      _formatPrice(shopProduct.price),
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.petrol,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: CustomerHomeV1Tokens.space8,
                        vertical: CustomerHomeV1Tokens.space4,
                      ),
                      decoration: BoxDecoration(
                        color: shopProduct.isAvailable
                            ? CustomerHomeV1Tokens.mint
                            : CustomerHomeV1Tokens.border,
                        borderRadius: BorderRadius.circular(
                          CustomerHomeV1Tokens.radiusPill,
                        ),
                      ),
                      child: Text(
                        shopProduct.isAvailable
                            ? 'Mağazada mevcut'
                            : 'Şu an mevcut değil',
                        style: const TextStyle(
                          color: CustomerHomeV1Tokens.navy,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (product != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: CustomerHomeV1Tokens.petrol,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return '₺${price.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _openProductDetails(BuildContext context, ProductEntity product) {
    THelperFunctions.navigateToScreen(
      context,
      ProductDetailsView(product: product),
    );
  }
}

class _ShopProductVisual extends StatelessWidget {
  const _ShopProductVisual({required this.shopProduct});

  final ShopProductEntity shopProduct;

  @override
  Widget build(BuildContext context) {
    final product = shopProduct.product;
    final imageUrl = shopProduct.images.isNotEmpty
        ? shopProduct.images.first
        : product?.thumbnail?.trim().isNotEmpty == true
        ? product!.thumbnail!.trim()
        : product?.images.isNotEmpty == true
        ? product!.images.first
        : null;

    return Container(
      width: 82,
      height: 82,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.mint,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      ),
      child: imageUrl == null
          ? const _ShopProductFallback()
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const _ShopProductFallback(),
            ),
    );
  }
}

class _ShopProductFallback extends StatelessWidget {
  const _ShopProductFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.shopping_bag_rounded,
        size: 30,
        color: CustomerHomeV1Tokens.petrol,
      ),
    );
  }
}
