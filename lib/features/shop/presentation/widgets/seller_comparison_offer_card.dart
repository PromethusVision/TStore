import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';

class SellerComparisonOfferCard extends StatelessWidget {
  const SellerComparisonOfferCard({
    super.key,
    required this.listingId,
    required this.shopName,
    required this.price,
    required this.isAvailable,
    required this.isLowestPrice,
    required this.canAddToCart,
    required this.onViewShop,
    required this.onAddToCart,
    this.address,
    this.rating = 0,
    this.locationText,
    this.onMessage,
  });

  final String listingId;
  final String shopName;
  final String? address;
  final double price;
  final double rating;
  final String? locationText;
  final bool isAvailable;
  final bool isLowestPrice;
  final bool canAddToCart;
  final VoidCallback? onViewShop;
  final Future<void> Function()? onMessage;
  final Future<void>? Function() onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surface,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        border: Border.all(
          color: isLowestPrice
              ? EsnaftaVarColors.primary.withValues(alpha: 0.42)
              : EsnaftaVarColors.borderDefault,
        ),
        boxShadow: EsnaftaVarElevation.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: EsnaftaVarTouchTargets.minimum,
                height: EsnaftaVarTouchTargets.minimum,
                decoration: const BoxDecoration(
                  color: EsnaftaVarColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  size: EsnaftaVarIconSizes.medium,
                  color: EsnaftaVarColors.primary,
                ),
              ),
              const SizedBox(width: EsnaftaVarSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shopName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: EsnaftaVarColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (address != null && address!.trim().isNotEmpty) ...[
                      const SizedBox(height: EsnaftaVarSpacing.xxs),
                      Text(
                        address!.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: EsnaftaVarColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onMessage != null)
                _AsyncMessageButton(
                  listingId: listingId,
                  onPressed: onMessage!,
                ),
            ],
          ),
          const SizedBox(height: EsnaftaVarSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: EsnaftaVarSpacing.xs,
                  runSpacing: EsnaftaVarSpacing.xxs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _AvailabilityChip(isAvailable: isAvailable),
                    if (rating > 0)
                      _OfferFact(
                        icon: Icons.star_rounded,
                        text: rating.toStringAsFixed(1),
                        iconColor: EsnaftaVarColors.highlight,
                      ),
                    if (locationText != null && locationText!.isNotEmpty)
                      _OfferFact(
                        icon: Icons.location_on_outlined,
                        text: locationText!,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: EsnaftaVarSpacing.xs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTurkishPrice(price),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: EsnaftaVarColors.price,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (isLowestPrice)
                    Container(
                      margin: const EdgeInsets.only(top: EsnaftaVarSpacing.xxs),
                      padding: const EdgeInsets.symmetric(
                        horizontal: EsnaftaVarSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: EsnaftaVarColors.primarySoft,
                        borderRadius: BorderRadius.circular(
                          EsnaftaVarRadii.pill,
                        ),
                      ),
                      child: Text(
                        'En uygun fiyat',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: EsnaftaVarColors.primaryPressed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: EsnaftaVarSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final compactActions =
                  constraints.maxWidth < 300 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.15;
              return Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: EsnaftaVarTouchTargets.preferred,
                      child: Semantics(
                        button: true,
                        enabled: onViewShop != null,
                        label: '$shopName mağazasını gör',
                        onTap: onViewShop,
                        child: ExcludeSemantics(
                          child: compactActions
                              ? FilledButton(
                                  key: ValueKey(
                                    'product-seller-shop-profile-$listingId',
                                  ),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: EsnaftaVarSpacing.xs,
                                    ),
                                  ),
                                  onPressed: onViewShop,
                                  child: const Text('Mağazayı gör'),
                                )
                              : FilledButton.icon(
                                  key: ValueKey(
                                    'product-seller-shop-profile-$listingId',
                                  ),
                                  onPressed: onViewShop,
                                  icon: const Icon(
                                    Icons.store_mall_directory_outlined,
                                    size: EsnaftaVarIconSizes.small,
                                  ),
                                  label: const Text('Mağazayı gör'),
                                ),
                        ),
                      ),
                    ),
                  ),
                  if (canAddToCart) ...[
                    const SizedBox(width: EsnaftaVarSpacing.xs),
                    Expanded(
                      child: SizedBox(
                        height: EsnaftaVarTouchTargets.preferred,
                        child: _AsyncAddButton(
                          listingId: listingId,
                          onPressed: onAddToCart,
                          showIcon: !compactActions,
                          semanticLabel:
                              '$shopName için fiziksel alışveriş listesine ekle',
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          if (!canAddToCart) ...[
            const SizedBox(height: EsnaftaVarSpacing.xs),
            Text(
              'Şu an rafta yok',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: EsnaftaVarColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTurkishPrice(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final whole = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return '$whole,${parts.last} TL';
  }
}

class _AvailabilityChip extends StatelessWidget {
  const _AvailabilityChip({required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final foreground = isAvailable
        ? EsnaftaVarColors.success
        : EsnaftaVarColors.textMuted;
    final background = isAvailable
        ? EsnaftaVarColors.successSoft
        : EsnaftaVarColors.surfaceAlt;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: EsnaftaVarSpacing.xs,
        vertical: EsnaftaVarSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.pill),
      ),
      child: Text(
        isAvailable ? 'Rafta var' : 'Rafta yok',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _OfferFact extends StatelessWidget {
  const _OfferFact({
    required this.icon,
    required this.text,
    this.iconColor = EsnaftaVarColors.primary,
  });

  final IconData icon;
  final String text;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: EsnaftaVarIconSizes.small, color: iconColor),
        const SizedBox(width: EsnaftaVarSpacing.xxs),
        Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: EsnaftaVarColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AsyncMessageButton extends StatefulWidget {
  const _AsyncMessageButton({required this.listingId, required this.onPressed});

  final String listingId;
  final Future<void> Function() onPressed;

  @override
  State<_AsyncMessageButton> createState() => _AsyncMessageButtonState();
}

class _AsyncMessageButtonState extends State<_AsyncMessageButton> {
  bool _isOpening = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: Key('product-seller-message-${widget.listingId}'),
      tooltip: 'Esnafa yaz',
      constraints: const BoxConstraints.tightFor(
        width: EsnaftaVarTouchTargets.minimum,
        height: EsnaftaVarTouchTargets.minimum,
      ),
      onPressed: _isOpening ? null : _handlePressed,
      icon: const Icon(Icons.message_outlined),
      color: EsnaftaVarColors.primary,
    );
  }

  Future<void> _handlePressed() async {
    if (_isOpening) return;
    setState(() => _isOpening = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }
}

class _AsyncAddButton extends StatefulWidget {
  const _AsyncAddButton({
    required this.listingId,
    required this.onPressed,
    required this.showIcon,
    required this.semanticLabel,
  });

  final String listingId;
  final Future<void>? Function() onPressed;
  final bool showIcon;
  final String semanticLabel;

  @override
  State<_AsyncAddButton> createState() => _AsyncAddButtonState();
}

class _AsyncAddButtonState extends State<_AsyncAddButton> {
  bool _isAdding = false;

  @override
  Widget build(BuildContext context) {
    final Widget button;
    if (!widget.showIcon && !_isAdding) {
      button = OutlinedButton(
        key: ValueKey('product-seller-add-${widget.listingId}'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: EsnaftaVarSpacing.xs),
        ),
        onPressed: _handlePressed,
        child: const Text('Listeye ekle'),
      );
    } else {
      button = OutlinedButton.icon(
        key: ValueKey('product-seller-add-${widget.listingId}'),
        onPressed: _isAdding ? null : _handlePressed,
        icon: _isAdding
            ? const SizedBox(
                key: Key('product-seller-add-progress'),
                width: EsnaftaVarIconSizes.small,
                height: EsnaftaVarIconSizes.small,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(
                Icons.playlist_add_rounded,
                size: EsnaftaVarIconSizes.small,
              ),
        label: Text(_isAdding ? 'Ekleniyor…' : 'Listeye ekle'),
      );
    }

    return Semantics(
      button: true,
      enabled: !_isAdding,
      label: widget.semanticLabel,
      onTap: _isAdding ? null : _handlePressed,
      child: ExcludeSemantics(
        child: Tooltip(
          message: 'Fiziksel alışveriş listesine ekle',
          child: button,
        ),
      ),
    );
  }

  Future<void> _handlePressed() async {
    if (_isAdding) return;
    final operation = widget.onPressed();
    if (operation == null) return;

    setState(() => _isAdding = true);
    try {
      await operation;
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }
}
