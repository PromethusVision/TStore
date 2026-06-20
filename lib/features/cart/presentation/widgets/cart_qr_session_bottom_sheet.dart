import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_state.dart';

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
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: TSizes.defaultSpace,
          right: TSizes.defaultSpace,
          top: TSizes.defaultSpace,
          bottom: MediaQuery.of(context).viewInsets.bottom + TSizes.defaultSpace,
        ),
        child: BlocConsumer<QrSessionCubit, QrSessionState>(
          listener: (context, state) {
            if (state is QrSessionCreated) {
              _startTimer();
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
                  context
                      .read<QrSessionCubit>()
                      .createQrSession(widget.cartId);
                },
              );
            }

            if (state is QrSessionCreated) {
              return _QrSessionContent(
                session: state.session,
                shopName: widget.shopName,
                itemCount: widget.itemCount,
                totalAmount: widget.totalAmount,
                remaining: state.session.expiresAt.difference(_now),
                onRefresh: () {
                  context
                      .read<QrSessionCubit>()
                      .createQrSession(widget.cartId);
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

  const _QrSessionFailureView({
    required this.message,
    required this.onRetry,
  });

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
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            'Bu QR ödeme değildir.',
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.xs),
          Text(
            'Rezervasyon veya stok garantisi sağlamaz. Mağaza kasasında göster.',
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

  const _QrInfoRow({
    required this.label,
    required this.value,
  });

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
