part of 'nearby_view.dart';

class _NearbyPrototypeHeader extends StatelessWidget {
  const _NearbyPrototypeHeader({required this.onCartPressed});
  final VoidCallback onCartPressed;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'YEREL KEŞİF',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: EsnaftaVarColors.accent,
                letterSpacing: 0.5,
              ),
            ),
            Semantics(
              container: true,
              header: true,
              child: Text(
                'Yakınındakiler',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
      ),
      BlocBuilder<CartV2Cubit, CartV2State>(
        builder: (context, state) => EsnaftaVarSurfaceIconButton(
          buttonKey: const Key('nearby-prototype-cart'),
          icon: Icons.shopping_bag_outlined,
          tooltip: 'Sepet',
          badgeCount: state is CartV2Loaded ? state.itemCount : 0,
          onPressed: onCartPressed,
        ),
      ),
    ],
  );
}

Widget _buildNearbyPrototype(_LoadedNearbyShops view, BuildContext context) {
  final state = view.state;
  final ready = state.locationStatus == NearbyLocationStatus.ready;
  final saved =
      ready &&
      state.locationSource == NearbyLocationSource.savedLocation &&
      state.locationLabel?.trim().isNotEmpty == true;
  final hasDistances =
      ready &&
      state.shops.any((shop) {
        final distance = state.distanceForShop(shop.id);
        return distance != null && distance.isFinite && distance >= 0;
      });
  final theme = Theme.of(context).textTheme;
  final locationCard = _NearbyLocationCard(
    status: state.locationStatus,
    hasDistances: hasDistances,
    locationSource: state.locationSource,
    locationLabel: state.locationLabel,
    onLocationRequested: view.onLocationRequested,
    onLocationSettingsRequested: view.onLocationSettingsRequested,
    onSavedLocationRequested: view.onSavedLocationRequested,
  );
  return RefreshIndicator(
    onRefresh: view.onRefresh,
    child: ListView.separated(
      key: const Key('nearby-shop-list'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: EsnaftaVarSpacing.xl),
      itemCount: state.shops.length + 2,
      separatorBuilder: (_, _) => const SizedBox(height: EsnaftaVarSpacing.sm),
      itemBuilder: (context, index) {
        if (index == 0) {
          if (!ready) return locationCard;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                container: true,
                button: saved,
                child: Material(
                  key: const Key('nearby-location-card'),
                  color: Colors.transparent,
                  child: InkWell(
                    key: const Key('nearby-change-location'),
                    onTap: saved ? view.onSavedLocationRequested : null,
                    borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: EsnaftaVarSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: EsnaftaVarColors.primarySoft,
                              borderRadius: BorderRadius.circular(
                                EsnaftaVarRadii.medium,
                              ),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              size: 20,
                              color: EsnaftaVarColors.primary,
                            ),
                          ),
                          const SizedBox(width: EsnaftaVarSpacing.xs),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  saved
                                      ? state.locationLabel!.trim()
                                      : 'Mevcut konumun',
                                  style: theme.titleSmall,
                                ),
                                Text(
                                  hasDistances
                                      ? 'Yakından uzağa sıralandı'
                                      : 'Mesafe bilgisi henüz yok',
                                  style: theme.bodySmall?.copyWith(
                                    color: EsnaftaVarColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (saved)
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: EsnaftaVarColors.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                saved
                    ? 'Konumun mağazalarla paylaşılmaz.'
                    : 'Konumunu bu sıralama için kullandık; kaydetmedik.',
                style: theme.labelSmall?.copyWith(
                  color: EsnaftaVarColors.textMuted,
                ),
              ),
            ],
          );
        }
        if (index == 1) {
          return Padding(
            padding: const EdgeInsets.only(
              top: EsnaftaVarSpacing.xs,
              bottom: EsnaftaVarSpacing.xxs,
            ),
            child: EsnaftaVarSectionHeader(
              title: ready && hasDistances
                  ? 'Yakınındaki esnaf'
                  : 'Mağazaları keşfet',
              subtitle:
                  '${state.shops.length} mağaza · Ürünleri incele, mağazaya uğra.',
            ),
          );
        }
        final shop = state.shops[index - 2];
        final distance = ready ? state.distanceForShop(shop.id) : null;
        final knownDistance =
            distance != null && distance.isFinite && distance >= 0;
        final canOpen = shop.isActive && shop.id.trim().isNotEmpty;
        return Container(
          key: ValueKey('nearby-shop-${shop.id}'),
          padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
          decoration: BoxDecoration(
            color: EsnaftaVarColors.surface,
            borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
            border: Border.all(color: EsnaftaVarColors.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: FittedBox(child: _NearbyShopVisual(shopId: shop.id)),
                  ),
                  const SizedBox(width: EsnaftaVarSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.titleMedium,
                        ),
                        if (shop.address?.trim().isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            shop.address!.trim(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.bodySmall?.copyWith(
                              color: EsnaftaVarColors.textMuted,
                            ),
                          ),
                        ],
                        if (shop.rating > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: EsnaftaVarColors.highlight,
                                size: 17,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                shop.rating
                                    .toStringAsFixed(1)
                                    .replaceAll('.', ','),
                                style: theme.labelMedium,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (shop.description?.trim().isNotEmpty == true) ...[
                const SizedBox(height: EsnaftaVarSpacing.xs),
                Text(
                  shop.description!.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodySmall?.copyWith(
                    color: EsnaftaVarColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: EsnaftaVarSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.near_me_outlined,
                          size: 16,
                          color: EsnaftaVarColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            knownDistance
                                ? CustomerProximityHelper.formatDistance(
                                    distance,
                                  )
                                : ready
                                ? 'Mesafe bilgisi yok'
                                : 'Konum seçilmedi',
                            style: theme.labelSmall?.copyWith(
                              color: EsnaftaVarColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    key: Key('nearby-shop-open-${shop.id}'),
                    onPressed: canOpen ? () => view.onShopSelected(shop) : null,
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('Mağazayı gör'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}
