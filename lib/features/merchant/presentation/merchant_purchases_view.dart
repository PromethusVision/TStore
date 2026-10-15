import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/features/cart/data/qr_installation.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';
import 'package:t_store/features/purchases/domain/repositories/purchase_evidence_repository.dart';
import 'package:t_store/features/rewards/domain/reward_program.dart';

class MerchantPurchasesView extends StatefulWidget {
  const MerchantPurchasesView({
    super.key,
    required this.repository,
    required this.shopId,
    required this.userId,
  });
  final PurchaseEvidenceRepository repository;
  final String shopId, userId;
  @override
  State<MerchantPurchasesView> createState() => _MerchantPurchasesViewState();
}

class _MerchantPurchasesViewState extends State<MerchantPurchasesView> {
  final _rows = <PurchaseEvidence>[];
  bool _loading = false, _more = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await widget.repository.list(
      widget.shopId,
      offset: refresh ? 0 : _rows.length,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      result.fold((e) => _error = e, (rows) {
        if (refresh) _rows.clear();
        _rows.addAll(rows);
        _more = rows.length == 20;
      });
    });
  }

  Future<void> _open(PurchaseEvidence value) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _PurchaseDetail(
          repository: widget.repository,
          purchaseId: value.id,
          userId: widget.userId,
        ),
      ),
    );
    if (mounted) await _load(refresh: true);
  }

  @override
  Widget build(BuildContext context) => MerchantPage(
    title: 'Doğrulanmış alışverişler',
    children: [
      const MerchantNotice(
        'Burada yalnız EsnaftaVar ile doğrulanan alışverişler görünür.',
      ),
      if (_error != null)
        MerchantNotice(
          _error!,
          error: true,
          onRetry: () => _load(refresh: true),
        ),
      if (_rows.isEmpty && !_loading && _error == null)
        const MerchantNotice('Henüz doğrulanmış alışveriş yok.'),
      for (final p in _rows)
        ListTile(
          title: Text(
            p.saleExact != null
                ? rewardMoney(p.saleExact!)
                : p.finalSaleMinor == null
                ? 'Eski alışveriş kaydı'
                : merchantPrice(p.finalSaleMinor! / 100),
          ),
          subtitle: Text(
            '${_date(p.confirmedAt)} • ${p.items.length} ürün türü${p.invalidated ? ' • Geçersiz kayıt' : ''}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _open(p),
        ),
      if (_loading) const Center(child: CircularProgressIndicator()),
      if (!_loading && _more && _rows.isNotEmpty)
        OutlinedButton(
          onPressed: _load,
          child: const Text('Daha fazla göster'),
        ),
    ],
  );
}

