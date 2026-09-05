part of 'shop_profile_view.dart';

/// W45A opt-in composition. Actions use the existing profile's guarded methods.
Widget _buildShopVisualPrototype(
  _ShopProfileViewState state,
  BuildContext context,
) {
  final widget = state.widget;
  final shop = widget.shop;
  final info = _ShopInfoSection(
    shop: shop,
    currentUserIdProvider:
        widget.currentUserIdProvider ?? _currentShopProfileUserId,
    urlLauncher: widget.urlLauncher ?? _launchShopProfileUrl,
    chatDestinationBuilder: widget.chatDestinationBuilder,
    pendingProductChatStorage: widget.pendingProductChatStorage,
  );
  final owner = shop.ownerUserId?.trim();
  final canChat =
      owner != null && owner.isNotEmpty && owner != info._currentUserId;
  final theme = Theme.of(context).textTheme;

  return EsnaftaVarScaffold(
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: ListView(
          key: const Key('shop-profile-prototype-scroll'),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                EsnaftaVarSurfaceIconButton(
                  buttonKey: const Key('shop-profile-back'),
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Geri',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: EsnaftaVarSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MAHALLENDEKİ ESNAF',
                        style: theme.labelSmall?.copyWith(
                          color: EsnaftaVarColors.accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Semantics(
                        container: true,
                        header: true,
                        child: Text('Mağazayı keşfet', style: theme.titleLarge),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: EsnaftaVarSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: EsnaftaVarColors.primarySoft,
                    borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: EsnaftaVarColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: EsnaftaVarSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shop.name, style: theme.headlineSmall),
                      const SizedBox(height: EsnaftaVarSpacing.xxs),
                      if (shop.rating > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: EsnaftaVarColors.highlight,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${shop.rating.toStringAsFixed(1).replaceAll('.', ',')}'
                                '${shop.ratingCount > 0 ? ' · ${shop.ratingCount} değerlendirme' : ''}',
                                style: theme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (info._hasText(shop.description)) ...[
              const SizedBox(height: EsnaftaVarSpacing.sm),
              Text(
                shop.description!.trim(),
                style: theme.bodyMedium?.copyWith(
                  color: EsnaftaVarColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: EsnaftaVarSpacing.md),
            Container(
              key: const Key('shop-profile-visit-context'),
              padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
              decoration: BoxDecoration(
                color: EsnaftaVarColors.primarySoft,
                borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: EsnaftaVarColors.primary,
                      ),
                      const SizedBox(width: EsnaftaVarSpacing.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mağazaya uğra', style: theme.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              info._hasText(shop.address)
                                  ? shop.address!.trim()
                                  : 'Adres bilgisi eklenmemiş.',
                              style: theme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: EsnaftaVarSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        size: 18,
                        color: EsnaftaVarColors.primary,
                      ),
                      const SizedBox(width: EsnaftaVarSpacing.xs),
                      Expanded(
                        child: Text(
                          shop.openingHours.isEmpty
                              ? 'Çalışma saatleri eklenmemiş.'
                              : info._formatOpeningHours(),
                          style: theme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  if (info._hasDirections) ...[
                    const SizedBox(height: EsnaftaVarSpacing.md),
                    FilledButton.icon(
                      key: const Key('shop-profile-directions-action'),
                      onPressed: () => info._openDirections(context),
                      icon: const Icon(Icons.directions_outlined, size: 20),
                      label: const Text('Yol tarifi al'),
                    ),
                  ],
                ],
              ),
            ),
            if (canChat || info._phoneTarget != null) ...[
              const SizedBox(height: EsnaftaVarSpacing.xs),
              Row(
                children: [
                  if (info._phoneTarget != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('shop-profile-call-action'),
                        onPressed: () =>
                            info._openPhoneCall(context, info._phoneTarget!),
                        icon: const Icon(Icons.call_outlined, size: 18),
                        label: const Text('Ara'),
                      ),
                    ),
                  if (canChat && info._phoneTarget != null)
                    const SizedBox(width: EsnaftaVarSpacing.xs),
                  if (canChat)
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('shop-profile-message-action'),
                        onPressed: () => info._openChat(context, owner),
                        icon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18,
                        ),
                        label: const Text('Esnafa yaz'),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: EsnaftaVarSpacing.lg),
            const EsnaftaVarSectionHeader(
              title: 'Mağazadaki ürünler',
              subtitle: 'Ürünleri incele, mağazada gör.',
            ),
            const SizedBox(height: EsnaftaVarSpacing.sm),
            FutureBuilder<Either<String, List<ShopProductEntity>>>(
              future: state._productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const EsnaftaVarStateCard(
                    key: Key('shop-profile-products-loading'),
                    icon: Icons.inventory_2_outlined,
                    title: 'Ürünler hazırlanıyor',
                    message: 'Mağazanın ürünleri yükleniyor.',
                  );
                }
                final products = snapshot.data?.fold<List<ShopProductEntity>?>(
                  (_) => null,
                  (products) => products,
                );
                if (snapshot.hasError || products == null || products.isEmpty) {
                  return EsnaftaVarStateCard(
                    key: Key(
                      products?.isEmpty == true
                          ? 'shop-profile-products-empty'
                          : 'shop-profile-products-error',
                    ),
                    icon: Icons.inventory_2_outlined,
                    title: products?.isEmpty == true
                        ? 'Henüz ürün yok'
                        : 'Ürünler yüklenemedi',
                    message: products?.isEmpty == true
                        ? 'Bu mağazada şu an listelenen ürün yok.'
                        : 'Lütfen daha sonra tekrar dene.',
                  );
                }
                return Column(
                  children: [
                    for (final listing in products)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: EsnaftaVarSpacing.xs,
                        ),
                        child: _ShopPrototypeProduct(
                          listing: listing,
                          onTap: listing.product == null
                              ? null
                              : () => unawaited(
                                  state._openProductDetails(
                                    context,
                                    listing.product!,
                                  ),
                                ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _ShopPrototypeProduct extends StatelessWidget {
  const _ShopPrototypeProduct({required this.listing, required this.onTap});
  final ShopProductEntity listing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final product = listing.product;
    final images = listing.images.isNotEmpty
        ? listing.images
        : product?.images ?? <String>[];
    final image = images.isNotEmpty ? images.first : product?.thumbnail ?? '';
    final theme = Theme.of(context).textTheme;
    return Material(
      color: EsnaftaVarColors.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: EsnaftaVarColors.borderDefault),
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
      ),
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        container: true,
        button: onTap != null,
        label: product?.name ?? 'Ürün bilgisi yok',
        child: InkWell(
          key: ValueKey('shop-profile-product-link-${listing.id}'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
            child: Row(
              children: [
                if (image.isNotEmpty)
                  RoundedImage(
                    roundedImageModel: RoundedImageModel(
                      image: image,
                      width: 76,
                      height: 84,
                      padding: const EdgeInsets.all(EsnaftaVarSpacing.xs),
                      fit: BoxFit.contain,
                      backgroundColor: EsnaftaVarColors.surfaceAlt,
                      isNetworkImage: image.startsWith('http'),
                      errorWidget: const _ShopProductFallback(),
                    ),
                  )
                else
                  const SizedBox(
                    width: 76,
                    height: 84,
                    child: _ShopProductFallback(),
                  ),
                const SizedBox(width: EsnaftaVarSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                        child: Text(
                          product?.name ?? 'Ürün bilgisi yok',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.titleSmall,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${listing.price.toStringAsFixed(2).replaceAll('.', ',')} TL',
                        style: theme.titleMedium?.copyWith(
                          color: EsnaftaVarColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        listing.isAvailable
                            ? 'Mağazada mevcut'
                            : 'Şu an mevcut değil',
                        style: theme.labelSmall?.copyWith(
                          color: listing.isAvailable
                              ? EsnaftaVarColors.success
                              : EsnaftaVarColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: EsnaftaVarColors.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
