import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_state.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_cubit.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_state.dart';

class CartQrSessionBottomSheet extends StatefulWidget {
  final String cartId;
  final String shopName;
  final int itemCount;
  final double totalAmount;
  final ValueChanged<String> onViewPurchases;

  const CartQrSessionBottomSheet({
    super.key,
    required this.cartId,
    required this.shopName,
    required this.itemCount,
    required this.totalAmount,
    required this.onViewPurchases,
  });

  @override
  State<CartQrSessionBottomSheet> createState() =>
      _CartQrSessionBottomSheetState();
}

class _CartQrSessionBottomSheetState extends State<CartQrSessionBottomSheet> {
  Timer? _timer;
  DateTime _now = DateTime.now();
  String? _confirmedUpdatedSummarySessionId;
  bool _isRetryingInvalidSnapshot = false;
  bool _isRefreshingExpiredSession = false;

  @override
  void initState() {
    super.initState();
    context.read<QrSessionCubit>().createQrSession(widget.cartId);
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      final now = DateTime.now();
      final state = context.read<QrSessionCubit>().state;
      if (state is QrSessionCreated && !state.session.expiresAt.isAfter(now)) {
        _stopTimer();
      }

      setState(() => _now = now);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _retryInvalidSnapshot() {
    if (_isRetryingInvalidSnapshot) return;

    _stopTimer();
    setState(() => _isRetryingInvalidSnapshot = true);
    context.read<QrSessionCubit>().createQrSession(widget.cartId);
  }

  void _refreshExpiredSession() {
    if (_isRefreshingExpiredSession) return;

    _stopTimer();
    setState(() => _isRefreshingExpiredSession = true);
    context.read<QrSessionCubit>().createQrSession(widget.cartId);
  }

  bool _hasValidSnapshotSummary(QrSessionEntity session) {
    final itemCount = session.itemCount;
    final totalAmount = session.totalAmount;
    return itemCount != null &&
        itemCount > 0 &&
        totalAmount != null &&
        totalAmount.isFinite &&
        totalAmount >= 0;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: TSizes.defaultSpace,
          right: TSizes.defaultSpace,
          top: TSizes.defaultSpace,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + TSizes.defaultSpace,
        ),
        child: BlocConsumer<QrSessionCubit, QrSessionState>(
          listener: (context, state) {
            if (state is QrSessionCreated) {
              _isRetryingInvalidSnapshot = false;
              _isRefreshingExpiredSession = false;
              if (_hasValidSnapshotSummary(state.session) &&
                  state.session.expiresAt.isAfter(DateTime.now())) {
                _startTimer();
              } else {
                _stopTimer();
              }
            }
            if (state is QrSessionCompleted ||
                state is QrSessionCancelled ||
                state is QrSessionExpired ||
                state is QrSessionFailure) {
              _isRetryingInvalidSnapshot = false;
              _isRefreshingExpiredSession = false;
              _stopTimer();
            }
          },
          builder: (context, state) {
            if (state is QrSessionLoading || state is QrSessionInitial) {
              return const _QrSessionLoadingView();
            }

            if (state is QrSessionFailure) {
              return _QrSessionFailureView(
                message: state.message,
                onRetry: () {
                  context.read<QrSessionCubit>().createQrSession(widget.cartId);
                },
              );
            }

            if (state is QrSessionCancelled) {
              return _QrSessionCancelledView(
                onBackToCart: () => Navigator.of(context).pop(),
              );
            }

            if (state is QrSessionExpired) {
              return _QrSessionExpiredView(
                isRefreshing: _isRefreshingExpiredSession,
                onRefresh: _refreshExpiredSession,
              );
            }

            if (state is QrSessionCompleted) {
              return BlocProvider<ShopRatingCubit>(
                create: (_) => sl<ShopRatingCubit>(),
                child: _QrSessionCompletedView(
                  sessionId: state.sessionId,
                  shopName: widget.shopName,
                  onClose: () => Navigator.of(context).pop(),
                  onViewPurchases: widget.onViewPurchases,
                ),
              );
            }

            if (state is QrSessionCreated) {
              if (!state.session.expiresAt.isAfter(_now)) {
                return _QrSessionExpiredView(
                  isRefreshing: _isRefreshingExpiredSession,
                  onRefresh: _refreshExpiredSession,
                );
              }

              if (!_hasValidSnapshotSummary(state.session)) {
                return _QrSessionInvalidSnapshotView(
                  isRetrying: _isRetryingInvalidSnapshot,
                  onRetry: _retryInvalidSnapshot,
                  onBack: () => Navigator.of(context).pop(),
                );
              }

              final sessionItemCount = state.session.itemCount!;
              final sessionTotal = state.session.totalAmount!;
              final itemCountChanged = sessionItemCount != widget.itemCount;
              final totalChanged =
                  (sessionTotal - widget.totalAmount).abs() > 0.005;
              final requiresUpdatedSummaryConfirmation =
                  (itemCountChanged || totalChanged) &&
                  _confirmedUpdatedSummarySessionId != state.session.id;

              if (requiresUpdatedSummaryConfirmation) {
                return _QrSessionSummaryChangeView(
                  previousItemCount: widget.itemCount,
                  currentItemCount: sessionItemCount,
                  previousTotal: widget.totalAmount,
                  currentTotal: sessionTotal,
                  itemCountChanged: itemCountChanged,
                  totalChanged: totalChanged,
                  onCancel: () => Navigator.of(context).pop(),
                  onContinue: () {
                    setState(
                      () =>
                          _confirmedUpdatedSummarySessionId = state.session.id,
                    );
                  },
                );
              }

              return _QrSessionContent(
                session: state.session,
                shopName: widget.shopName,
                itemCount: sessionItemCount,
                totalAmount: sessionTotal,
                remaining: state.session.expiresAt.difference(_now),
                isStatusCheckDelayed: state.isStatusCheckDelayed,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _QrSessionInvalidSnapshotView extends StatelessWidget {
  const _QrSessionInvalidSnapshotView({
    required this.isRetrying,
    required this.onRetry,
    required this.onBack,
  });

  final bool isRetrying;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            'QR bilgileri doğrulanamadı',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.sm),
          Text(
            'Sunucudan gelen ürün adedi veya toplam bilgisi eksik ya da geçersiz. '
            'Güvenliğiniz için QR kodu gösterilmedi.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          FilledButton(
            key: const Key('qr-invalid-snapshot-retry-action'),
            onPressed: isRetrying ? null : onRetry,
            child: isRetrying
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Yeniden dene'),
          ),
          const SizedBox(height: TSizes.sm),
          OutlinedButton(
            key: const Key('qr-invalid-snapshot-back-action'),
            onPressed: isRetrying ? null : onBack,
            child: const Text('Sepete dön'),
          ),
        ],
      ),
    );
  }
}

class _QrSessionSummaryChangeView extends StatelessWidget {
  const _QrSessionSummaryChangeView({
    required this.previousItemCount,
    required this.currentItemCount,
    required this.previousTotal,
    required this.currentTotal,
    required this.itemCountChanged,
    required this.totalChanged,
    required this.onCancel,
    required this.onContinue,
  });