String _date(DateTime value) {
  final d = value.toLocal();
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _PurchaseDetail extends StatefulWidget {
  const _PurchaseDetail({
    required this.repository,
    required this.purchaseId,
    required this.userId,
  });
  final PurchaseEvidenceRepository repository;
  final String purchaseId, userId;
  @override
  State<_PurchaseDetail> createState() => _PurchaseDetailState();
}

class _PurchaseDetailState extends State<_PurchaseDetail> {
  PurchaseEvidence? _purchase;
  String? _error;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await widget.repository.read(widget.purchaseId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      result.fold((e) => _error = e, (p) => _purchase = p);
    });
  }

  Future<void> _return() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _ReturnForm(
          repository: widget.repository,
          purchase: _purchase!,
          userId: widget.userId,
        ),
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final p = _purchase;
    return MerchantPage(
      title: 'Alışveriş kaydı',
      children: [
        if (_loading) const Center(child: CircularProgressIndicator()),
        if (_error != null)
          MerchantNotice(_error!, error: true, onRetry: _load),
        if (p != null) ...[
          SelectableText('İşlem no: ${p.id}'), Text(_date(p.confirmedAt)),
          if (p.finalSaleMinor != null)
            Text('Doğrulanan tutar: ${merchantPrice(p.finalSaleMinor! / 100)}'),
          if (p.saleExact != null) ...[
            Text('Satış: ${rewardMoney(p.saleExact!)}'),
            Text('Kullanılan EV kuponu: ${rewardMoney(p.couponExact!)}'),
            Text('Müşteriden alınan: ${rewardMoney(p.paymentExact!)}'),
          ],
          if (p.classification == 'legacy_unclassified')
            const MerchantNotice(
              'Eski kaydın satış ve iade koşulları eksik. Yeni koşullar varsayılmıyor.',
            ),
          if (p.invalidated)
            const MerchantNotice(
              'Bu alışveriş geçersiz olarak işaretlenmiş.',
              error: true,
            ),
          for (final i in p.items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(i.name),
              subtitle: Text(
                '${i.quantity} adet satın alındı • ${i.returnedQuantity} adet iade kaydı',
              ),
            ),
          MerchantNotice(
            p.classification == 'coupon_checkout_e_v1'
                ? 'İade kaydı satış ve kupon payını kaydeder. Para transferi veya kupon iadesi gerçekleştirmez.'
                : 'İade kaydı para transferi veya kupon iadesi gerçekleştirmez. İade süresi bu kayıtta tanımlı değildir.',
          ),
          if (p.canRecordReturn && !_loading && _error == null)
            FilledButton(
              onPressed: _return,
              child: const Text('İade kaydı oluştur'),
            ),
          // Keep recovery reachable even if a previous return consumed all units.
          if (!p.canRecordReturn &&
              const {
                'quote_only_b_v1',
                'coupon_checkout_e_v1',
              }.contains(p.classification) &&
              !_loading)
            OutlinedButton(
              onPressed: _return,
              child: const Text('Bekleyen iade isteğini kontrol et'),
            ),
          for (final r in p.returns)
            MerchantSection(
              title: r.isCorrection ? 'İade düzeltmesi' : 'İade kaydı',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_date(r.occurredAt)),
                  SelectableText('Kayıt no: ${r.id}'),
                  const Text('Para iadesi gerçekleştirilmedi.'),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _ReturnForm extends StatefulWidget {
  const _ReturnForm({
    required this.repository,
    required this.purchase,
    required this.userId,
  });
  final PurchaseEvidenceRepository repository;
  final PurchaseEvidence purchase;
  final String userId;
  @override
  State<_ReturnForm> createState() => _ReturnFormState();
}

class _ReturnFormState extends State<_ReturnForm> {
  final _reason = TextEditingController();
  late final _quantities = {
    for (final i in widget.purchase.items)
      i.id: TextEditingController(text: '0'),
  };
  bool _loading = true, _sending = false, _success = false;
  String? _error;
  Map<String, dynamic>? _pending;
  String get _key => 'pending_return_b:${widget.userId}:${widget.purchase.id}';
  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (!mounted) return;
      if (raw != null) {
        final p = Map<String, dynamic>.from(jsonDecode(raw) as Map);
        if (p['request_id'] is! String ||
            p['reason'] is! String ||
            p['quantities'] is! Map) {
          throw const FormatException('Invalid draft');
        }
        _pending = p;
        _reason.text = p['reason'] as String;
        for (final entry in (p['quantities'] as Map).entries) {
          _quantities[entry.key]?.text = entry.value.toString();
        }
      }
      setState(() => _loading = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error =
              'Bekleyen istek okunamadı. Yeni kayıt göndermeden önce yeniden deneyin.';
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_sending || _loading || _success) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      if (_pending == null) {
        final quantities = <String, int>{};
        for (final i in widget.purchase.items) {
          final value = int.tryParse(_quantities[i.id]!.text);
          if (value == null || value < 0 || value > i.remaining) {
            throw const FormatException('İade adedini kontrol edin.');
          }
          if (value > 0) quantities[i.id] = value;
        }
        if (quantities.isEmpty || _reason.text.trim().isEmpty) {
          throw const FormatException('En az bir ürün ve iade nedeni girin.');
        }
        final draft = <String, dynamic>{
          'request_id': newQrRequestId(),
          'reason': _reason.text.trim(),
          'quantities': quantities,
        };
        final prefs = await SharedPreferences.getInstance();
        if (!await prefs.setString(_key, jsonEncode(draft))) {
          throw StateError('Draft could not persist');
        }
        if (!mounted) return;
        _pending = draft;
      }
      final result = await widget.repository.recordReturn(
        purchaseId: widget.purchase.id,
        requestId: _pending!['request_id'] as String,
        reason: _pending!['reason'] as String,
        quantities: Map<String, int>.from(_pending!['quantities'] as Map),
      );
      if (!mounted) return;
      await result.fold(
        (e) async {
          if (e.definitelyRejected) {
            final prefs = await SharedPreferences.getInstance();
            if (!await prefs.remove(_key)) {
              throw StateError('Rejected draft could not clear');
            }
            if (!mounted) return;
            _pending = null;
          }
          if (mounted) setState(() => _error = e.message);
        },
        (_) async {
          final prefs = await SharedPreferences.getInstance();
          // A failed clear retains the same idempotent request across reopen/restart.
          if (!await prefs.remove(_key)) {
            throw StateError('Acknowledgement could not persist');
          }
          if (mounted) setState(() => _success = true);
        },
      );
    } on FormatException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'İşlem sonucu kesinleşmedi. Aynı isteği yeniden kontrol edin.',
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _reason.dispose();
    for (final c in _quantities.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MerchantPage(
    title: 'İade kaydı',
    children: [
      const MerchantNotice(
        'Bu işlem yalnız iade kanıtı kaydeder. Para iadesi yapmaz.',
      ),
      if (_success) const MerchantNotice('İade kaydı sunucuda doğrulandı.'),
      if (_pending != null && !_success)
        const MerchantNotice(
          'Kaydedilmiş istek aynı işlem numarasıyla kontrol edilecek. Sonuç kesinleşene kadar bilgiler değiştirilemez.',
        ),
      if (_error != null)
        MerchantNotice(
          _error!,
          error: true,
          onRetry: _loading ? _restore : null,
        ),
      if (_loading || _sending)
        const Center(child: CircularProgressIndicator()),
      if (!_loading && !_success) ...[
        for (final i in widget.purchase.items)
          TextField(
            controller: _quantities[i.id],
            enabled: !_sending && _pending == null,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            decoration: InputDecoration(
              labelText: i.name,
              helperText: 'İade kaydı açılabilecek adet: ${i.remaining}',
            ),
          ),
        TextField(
          controller: _reason,
          enabled: !_sending && _pending == null,
          maxLength: 500,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'İade nedeni'),
        ),
        FilledButton(
          onPressed: _sending ? null : _submit,
          child: Text(
            _pending == null
                ? 'İade kaydını onayla'
                : 'Aynı isteğin sonucunu kontrol et',
          ),
        ),
      ],
      if (_success)
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Alışveriş kaydına dön'),
        ),
    ],
  );
}
