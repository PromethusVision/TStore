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

  const CartQrSessionBottomSheet({
    super.key,
    required this.cartId,
    required this.shopName,
    required this.itemCount,
    required this.totalAmount,
  });

  @override
  State<CartQrSessionBottomSheet> createState() =>
      _CartQrSessionBottomSheetState();
}

class _CartQrSessionBottomSheetState extends State<CartQrSessionBottomSheet> {
  Timer? _timer;
  DateTime _now = DateTime.now();

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
              _startTimer();
            }
            if (state is QrSessionCompleted || state is QrSessionFailure) {
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

            if (state is QrSessionCompleted) {
              return BlocProvider<ShopRatingCubit>(
                create: (_) => sl<ShopRatingCubit>(),
                child: _QrSessionCompletedView(
                  sessionId: state.sessionId,
                  shopName: widget.shopName,
                  onClose: () => Navigator.of(context).pop(),
                ),
              );
            }

            if (state is QrSessionCreated) {
              return _QrSessionContent(
                session: state.session,
                shopName: widget.shopName,
                itemCount: state.session.itemCount ?? widget.itemCount,
                totalAmount: state.session.totalAmount ?? widget.totalAmount,
                remaining: state.session.expiresAt.difference(_now),
                onRefresh: () {
                  context.read<QrSessionCubit>().createQrSession(widget.cartId);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _QrSessionCompletedView extends StatefulWidget {
  const _QrSessionCompletedView({
    required this.sessionId,
    required this.shopName,
    required this.onClose,
  });

  final String sessionId;
  final String shopName;
  final VoidCallback onClose;

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
  int _selectedRating = 0;

  void _selectRating(int rating) {
    setState(() => _selectedRating = rating);
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
                      onPressed: isSubmitting
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
                  onPressed: () => setState(() => _showRatingForm = true),
                  icon: const Icon(Icons.star_outline_rounded),
                  label: const Text('Esnafa puan ver'),
                ),
              const SizedBox(height: TSizes.spaceBtwItems),
              if (_showRatingForm && !isSuccess) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('shop-rating-submit-action'),
                    onPressed: isSubmitting || _selectedRating == 0
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
                  onPressed: isSubmitting ? null : widget.onClose,
                  child: const Text('Şimdi değil'),
                ),
              ] else
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: widget.onClose,
                    child: const Text('Tamam'),
                  ),
                ),
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

class _QrSessionContent extends StatelessWidget {
  final QrSessionEntity session;
  final String shopName;
  final int itemCount;
  final double totalAmount;
  final Duration remaining;
  final VoidCallback onRefresh;

  const _QrSessionContent({
    required this.session,
    required this.shopName,
    required this.itemCount,
    required this.totalAmount,
    required this.remaining,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = remaining.inSeconds <= 0;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mağazada Göster',
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
          _QrInfoRow(
            label: 'Kalan süre',
            value: isExpired ? 'Süresi doldu' : _formatRemaining(remaining),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          if (!isExpired)
            Center(
              child: Container(
                padding: const EdgeInsets.all(TSizes.sm),
                color: Colors.white,
                child: QrImageView(
                  data: session.sessionToken,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
              ),
            )
          else
            const Icon(Icons.timer_off_outlined, size: 72),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            'Alışverişi doğrula',
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.xs),
          Text(
            'QR kodunu esnafa okut. Onay verildiğinde bu ekran otomatik güncellenir. Rezervasyon veya stok garantisi sağlamaz.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (isExpired) ...[
            const SizedBox(height: TSizes.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRefresh,
                child: const Text('Yeniden Oluştur'),
              ),
            ),
          ],
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
