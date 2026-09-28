import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:t_store/features/cart/domain/repositories/qr_session_repository.dart';
import 'package:t_store/features/cart/domain/usecases/confirm_qr_verification_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/get_qr_verification_usecase.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_verification_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_verification_state.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';

class MerchantQrView extends StatefulWidget {
  const MerchantQrView({
    super.key,
    required this.repository,
    this.preview = false,
  });
  final QrSessionRepository repository;
  final bool preview;
  @override
  State<MerchantQrView> createState() => _MerchantQrViewState();
}

class _MerchantQrViewState extends State<MerchantQrView> {
  late final QrVerificationCubit _cubit;
  final _token = TextEditingController();
  Timer? _expiry;
  @override
  void initState() {
    super.initState();
    _cubit = QrVerificationCubit(
      getQrVerificationUsecase: GetQrVerificationUsecase(widget.repository),
      confirmQrVerificationUsecase: ConfirmQrVerificationUsecase(
        widget.repository,
      ),
    );
  }

  @override
  void dispose() {
    _expiry?.cancel();
    _token.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _scan() async {
    final token = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const _MerchantCamera()));
    if (mounted && token != null) _cubit.loadVerification(token);
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<QrVerificationCubit, QrVerificationState>(
    bloc: _cubit,
    listener: (context, state) {
      _expiry?.cancel();
      if (state is QrVerificationLoaded) {
        final delay = state.verification.expiresAt.difference(DateTime.now());
        _expiry = Timer(delay.isNegative ? Duration.zero : delay, () {
          if (mounted) setState(() {});
        });
      }
    },
    builder: (context, state) {
      final busy =
          state is QrVerificationLoading || state is QrVerificationConfirming;
      final verification = switch (state) {
        QrVerificationLoaded() => state.verification,
        QrVerificationConfirming() => state.verification,
        QrVerificationSuccess() => state.verification,
        _ => null,
      };
      return MerchantPage(
        title: 'QR doğrula',
        children: [
          const MerchantNotice(
            'Müşterinin mağazanız için oluşturduğu QR kodunu okutun. Ürünleri kontrol ettikten sonra onaylayın.',
          ),
          if (widget.preview)
            const Text(
              'Yerel önizleme • Bu ekran gerçek alışveriş kanıtı oluşturmaz.',
            ),
          if (state is QrVerificationFailure)
            MerchantNotice(state.message, error: true),
          if (state is QrVerificationSuccess)
            const MerchantNotice('Sunucu işlem onayını doğruladı.'),
          if (busy) const Center(child: CircularProgressIndicator()),
          if (verification != null)
            MerchantSection(
              title: verification.shopName,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final item in verification.items)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.productName),
                      subtitle: Text(
                        '${item.quantity} adet × ${merchantPrice(item.unitPrice)}',
                      ),
                      trailing: Text(merchantPrice(item.lineTotal)),
                    ),
                  const Divider(),
                  Text(
                    'Toplam: ${merchantPrice(verification.totalAmount)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (state is QrVerificationLoaded) ...[
                    const SizedBox(height: 16),
                    if (!verification.canBeConfirmed)
                      const MerchantNotice(
                        'QR süresi doldu. Müşteriden yeni kod isteyin.',
                        error: true,
                      ),
                    FilledButton(
                      onPressed: verification.canBeConfirmed
                          ? _cubit.confirmVerification
                          : null,
                      child: const Text('İşlemi onayla'),
                    ),
                  ],
                ],
              ),
            ),
          if (!busy && verification == null) ...[
            FilledButton.icon(
              onPressed: widget.preview ? null : _scan,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Kamerayla okut'),
            ),
            if (widget.preview) ...[
              TextField(
                controller: _token,
                decoration: const InputDecoration(
                  labelText: 'Yerel test QR kodu',
                ),
              ),
              OutlinedButton(
                onPressed: () => _cubit.loadVerification(_token.text),
                child: const Text('Test kodunu kontrol et'),
              ),
            ],
          ],
          if (!busy && state is! QrVerificationInitial)
            TextButton(
              onPressed: _cubit.reset,
              child: const Text('Yeni QR okut'),
            ),
        ],
      );
    },
  );
}

class _MerchantCamera extends StatefulWidget {
  const _MerchantCamera();
  @override
  State<_MerchantCamera> createState() => _MerchantCameraState();
}

class _MerchantCameraState extends State<_MerchantCamera>
    with WidgetsBindingObserver {
  final _controller = MobileScannerController(
    autoStart: false,
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handled = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    if (!mounted || _handled) return;
    try {
      await _controller.start();
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Kamera açılamadı. Kamera iznini cihaz ayarlarından kontrol edin.',
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _start();
    } else {
      unawaited(_controller.stop().catchError((Object _) {}));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('QR kodunu okut')),
    body: SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Müşterinin QR kodunu kameranın ortasına getir.'),
          ),
          if (_error != null)
            MerchantNotice(
              _error!,
              error: true,
              onRetry: () {
                setState(() => _error = null);
                _start();
              },
            ),
          Expanded(
            child: MobileScanner(
              controller: _controller,
              errorBuilder: (context, error) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Kamera kullanılamıyor. Kamera iznini kontrol edip ekranı yeniden açın.',
                  ),
                ),
              ),
              onDetect: (capture) {
                if (_handled) return;
                final token = capture.barcodes
                    .map((b) => b.rawValue)
                    .whereType<String>()
                    .where((v) => v.trim().isNotEmpty)
                    .firstOrNull;
                if (token == null) return;
                _handled = true;
                unawaited(_controller.stop().catchError((Object _) {}));
                Navigator.pop(context, token.trim());
              },
            ),
          ),
        ],
      ),
    ),
  );
}