  final int previousItemCount;
  final int currentItemCount;
  final double previousTotal;
  final double currentTotal;
  final bool itemCountChanged;
  final bool totalChanged;
  final VoidCallback onCancel;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.fact_check_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            'Sepet bilgileri güncellendi',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.sm),
          Text(
            'QR hazırlanırken ürün adedi veya toplam tutar değişti. '
            'Kodu göstermeden önce güncel sepeti kontrol edin.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          if (itemCountChanged) ...[
            _QrSummaryChangeRow(
              label: 'Az önceki ürün adedi',
              value: previousItemCount.toString(),
            ),
            const SizedBox(height: TSizes.sm),
            _QrSummaryChangeRow(
              label: 'Güncel ürün adedi',
              value: currentItemCount.toString(),
              isHighlighted: true,
            ),
          ],
          if (itemCountChanged && totalChanged)
            const SizedBox(height: TSizes.spaceBtwItems),
          if (totalChanged) ...[
            _QrSummaryChangeRow(
              label: 'Az önceki toplam',
              value: '₺${previousTotal.toStringAsFixed(2)}',
            ),
            const SizedBox(height: TSizes.sm),
            _QrSummaryChangeRow(
              label: 'Güncel toplam',
              value: '₺${currentTotal.toStringAsFixed(2)}',
              isHighlighted: true,
            ),
          ],
          const SizedBox(height: TSizes.spaceBtwItems),
          FilledButton(
            key: const Key('qr-summary-change-continue-action'),
            onPressed: onContinue,
            child: const Text('Güncel sepetle devam et'),
          ),
          const SizedBox(height: TSizes.sm),
          OutlinedButton(
            key: const Key('qr-summary-change-cancel-action'),
            onPressed: onCancel,
            child: const Text('Sepete dön'),
          ),
        ],
      ),
    );
  }
}

