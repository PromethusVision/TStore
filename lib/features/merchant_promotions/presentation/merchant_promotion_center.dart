import 'dart:async';
import 'package:flutter/material.dart';
import '../domain/merchant_promotion.dart';

class MerchantPromotionCenter extends StatefulWidget {
  const MerchantPromotionCenter({
    super.key,
    required this.repository,
    required this.shopId,
    required this.ownerId,
  });
  final MerchantPromotionRepository repository;
  final String shopId, ownerId;
  @override
  State<MerchantPromotionCenter> createState() =>
      _MerchantPromotionCenterState();
}

class _MerchantPromotionCenterState extends State<MerchantPromotionCenter>
    with WidgetsBindingObserver {
  StreamSubscription<String?>? _session;
  final _drafts = <PromotionDraft>[],
      _history = <PromotionHistoryEntry>[],
      _sources = <PromotionSource>[];
  final _search = TextEditingController();
  PromotionSelection _selection = const PromotionSelection();
  PromotionPreview? _preview;
  PromotionDraft? _draft;
  PromotionCommand? _pending;
  PromotionFailure? _error;
  String _page = 'list',
      _sourceKind = 'listing',
      _listingLabel = '',
      _campaignLabel = '';
  bool _busy = false, _enabled = false, _more = false, _broken = false;
  int _generation = 0;
  bool get _current =>
      !_broken && widget.repository.currentUserId == widget.ownerId;
  bool get _locked => _busy || _pending != null;
  void _fail(PromotionFailure error) {
    _error = error;
    if (error == PromotionFailure.session) {
      _broken = true;
      _drafts.clear();
      _history.clear();
      _sources.clear();
      _preview = null;
      _draft = null;
      _pending = null;
    }
    if (error == PromotionFailure.unavailable) {
      _sources.clear();
      _history.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listen();
    _load();
  }

  void _listen() {
    _session = widget.repository.sessionChanges.listen(
      (_) {
        _invalidate();
      },
      onError: (Object _) {
        _broken = true;
        _invalidate();
      },
    );
  }

  void _invalidate() {
    if (!mounted) return;
    _generation++;
    setState(() {
      _drafts.clear();
      _history.clear();
      _sources.clear();
      _preview = null;
      _busy = false;
      _error = null;
      if (!_current) {
        _pending = null;
        _draft = null;
        _selection = const PromotionSelection();
        _listingLabel = '';
        _campaignLabel = '';
        _page = 'list';
      } else if (_pending != null) {
        _page = 'editor';
        _error = PromotionFailure.uncertain;
      }
    });
    if (_current && _page == 'list') _load();
  }

  @override
  void didUpdateWidget(covariant MerchantPromotionCenter old) {
    super.didUpdateWidget(old);
    if (old.repository != widget.repository ||
        old.shopId != widget.shopId ||
        old.ownerId != widget.ownerId) {
      _session?.cancel();
      _pending = null;
      _draft = null;
      _selection = const PromotionSelection();
      _page = 'list';
      _broken = false;
      _listen();
      _invalidate();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _invalidate();
  }

  @override
  void dispose() {
    _generation++;
    _session?.cancel();
    _search.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    if (!_current || _busy) return;
    final generation = ++_generation, offset = more ? _drafts.length : 0;
    setState(() {
      _busy = true;
      _error = null;
      if (!more) _drafts.clear();
    });
    final result = await widget.repository.read(widget.shopId, offset: offset);
    if (!mounted || !_current || generation != _generation) return;
    setState(() {
      _busy = false;
      result.fold(
        (e) {
          _fail(e);
        },
        (v) {
          _enabled = v.enabled;
          if (!v.enabled) _drafts.clear();
          _more = v.hasMore;
          final known = _drafts.map((e) => e.id).toSet();
          _drafts.addAll(v.items.where((e) => !known.contains(e.id)));
        },
      );
    });
  }

  void _edit([PromotionDraft? draft]) {
    setState(() {
      _generation++;
      _page = 'editor';
      _draft = draft;
      _selection = draft?.selection ?? const PromotionSelection();
      _preview = null;
      _error = null;
      _pending = null;
      _listingLabel = draft?.copy.title ?? '';
      _campaignLabel = draft?.copy.title ?? '';
    });
  }

  void _select(PromotionSelection selection) {
    setState(() {
      _generation++;
      _selection = selection;
      _preview = null;
      _error = null;
    });
  }

  Future<void> _previewNow() async {
    if (!_current || _locked) return;
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _error = null;
      _preview = null;
    });
    final result = await widget.repository.preview(widget.shopId, _selection);
    if (!mounted || !_current || generation != _generation) return;
    setState(() {
      _busy = false;
      result.fold(_fail, (v) => _preview = v);
    });
  }

  Future<void> _submit(String action) async {
    if (!_current || _busy) return;
    if (_pending == null) {
      if (action == 'save' && _preview?.ready != true) return;
      _pending = PromotionCommand(
        shopId: widget.shopId,
        draftId: _draft?.id,
        expectedRevision: _draft?.revisionId,
        action: action,
        selection: action == 'save' ? _selection : null,
        fingerprint: action == 'save' ? _preview!.fingerprint : null,
      );
    }
    final command = _pending!, generation = ++_generation;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await widget.repository.mutate(command);
    if (!mounted || !_current || generation != _generation) return;
    var success = false;
    setState(() {
      _busy = false;
      result.fold(
        (e) {
          _fail(e);
          if (e != PromotionFailure.uncertain) {
            _pending = null;
            _preview = null;
          }
        },
        (_) {
          _pending = null;
          _preview = null;
          _page = 'list';
          success = true;
        },
      );
    });
    if (success) {
      await _load();
    }
  }

  Future<void> _pickSource(String kind, {bool more = false}) async {
    if (!_current || _locked) return;
    if (_page != 'sources') {
      _sourceKind = kind;
      _search.clear();
    }
    final generation = ++_generation, offset = more ? _sources.length : 0;
    setState(() {
      _page = 'sources';
      _busy = true;
      _error = null;
      if (!more) _sources.clear();
    });
    final result = await widget.repository.sources(
      widget.shopId,
      _sourceKind,
      query: _search.text.trim(),
      offset: offset,
    );
    if (!mounted || !_current || generation != _generation) return;
    setState(() {
      _busy = false;
      result.fold(_fail, (v) {
        _more = v.length == 20;
        _sources.addAll(v.where((e) => !_sources.any((old) => old.id == e.id)));
      });
    });
  }

  Future<void> _readHistory(PromotionDraft draft, {bool more = false}) async {
    if (!_current || _locked) return;
    final generation = ++_generation, offset = more ? _history.length : 0;
    setState(() {
      _page = 'history';
      _draft = draft;
      _busy = true;
      _error = null;
      if (!more) _history.clear();
    });
    final result = await widget.repository.history(
      widget.shopId,
      draft.id,
      offset: offset,
    );
    if (!mounted || !_current || generation != _generation) return;
    setState(() {
      _busy = false;
      result.fold(_fail, (v) {
        _more = v.length == 20;
        _history.addAll(v);
      });
    });
  }

  void _back() {
    if (_locked) return;
    setState(() {
      _generation++;
      _error = null;
      _page = _page == 'sources' ? 'editor' : 'list';
    });
    if (_page == 'list') _load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_current) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tanıtım Merkezi')),
        body: const SafeArea(
          child: Center(
            child: Text('Oturum değişti. Tanıtım merkezini yeniden aç.'),
          ),
        ),
      );
    }
    return PopScope(
      canPop: !_locked && _page == 'list',
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tanıtım Merkezi'),
          leading: _page == 'list'
              ? null
              : IconButton(
                  tooltip: 'Geri',
                  onPressed: _locked ? null : _back,
                  icon: const Icon(Icons.arrow_back),
                ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children:
                <Widget>[
                      const Text(
                        'Tanıtımını hazırla',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Taslaklar müşterilere gösterilmez. Satın alma, yayınlama ve gönderim henüz açık değil.',
                      ),
                      if (_error != null) ...[
                        Text(
                          _error!.message,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        if (_pending != null)
                          FilledButton(
                            onPressed: _busy
                                ? null
                                : () => _submit(_pending!.action),
                            child: const Text('Aynı işlemi kontrol et'),
                          ),
                      ],
                      if (_busy) const LinearProgressIndicator(),
                      ...switch (_page) {
                        'editor' => _editor(),
                        'sources' => _sourcePicker(),
                        'history' => _historyView(),
                        _ => _list(),
                      },
                    ]
                    .map(
                      (child) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: child,
                      ),
                    )
                    .toList(),
          ),
        ),
      ),
    );
  }

  List<Widget> _list() => [
    OutlinedButton(
      onPressed: _busy ? null : () => _load(),
      child: const Text('Listeyi yenile'),
    ),
    if (!_busy && !_enabled && _error == null)
      const Text('Tanıtım hazırlama bu ortamda henüz açılmadı.'),
    if (_enabled)
      FilledButton.icon(
        onPressed: _busy ? null : () => _edit(),
        icon: const Icon(Icons.add),
        label: const Text('Yeni tanıtım taslağı'),
      ),
    if (_enabled && !_busy && _drafts.isEmpty && _error == null)
      const Text('Henüz tanıtım taslağın yok.'),
    for (final d in _drafts)
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                d.copy.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(d.statusLabel),
              Text(d.copy.body),
              if (d.status == 'needs_update')
                const Text(
                  'Kaydedilmiş içerik güncel bilgilerle uyuşmuyor. Yeniden önizle.',
                ),
              Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: _busy ? null : () => _edit(d),
                    child: Text(
                      d.status == 'archived'
                          ? 'Taslak olarak geri al'
                          : 'Düzenle',
                    ),
                  ),
                  TextButton(
                    onPressed: _busy ? null : () => _readHistory(d),
                    child: const Text('Geçmiş'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    if (_enabled && _more)
      OutlinedButton(
        onPressed: _busy ? null : () => _load(more: true),
        child: const Text('Daha fazla taslak'),
      ),
    const SizedBox(height: 16),
    const Text('Gösterim ve etkileşim raporu yayınlama aşamasında açılacak.'),
  ];
  List<Widget> _editor() {
    final readySelection =
        (_selection.family != PromotionFamily.product ||
            _selection.listingId != null) &&
        (_selection.family != PromotionFamily.offer ||
            _selection.campaignId != null);
    return [
      if (_draft != null) Text('Kaydedilmiş sürüm · ${_draft!.statusLabel}'),
      DropdownButtonFormField<PromotionFamily>(
        initialValue: _selection.family,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Tanıtım türü'),
        items: PromotionFamily.values
            .map(
              (f) => DropdownMenuItem(
                value: f,
                child: Text(switch (f) {
                  PromotionFamily.store => 'Mağaza tanıtımı',
                  PromotionFamily.product => 'Ürün tanıtımı',
                  PromotionFamily.offer => 'Kampanya duyurusu',
                  PromotionFamily.invitation => 'Mağazaya davet',
                }),
              ),
            )
            .toList(),
        onChanged: _locked
            ? null
            : (f) {
                if (f != null) {
                  _listingLabel = '';
                  _campaignLabel = '';
                  _select(PromotionSelection(family: f));
                }
              },
      ),
      DropdownButtonFormField<int>(
        key: ValueKey('variant-${_selection.family}'),
        initialValue: _selection.variant,
        decoration: const InputDecoration(labelText: 'Metin seçeneği'),
        items: const [
          DropdownMenuItem(value: 0, child: Text('Seçenek 1')),
          DropdownMenuItem(value: 1, child: Text('Seçenek 2')),
        ],
        onChanged: _locked
            ? null
            : (v) {
                if (v != null) {
                  _select(
                    PromotionSelection(
                      family: _selection.family,
                      variant: v,
                      listingId: _selection.listingId,
                      campaignId: _selection.campaignId,
                      imageId: _selection.imageId,
                    ),
                  );
                }
              },
      ),
      if (_selection.family == PromotionFamily.offer)
        OutlinedButton(
          onPressed: _locked ? null : () => _pickSource('campaign'),
          child: Text(
            _selection.campaignId == null
                ? 'Aktif kampanya seç'
                : 'Kampanya: $_campaignLabel',
          ),
        ),
      OutlinedButton(
        onPressed: _locked ? null : () => _pickSource('listing'),
        child: Text(
          _selection.listingId == null
              ? (_selection.family == PromotionFamily.product
                    ? 'Ürün seç'
                    : 'Fotoğraf için ürün seç (isteğe bağlı)')
              : 'Ürün: $_listingLabel',
        ),
      ),
      if (_selection.listingId != null &&
          _selection.family != PromotionFamily.product)
        TextButton(
          onPressed: _locked
              ? null
              : () {
                  _select(
                    PromotionSelection(
                      family: _selection.family,
                      variant: _selection.variant,
                      campaignId: _selection.campaignId,
                    ),
                  );
                },
          child: const Text('Ürün ve fotoğraf seçimini kaldır'),
        ),
      const Text(
        'Metinler güncel mağaza, ürün ve kampanya bilgilerinden hazırlanır. Yeni fotoğrafları ürün yönetiminden ekleyebilirsin.',
      ),
      OutlinedButton(
        onPressed: _locked || !readySelection ? null : _previewNow,
        child: const Text('Önizlemeyi yenile'),
      ),
      if (_preview case final preview?) ...[
        if (!preview.enabled)
          const Text('Tanıtım hazırlama bu ortamda kapalı.')
        else if (!preview.ready)
          const Text(
            'Seçilen kaynak artık uygun değil. Ürün, kampanya veya fotoğrafı yeniden seç.',
          ),
        if (preview.ready) ...[
          PromotionCopyCard(copy: preview.copy!, label: 'Güncel önizleme'),
          if (preview.images.isNotEmpty) ...[
            const Text('Ürün fotoğrafı'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Fotoğrafsız'),
                  selected: _selection.imageId == null,
                  onSelected: _locked ? null : (_) => _choosePhoto(null),
                ),
                for (final photo in preview.images)
                  SizedBox(
                    width: 136,
                    child: Column(
                      children: [
                        if (photo.url != null)
                          Image.network(
                            photo.url!,
                            height: 96,
                            width: 128,
                            fit: BoxFit.cover,
                            errorBuilder: (_, error, stack) =>
                                const Text('Fotoğraf yüklenemedi'),
                          )
                        else
                          const Text('Fotoğraf yüklenemedi'),
                        ChoiceChip(
                          label: Text(
                            'Fotoğraf ${preview.images.indexOf(photo) + 1}',
                          ),
                          selected: _selection.imageId == photo.id,
                          onSelected: _locked
                              ? null
                              : (_) => _choosePhoto(photo.id),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ],
      FilledButton(
        onPressed: _locked || _preview?.ready != true
            ? null
            : () => _submit('save'),
        child: const Text('Taslağı kaydet'),
      ),
      if (_draft != null && _draft!.status != 'archived')
        OutlinedButton(
          onPressed: _locked ? null : () => _submit('archive'),
          child: const Text('Arşivle'),
        ),
      if (_error == PromotionFailure.changed && _draft != null)
        TextButton(
          onPressed: _locked ? null : _back,
          child: const Text('Güncel taslak listesine dön'),
        ),
    ];
  }

  void _choosePhoto(String? image) {
    _select(
      PromotionSelection(
        family: _selection.family,
        variant: _selection.variant,
        listingId: _selection.listingId,
        campaignId: _selection.campaignId,
        imageId: image,
      ),
    );
    _previewNow();
  }

  List<Widget> _sourcePicker() => [
    Text(_sourceKind == 'listing' ? 'Uygun ürünler' : 'Aktif kampanyalar'),
    TextField(
      controller: _search,
      enabled: !_busy,
      maxLength: 120,
      decoration: const InputDecoration(labelText: 'Ara'),
      onSubmitted: (_) => _pickSource(_sourceKind),
    ),
    OutlinedButton(
      onPressed: _busy ? null : () => _pickSource(_sourceKind),
      child: const Text('Ara'),
    ),
    if (!_busy && _sources.isEmpty && _error == null)
      const Text(
        'Uygun kayıt bulunamadı. Ürünlerin stok ve yayın durumunu veya kampanya koşullarını kontrol et.',
      ),
    for (final source in _sources)
      ListTile(
        title: Text(source.label),
        trailing: const Icon(Icons.chevron_right),
        onTap: _busy
            ? null
            : () {
                if (_sourceKind == 'listing') {
                  _listingLabel = source.label;
                } else {
                  _campaignLabel = source.label;
                }
                _select(
                  PromotionSelection(
                    family: _selection.family,
                    variant: _selection.variant,
                    listingId: _sourceKind == 'listing' ? source.id : null,
                    campaignId: _sourceKind == 'campaign'
                        ? source.id
                        : _selection.campaignId,
                  ),
                );
                setState(() => _page = 'editor');
              },
      ),
    if (_more)
      OutlinedButton(
        onPressed: _busy ? null : () => _pickSource(_sourceKind, more: true),
        child: const Text('Daha fazla sonuç'),
      ),
  ];
  List<Widget> _historyView() => [
    const Text(
      'Kayıt geçmişi',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    const Text(
      'Bu içerikler kaydedildikleri zamana aittir; güncel fiyat veya yayın kanıtı değildir.',
    ),
    if (!_busy && _history.isEmpty && _error == null)
      const Text('Gösterilecek kayıt yok.'),
    for (final entry in _history)
      PromotionCopyCard(
        copy: entry.copy,
        label:
            '${entry.action == 'save' ? 'Kaydedildi' : 'Arşivlendi'} · ${promotionDate(entry.recordedAt)}',
      ),
    if (_more)
      OutlinedButton(
        onPressed: _busy ? null : () => _readHistory(_draft!, more: true),
        child: const Text('Daha fazla kayıt'),
      ),
  ];
}

String promotionDate(DateTime value) {
  final d = value.toLocal();
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class PromotionCopyCard extends StatelessWidget {
  const PromotionCopyCard({super.key, required this.copy, required this.label});
  final PromotionCopy copy;
  final String label;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label),
          const SizedBox(height: 8),
          Text(copy.title, style: Theme.of(context).textTheme.titleLarge),
          Text(copy.body),
          if (copy.products.isNotEmpty)
            Text('Kapsamdaki ürünler: ${copy.products.join(', ')}'),
          if (copy.startsAt != null)
            Text('Başlangıç: ${promotionDate(copy.startsAt!)}'),
          if (copy.endsAt != null)
            Text('Bitiş: ${promotionDate(copy.endsAt!)}'),
        ],
      ),
    ),
  );
}
