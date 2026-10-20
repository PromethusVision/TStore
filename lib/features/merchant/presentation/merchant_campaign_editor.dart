part of 'merchant_campaigns.dart';

class MerchantCampaignEditor extends StatefulWidget {
  const MerchantCampaignEditor({
    super.key,
    required this.services,
    required this.access,
    this.existing,
    this.pricePublicationEnabled = false,
    this.originIsCurrent,
  });
  final MerchantServices services;
  final MerchantAccess access;
  final Campaign? existing;
  final bool pricePublicationEnabled;
  final bool Function()? originIsCurrent;
  @override
  State<MerchantCampaignEditor> createState() => _MerchantCampaignEditorState();
}

class _MerchantCampaignEditorState extends State<MerchantCampaignEditor>
    with TrustSessionGuard<MerchantCampaignEditor> {
  final _title = TextEditingController(),
      _description = TextEditingController(),
      _amount = TextEditingController();
  late CampaignType _type;
  late CampaignScope _scope;
  late DateTime _starts, _ends;
  final _listings = <String>{};
  final _productNames = <String, String>{};
  final _images = <String, CampaignImage>{};
  final _imageIds = <String>{};
  bool _busy = false, _selecting = false, _mediaLoading = false;
  TrustFailure? _failure;
  String? _validation;
  CampaignCommand? _pending;
  Campaign? _currentCampaign, _fresh;
  bool _needsReview = false, _recoveryLoaded = false, _saved = false;
  late Map<String, dynamic> _baseline;
  Map<String, dynamic> _formValues() => {
    ..._draft().toJson(),
    'raw_amount': _amount.text,
  };
  bool get _dirty =>
      !_saved &&
      (_needsReview || !merchantValuesEqual(_baseline, _formValues()));
  void _textChanged() {
    if (mounted) setState(() {});
  }

  @override
  TrustCommerceRepository get trustRepository => widget.services.trustCommerce!;
  @override
  String get trustActor => widget.access.user.id;
  @override
  bool Function()? get trustOriginIsCurrent => widget.originIsCurrent;
  @override
  void clearTrustSession() {
    _title.clear();
    _description.clear();
    _amount.clear();
    _listings.clear();
    _productNames.clear();
    _images.clear();
    _imageIds.clear();
    _pending = null;
    _currentCampaign = null;
    _fresh = null;
    _baseline = {};
  }

  @override
  void initState() {
    super.initState();
    _currentCampaign = widget.existing;
    _useCampaign(widget.existing);
    _baseline = _formValues();
    for (final c in [_title, _description, _amount]) {
      c.addListener(_textChanged);
    }
  }

  void _useCampaign(Campaign? value) {
    final old = value?.draft;
    _listings.clear();
    _productNames.clear();
    _imageIds.clear();
    _images.clear();
    _amount.clear();
    _title.text = old?.title ?? '';
    _description.text = old?.description ?? '';
    _type = old?.type ?? CampaignType.announcement;
    _scope = old?.scope ?? CampaignScope.single;
    _starts = old?.startsAt.toLocal() ?? DateTime.now();
    _ends =
        old?.endsAt.toLocal() ?? DateTime.now().add(const Duration(days: 7));
    _listings.addAll(old?.listingIds ?? []);
    for (final product in value?.products ?? <CampaignProduct>[]) {
      _productNames[product.listingId] = product.name;
    }
    _imageIds.addAll(old?.imageIds ?? []);
    for (final image in value?.images ?? <CampaignImage>[]) {
      _images[image.id] = image;
    }
    final amount = old?.priceMinor ?? old?.percentageBasisPoints;
    if (amount != null) {
      _amount.text = (amount / 100).toStringAsFixed(2).replaceAll('.', ',');
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _amount.dispose();
    super.dispose();
  }

  CampaignDraft _draft() => CampaignDraft(
    title: _title.text,
    description: _description.text,
    type: _type,
    scope: _scope,
    startsAt: _starts,
    endsAt: _ends,
    listingIds: List.unmodifiable(_listings),
    imageIds: List.unmodifiable(_imageIds),
    priceMinor: _type == CampaignType.price
        ? MerchantListingDraft.parsePrice(_amount.text)
        : null,
    percentageBasisPoints: _type == CampaignType.percentage
        ? MerchantListingDraft.parsePrice(_amount.text)
        : null,
  );
  bool get _locked => _busy || _pending != null || _selecting;
  Future<void> _date(bool start) async {
    if (_locked || !sessionCurrent) return;
    setState(() => _selecting = true);
    try {
      final old = start ? _starts : _ends;
      final day = await showDatePicker(
        context: context,
        initialDate: old,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (day == null || !mounted || !sessionCurrent) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(old),
      );
      if (time == null || !mounted || !sessionCurrent) return;
      setState(() {
        final value = DateTime(
          day.year,
          day.month,
          day.day,
          time.hour,
          time.minute,
        );
        if (start) {
          _starts = value;
        } else {
          _ends = value;
        }
      });
    } finally {
      if (mounted) setState(() => _selecting = false);
    }
  }

  Future<void> _pickProducts({bool photo = false}) async {
    if (_locked || !sessionCurrent) return;
    setState(() => _selecting = true);
    final picker = _CampaignProductPicker(
      services: widget.services,
      access: widget.access,
      selected: photo ? const {} : Set.of(_listings),
      single: photo || _scope == CampaignScope.single,
      allowedIds: photo && _scope != CampaignScope.all
          ? Set.of(_listings)
          : null,
      originIsCurrent: trustContinuationIsCurrent,
    );
    final selected = await Navigator.push<List<ShopProductEntity>>(
      context,
      MaterialPageRoute(builder: (_) => picker),
    );
    if (!checkTrustContinuation()) return;
    setState(() => _selecting = false);
    if (selected == null) return;
    if (photo) {
      if (selected.isNotEmpty) await _pickImage(selected.single);
    } else {
      setState(() {
        _listings
          ..clear()
          ..addAll(selected.map((p) => p.id));
        for (final product in selected) {
          if (product.product?.name case final name?) {
            _productNames[product.id] = name;
          }
        }
        _imageIds.removeWhere(
          (id) => !_listings.contains(_images[id]?.listingId),
        );
      });
    }
  }

  Future<void> _pickImage(ShopProductEntity listing) async {
    final media = widget.services.catalogMedia;
    if (media == null || !sessionCurrent) return;
    setState(() {
      _selecting = true;
      _mediaLoading = true;
      _validation = null;
    });
    final result = await merchantRead(
      () => media.media(widget.access, listing.id),
    );
    if (!checkTrustContinuation()) return;
    List<ListingImage>? images;
    setState(() => _mediaLoading = false);
    result.fold(
      (e) => _validation = e,
      (v) => images = v.images.where((i) => i.state == 'published').toList(),
    );
    if (images == null) {
      setState(() => _selecting = false);
      return;
    }
    if (images!.isEmpty) {
      _selecting = false;
      setState(
        () => _validation =
            'Bu ürünün yayınlanmış fotoğrafı yok. Ürün yönetiminden fotoğraf ekleyebilirsin.',
      );
      return;
    }
    if (!mounted) return;
    final choice = await showDialog<ListingImage>(
      context: context,
      builder: (context) => PrivateTrustOverlay(
        repository: trustRepository,
        actor: trustActor,
        originIsCurrent: trustContinuationIsCurrent,
        child: SimpleDialog(
          title: const Text('Mevcut fotoğrafı seç'),
          children: [
            for (final image in images!)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, image),
                child: Row(
                  children: [
                    if (image.url != null)
                      Image.network(
                        image.url!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, error, stack) =>
                            const Icon(Icons.image_outlined),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${listing.product?.name ?? 'Ürün'} · Fotoğraf ${image.order + 1}',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
    if (!checkTrustContinuation()) return;
    setState(() => _selecting = false);
    if (choice == null) return;
    setState(() {
      _imageIds.add(choice.id);
      _images[choice.id] = CampaignImage(
        choice.id,
        listing.id,
        choice.path,
        url: choice.url,
      );
    });
  }

  Future<void> _preview() async {
    if (_locked || !sessionCurrent) return;
    final draft = _draft();
    if (draft.error != null) {
      setState(() => _validation = draft.error);
      return;
    }
    setState(() => _selecting = true);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => PrivateTrustOverlay(
        repository: trustRepository,
        actor: trustActor,
        originIsCurrent: trustContinuationIsCurrent,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: CampaignCard(
              preview: true,
              campaign: Campaign(
                id: '',
                shopId: widget.access.shop!.id,
                revisionId: '',
                draft: draft,
                status: 'draft',
                products: [
                  for (final id in _listings)
                    CampaignProduct(
                      id,
                      _productNames[id] ?? 'Ürün bilgisi yüklenemedi',
                    ),
                ],
                images: _imageIds
                    .map((id) => _images[id])
                    .whereType<CampaignImage>()
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
    if (mounted) setState(() => _selecting = false);
  }

  Future<void> _save() async {
    if (_busy || _selecting || _needsReview || !sessionCurrent) return;
    if (_pending == null) {
      final draft = _draft();
      if (draft.error != null) {
        setState(() => _validation = draft.error);
        return;
      }
      _pending = CampaignCommand(
        shopId: widget.access.shop!.id,
        requestId: newCampaignRequestId(),
        action: 'save',
        campaignId: _currentCampaign?.id,
        expectedRevision: _currentCampaign?.revisionId,
        draft: draft,
      );
    }
    setState(() {
      _busy = true;
      _failure = null;
      _validation = null;
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
    bool saved = false;
    setState(() {
      _busy = false;
      result.fold(
        (e) {
          _failure = e;
          if (!e.retrySameRequest) _pending = null;
          if (e.kind == TrustFailureKind.changed) _needsReview = true;
        },
        (_) {
          _pending = null;
          saved = true;
          _saved = true;
        },
      );
    });
    if (saved) {
      await WidgetsBinding.instance.endOfFrame;
      if (mounted && sessionCurrent) Navigator.pop(context, true);
    }
  }

  Future<void> _recover() async {
    if (_locked || !sessionCurrent || _currentCampaign == null) return;
    setState(() {
      _busy = true;
      _fresh = null;
      _recoveryLoaded = false;
      _failure = null;
    });
    final repo = trustRepository;
    if (repo is! CampaignRecoveryRepository) {
      setState(() {
        _busy = false;
        _failure = _readFailure;
      });
      return;
    }
    final result = await managementRequest(
      () => (repo as CampaignRecoveryRepository).readCampaign(
        widget.access.shop!.id,
        _currentCampaign!.id,
      ),
      failure: _readFailure,
    );
    if (!checkTrustContinuation()) return;
    if (result.fold((e) => e.kind == TrustFailureKind.auth, (_) => false)) {
      expireTrustSession();
      return;
    }
    setState(() {
      _busy = false;
      result.fold((e) => _failure = e, (v) {
        if (v != null &&
            (v.id != _currentCampaign!.id ||
                v.shopId != widget.access.shop!.id)) {
          _failure = _readFailure;
          return;
        }
        _fresh = v;
        _recoveryLoaded = true;
      });
    });
  }

  void _review(bool useCurrent) {
    if (_locked || !sessionCurrent || !_recoveryLoaded || _fresh == null) {
      return;
    }
    setState(() {
      _currentCampaign = _fresh;
      if (useCurrent) {
        _useCampaign(_fresh);
        _baseline = _formValues();
      } else {
        final draft = _fresh!.draft;
        final amount = draft.priceMinor ?? draft.percentageBasisPoints;
        _baseline = {
          ...draft.toJson(),
          'raw_amount': amount == null
              ? ''
              : (amount / 100).toStringAsFixed(2).replaceAll('.', ','),
        };
      }
      _needsReview = false;
      _failure = null;
      _validation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!sessionCurrent) return const TrustSessionExpired();
    return MerchantDraftGuard(
      dirty: _dirty,
      busy: _busy || _selecting || _pending != null,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.existing == null ? 'Kampanya oluştur' : 'Kampanyayı düzenle',
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Önce taslağını kaydet, ardından kampanya listesinden yayınla.',
            ),
            if (_currentCampaign?.active == true)
              const Text(
                'Düzenlemeyi kaydettiğinde mevcut yayın durur. Yeniden yayınlamadan değişiklikler müşteriye gösterilmez.',
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              enabled: !_locked,
              maxLength: 100,
              decoration: const InputDecoration(labelText: 'Kampanya başlığı'),
            ),
            TextField(
              controller: _description,
              enabled: !_locked,
              maxLength: 500,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Kısa açıklama'),
            ),
            DropdownButtonFormField<CampaignType>(
              key: ValueKey("type-$_type"),
              initialValue: _type,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Kampanya türü'),
              items: const [
                DropdownMenuItem(
                  value: CampaignType.announcement,
                  child: Text('Duyuru'),
                ),
                DropdownMenuItem(
                  value: CampaignType.price,
                  child: Text('İndirimli fiyat'),
                ),
                DropdownMenuItem(
                  value: CampaignType.percentage,
                  child: Text('Yüzde indirim'),
                ),
              ],
              onChanged: _locked
                  ? null
                  : (v) => setState(() {
                      _type = v!;
                      _amount.clear();
                    }),
            ),
            if (_type != CampaignType.announcement) ...[
              TextField(
                controller: _amount,
                enabled: !_locked,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: _type == CampaignType.price
                      ? 'İndirimli fiyat (TL)'
                      : 'İndirim oranı (%)',
                ),
              ),
              if (!widget.pricePublicationEnabled)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Bu türü taslak olarak hazırlayabilirsin; fiyatlı yayınlar henüz açılmadı.',
                  ),
                ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<CampaignScope>(
              key: ValueKey("scope-$_scope"),
              initialValue: _scope,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Geçerli ürünler'),
              items: const [
                DropdownMenuItem(
                  value: CampaignScope.single,
                  child: Text('Tek ürün'),
                ),
                DropdownMenuItem(
                  value: CampaignScope.multiple,
                  child: Text('Birden fazla ürün'),
                ),
                DropdownMenuItem(
                  value: CampaignScope.all,
                  child: Text('Satışa açık tüm ürünler'),
                ),
              ],
              onChanged: _locked
                  ? null
                  : (v) => setState(() {
                      _scope = v!;
                      _listings.clear();
                      _imageIds.clear();
                    }),
            ),
            if (_scope != CampaignScope.all)
              OutlinedButton.icon(
                onPressed: _locked ? null : _pickProducts,
                icon: const Icon(Icons.inventory_2_outlined),
                label: Text('Ürün seç (${_listings.length})'),
              ),
            if (_listings.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final id in _listings)
                    InputChip(
                      label: SizedBox(
                        width: 200,
                        child: Text(
                          _productNames[id] ?? 'Ürün bilgisi yüklenemedi',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      onDeleted: _locked
                          ? null
                          : () => setState(() {
                              _listings.remove(id);
                              _imageIds.removeWhere(
                                (image) => _images[image]?.listingId == id,
                              );
                            }),
                    ),
                ],
              ),
            OutlinedButton.icon(
              onPressed:
                  _locked ||
                      _imageIds.length >= 5 ||
                      widget.services.catalogMedia == null ||
                      (_scope != CampaignScope.all && _listings.isEmpty)
                  ? null
                  : () => _pickProducts(photo: true),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Ürün fotoğraflarından seç'),
            ),
            if (_imageIds.isNotEmpty)
              Wrap(
                spacing: 8,
                children: [
                  for (final id in _imageIds)
                    InputChip(
                      label: Text(
                        'Fotoğraf ${_imageIds.toList().indexOf(id) + 1}',
                      ),
                      onDeleted: _locked
                          ? null
                          : () => setState(() => _imageIds.remove(id)),
                    ),
                ],
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Başlangıç'),
              subtitle: Text(DateFormat('dd.MM.yyyy HH:mm').format(_starts)),
              trailing: const Icon(Icons.calendar_month),
              onTap: _locked ? null : () => _date(true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Bitiş'),
              subtitle: Text(DateFormat('dd.MM.yyyy HH:mm').format(_ends)),
              trailing: const Icon(Icons.calendar_month),
              onTap: _locked ? null : () => _date(false),
            ),
            if (_busy || _mediaLoading) const LinearProgressIndicator(),
            if (_validation != null)
              Text(
                _validation!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (_failure != null)
              Text(
                _failure!.message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (_needsReview)
              MerchantRecoveryPanel(
                message:
                    'Kayıt başka bir işlemle değişmiş. Hazırladığın taslak bu ekranda korunuyor. Güncel bilgileri kontrol edip nasıl devam edeceğini seç.',
                busy: _locked,
                loaded: _recoveryLoaded,
                matches: false,
                summary: _fresh == null
                    ? 'Kayıt artık bulunamıyor. Düzenlemelerin bu ekranda korunuyor.'
                    : 'Güncel kayıt: ${_fresh!.draft.title} · ${_fresh!.statusLabel}\n${_fresh!.draft.description}\n${_fresh!.draft.offerLabel}',
                onReload: _recover,
                onUseCurrent: _fresh == null ? null : () => _review(true),
                onKeepDraft: _fresh == null ? null : () => _review(false),
              ),
            OutlinedButton(
              onPressed: _locked ? null : _preview,
              child: const Text('Müşteri görünümünü önizle'),
            ),
            FilledButton(
              onPressed: _busy || _selecting || _needsReview ? null : _save,
              child: Text(
                _pending == null
                    ? 'Taslak olarak kaydet'
                    : 'Aynı işlemi tekrar dene',
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _CampaignProductPicker extends StatefulWidget {
  const _CampaignProductPicker({
    required this.services,
    required this.access,
    required this.selected,
    required this.single,
    required this.originIsCurrent,
    this.allowedIds,
  });
  final MerchantServices services;
  final MerchantAccess access;
  final Set<String> selected;
  final Set<String>? allowedIds;
  final bool single;
  final bool Function() originIsCurrent;
  @override
  State<_CampaignProductPicker> createState() => _CampaignProductPickerState();
}

class _CampaignProductPickerState extends State<_CampaignProductPicker>
    with TrustSessionGuard<_CampaignProductPicker> {
  final _query = TextEditingController();
  final _selected = <String, ShopProductEntity>{};
  final _rows = <ShopProductEntity>[];
  int _page = 0;
  bool _retryMore = false;
  String _activeQuery = '';
  bool _loading = false, _more = true;
  String? _error;
  @override
  TrustCommerceRepository get trustRepository => widget.services.trustCommerce!;
  @override
  String get trustActor => widget.access.user.id;
  @override
  bool Function() get trustOriginIsCurrent => widget.originIsCurrent;
  @override
  void clearTrustSession() {
    _rows.clear();
    _selected.clear();
  }

  @override
  void initState() {
    super.initState();
    for (final id in widget.selected) {
      _selected[id] = ShopProductEntity(
        id: id,
        shopId: widget.access.shop!.id,
        productId: '',
        price: 0,
      );
    }
    _load();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    if (_loading || !sessionCurrent) return;
    _retryMore = more;
    if (!more) {
      _activeQuery = _query.text.trim();
      _page = 0;
      _rows.clear();
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await merchantRead(
      () => widget.services.merchants.listings(
        widget.access,
        page: _page,
        query: _activeQuery,
      ),
    );
    if (!checkTrustContinuation()) return;
    setState(() {
      _loading = false;
      result.fold((e) => _error = e, (v) {
        if (v.any((r) => r.shopId != widget.access.shop!.id)) {
          _error = 'Ürün bilgileri doğrulanamadı. Yeniden dene.';
          return;
        }
        _more = v.length == merchantPageSize;
        _page++;
        _rows.addAll(
          v.where(
            (r) =>
                !_rows.any((old) => old.id == r.id) &&
                (widget.allowedIds == null ||
                    widget.allowedIds!.contains(r.id)),
          ),
        );
        for (final row in v.where((r) => _selected.containsKey(r.id))) {
          _selected[row.id] = row;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!sessionCurrent) return const TrustSessionExpired();
    return Scaffold(
      appBar: AppBar(title: const Text('Mağazanın ürünleri')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _query,
              enabled: !_loading,
              decoration: InputDecoration(
                labelText: 'Ürün ara',
                suffixIcon: IconButton(
                  tooltip: 'Ara',
                  onPressed: _loading ? null : _load,
                  icon: const Icon(Icons.search),
                ),
              ),
              onSubmitted: (_) => _load(),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null)
            TrustRetry(
              message: _error!,
              onRetry: () => _load(more: _retryMore),
            ),
          Expanded(
            child: ListView(
              children: [
                if (_rows.isEmpty && !_loading && _error == null)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Uygun ürün bulunamadı.'),
                  ),
                for (final row in _rows)
                  CheckboxListTile(
                    value: _selected.containsKey(row.id),
                    title: Text(row.product?.name ?? 'Ürün'),
                    subtitle: Text(
                      '${row.price.toStringAsFixed(2).replaceAll('.', ',')} TL${!row.isActive || !row.isAvailable ? ' · Satışa kapalı' : ''}',
                    ),
                    onChanged: _loading || _error != null
                        ? null
                        : (value) => setState(() {
                            if (value == true) {
                              if (widget.single) _selected.clear();
                              if (_selected.length < 100) {
                                _selected[row.id] = row;
                              }
                            } else {
                              _selected.remove(row.id);
                            }
                          }),
                  ),
                if (_more)
                  TextButton(
                    onPressed: _loading ? null : () => _load(more: true),
                    child: const Text('Diğer ürünleri yükle'),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _loading || _error != null
                    ? null
                    : () => Navigator.pop(context, _selected.values.toList()),
                child: Text('Seçimi kullan (${_selected.length})'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