class _QrSummaryChangeRow extends StatelessWidget {
  const _QrSummaryChangeRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  final String label;
  final String value;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final textStyle = isHighlighted
        ? Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
        : Theme.of(context).textTheme.bodyMedium;

    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: isHighlighted
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textStyle)),
          Text(value, style: textStyle),
        ],
      ),
    );
  }
}

class _QrSessionCompletedView extends StatefulWidget {
  const _QrSessionCompletedView({
    required this.sessionId,
    required this.shopName,
    required this.onClose,
    required this.onViewPurchases,
  });

  final String sessionId;
  final String shopName;
  final VoidCallback onClose;
  final ValueChanged<String> onViewPurchases;

  @override
  State<_QrSessionCompletedView> createState() =>
      _QrSessionCompletedViewState();
}

class _QrSessionCompletedViewState extends State<_QrSessionCompletedView> {
  static const List<String> _ratingLabels = [
    '',
    'Çok kötü',
    'Kötü',
    'Orta',
    'İyi',
    'Çok iyi',
  ];

  bool _showRatingForm = false;
  bool _isOpeningPurchases = false;
  bool _isClosing = false;
  int _selectedRating = 0;

  void _selectRating(int rating) {
    if (_isClosing || _isOpeningPurchases) return;
    setState(() => _selectedRating = rating);
  }

  void _openRatingForm() {
    if (_isClosing || _isOpeningPurchases) return;
    setState(() => _showRatingForm = true);
  }

  void _openPurchases() {
    if (_isClosing || _isOpeningPurchases) return;

    setState(() => _isOpeningPurchases = true);
    widget.onViewPurchases(widget.sessionId);
  }

  void _close() {
    if (_isClosing || _isOpeningPurchases) return;

    setState(() => _isClosing = true);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopRatingCubit, ShopRatingState>(
      builder: (context, ratingState) {
        final isSubmitting = ratingState is ShopRatingSubmitting;
        final isSuccess = ratingState is ShopRatingSuccess;

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 72, color: Colors.green.shade600),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                'Alışveriş onaylandı',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.sm),
              Text(
                'Esnaf alışverişinizi doğruladı. Sepetiniz başarıyla tamamlandı.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              if (isSuccess) ...[
                Icon(
                  Icons.star_rounded,
                  color: Colors.amber.shade700,
                  size: 40,
                ),
                const SizedBox(height: TSizes.xs),
                Text(
                  'Puanınız kaydedildi. Teşekkür ederiz.',
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
              ] else if (_showRatingForm) ...[
                Text(
                  '${widget.shopName} için puanınızı seçin',
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TSizes.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final rating = index + 1;
                    final isSelected = rating <= _selectedRating;
                    return IconButton(
                      key: Key('shop-rating-star-$rating'),
                      tooltip: '$rating yıldız',
                      onPressed:
                          isSubmitting || _isClosing || _isOpeningPurchases
                          ? null
                          : () => _selectRating(rating),
                      icon: Icon(
                        isSelected ? Icons.star_rounded : Icons.star_border,
                        color: Colors.amber.shade700,
                      ),
                    );
                  }),
                ),
                if (_selectedRating > 0)
                  Text(
                    _ratingLabels[_selectedRating],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                if (ratingState is ShopRatingFailure) ...[
                  const SizedBox(height: TSizes.sm),
                  Text(
                    ratingState.message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ] else
                TextButton.icon(
                  key: const Key('shop-rating-open-action'),
                  onPressed: _isClosing || _isOpeningPurchases
                      ? null
                      : _openRatingForm,
                  icon: const Icon(Icons.star_outline_rounded),
                  label: const Text('Esnafa puan ver'),
                ),
              const SizedBox(height: TSizes.spaceBtwItems),
              if (_showRatingForm && !isSuccess) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('shop-rating-submit-action'),
                    onPressed:
                        isSubmitting ||
                            _isClosing ||
                            _isOpeningPurchases ||
                            _selectedRating == 0
                        ? null
                        : () => context.read<ShopRatingCubit>().submitRating(
                            qrSessionId: widget.sessionId,
                            rating: _selectedRating,
                          ),
                    child: isSubmitting
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Puanı gönder'),
                  ),
                ),
                TextButton(
                  onPressed: isSubmitting || _isClosing ? null : _close,
                  child: const Text('Şimdi değil'),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('view-completed-purchase-action'),
                    onPressed: _isClosing || _isOpeningPurchases
                        ? null
                        : _openPurchases,
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: Text(
                      _isOpeningPurchases
                          ? 'Alışverişlerim açılıyor…'
                          : 'Alışverişlerimde gör',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _isClosing || _isOpeningPurchases ? null : _close,
                  child: const Text('Tamam'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _QrSessionLoadingView extends StatelessWidget {
  const _QrSessionLoadingView();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 240,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _QrSessionFailureView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _QrSessionFailureView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'QR oturumu oluşturulamadı',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onRetry,
            child: const Text('Yeniden Dene'),
          ),
        ),
      ],
    );
  }
}

