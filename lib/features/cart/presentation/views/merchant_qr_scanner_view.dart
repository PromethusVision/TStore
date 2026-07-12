import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_verification_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_verification_state.dart';

class MerchantQrScannerView extends StatelessWidget {
  const MerchantQrScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QrVerificationCubit>(),
      child: const _MerchantQrScannerBody(),
    );
  }
}

class _MerchantQrScannerBody extends StatefulWidget {
  const _MerchantQrScannerBody();

  @override
  State<_MerchantQrScannerBody> createState() => _MerchantQrScannerBodyState();
}

class _MerchantQrScannerBodyState extends State<_MerchantQrScannerBody>
    with WidgetsBindingObserver {
  late final MobileScannerController _scannerController;
  StreamSubscription<BarcodeCapture>? _scannerSubscription;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scannerController = MobileScannerController(
      autoStart: false,
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const [BarcodeFormat.qrCode],
    );
    unawaited(_startScanner());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_scannerSubscription?.cancel());
    _scannerSubscription = null;
    super.dispose();
    unawaited(_scannerController.dispose());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_isProcessing) {
          unawaited(_startScanner());
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        unawaited(_stopScanner());
        break;
    }
  }

  Future<void> _startScanner() async {
    if (_isProcessing) return;

    _scannerSubscription ??= _scannerController.barcodes.listen(
      _handleDetection,
    );

    if (_scannerController.value.isRunning ||
        _scannerController.value.isStarting) {
      return;
    }

    try {
      await _scannerController.start();
    } catch (_) {
      // MobileScanner renders permission and camera failures in errorBuilder.
    }
  }

  Future<void> _stopScanner() async {
    await _scannerSubscription?.cancel();
    _scannerSubscription = null;

    if (!_scannerController.value.isRunning) return;

    try {
      await _scannerController.stop();
    } catch (_) {
      // A lifecycle transition may already have stopped the camera.
    }
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing || capture.barcodes.isEmpty) return;

    final token = capture.barcodes.first.rawValue?.trim() ?? '';
    if (token.isEmpty) return;

    _isProcessing = true;
    await _stopScanner();

    if (!mounted) return;
    context.read<QrVerificationCubit>().loadVerification(token);
  }

  Future<void> _scanAgain() async {
    _isProcessing = false;
    context.read<QrVerificationCubit>().reset();
    await _startScanner();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBarModel: AppBarModel(
          title: const Text('Kasada QR Doğrula'),
          hasArrowBack: true,
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<QrVerificationCubit, QrVerificationState>(
          builder: (context, state) {
            Widget? foreground;

            if (state is QrVerificationLoading) {
              foreground = const _LoadingPanel(
                message: 'QR bilgileri güvenli biçimde kontrol ediliyor...',
              );
            } else if (state is QrVerificationLoaded) {
              foreground = _VerificationPreview(
                verification: state.verification,
                isConfirming: false,
                onConfirm: () =>
                    context.read<QrVerificationCubit>().confirmVerification(),
                onScanAgain: _scanAgain,
              );
            } else if (state is QrVerificationConfirming) {
              foreground = _VerificationPreview(
                verification: state.verification,
                isConfirming: true,
                onConfirm: null,
                onScanAgain: null,
              );
            } else if (state is QrVerificationSuccess) {
              foreground = _VerificationSuccessPanel(
                verification: state.verification,
                onClose: () => Navigator.of(context).pop(true),
              );
            } else if (state is QrVerificationFailure) {
              foreground = _VerificationFailurePanel(
                message: state.message,
                onScanAgain: _scanAgain,
              );
            }

            return Stack(
              children: [
                Positioned.fill(
                  child: _ScannerPanel(controller: _scannerController),
                ),
                if (foreground != null)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: foreground,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScannerPanel extends StatelessWidget {
  const _ScannerPanel({required this.controller});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              Text(
                'Müşterinin telefonundaki QR kodunu çerçevenin içine alın.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.xs),
              Text(
                'Kod okunduktan sonra ürünleri ve toplamı onaylamadan önce göreceksiniz.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              TSizes.defaultSpace,
              0,
              TSizes.defaultSpace,
              TSizes.defaultSpace,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final shortestSide =
                      constraints.maxWidth < constraints.maxHeight
                      ? constraints.maxWidth
                      : constraints.maxHeight;
                  final scanSide = shortestSide * 0.72;
                  final scanWindow = Rect.fromCenter(
                    center: Offset(
                      constraints.maxWidth / 2,
                      constraints.maxHeight / 2,
                    ),
                    width: scanSide,
                    height: scanSide,
                  );

                  return MobileScanner(
                    controller: controller,
                    useAppLifecycleState: false,
                    scanWindow: kIsWeb ? null : scanWindow,
                    errorBuilder: (context, error) {
                      return _CameraErrorPanel(error: error);
                    },
                    overlayBuilder: (context, constraints) {
                      return Center(
                        child: Container(
                          width: scanSide,
                          height: scanSide,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CameraErrorPanel extends StatelessWidget {
  const _CameraErrorPanel({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final permissionDenied =
        error.errorCode == MobileScannerErrorCode.permissionDenied;

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined, size: 52),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                permissionDenied
                    ? 'QR okuyabilmek için kamera izni gerekiyor.'
                    : 'Kamera şu anda açılamadı.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.sm),
              Text(
                permissionDenied
                    ? 'Telefon ayarlarından kamera iznini açıp tekrar deneyin.'
                    : 'Kameranın başka bir uygulama tarafından kullanılmadığını kontrol edin.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (permissionDenied) ...[
                const SizedBox(height: TSizes.spaceBtwItems),
                FilledButton(
                  onPressed: openAppSettings,
                  child: const Text('Ayarları Aç'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _VerificationPreview extends StatelessWidget {
  const _VerificationPreview({
    required this.verification,
    required this.isConfirming,
    required this.onConfirm,
    required this.onScanAgain,
  });

  final QrVerificationEntity verification;
  final bool isConfirming;
  final VoidCallback? onConfirm;
  final VoidCallback? onScanAgain;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            verification.shopName,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.xs),
          Text(
            'Ürünleri müşteriyle birlikte kontrol edin.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.spaceBtwSections),
          ...verification.items.map(
            (item) => _VerificationItemCard(item: item),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          _SummaryRow(
            label: 'Toplam ürün adedi',
            value: verification.itemCount.toString(),
          ),
          _SummaryRow(
            label: 'Genel toplam',
            value: '₺${verification.totalAmount.toStringAsFixed(2)}',
            emphasize: true,
          ),
          const SizedBox(height: TSizes.spaceBtwSections),
          FilledButton.icon(
            onPressed: onConfirm,
            icon: isConfirming
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.verified_outlined),
            label: Text(
              isConfirming ? 'Doğrulanıyor...' : 'Alışverişi Doğrula',
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          OutlinedButton(
            onPressed: onScanAgain,
            child: const Text('Vazgeç ve Başka QR Oku'),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            'Bu işlem ödeme almaz. Yalnızca mağazada gerçekleşen alışverişi doğrular.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VerificationItemCard extends StatelessWidget {
  const _VerificationItemCard({required this.item});

  final QrVerificationItemEntity item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      child: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.productName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TSizes.sm),
            _SummaryRow(label: 'Adet', value: item.quantity.toString()),
            _SummaryRow(
              label: 'Birim fiyat',
              value: '₺${item.unitPrice.toStringAsFixed(2)}',
            ),
            _SummaryRow(
              label: 'Satır toplamı',
              value: '₺${item.lineTotal.toStringAsFixed(2)}',
              emphasize: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _VerificationSuccessPanel extends StatelessWidget {
  const _VerificationSuccessPanel({
    required this.verification,
    required this.onClose,
  });

  final QrVerificationEntity verification;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 72, color: colorScheme.primary),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              'Alışveriş doğrulandı',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSizes.sm),
            Text(
              '${verification.itemCount} ürün • ₺${verification.totalAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onClose,
                child: const Text('Mağazama Dön'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationFailurePanel extends StatelessWidget {
  const _VerificationFailurePanel({
    required this.message,
    required this.onScanAgain,
  });

  final String message;
  final VoidCallback onScanAgain;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.qr_code_scanner_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              'QR doğrulanamadı',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSizes.sm),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onScanAgain,
                child: const Text('Başka QR Oku'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
