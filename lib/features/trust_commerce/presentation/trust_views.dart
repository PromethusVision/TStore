import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_store/features/trust_commerce/domain/trust_commerce.dart';
import 'package:t_store/features/trust_commerce/presentation/trust_session_guard.dart';

Future<void> showTrustExplanation(
  BuildContext context,
  TrustBadge badge, {
  Widget Function(Widget)? protect,
}) => showDialog<void>(
  context: context,
  barrierDismissible: true,
  builder: (context) {
    final dialog = AlertDialog(
      title: Text(badge.title),
      content: SingleChildScrollView(
        child: Text(
          '${badge.explanation}\n\nRozetler para, indirim veya arama sırası ayrıcalığı sağlamaz.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kapat'),
        ),
      ],
    );
    return protect?.call(dialog) ?? dialog;
  },
);

class TrustBadgeStrip extends StatelessWidget {
  const TrustBadgeStrip({super.key, required this.badges, this.protect});
  final List<TrustBadge> badges;
  final Widget Function(Widget)? protect;
  @override
  Widget build(BuildContext context) {
    final visible = highestTrustBadges(badges);
    if (visible.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth < 340 ? 2 : 3;
        return Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final badge in visible.take(count))
              ActionChip(
                avatar: const Icon(Icons.verified_outlined, size: 18),
                label: Text(badge.title),
                onPressed: () =>
                    showTrustExplanation(context, badge, protect: protect),
              ),
            if (visible.length > count)
              ActionChip(
                label: Text('+${visible.length - count}'),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) {
                    final dialog = AlertDialog(
                      title: const Text('Rozetler'),
                      content: SizedBox(
                        width: 360,
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            for (final badge in visible)
                              ListTile(
                                title: Text(badge.title),
                                subtitle: Text(badge.explanation),
                              ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Kapat'),
                        ),
                      ],
                    );
                    return protect?.call(dialog) ?? dialog;
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class TrustSummary extends StatefulWidget {
  const TrustSummary({
    super.key,
    required this.repository,
    required this.actor,
    this.shopId,
    this.readTimeout = const Duration(seconds: 15),
  });
  final TrustCommerceRepository repository;
  final String actor;
  final String? shopId;
  final Duration readTimeout;
  @override
  State<TrustSummary> createState() => _TrustSummaryState();
}

class _TrustSummaryState extends State<TrustSummary>
    with WidgetsBindingObserver, TrustSessionGuard<TrustSummary> {
  TrustSnapshot? _data;
  String? _error;
  bool _loading = true, _opening = false;
  int _epoch = 0;
  @override
  TrustCommerceRepository get trustRepository => widget.repository;
  @override
  String get trustActor => widget.actor;
  @override
  void clearTrustSession() {
    _data = null;
    _epoch++;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void didUpdateWidget(TrustSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shopId != widget.shopId) _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  @override
  void dispose() {
    _epoch++;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load() async {
    if (!checkTrustContinuation()) return;
    final epoch = ++_epoch;
    setState(() {
      _loading = true;
      _error = null;
      _data = null;
    });
    try {
      final result = await widget.repository
          .trust(shopId: widget.shopId)
          .timeout(widget.readTimeout);
      if (!mounted || epoch != _epoch || !checkTrustContinuation()) return;
      result.fold(
        (e) {
          if (e.kind == TrustFailureKind.auth) {
            expireTrustSession();
          } else {
            setState(() {
              _loading = false;
              _error = e.message;
            });
          }
        },
        (v) => setState(() {
          _loading = false;
          _data = v;
        }),
      );
    } catch (_) {
      if (!mounted || epoch != _epoch || !checkTrustContinuation()) return;
      setState(() {
        _loading = false;
        _error =
            'Bilgiler yüklenemedi. Bağlantınızı kontrol edip tekrar deneyin.';
      });
    }
  }

  Future<void> _open() async {
    if (_opening || !sessionCurrent) return;
    _opening = true;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => TrustDetailView(
          repository: widget.repository,
          actor: widget.actor,
          shopId: widget.shopId,
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
              widget.shopId == null ? 'Rozetlerim' : 'Mağazamın rozetleri',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_loading)
              const LinearProgressIndicator()
            else if (_error != null)
              TrustRetry(message: _error!, onRetry: _load)
            else ...[
              TrustBadgeStrip(
                badges: _data!.badges,
                protect: (child) => PrivateTrustOverlay(
                  repository: widget.repository,
                  actor: widget.actor,
                  child: child,
                ),
              ),
              if (!_data!.badges.any((b) => b.eligible))
                const Text('İlk rozetine doğru ilerlemeni takip et.'),
              TextButton(
                onPressed: _open,
                child: const Text('İlerleme ve geçmiş'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TrustDetailView extends StatefulWidget {
  const TrustDetailView({
    super.key,
    required this.repository,
    required this.actor,
    this.shopId,
    this.readTimeout = const Duration(seconds: 15),
  });
  final TrustCommerceRepository repository;
  final String actor;
  final String? shopId;
  final Duration readTimeout;
  @override
  State<TrustDetailView> createState() => _TrustDetailViewState();
}

class _TrustDetailViewState extends State<TrustDetailView>
    with WidgetsBindingObserver, TrustSessionGuard<TrustDetailView> {
  TrustSnapshot? _data;
  final _history = <TrustEvent>[];
  String? _error;
  bool _loading = false, _retryMore = false;
  int _epoch = 0;
  @override
  TrustCommerceRepository get trustRepository => widget.repository;
  @override
  String get trustActor => widget.actor;
  @override
  void clearTrustSession() {
    _data = null;
    _history.clear();
    _epoch++;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void didUpdateWidget(TrustDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shopId != widget.shopId) _load(force: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load(force: true);
  }

  @override
  void dispose() {
    _epoch++;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load({bool more = false, bool force = false}) async {
    if (!checkTrustContinuation() || (_loading && !force)) return;
    final before = more ? _data?.nextBefore : null;
    if (more && before == null) return;
    final epoch = ++_epoch;
    setState(() {
      _loading = true;
      _error = null;
      _retryMore = more;
      if (!more) {
        _data = null;
        _history.clear();
      }
    });
    try {
      final result = await widget.repository
          .trust(shopId: widget.shopId, before: before)
          .timeout(widget.readTimeout);
      if (!mounted || epoch != _epoch || !checkTrustContinuation()) return;
      result.fold(
        (e) {
          if (e.kind == TrustFailureKind.auth) {
            expireTrustSession();
          } else {
            setState(() {
              _loading = false;
              _error = e.message;
            });
          }
        },
        (v) => setState(() {
          _loading = false;
          if (!v.enabled) {
            _history.clear();
            _data = const TrustSnapshot(enabled: false);
            _retryMore = false;
          } else if (!_validPage(v, before)) {
            _data = null;
            _history.clear();
            _retryMore = false;
            _error =
                'Bilgiler değişti. Güncel durumu görmek için yeniden deneyin.';
          } else {
            _history.addAll(v.history);
            _data = v;
          }
        }),
      );
    } catch (_) {
      if (!mounted || epoch != _epoch || !checkTrustContinuation()) return;
      setState(() {
        _loading = false;
        _error =
            'Bilgiler yüklenemedi. Bağlantınızı kontrol edip tekrar deneyin.';
      });
    }
  }

  bool _validPage(TrustSnapshot value, int? before) {
    var previous = before;
    for (final event in value.history) {
      if (event.id <= 0 ||
          (previous != null && event.id >= previous) ||
          _history.any((old) => old.id == event.id)) {
        return false;
      }
      previous = event.id;
    }
    return value.nextBefore == null ||
        (value.history.isNotEmpty && value.nextBefore == value.history.last.id);
  }

  @override
  Widget build(BuildContext context) {
    if (!sessionCurrent) return const TrustSessionExpired();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rozetler ve ilerleme'),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(force: true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Doğrulanmış alışveriş ve değerlendirmelerden hesaplanır. Para veya sıralama ayrıcalığı sağlamaz.',
            ),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              TrustRetry(
                message: _error!,
                onRetry: () => _load(more: _retryMore),
              ),
            if (_data?.enabled == false)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Rozetler henüz kullanıma açılmadı.'),
              ),
            for (final b in _data?.badges ?? <TrustBadge>[])
              Semantics(
                container: true,
                explicitChildNodes: true,
                child: Card(
                  semanticContainer: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              b.eligible
                                  ? Icons.verified
                                  : Icons.shield_outlined,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                b.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            IconButton(
                              tooltip: '${b.title} koşulları',
                              onPressed: () => showTrustExplanation(
                                context,
                                b,
                                protect: (child) => PrivateTrustOverlay(
                                  repository: widget.repository,
                                  actor: widget.actor,
                                  child: child,
                                ),
                              ),
                              icon: const Icon(Icons.info_outline),
                            ),
                          ],
                        ),
                        Text(
                          b.eligible
                              ? 'Kazanıldı'
                              : b.pending
                              ? 'Onaylı mahalle eşleşmesi bekleniyor'
                              : 'Koşullar henüz tamamlanmadı',
                        ),
                        if (b.requiredCount != null) ...[
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: b.progress),
                          Text(
                            '${b.count ?? 0} / ${b.requiredCount} ${b.family == 'reviews'
                                ? 'değerlendirme'
                                : b.family == 'purchases'
                                ? 'alışveriş'
                                : 'farklı müşteri'}',
                          ),
                        ],
                        if (b.requiredValue != null)
                          Text(
                            'Puan: ${b.value?.toStringAsFixed(3).replaceAll('.', ',') ?? '—'} · Eşik: ${b.requiredValue!.toStringAsFixed(2).replaceAll('.', ',')}',
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_data?.enabled == true) ...[
              const SizedBox(height: 16),
              Text(
                'Kazanım ve düzeltme geçmişi',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (_history.isEmpty && !_loading)
                const Text('Henüz bir rozet değişikliği yok.'),
              for (final event in _history)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    event.event == 'awarded'
                        ? Icons.verified_outlined
                        : Icons.history,
                  ),
                  title: Text(
                    _data!.badges
                            .where((b) => b.code == event.code)
                            .firstOrNull
                            ?.title ??
                        'Rozet',
                  ),
                  subtitle: Text(
                    '${event.event == 'awarded' ? 'Kazanıldı' : 'Koşullar değişti, rozet kaldırıldı'} · ${DateFormat('dd.MM.yyyy HH:mm').format(event.recordedAt.toLocal())}',
                  ),
                ),
              if (_data?.nextBefore != null)
                TextButton(
                  onPressed: _loading ? null : () => _load(more: true),
                  child: const Text('Önceki değişiklikler'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class TrustRetry extends StatelessWidget {
  const TrustRetry({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        TextButton(onPressed: onRetry, child: const Text('Tekrar dene')),
      ],
    ),
  );
}

class ShopTrustOffers extends StatefulWidget {
  const ShopTrustOffers({
    super.key,
    required this.repository,
    required this.shopId,
    this.readTimeout = const Duration(seconds: 15),
  });
  final TrustCommerceRepository repository;
  final String shopId;
  final Duration readTimeout;
  @override
  State<ShopTrustOffers> createState() => _ShopTrustOffersState();
}

class _ShopTrustOffersState extends State<ShopTrustOffers>
    with WidgetsBindingObserver {
  List<TrustBadge> _badges = const [];
  List<Campaign> _offers = const [];
  String? _error;
  int _epoch = 0;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void didUpdateWidget(ShopTrustOffers oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shopId != widget.shopId ||
        !identical(oldWidget.repository, widget.repository)) {
      _badges = [];
      _offers = [];
      _load();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  @override
  void dispose() {
    _epoch++;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load() async {
    final epoch = ++_epoch;
    setState(() {
      _loading = true;
      _error = null;
      _badges = [];
      _offers = [];
    });
    // Subscribe to both failures immediately; one failed read must not leave
    // another future's error unhandled or keep the visible section loading.
    final repository = widget.repository, shop = widget.shopId;
    Future<void> badges() async {
      final value = await repository
          .shopBadges(shop)
          .timeout(widget.readTimeout);
      if (!mounted || epoch != _epoch) return;
      value.fold((e) => _error = e.message, (v) => _badges = v);
    }

    Future<void> offers() async {
      final value = await repository
          .shopCampaigns(shop)
          .timeout(widget.readTimeout);
      if (!mounted || epoch != _epoch) return;
      value.fold((e) => _error = e.message, (v) => _offers = v);
    }

    try {
      await Future.wait([badges(), offers()]);
    } catch (_) {
      if (!mounted || epoch != _epoch) return;
      _error =
          'Bilgiler yüklenemedi. Bağlantınızı kontrol edip tekrar deneyin.';
    }
    if (!mounted || epoch != _epoch) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (_loading) const LinearProgressIndicator(),
      if (_error != null) TrustRetry(message: _error!, onRetry: _load),
      TrustBadgeStrip(badges: _badges),
      if (_offers.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'Mağazanın duyuru ve fırsatları',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      for (final offer in _offers.take(3)) PublicCampaignCard(campaign: offer),
      if (_offers.length > 3)
        TextButton(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (context) => SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * .8,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('Tüm duyuru ve fırsatlar'),
                    for (final offer in _offers)
                      PublicCampaignCard(campaign: offer),
                  ],
                ),
              ),
            ),
          ),
          child: const Text('Tümünü gör'),
        ),
    ],
  );
}

class PublicCampaignCard extends StatefulWidget {
  const PublicCampaignCard({super.key, required this.campaign});
  final Campaign campaign;
  @override
  State<PublicCampaignCard> createState() => _PublicCampaignCardState();
}

class _PublicCampaignCardState extends State<PublicCampaignCard> {
  Timer? _expiry;
  bool _elapsed = false;
  bool get _expired =>
      _elapsed ||
      widget.campaign.displayExpiresAt?.isAfter(DateTime.now()) == false;
  void _schedule() {
    _expiry?.cancel();
    _elapsed = false;
    final deadline = widget.campaign.displayExpiresAt;
    if (deadline != null && !_expired) {
      _expiry = Timer(deadline.difference(DateTime.now()), () {
        if (mounted) setState(() => _elapsed = true);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(PublicCampaignCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _schedule();
  }

  @override
  void dispose() {
    _expiry?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _expired
      ? const SizedBox.shrink()
      : CampaignCard(campaign: widget.campaign);
}

class CampaignCard extends StatelessWidget {
  const CampaignCard({
    super.key,
    required this.campaign,
    this.preview = false,
    this.actions = const [],
  });
  final Campaign campaign;
  final bool preview;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    child: Card(
      semanticContainer: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (preview) const Text('Önizleme · Henüz yayınlanmadı'),
            Text(
              campaign.draft.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              campaign.draft.offerLabel,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (campaign.images.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final image in campaign.images)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: image.url == null
                            ? const SizedBox(
                                width: 140,
                                child: Icon(Icons.image_outlined),
                              )
                            : Image.network(
                                image.url!,
                                width: 140,
                                fit: BoxFit.cover,
                                errorBuilder: (_, error, stack) =>
                                    const SizedBox(
                                      width: 140,
                                      child: Icon(Icons.image_outlined),
                                    ),
                              ),
                      ),
                  ],
                ),
              ),
            if (campaign.draft.description.isNotEmpty)
              Text(campaign.draft.description),
            Text(
              campaign.draft.scope == CampaignScope.all
                  ? 'Satışa açık tüm ürünlerde'
                  : '${campaign.draft.listingIds.length} seçili üründe',
            ),
            if (campaign.products.isNotEmpty)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Geçerli ürünleri gör'),
                children: [
                  for (final product in campaign.products)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(product.name),
                    ),
                ],
              ),
            Text(
              '${DateFormat('dd.MM.yyyy HH:mm').format(campaign.draft.startsAt.toLocal())} – ${DateFormat('dd.MM.yyyy HH:mm').format(campaign.draft.endsAt.toLocal())}',
            ),
            const SizedBox(height: 8),
            const Text(
              'Mağazada uygulanır. Sepette otomatik indirim oluşturmaz.',
            ),
            if (actions.isNotEmpty)
              Wrap(spacing: 8, runSpacing: 4, children: actions),
          ],
        ),
      ),
    ),
  );
}
