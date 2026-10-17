import 'package:flutter/material.dart';
import 'merchant_edit_recovery.dart';
import 'merchant_management_request.dart';
import 'merchant_read.dart';
import 'package:intl/intl.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/trust_commerce/domain/trust_commerce.dart';
import 'package:t_store/features/trust_commerce/presentation/trust_session_guard.dart';
import 'package:t_store/features/trust_commerce/presentation/trust_views.dart';

part 'merchant_campaign_editor.dart';

const _readFailure = TrustFailure(
  TrustFailureKind.unavailable,
  'Bilgiler yüklenemedi. Bağlantını kontrol edip yeniden dene.',
);
const _writeFailure = TrustFailure(
  TrustFailureKind.uncertain,
  'İşlem sonucu doğrulanamadı. Aynı işlemi tekrar dene.',
);

class MerchantCampaignSummary extends StatefulWidget {
  const MerchantCampaignSummary({
    super.key,
    required this.services,
    required this.access,
  });
  final MerchantServices services;
  final MerchantAccess access;
  @override
  State<MerchantCampaignSummary> createState() =>
      _MerchantCampaignSummaryState();
}

class _MerchantCampaignSummaryState extends State<MerchantCampaignSummary>
    with TrustSessionGuard<MerchantCampaignSummary>, WidgetsBindingObserver {
  CampaignPage? _data;
  String? _error;
  bool _loading = true, _opening = false;
  int _epoch = 0;
  @override
  TrustCommerceRepository get trustRepository => widget.services.trustCommerce!;
  @override
  String get trustActor => widget.access.user.id;
  @override
  void clearTrustSession() {
    _data = null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_opening) _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load() async {
    if (!sessionCurrent) return;
    final epoch = ++_epoch;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await managementRequest(
      () => trustRepository.campaigns(widget.access.shop!.id),
      failure: _readFailure,
    );
    if (!checkTrustContinuation() || epoch != _epoch) return;
    setState(() {
      _loading = false;
      result.fold((e) => _error = e.message, (v) => _data = v);
    });
  }

  Future<void> _open() async {
    if (_opening || !sessionCurrent) return;
    _opening = true;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => MerchantCampaignsView(
          services: widget.services,
          access: widget.access,
        ),
      ),
    );
    _opening = false;
    if (mounted && sessionCurrent) await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (!sessionCurrent ||
        (!_loading && _error == null && _data?.enabled != true)) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Mağaza kampanyaları',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_loading)
              const LinearProgressIndicator()
            else if (_error != null)
              TrustRetry(message: _error!, onRetry: _load)
            else ...[
              Text(
                '${_data!.total} kayıt · Duyuru ve mağazada uygulanan fırsatlar',
              ),
              TextButton(
                onPressed: _open,
                child: const Text('Kampanyaları yönet'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MerchantCampaignsView extends StatefulWidget {
  const MerchantCampaignsView({
    super.key,
    required this.services,
    required this.access,
  });
  final MerchantServices services;
  final MerchantAccess access;
  @override
  State<MerchantCampaignsView> createState() => _MerchantCampaignsViewState();
}

class _MerchantCampaignsViewState extends State<MerchantCampaignsView>
    with TrustSessionGuard<MerchantCampaignsView>, WidgetsBindingObserver {
  CampaignPage? _page;
  final _rows = <Campaign>[];
  TrustFailure? _failure;
  bool _loading = false, _busy = false, _opening = false;
  CampaignCommand? _pending;
  int _offset = 0;
  bool _retryMore = false, _confirming = false;
  @override
  TrustCommerceRepository get trustRepository => widget.services.trustCommerce!;
  @override
  String get trustActor => widget.access.user.id;
  @override
  void clearTrustSession() {
    _rows.clear();
    _pending = null;
    _page = null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    if (_loading ||
        _busy ||
        _opening ||
        _confirming ||
        _pending != null ||
        !sessionCurrent) {
      return;
    }
    _retryMore = more;
    final offset = more ? _offset : 0;
    setState(() {
      _loading = true;
      _failure = null;
    });
    final result = await managementRequest(
      () => trustRepository.campaigns(widget.access.shop!.id, offset: offset),
      failure: _readFailure,
    );
    if (!checkTrustContinuation()) return;
    if (result.fold((e) => e.kind == TrustFailureKind.auth, (_) => false)) {
      expireTrustSession();
      return;
    }
    setState(() {
      _loading = false;
      result.fold((e) => _failure = e, (p) {
        if (!more || !p.enabled) _rows.clear();
        if (p.enabled) {
          _rows.addAll(
            p.campaigns.where((c) => !_rows.any((old) => old.id == c.id)),
          );
        }
        _offset = offset + p.campaigns.length;
        _page = p;
      });
    });
  }

  Future<void> _edit([Campaign? campaign]) async {
    if (_opening ||
        _busy ||
        _loading ||
        _confirming ||
        _failure != null ||
        _pending != null ||
        !sessionCurrent ||
        _page?.enabled != true) {
      return;
    }
    _opening = true;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => MerchantCampaignEditor(
          services: widget.services,
          access: widget.access,
          existing: campaign,
          pricePublicationEnabled: _page!.pricePublicationEnabled,
        ),
      ),
    );
    _opening = false;
    if (mounted && sessionCurrent) await _load();
  }

  Future<void> _change(Campaign campaign, bool activate) async {
    if (_busy ||
        _loading ||
        _opening ||
        _confirming ||
        _failure != null ||
        _pending != null ||
        !sessionCurrent) {
      return;
    }
    if (activate) {
      setState(() => _confirming = true);
      final yes = await showDialog<bool>(
        context: context,
        builder: (context) => PrivateTrustOverlay(
          repository: trustRepository,
          actor: trustActor,
          child: AlertDialog(
            title: const Text('Kampanyayı yayınla'),
            content: SingleChildScrollView(
              child: Text(
                '${campaign.draft.title}\n\n${campaign.draft.offerLabel}\nMağazada uygulanır. Başlangıç tarihi gelince müşterilere görünür.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Vazgeç'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yayınla'),
              ),
            ],
          ),
        ),
      );
      if (!checkTrustContinuation()) return;
      setState(() => _confirming = false);
      if (yes != true) return;
    }
    _pending = CampaignCommand(
      shopId: widget.access.shop!.id,
      campaignId: campaign.id,
      expectedRevision: campaign.revisionId,
      requestId: newCampaignRequestId(),
      action: activate ? 'activate' : 'pause',
    );
    await _submit();
  }

  Future<void> _submit() async {
    if (_busy || _pending == null || !sessionCurrent) return;
    setState(() {
      _busy = true;
      _failure = null;
    });
    final result = await managementRequest(
      () => trustRepository.mutate(_pending!),
      failure: _writeFailure,
      write: true,
    );
    if (!checkTrustContinuation()) return;
    if (result.fold((e) => e.kind == TrustFailureKind.auth, (_) => false)) {
      expireTrustSession();
      return;
    }
    bool success = false;
    setState(() {
      _busy = false;
      result.fold(
        (e) {
          _failure = e;
          if (!e.retrySameRequest) _pending = null;
        },
        (_) {
          _pending = null;
          success = true;
        },
      );
    });
    if (success) await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (!sessionCurrent) return const TrustSessionExpired();
    final locked =
        _busy || _loading || _pending != null || _opening || _confirming;
    final stale = locked || _failure != null;
    return PopScope(
      canPop: !_busy && !_confirming && _pending == null,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kampanyalar'),
          actions: [
            IconButton(
              tooltip: 'Yenile',
              onPressed: locked ? null : _load,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Duyurularını ve mağazada uygulanacak fırsatlarını hazırla. Ürün fiyatları ve sepet otomatik değişmez.',
              ),
              if (_page?.enabled == true)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: FilledButton.icon(
                    onPressed: stale ? null : _edit,
                    icon: const Icon(Icons.add),
                    label: const Text('Kampanya oluştur'),
                  ),
                ),
              if (_loading || _busy) const LinearProgressIndicator(),
              if (_failure != null)
                TrustRetry(
                  message: _failure!.message,
                  onRetry: _busy
                      ? () {}
                      : _pending != null
                      ? _submit
                      : () => _load(more: _retryMore),
                ),
              if (_page?.enabled == false)
                const Text('Kampanyalar henüz kullanıma açılmadı.'),
              if (_page?.enabled == true && !_page!.pricePublicationEnabled)
                const Text(
                  'Fiyatlı ve yüzdeli kampanyaları taslak olarak hazırlayabilirsin. Yayınları henüz açılmadı.',
                ),
              if (_page?.enabled == true &&
                  _rows.isEmpty &&
                  !_loading &&
                  _failure == null)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Henüz kampanyan yok. İlk duyurunu oluştur.'),
                ),
              for (final c in _rows)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      c.statusLabel,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    if (c.blockedMessage != null) Text(c.blockedMessage!),
                    CampaignCard(
                      campaign: c,
                      actions: [
                        TextButton(
                          onPressed: stale ? null : () => _edit(c),
                          child: const Text('Düzenle'),
                        ),
                        if (c.active)
                          TextButton(
                            onPressed: stale ? null : () => _change(c, false),
                            child: const Text('Yayından kaldır'),
                          )
                        else
                          FilledButton(
                            onPressed:
                                stale ||
                                    (c.draft.type !=
                                            CampaignType.announcement &&
                                        !_page!.pricePublicationEnabled)
                                ? null
                                : () => _change(c, true),
                            child: const Text('Yayınla'),
                          ),
                      ],
                    ),
                  ],
                ),
              if (_offset < (_page?.total ?? 0) && _offset <= 500)
                TextButton(
                  onPressed: locked ? null : () => _load(more: true),
                  child: const Text('Daha fazla kampanya'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
