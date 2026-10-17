import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';
import 'package:t_store/features/rewards/domain/reward_program.dart';
import 'package:t_store/features/cart/domain/repositories/qr_claim_repository.dart';
import 'package:t_store/features/merchant/presentation/merchant_purchases_view.dart';
import 'package:t_store/features/purchases/domain/repositories/purchase_evidence_repository.dart';
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
    this.shopId,
    this.purchaseEvidence,
    this.userId,
  });
  final QrSessionRepository repository;
  final bool preview;
  final String? shopId;
  final PurchaseEvidenceRepository? purchaseEvidence;
  final String? userId;
  @override
  State<MerchantQrView> createState() => _MerchantQrViewState();
}

class _MerchantQrViewState extends State<MerchantQrView>
    with WidgetsBindingObserver {
  late final QrVerificationCubit _cubit;
  final _token = TextEditingController();
  Timer? _expiry;
  bool _scanning = false;
  bool _openingHistory = false;
  bool get _claimsEnabled =>
      widget.shopId != null &&
      widget.repository is QrClaimRepository &&
      (widget.repository as QrClaimRepository).claimsEnabled;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit = QrVerificationCubit(
      shopId: widget.shopId,
      getQrVerificationUsecase: GetQrVerificationUsecase(widget.repository),
      confirmQrVerificationUsecase: ConfirmQrVerificationUsecase(
        widget.repository,
      ),
    );
    if (_claimsEnabled) _cubit.recoverClaim();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _claimsEnabled) {
      _cubit.refreshClaim();
    }
  }

  @override
  void dispose() {
    _expiry?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _token.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _scan() async {
    if (_scanning) return;
    _scanning = true;
    try {
      final token = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const _MerchantCamera()),
      );
      if (mounted && token != null) _cubit.loadVerification(token);
    } finally {
      _scanning = false;
    }
  }

  bool _confirmingSale = false;
  Future<void> _history() async {
    if (_openingHistory ||
        widget.purchaseEvidence == null ||
        widget.shopId == null ||
        widget.userId == null) {
      return;
    }
    _openingHistory = true;
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => MerchantPurchasesView(
            repository: widget.purchaseEvidence!,
            shopId: widget.shopId!,
            userId: widget.userId!,
          ),
        ),
      );
    } finally {
      _openingHistory = false;
    }
  }

  Future<void> _confirm(QrVerificationEntity verification) async {
    if (_confirmingSale) return;
    if (!verification.rewardConfirmationRequired) {
      await _cubit.confirmVerification();
      return;
    }
    _confirmingSale = true;
    try {
      final approved = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          scrollable: true,
          title: const Text('Gerçek satış tutarını doğrula'),
          content: Text(
            verification.couponCheckout == null
                ? '${rewardMoney(LedgerMinorUnits.fromWire(verification.rewardSaleMinor))} tutarında fiziksel alışveriş tamamlandığını ve bu satışta EV kuponu kullanılmadığını onaylıyor musunuz?\n\nFarklı bir tutar veya mağaza indirimi varsa bu işlemi iptal edin. Yanlış tutarla ödül kazandırmayın.'
                : 'Satış: ${rewardMoney(verification.couponCheckout!.sale)}\nMüşterinin onayladığı EV kuponu: ${rewardMoney(verification.couponCheckout!.coupon)}\nMüşteriden alınacak: ${rewardMoney(verification.couponCheckout!.payment)}\n\nFiziksel alışveriş ve kalan ödeme tamamlandı mı? Tutarlar farklıysa iptal edin ve müşteriden yeni onay isteyin.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Satışı doğrula'),
            ),
          ],
        ),
      );
      final current = _cubit.state;
      final currentVerification = switch (current) {
        QrVerificationLoaded() => current.verification,
        QrVerificationUncertain() => current.verification,
        _ => null,
      };
      if (mounted &&
          approved == true &&
          verification.canBeConfirmed &&
          currentVerification == verification) {
        await _cubit.confirmVerification();
      }
    } finally {
      _confirmingSale = false;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<QrVerificationCubit, QrVerificationState>(
    bloc: _cubit,
    listener: (context, state) {
      _expiry?.cancel();
      if (state is QrVerificationLoaded) {
        final delay = state.verification.confirmationDeadline.difference(
          DateTime.now(),
        );
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
        QrVerificationUncertain() => state.verification,
        _ => null,
      };
      return MerchantPage(
        title: 'QR doğrula',
        children: [
          if (widget.purchaseEvidence != null &&
              widget.shopId != null &&
              widget.userId != null)
            OutlinedButton.icon(
              onPressed: busy ? null : _history,
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Doğrulanmış alışverişler'),
            ),
          const MerchantNotice(
            'Müşterinin mağazanız için oluşturduğu QR kodunu okutun. Ürünleri kontrol ettikten sonra onaylayın.',
          ),
          if (widget.preview)
            const Text(
              'Yerel önizleme • Bu ekran gerçek alışveriş kanıtı oluşturmaz.',
            ),
          if (state is QrVerificationFailure)
            MerchantNotice(state.message, error: true),
          if (state is QrClaimRecoveryRequired)
            MerchantNotice(
              'Son işlem durumu doğrulanamadı. Yeni kod almadan önce son işlemi geri yükleyin. ${state.message}',
              error: true,
              onRetry: _cubit.recoverClaim,
            ),
          if (state is QrVerificationUncertain)
            MerchantNotice(
              'İşlemin sonucu henüz doğrulanamadı. ${state.message}',
              error: true,
              onRetry: _cubit.refreshClaim,
            ),
          if (state is QrVerificationSuccess)
            const MerchantNotice('Sunucu işlem onayını doğruladı.'),
          if (state is QrVerificationSuccess &&
              state.verification.purchaseId != null)
            SelectableText(
              'Doğrulanan işlem no: ${state.verification.purchaseId}',
            ),
          if (busy) const Center(child: CircularProgressIndicator()),
          if (state is QrVerificationConfirming)
            const Text(
              'Sunucu yanıtı bekleniyor. Bu sırada yeni bir işlem başlatılmaz.',
            ),
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
                    if (verification.protocolVersion == 2)
                      Text(
                        'Kod alındı. Tamamlama son saati: ${verification.confirmationDeadline.toLocal().hour.toString().padLeft(2, '0')}:${verification.confirmationDeadline.toLocal().minute.toString().padLeft(2, '0')}',
                      ),
                    if (!verification.canBeConfirmed)
                      const MerchantNotice(
                        'QR süresi doldu. Müşteriden yeni kod isteyin.',
                        error: true,
                      ),
                    FilledButton(
                      onPressed: verification.canBeConfirmed
                          ? () => _confirm(verification)
                          : null,
                      child: const Text('İşlemi onayla'),
                    ),
                    if (verification.protocolVersion == 2) ...[
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _cubit.refreshClaim,
                        child: const Text('İşlem durumunu kontrol et'),
                      ),
                      TextButton(
                        onPressed: _cubit.cancelClaim,
                        child: const Text('İşlemi iptal et'),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          if (!busy &&
              verification == null &&
              state is! QrClaimRecoveryRequired) ...[
            FilledButton.icon(
              onPressed: widget.preview ? null : _scan,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Kamerayla okut'),
            ),
            if (_claimsEnabled) ...[
              TextField(
                controller: _token,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  labelText: 'Müşterinin 6 haneli kodu',
                ),
              ),
              OutlinedButton(
                onPressed: () =>
                    _cubit.claimVerification(manualCode: _token.text.trim()),
                child: const Text('Kodu kontrol et'),
              ),
              TextButton(
                onPressed: _cubit.recoverClaim,
                child: const Text('Son işlemi geri yükle'),
              ),
            ],
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
          if (!busy &&
              state is! QrVerificationInitial &&
              state is! QrVerificationUncertain &&
              state is! QrClaimRecoveryRequired &&
              !(verification?.protocolVersion == 2 &&
                  verification?.canBeConfirmed == true))
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
