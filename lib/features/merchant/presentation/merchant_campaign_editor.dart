part of 'merchant_campaigns.dart';

class MerchantCampaignEditor extends StatefulWidget {
  const MerchantCampaignEditor({
    super.key,
    required this.services,
    required this.access,
    this.existing,
    this.pricePublicationEnabled = false,
  });
  final MerchantServices services;
  final MerchantAccess access;
  final Campaign? existing;
  final bool pricePublicationEnabled;
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
  bool _busy = false, _selecting = false;
  TrustFailure? _failure;
  String? _validation;
  CampaignCommand? _pending;
  @override
  TrustCommerceRepository get trustRepository => widget.services.trustCommerce!;
  @override
  String get trustActor => widget.access.user.id;
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
  }

  @override
  void initState() {
    super.initState();
    final old = widget.existing?.draft;
    _title.text = old?.title ?? '';
    _description.text = old?.description ?? '';
    _type = old?.type ?? CampaignType.announcement;
    _scope = old?.scope ?? CampaignScope.single;
    _starts = old?.startsAt.toLocal() ?? DateTime.now();
    _ends =
        old?.endsAt.toLocal() ?? DateTime.now().add(const Duration(days: 7));
    _listings.addAll(old?.listingIds ?? []);
    for (final product in widget.existing?.products ?? <CampaignProduct>[]) {
      _productNames[product.listingId] = product.name;
    }
    _imageIds.addAll(old?.imageIds ?? []);
    for (final image in widget.existing?.images ?? <CampaignImage>[]) {
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
  }

  Future<void> _pickProducts({bool photo = false}) async {
    if (_locked || !sessionCurrent) return;
    setState(() => _selecting = true);
    final selected = await Navigator.push<List<ShopProductEntity>>(
      context,
      MaterialPageRoute(
        builder: (_) => _CampaignProductPicker(
          services: widget.services,
          access: widget.access,
          selected: photo ? const {} : _listings,
          single: photo || _scope == CampaignScope.single,
          allowedIds: photo && _scope != CampaignScope.all ? _listings : null,
        ),
      ),
    );
    if (!mounted || !sessionCurrent) return;
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
      _validation = null;
    });
    final result = await media.media(widget.access, listing.id);
    if (!mounted || !sessionCurrent) return;
    List<ListingImage>? images;
    result.fold(
      (e) => _validation = e,
      (v) => images = v.images.where((i) => i.state == 'published').toList(),
    );
    setState(() => _selecting = false);
    if (images == null) return;
    if (images!.isEmpty) {
      setState(
        () => _validation =
            'Bu ürünün yayınlanmış fotoğrafı yok. Ürün yönetiminden fotoğraf ekleyebilirsin.',
      );
      return;
    }
    final choice = await showDialog<ListingImage>(
      context: context,
      builder: (context) => PrivateTrustOverlay(
        repository: trustRepository,
        actor: trustActor,
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
    if (choice == null || !mounted || !sessionCurrent) return;
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

  void _preview() {
    final draft = _draft();
    if (draft.error != null) {
      setState(() => _validation = draft.error);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => PrivateTrustOverlay(
        repository: trustRepository,
        actor: trustActor,
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
  }

  Future<void> _save() async {
    if (_busy || !sessionCurrent) return;
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
        campaignId: widget.existing?.id,
        expectedRevision: widget.existing?.revisionId,
        draft: draft,
      );
    }
    setState(() {
      _busy = true;
      _failure = null;
      _validation = null;
    });
    final result = await trustRepository.mutate(_pending!);
    if (!mounted || !sessionCurrent) return;
    bool saved = false;
    setState(() {
      _busy = false;
      result.fold(
        (e) {
          _failure = e;
          if (!e.retrySameRequest) _pending = null;
        },
        (_) {
          _pending = null;
          saved = true;
        },
      );
    });
    if (saved) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (!sessionCurrent) return const TrustSessionExpired();
    return PopScope(
      canPop: !_busy && _pending == null,
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
            if (widget.existing?.active == true)
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
            if (_busy || _selecting) const LinearProgressIndicator(),
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
            if (_failure?.kind == TrustFailureKind.changed)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Güncel kayda dön'),
              ),
            OutlinedButton(
              onPressed: _locked ? null : _preview,
              child: const Text('Müşteri görünümünü önizle'),
            ),
            FilledButton(
              onPressed:
                  _busy ||
                      _selecting ||
                      _failure?.kind == TrustFailureKind.changed
                  ? null
                  : _save,
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
    this.allowedIds,
  });
  final MerchantServices services;
  final MerchantAccess access;
  final Set<String> selected;
  final Set<String>? allowedIds;
  final bool single;
  @override
  State<_CampaignProductPicker> createState() => _CampaignProductPickerState();
}

class _CampaignProductPickerState extends State<_CampaignProductPicker>
    with TrustSessionGuard<_CampaignProductPicker> {
  final _query = TextEditingController();
  final _selected = <String, ShopProductEntity>{};
  final _rows = <ShopProductEntity>[];
  int _page = 0;
  bool _loading = false, _more = true;
  String? _error;
  @override
  TrustCommerceRepository get trustRepository => widget.services.trustCommerce!;
  @override
  String get trustActor => widget.access.user.id;
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
    if (!more) {
      _page = 0;
      _rows.clear();
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await widget.services.merchants.listings(
      widget.access,
      page: _page,
      query: _query.text.trim(),
    );
    if (!mounted || !sessionCurrent) return;
    setState(() {
      _loading = false;
      result.fold((e) => _error = e, (v) {
        _more = v.length == merchantPageSize;
        _page++;
        _rows.addAll(
          v.where(
            (r) =>
                widget.allowedIds == null || widget.allowedIds!.contains(r.id),
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
          if (_error != null) TrustRetry(message: _error!, onRetry: _load),
          Expanded(
            child: ListView(
              children: [
                if (_rows.isEmpty && !_loading)
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
                    onChanged: _loading
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
                onPressed: _loading
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
