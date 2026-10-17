import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_store/features/merchant/data/pending_purchase_return_store.dart';
import 'package:t_store/features/merchant/presentation/merchant_edit_recovery.dart';
import 'package:t_store/features/merchant/presentation/merchant_return_controller.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';
import 'package:t_store/features/purchases/domain/repositories/purchase_evidence_repository.dart';

class MerchantReturnForm extends StatefulWidget {
  const MerchantReturnForm({
    super.key,
    required this.repository,
    required this.purchase,
    required this.userId,
    this.store,
  });
  final PurchaseEvidenceRepository repository;
  final PurchaseEvidence purchase;
  final String userId;
  final PendingPurchaseReturnStore? store;
  @override
  State<MerchantReturnForm> createState() => _MerchantReturnFormState();
}

class _MerchantReturnFormState extends State<MerchantReturnForm> {
  final _reason = TextEditingController();
  late final _quantities = {
    for (final i in widget.purchase.items)
      i.id: TextEditingController(text: '0'),
  };
  late final MerchantReturnController _controller;
  PendingPurchaseReturn? _displayed;
  String? _validation;

  @override
  void initState() {
    super.initState();
    _controller = MerchantReturnController(
      repository: widget.repository,
      purchase: widget.purchase,
      store:
          widget.store ??
          LocalPendingPurchaseReturnStore(
            userId: widget.userId,
            purchaseId: widget.purchase.id,
          ),
    )..addListener(_changed);
    _reason.addListener(_edited);
    for (final c in _quantities.values) {
      c.addListener(_edited);
    }
    _controller.restore();
  }

  void _edited() {
    if (mounted) setState(() => _validation = null);
  }

  void _changed() {
    if (!mounted) return;
    final pending = _controller.pending;
    if (pending != null && !identical(pending, _displayed)) {
      _displayed = pending;
      _reason.text = pending.reason;
      for (final entry in _quantities.entries) {
        entry.value.text = (pending.quantities[entry.key] ?? 0).toString();
      }
    }
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_controller.canSubmit) return;
    final quantities = <String, int>{};
    if (_controller.pending == null) {
      for (final entry in _quantities.entries) {
        final n = int.tryParse(entry.value.text);
        if (n == null || n < 0) {
          setState(() => _validation = 'İade adedini kontrol edin.');
          return;
        }
        if (n > 0) quantities[entry.key] = n;
      }
    }
    FocusScope.of(context).unfocus();
    await _controller.submit(quantities: quantities, reason: _reason.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    _controller.dispose();
    _reason.dispose();
    for (final c in _quantities.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final dirty =
        c.pending == null &&
        !c.confirmed &&
        (_reason.text.isNotEmpty ||
            _quantities.values.any((v) => v.text != '0'));
    return MerchantDraftGuard(
      dirty: c.current && dirty,
      busy: c.current && c.busy,
      child: MerchantPage(
        title: 'İade kaydı',
        children: [
          const MerchantNotice(
            'Bu işlem yalnız iade kanıtı kaydeder. Para iadesi yapmaz.',
          ),
          if (!c.current)
            const MerchantNotice(
              'Oturum değişti. Bu ekranı kapatıp yeniden giriş yapın.',
            )
          else ...[
            if (c.confirmed)
              const MerchantNotice('İade kaydı sunucuda doğrulandı.'),
            if (c.pending != null && !c.confirmed)
              const MerchantNotice(
                'Kaydedilmiş istek aynı işlem numarasıyla kontrol edilecek. Sonuç kesinleşene kadar bilgiler değiştirilemez.',
              ),
            if (_validation != null || c.error != null)
              MerchantNotice(
                _validation ?? c.error!,
                error: true,
                onRetry: c.busy
                    ? null
                    : c.cleanupRequired
                    ? c.retryCleanup
                    : !c.ready
                    ? (c.pending == null && _displayed != null
                          ? c.refresh
                          : c.restore)
                    : null,
              ),
            if (c.busy) const Center(child: CircularProgressIndicator()),
            if (c.ready && !c.confirmed) ...[
              for (final i in c.purchase.items)
                TextField(
                  key: Key('return-quantity-${i.id}'),
                  controller: _quantities[i.id],
                  enabled: !c.busy,
                  readOnly: !c.canEdit || !c.purchase.canRecordReturn,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  decoration: InputDecoration(
                    labelText: i.name,
                    helperText: 'İade kaydı açılabilecek adet: ${i.remaining}',
                    helperMaxLines: 3,
                  ),
                ),
              TextField(
                controller: _reason,
                enabled: !c.busy,
                readOnly: !c.canEdit || !c.purchase.canRecordReturn,
                maxLength: 500,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'İade nedeni'),
              ),
              if (!c.purchase.canRecordReturn && c.pending == null)
                const MerchantNotice(
                  'Bekleyen istek yok. Bu kayıtta yeni iade açılabilecek ürün bulunmuyor.',
                )
              else
                FilledButton(
                  onPressed: c.canSubmit ? _submit : null,
                  child: Text(
                    c.pending == null
                        ? 'İade kaydını onayla'
                        : 'Aynı isteğin sonucunu kontrol et',
                  ),
                ),
            ],
            if (c.confirmed)
              FilledButton(
                onPressed: c.busy ? null : () => Navigator.of(context).pop(),
                child: const Text('Alışveriş kaydına dön'),
              ),
          ],
        ],
      ),
    );
  }
}
