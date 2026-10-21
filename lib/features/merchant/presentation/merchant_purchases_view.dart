import 'package:flutter/material.dart';
import 'package:t_store/features/merchant/presentation/merchant_purchase_scope.dart';
import 'package:t_store/features/merchant/presentation/merchant_read.dart';
import 'package:t_store/features/merchant/presentation/merchant_return_form.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';
import 'package:t_store/features/purchases/domain/repositories/purchase_evidence_repository.dart';
import 'package:t_store/features/rewards/domain/reward_program.dart';

class MerchantPurchasesView extends StatefulWidget {
  const MerchantPurchasesView({
    super.key,
    required this.repository,
    required this.shopId,
    required this.userId,
    this.originIsCurrent,
  });
  final PurchaseEvidenceRepository repository;
  final String shopId, userId;
  final bool Function()? originIsCurrent;
  @override
  State<MerchantPurchasesView> createState() => _MerchantPurchasesViewState();
}

class _MerchantPurchasesViewState extends State<MerchantPurchasesView>
    with WidgetsBindingObserver {
  final _rows = <PurchaseEvidence>[];
  bool _loading = false, _more = true;
  String? _error;
  late MerchantPurchaseScope _scope;
  int _epoch = 0, _offset = 0;
  bool _opening = false, _pageFailed = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scope = MerchantPurchaseScope(
      widget.repository,
      onRetired: _retire,
      originIsCurrent: widget.originIsCurrent,
    );
    _load();
  }

  @override
  void didUpdateWidget(covariant MerchantPurchasesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.userId != widget.userId ||
        oldWidget.shopId != widget.shopId) {
      _scope.close();
      _scope = MerchantPurchaseScope(
        widget.repository,
        onRetired: _retire,
        originIsCurrent: widget.originIsCurrent,
      );
      _load(refresh: true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_opening) _load(refresh: true);
  }

  @override
  void dispose() {
    _scope.close();
    _epoch++;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _retire() {
    if (!mounted) return;
    setState(() {
      _epoch++;
      _rows.clear();
      _error = null;
      _loading = false;
    });
  }

  Future<void> _load({bool refresh = false}) async {
    if (!_scope.current || _loading && !refresh) return;
    final scope = _scope;
    final epoch = ++_epoch;
    setState(() {
      _loading = true;
      _error = null;
      _pageFailed = false;
      if (refresh) {
        _rows.clear();
        _offset = 0;
        _more = true;
      }
    });
    final result = await merchantRead(
      () => widget.repository.list(widget.shopId, offset: _offset),
    );
    if (!mounted || !scope.current || epoch != _epoch) return;
    setState(() {
      _loading = false;
      result.fold(
        (e) {
          _error = e;
          _pageFailed = _rows.isNotEmpty;
        },
        (rows) {
          if (rows.any((p) => p.shopId != widget.shopId) || rows.length > 20) {
            _rows.clear();
            _offset = 0;
            _more = false;
            _error = 'Alışveriş listesi doğrulanamadı.';
            return;
          }
          _offset += rows.length;
          final merged = {
            for (final p in _rows) p.id: p,
            for (final p in rows) p.id: p,
          };
          _rows
            ..clear()
            ..addAll(merged.values);
          _more = rows.length == 20;
        },
      );
    });
  }

  Future<void> _open(PurchaseEvidence value) async {
    if (_opening || !_scope.current || _loading) return;
    _opening = true;
    final scope = _scope;
    final repository = widget.repository,
        shopId = widget.shopId,
        userId = widget.userId;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _PurchaseDetail(
          repository: repository,
          purchaseId: value.id,
          userId: userId,
          shopId: shopId,
          originIsCurrent: () => scope.current,
        ),
      ),
    );
    _opening = false;
    if (mounted && scope.current) await _load(refresh: true);
  }

  @override
  Widget build(BuildContext context) => MerchantPage(
    title: 'Doğrulanmış alışverişler',
    onRefresh: () => _load(refresh: true),
    children: [
      if (!_scope.current)
        const MerchantNotice('Oturum değişti. Bu ekranı kapatın.')
      else ...[
        const MerchantNotice(
          'Burada yalnız EsnaftaVar ile doğrulanan alışverişler görünür.',
        ),
        if (_error != null)
          MerchantNotice(
            _error!,
            error: true,
            onRetry: () => _load(refresh: !_pageFailed),
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
            onTap: _loading || _opening ? null : () => _open(p),
          ),
        if (_loading) const Center(child: CircularProgressIndicator()),
        if (!_loading && _error == null && _more && _rows.isNotEmpty)
          OutlinedButton(
            onPressed: _load,
            child: const Text('Daha fazla göster'),
          ),
      ],
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
    required this.shopId,
    required this.originIsCurrent,
  });
  final PurchaseEvidenceRepository repository;
  final String purchaseId, userId, shopId;
  final bool Function() originIsCurrent;
  @override
  State<_PurchaseDetail> createState() => _PurchaseDetailState();
}

class _PurchaseDetailState extends State<_PurchaseDetail>
    with WidgetsBindingObserver {
  PurchaseEvidence? _purchase;
  String? _error;
  bool _loading = false;
  bool _opening = false;
  int _epoch = 0;
  late final _scope = MerchantPurchaseScope(
    widget.repository,
    originIsCurrent: widget.originIsCurrent,
    onRetired: _retire,
  );
  void _retire() {
    if (!mounted) return;
    setState(() {
      _epoch++;
      _purchase = null;
      _error = null;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  Future<void> _load() async {
    if (!_scope.current) return;
    final epoch = ++_epoch;
    setState(() {
      _loading = true;
      _error = null;
      _purchase = null;
    });
    final result = await merchantRead(
      () => widget.repository.read(widget.purchaseId),
    );
    if (!mounted || !_scope.current || epoch != _epoch) return;
    setState(() {
      _loading = false;
      result.fold((e) => _error = e, (p) {
        if (p.id != widget.purchaseId || p.shopId != widget.shopId) {
          _error = 'Alışveriş bilgisi doğrulanamadı.';
        } else {
          _purchase = p;
        }
      });
    });
  }

  Future<void> _return() async {
    if (_opening ||
        !_scope.current ||
        _loading ||
        _purchase == null ||
        _error != null) {
      return;
    }
    _opening = true;
    final purchase = _purchase!;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MerchantReturnForm(
          repository: widget.repository,
          purchase: purchase,
          userId: widget.userId,
          originIsCurrent: () => _scope.current,
        ),
      ),
    );
    _opening = false;
    if (mounted && _scope.current) await _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_opening) _load();
  }

  @override
  void dispose() {
    _scope.close();
    _epoch++;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = _scope.current ? _purchase : null;
    return MerchantPage(
      title: 'Alışveriş kaydı',
      onRefresh: _load,
      children: [
        if (!_scope.current)
          const MerchantNotice('Oturum değişti. Bu ekranı kapatın.')
        else if (_loading)
          const Center(child: CircularProgressIndicator()),
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
              !_loading &&
              _error == null)
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