class _QrSessionCancelledView extends StatelessWidget {
  const _QrSessionCancelledView({required this.onBackToCart});

  final VoidCallback onBackToCart;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.sync_problem_outlined,
          size: 56,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Text(
          'QR iptal edildi',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TSizes.sm),
        Text(
          'Sepetiniz değiştiği için eski QR artık geçerli değil. '
          'Güncel sepetinizi kontrol edin.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: const Key('qr-cancelled-back-to-cart-action'),
            onPressed: onBackToCart,
            child: const Text('Sepete dön ve güncelle'),
          ),
        ),
      ],
    );
  }
}

class _QrSessionExpiredView extends StatelessWidget {
  const _QrSessionExpiredView({
    required this.isRefreshing,
    required this.onRefresh,
  });

  final bool isRefreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer_off_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Text(
          'QR süresi doldu',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TSizes.sm),
        Text(
          'Güvenliğiniz için bu QR artık kullanılamaz. '
          'Güncel sepetiniz için yeni bir QR oluşturun.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            key: const Key('qr-expired-refresh-action'),
            onPressed: isRefreshing ? null : onRefresh,
            child: isRefreshing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Yeni QR oluştur'),
          ),
        ),
      ],
    );
  }
}

class _QrSessionContent extends StatelessWidget {
  final QrSessionEntity session;
  final String shopName;
  final int itemCount;
  final double totalAmount;
  final Duration remaining;
  final bool isStatusCheckDelayed;

  const _QrSessionContent({
    required this.session,
    required this.shopName,
    required this.itemCount,
    required this.totalAmount,
    required this.remaining,
    required this.isStatusCheckDelayed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Alışverişi doğrula',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            shopName,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          _QrInfoRow(label: 'Ürün adedi', value: itemCount.toString()),
          _QrInfoRow(
            label: 'Sepet toplamı',
            value: 'TL ${totalAmount.toStringAsFixed(2)}',
          ),
          _QrInfoRow(label: 'Kalan süre', value: _formatRemaining(remaining)),
          const SizedBox(height: TSizes.spaceBtwItems),
          if (isStatusCheckDelayed) ...[
            Container(
              key: const Key('qr-status-check-warning'),
              padding: const EdgeInsets.all(TSizes.sm),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  const SizedBox(width: TSizes.sm),
                  Expanded(
                    child: Text(
                      'Bağlantı zayıf. Onay durumu yeniden kontrol ediliyor.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
          ],
          Center(
            child: Container(
              key: const Key('purchase-verification-qr-code'),
              padding: const EdgeInsets.all(TSizes.sm),
              color: Colors.white,
              child: QrImageView(
                data: session.sessionToken,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            'QR kodunu esnafa okut. Onay verildiğinde bu ekran otomatik güncellenir. Rezervasyon veya stok garantisi sağlamaz.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatRemaining(Duration duration) {
    final seconds = duration.inSeconds;
    final minutesPart = (seconds ~/ 60).toString().padLeft(2, '0');
    final secondsPart = (seconds % 60).toString().padLeft(2, '0');
    return '$minutesPart:$secondsPart';
  }
}

class _QrInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _QrInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
