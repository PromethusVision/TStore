// FS-21/27/28/29 candidates, isolated from the parallel implementation files.
// All data/actions come from a local fixture host; no route enables these views.
import 'package:flutter/material.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'sweep_frame.dart';

class SweepWishlist extends StatelessWidget {
  const SweepWishlist({
    super.key,
    required this.items,
    required this.onOpen,
    required this.onRemove,
  });
  final List<WishlistItemEntity> items;
  final ValueChanged<ProductEntity> onOpen;
  final ValueChanged<WishlistItemEntity> onRemove;
  @override
  Widget build(BuildContext context) {
    final visible = items.where((item) => item.product != null).toList();
    return SweepFrame(
      title: 'Favorilerim',
      subtitle: '${visible.length} ürün · Kaydettiklerine yeniden ulaş',
      showBack: false,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: visible.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 286,
        ),
        itemBuilder: (context, index) {
          final item = visible[index];
          final product = item.product!;
          return Material(
            color: EsnaftaVarColors.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: EsnaftaVarColors.borderDefault),
            ),
            child: InkWell(
              key: Key('sweep-wishlist-open-${product.id}'),
              onTap: product.id.trim().isEmpty ? null : () => onOpen(product),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 156,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(
                          color: EsnaftaVarColors.surfaceAlt,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: SweepProductImage(product: product),
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: IconButton.filledTonal(
                            key: Key('sweep-wishlist-remove-${item.productId}'),
                            tooltip: 'Favorilerden çıkar',
                            onPressed: () => onRemove(item),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: EsnaftaVarColors.primary,
                            ),
                            icon: const Icon(Icons.favorite_rounded, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          if (product.brandName?.isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(
                              product.brandName!,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: EsnaftaVarColors.textMuted),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            sweepMoney(product.effectivePrice),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SweepRecentProducts extends StatelessWidget {
  const SweepRecentProducts({
    super.key,
    required this.products,
    required this.favoriteIds,
    required this.onOpen,
    required this.onRemove,
    required this.onFavorite,
    required this.onClear,
  });
  final List<ProductEntity> products;
  final Set<String> favoriteIds;
  final ValueChanged<ProductEntity> onOpen;
  final ValueChanged<ProductEntity> onRemove;
  final ValueChanged<ProductEntity> onFavorite;
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) => SweepFrame(
    title: 'Son görüntülediklerim',
    subtitle: 'İncelediğin ${products.length} ürün',
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const Key('sweep-recent-clear'),
              icon: const Icon(Icons.delete_sweep_outlined, size: 20),
              label: const Text('Geçmişi temizle'),
              onPressed: products.isEmpty
                  ? null
                  : () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Geçmiş temizlensin mi?'),
                          content: const Text(
                            'Bu tarayıcıda kaydedilen son görüntülenen ürünler kaldırılacak.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: const Text('Vazgeç'),
                            ),
                            FilledButton(
                              key: const Key('sweep-recent-clear-confirm'),
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: const Text('Tümünü Temizle'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) onClear();
                    },
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return InkWell(
                key: Key('sweep-recent-open-${product.id}'),
                onTap: product.id.trim().isEmpty ? null : () => onOpen(product),
                child: SweepSurface(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 88,
                        child: SweepProductImage(product: product),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            if (product.brandName?.isNotEmpty == true) ...[
                              const SizedBox(height: 4),
                              Text(
                                product.brandName!,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: EsnaftaVarColors.textMuted,
                                    ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Text(
                              sweepMoney(product.effectivePrice),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Column(
                        children: [
                          IconButton(
                            key: Key('sweep-recent-favorite-${product.id}'),
                            tooltip: favoriteIds.contains(product.id)
                                ? 'Favorilerden çıkar'
                                : 'Favorilere ekle',
                            onPressed: () => onFavorite(product),
                            icon: Icon(
                              favoriteIds.contains(product.id)
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 20,
                            ),
                          ),
                          PopupMenuButton<String>(
                            key: Key('sweep-recent-menu-${product.id}'),
                            tooltip: 'Ürün işlemleri',
                            onSelected: (_) => onRemove(product),
                            icon: const Icon(
                              Icons.more_horiz_rounded,
                              size: 20,
                            ),
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'remove',
                                child: Text('Geçmişten kaldır'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

class SweepNotifications extends StatelessWidget {
  const SweepNotifications({
    super.key,
    required this.notifications,
    required this.hasDestination,
    required this.onTap,
    required this.onReadAll,
  });
  final List<NotificationEntity> notifications;
  final bool Function(NotificationEntity) hasDestination;
  final ValueChanged<NotificationEntity> onTap;
  final VoidCallback onReadAll;
  @override
  Widget build(BuildContext context) {
    final unread = notifications
        .where((notification) => !notification.isRead)
        .length;
    return SweepFrame(
      title: 'Bildirimlerim',
      subtitle: '$unread okunmamış bildirim',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                key: const Key('sweep-notifications-read-all'),
                onPressed: unread > 0 ? onReadAll : null,
                icon: const Icon(Icons.done_all_rounded, size: 20),
                label: const Text('Tümünü oku'),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final destination = hasDestination(notification);
                final icon = switch (notification.type) {
                  NotificationType.order => Icons.verified_outlined,
                  NotificationType.chat => Icons.chat_bubble_outline_rounded,
                  NotificationType.promotion => Icons.local_offer_outlined,
                  NotificationType.system => Icons.info_outline_rounded,
                };
                return InkWell(
                  key: Key('sweep-notification-${notification.id}'),
                  onTap: !notification.isRead || destination
                      ? () => onTap(notification)
                      : null,
                  child: SweepSurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              icon,
                              color: EsnaftaVarColors.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                notification.title,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            if (!notification.isRead)
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 5),
                                child: Semantics(
                                  label: 'Okunmamış',
                                  child: const CircleAvatar(
                                    radius: 4,
                                    backgroundColor: EsnaftaVarColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          notification.body,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: EsnaftaVarColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (notification.createdAt != null)
                              Text(
                                '${sweepDate(notification.createdAt!)} · ${sweepTime(notification.createdAt!)}',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: EsnaftaVarColors.textMuted,
                                    ),
                              ),
                            const Spacer(),
                            if (destination)
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: EsnaftaVarColors.primary,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SweepCoupons extends StatelessWidget {
  const SweepCoupons({super.key});
  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: SweepFrame(
      title: 'Kuponlarım',
      subtitle: 'Kuponların ve kullanım geçmişin',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: EsnaftaVarColors.borderDefault),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: EsnaftaVarColors.textSecondary,
                indicator: BoxDecoration(
                  color: EsnaftaVarColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                tabs: const [
                  Tab(text: 'Kullanılabilir'),
                  Tab(text: 'Geçmiş'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Expanded(
            child: TabBarView(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: EsnaftaVarStateCard(
                      icon: Icons.local_offer_outlined,
                      title: 'Henüz kullanılabilir kuponun yok',
                      message:
                          'Sana tanımlanan ve kullanıma açılan kuponlar burada görünecek.',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: EsnaftaVarStateCard(
                      icon: Icons.history_rounded,
                      title: 'Kupon geçmişin boş',
                      message:
                          'Kullandığın veya süresi dolan kuponları daha sonra buradan görebileceksin.',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class SweepProductImage extends StatelessWidget {
  const SweepProductImage({super.key, required this.product});
  final ProductEntity product;
  @override
  Widget build(BuildContext context) {
    final source =
        product.thumbnail ??
        (product.images.isEmpty ? '' : product.images.first);
    Widget fallback() => const Icon(
      Icons.shopping_bag_outlined,
      color: EsnaftaVarColors.textMuted,
      size: 32,
    );
    if (source.isEmpty) return fallback();
    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => fallback(),
      );
    }
    return Image.network(
      source,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => fallback(),
    );
  }
}
