import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/merchant/presentation/merchant_read.dart';
import 'package:flutter/foundation.dart';
import 'package:t_store/features/merchant/presentation/merchant_edit_recovery.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart';
import 'package:t_store/features/merchant/presentation/merchant_product_submission.dart';
import 'package:t_store/features/merchant/presentation/merchant_listing_media.dart';
import 'package:t_store/features/merchant/presentation/merchant_catalog_cubit.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';

class MerchantProducts extends StatefulWidget {
  const MerchantProducts({
    super.key,
    required this.repository,
    required this.access,
    this.onChanged,
    this.catalogMedia,
    this.revision = 0,
  });
  final MerchantRepository repository;
  final MerchantAccess access;
  final VoidCallback? onChanged;
  final CatalogMediaRepository? catalogMedia;
  final int revision;
  @override
  State<MerchantProducts> createState() => _MerchantProductsState();
}

class _MerchantProductsState extends State<MerchantProducts> {
  late final MerchantCatalogCubit _cubit;
  final _search = TextEditingController();
  bool _opening = false;
  @override
  void initState() {
    super.initState();
    _cubit = MerchantCatalogCubit(widget.repository, widget.access)..load();
  }

  @override
  void didUpdateWidget(covariant MerchantProducts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revision != widget.revision) _cubit.load(refresh: true);
  }

  @override
  void dispose() {
    _search.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _edit({ShopProductEntity? listing}) async {
    await _openPage(
      listing == null
          ? MerchantCatalogPicker(
              repository: widget.repository,
              catalogMedia: widget.catalogMedia,
              access: widget.access,
            )
          : MerchantListingForm(
              repository: widget.repository,
              catalogMedia: widget.catalogMedia,
              access: widget.access,
              product: listing.product,
              existing: listing,
            ),
    );
  }

  Future<void> _openPage(Widget page) async {
    if (_opening) return;
    _opening = true;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    try {
      await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (_) => page));
    } finally {
      _opening = false;
      // A dismissed editor may have committed despite losing its response.
      // Re-read on return; never infer cancellation or repeat the write.
      if (mounted) {
        _cubit.load(refresh: true);
        widget.onChanged?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MerchantCatalogCubit, MerchantCatalogState>(
        bloc: _cubit,
        builder: (context, state) => MerchantPage(
          title: 'Ürünlerim',
          onRefresh: () => _cubit.load(refresh: true),
          actions: [
            IconButton(
              tooltip: 'Ürün ekle',
              onPressed: () => _edit(),
              icon: const Icon(Icons.add),
            ),
          ],
          children: [
            TextField(
              controller: _search,
              maxLength: 100,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Ürünlerinde ara',
                suffixIcon: IconButton(
                  tooltip: 'Ara',
                  icon: const Icon(Icons.search),
                  onPressed: () =>
                      _cubit.load(refresh: true, query: _search.text),
                ),
              ),
              onSubmitted: (q) => _cubit.load(refresh: true, query: q),
            ),
            if (state.error != null)
              MerchantNotice(
                state.error!,
                error: true,
                onRetry: () => _cubit.load(refresh: state.items.isEmpty),
              ),
            if (!state.loading && state.error == null && state.items.isEmpty)
              MerchantNotice(
                state.query.isEmpty
                    ? 'Henüz ürün eklemedin. Katalogdan ilk ürününü seç.'
                    : 'Aramana uygun ürün bulunamadı.',
              ),
            for (final item in state.items)
              Card(
                child: ListTile(
                  leading: Icon(
                    !item.isActive
                        ? Icons.inventory_2_outlined
                        : item.isAvailable
                        ? Icons.check_circle_outline
                        : Icons.remove_circle_outline,
                  ),
                  title: Text(item.product?.name ?? 'Katalog ürünü'),
                  subtitle: Text(
                    '${merchantPrice(item.price)}\n${!item.isActive
                        ? 'Pasif'
                        : item.isAvailable
                        ? 'Stokta var'
                        : 'Stokta yok'}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _edit(listing: item),
                ),
              ),
            if (state.loading) const Center(child: CircularProgressIndicator()),
            if (!state.loading && state.hasMore && state.items.isNotEmpty)
              OutlinedButton(
                onPressed: () => _cubit.load(),
                child: const Text('Daha fazla ürün'),
              ),
            FilledButton.icon(
              onPressed: () => _edit(),
              icon: const Icon(Icons.add),
              label: const Text('Katalogdan ürün ekle'),
            ),
            if (widget.catalogMedia != null)
              OutlinedButton(
                onPressed: () => _openPage(
                  MerchantSubmissions(
                    catalog: widget.catalogMedia!,
                    repository: widget.repository,
                    access: widget.access,
                  ),
                ),
                child: const Text('Ürün başvurularım'),
              ),
          ],
        ),
      );
}

class MerchantCatalogPicker extends StatefulWidget {
  const MerchantCatalogPicker({
    super.key,
    required this.repository,
    required this.access,
    this.catalogMedia,
  });
  final MerchantRepository repository;
  final MerchantAccess access;
  final CatalogMediaRepository? catalogMedia;
  @override
  State<MerchantCatalogPicker> createState() => _MerchantCatalogPickerState();
}

class _MerchantCatalogPickerState extends State<MerchantCatalogPicker> {
  final _search = TextEditingController();
  List<ProductEntity> _items = [];
  String? _error;
  String _query = '';
  bool _loading = false, _more = true;
  bool _opening = false;
  int _page = 0, _epoch = 0;
  @override
  void initState() {
    super.initState();
    _load(refresh: true);
  }

  @override
  void dispose() {
    ++_epoch;
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({bool refresh = false}) async {
    if (_loading && !refresh) return;
    if (refresh) {
      ++_epoch;
      _page = 0;
      _query = _search.text;
      _items = [];
    }
    final epoch = _epoch;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final gtinSearch = RegExp(r'^[0-9]{8,14}$').hasMatch(_query.trim());
      final result = gtinSearch && widget.catalogMedia != null
          ? (await merchantRead(
              () =>
                  widget.catalogMedia!.lookup(widget.access, '', _query.trim()),
            )).map((v) => v.products)
          : await merchantRead(
              () => widget.repository.searchCatalog(
                widget.access,
                query: _query,
                page: _page,
              ),
            );
      if (!mounted || epoch != _epoch) return;
      setState(() {
        _loading = false;
        result.fold((e) => _error = e, (items) {
          _items = {
            ...{for (final p in _items) p.id: p},
            for (final p in items) p.id: p,
          }.values.toList();
          ++_page;
          _more = !gtinSearch && items.length == merchantPageSize;
        });
      });
    } catch (_) {
      if (mounted && epoch == _epoch) {
        setState(() {
          _loading = false;
          _error = 'Katalog yüklenemedi. Tekrar deneyin.';
        });
      }
    }
  }

  Future<void> _select(ProductEntity product) async {
    if (_opening) return;
    _opening = true;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MerchantListingForm(
          repository: widget.repository,
          access: widget.access,
          product: product,
          catalogMedia: widget.catalogMedia,
        ),
      ),
    );
    _opening = false;
    if (mounted && saved == true) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => MerchantPage(
    title: 'Katalogdan ürün seç',
    onRefresh: () => _load(refresh: true),
    children: [
      const Text(
        'Ortak katalogdan ürünü seç; mağazana ait fiyat ve bulunabilirliği ekle.',
      ),
      TextField(
        controller: _search,
        maxLength: 100,
        decoration: InputDecoration(
          labelText: widget.catalogMedia == null
              ? 'Ürün adıyla ara'
              : 'Ürün adı veya barkodla ara',
          suffixIcon: IconButton(
            tooltip: 'Ara',
            onPressed: () => _load(refresh: true),
            icon: const Icon(Icons.search),
          ),
        ),
        onSubmitted: (_) => _load(refresh: true),
      ),
      if (_error != null) MerchantNotice(_error!, error: true, onRetry: _load),
      for (final item in _items)
        Card(
          child: ListTile(
            title: Text(item.name),
            subtitle: item.brandName == null ? null : Text(item.brandName!),
            trailing: const Icon(Icons.add_circle_outline),
            onTap: () => _select(item),
          ),
        ),
      if (_loading) const Center(child: CircularProgressIndicator()),
      if (!_loading && _error == null && _items.isEmpty)
        const MerchantNotice('Aramana uygun ürün bulunamadı.'),
      if (widget.catalogMedia != null) ...[
        const Text('Ürünü bulamadın mı?'),
        OutlinedButton(
          onPressed: _loading
              ? null
              : () async {
                  final saved = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => MerchantProductSubmission(
                        catalog: widget.catalogMedia!,
                        repository: widget.repository,
                        access: widget.access,
                        initialName:
                            RegExp(
                              r'^[0-9]{8,14}$',
                            ).hasMatch(_search.text.trim())
                            ? ''
                            : _search.text,
                        initialGtin:
                            RegExp(
                              r'^[0-9]{8,14}$',
                            ).hasMatch(_search.text.trim())
                            ? _search.text.trim()
                            : '',
                      ),
                    ),
                  );
                  if (context.mounted && saved == true) {
                    Navigator.pop(context, true);
                  }
                },
          child: const Text('Yeni ürün ekle'),
        ),
      ],
      if (!_loading && _more && _items.isNotEmpty)
        OutlinedButton(onPressed: _load, child: const Text('Daha fazla sonuç')),
    ],
  );
}

class MerchantListingForm extends StatefulWidget {
  const MerchantListingForm({
    super.key,
    required this.repository,
    required this.access,
    this.product,
    this.existing,
    this.catalogMedia,
  });
  final MerchantRepository repository;
  final MerchantAccess access;
  final ProductEntity? product;
  final ShopProductEntity? existing;
  final CatalogMediaRepository? catalogMedia;
  @override
  State<MerchantListingForm> createState() => _MerchantListingFormState();
}

class _MerchantListingFormState extends State<MerchantListingForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _price, _description;
  late bool _available, _active;
  late final MerchantEditRecovery<ShopProductEntity> _recovery;
  ShopProductEntity? _existing;
  late Map<String, dynamic> _baseline;
  MerchantListingDraft? _submitted;
  bool get _saving => _recovery.busy;
  bool get _locked => _saving || _recovery.needsReview;
  String? _error;
  @override
  void initState() {
    super.initState();
    final old = widget.existing;
    _existing = old;
    _price = TextEditingController(
      text: old?.price.toStringAsFixed(2).replaceAll('.', ','),
    );
    _description = TextEditingController(text: old?.description);
    _available = old?.isAvailable ?? true;
    _active = old?.isActive ?? true;
    _baseline = _values;
    _recovery = MerchantEditRecovery(
      read: widget.repository is MerchantRecoveryRepository
          ? () => (widget.repository as MerchantRecoveryRepository).readListing(
              widget.access,
              widget.existing?.productId ?? widget.product!.id,
            )
          : null,
    )..addListener(_changed);
    _price.addListener(_changed);
    _description.addListener(_changed);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Map<String, dynamic> get _values => {
    'price': MerchantListingDraft.parsePrice(_price.text),
    'description': _description.text.trim(),
    'available': _available,
    'active': _active,
  };

  bool _matches(ShopProductEntity current) =>
      _submitted != null &&
      MerchantListingDraft.parsePrice(current.price.toStringAsFixed(2)) ==
          _submitted!.priceMinor &&
      (current.description ?? '').trim() == _submitted!.description.trim() &&
      current.isAvailable == _submitted!.available &&
      current.isActive == _submitted!.active;

  void _review(ShopProductEntity? current, {required bool keepDraft}) {
    if (current == null && _existing != null) return;
    _existing = current;
    _baseline = {
      'price': current == null
          ? null
          : MerchantListingDraft.parsePrice(current.price.toStringAsFixed(2)),
      'description': (current?.description ?? '').trim(),
      'available': current?.isAvailable ?? true,
      'active': current?.isActive ?? true,
    };
    if (!keepDraft) {
      _price.text =
          current?.price.toStringAsFixed(2).replaceAll('.', ',') ?? '';
      _description.text = current?.description ?? '';
      _available = current?.isAvailable ?? true;
      _active = current?.isActive ?? true;
    }
    _error = null;
    _recovery.reviewed();
  }

  @override
  void dispose() {
    _recovery.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_locked || !_form.currentState!.validate()) return;
    final draft = MerchantListingDraft(
      productId: widget.existing?.productId ?? widget.product?.id ?? '',
      priceMinor: MerchantListingDraft.parsePrice(_price.text)!,
      description: _description.text,
      available: _available,
      active: _active,
    );
    if (draft.error != null) {
      setState(() => _error = draft.error);
      return;
    }
    _error = null;
    _submitted = draft;
    FocusScope.of(context).unfocus();
    final saved = await _recovery.save(
      () => widget.repository.saveListing(
        widget.access,
        draft,
        existing: _existing,
      ),
    );
    if (!mounted) return;
    if (saved != null) {
      merchantSaved(context, 'Ürün bilgileri kaydedildi.');
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) => MerchantDraftGuard(
    dirty: _recovery.needsReview || !mapEquals(_baseline, _values),
    uncertain: _recovery.needsReview,
    busy: _saving,
    child: MerchantPage(
      title: widget.existing == null ? 'Ürün ekle' : 'Ürünü düzenle',
      children: [
        Text(
          widget.product?.name ??
              widget.existing?.product?.name ??
              'Katalog ürünü',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (widget.product?.brandName != null) Text(widget.product!.brandName!),
        if (_error != null) MerchantNotice(_error!, error: true),
        if (_recovery.error != null)
          MerchantNotice(_recovery.error!, error: true),
        if (_recovery.needsReview)
          MerchantRecoveryPanel(
            busy: _saving,
            loaded: _recovery.loaded,
            matches: _recovery.current != null && _matches(_recovery.current!),
            summary: _recovery.current == null
                ? (_existing == null
                      ? 'Mağazanda bu ürün için kayıt bulunamadı.'
                      : 'Bu ürün kaydına artık ulaşılamıyor. Ürünler listesine dön.')
                : '${merchantPrice(_recovery.current!.price)} • '
                      '${_recovery.current!.isActive ? 'Aktif' : 'Pasif'} • '
                      '${_recovery.current!.isAvailable ? 'Stokta var' : 'Stokta yok'}\n'
                      '${_recovery.current!.description ?? 'Açıklama yok'}',
            onReload: _recovery.reload,
            onUseCurrent: _recovery.current == null
                ? null
                : () {
                    if (_matches(_recovery.current!)) {
                      Navigator.pop(context, true);
                    } else {
                      _review(_recovery.current, keepDraft: false);
                    }
                  },
            onKeepDraft: _recovery.current == null && _existing != null
                ? null
                : () => _review(_recovery.current, keepDraft: true),
          ),
        Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _price,
                enabled: !_locked,
                decoration: const InputDecoration(
                  labelText: 'Mağaza fiyatı (TL)',
                  hintText: '0,00',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) =>
                    MerchantListingDraft.parsePrice(v ?? '') == null
                    ? 'En fazla iki ondalık basamaklı, negatif olmayan fiyat girin.'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _description,
                enabled: !_locked,
                maxLength: 2000,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Mağazana özel açıklama',
                ),
              ),
            ],
          ),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Stokta var'),
          subtitle: const Text('Müşterilere güncel bulunabilirliği göster.'),
          value: _available,
          onChanged: _locked ? null : (v) => setState(() => _available = v),
        ),
        if (_existing != null)
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ürün aktif'),
            subtitle: const Text(
              'Pasife alınan ürün müşterilerden gizlenir; kaydı korunur.',
            ),
            value: _active,
            onChanged: _locked ? null : (v) => setState(() => _active = v),
          ),
        FilledButton(
          onPressed: _locked ? null : _save,
          child: Text(_saving ? 'Kaydediliyor…' : 'Ürünü kaydet'),
        ),
        if (_existing != null && widget.catalogMedia != null)
          OutlinedButton.icon(
            onPressed: _locked
                ? null
                : () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => MerchantListingMedia(
                        repository: widget.catalogMedia!,
                        access: widget.access,
                        listingId: _existing!.id,
                      ),
                    ),
                  ),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Mağaza fotoğraflarını yönet'),
          ),
        if (widget.existing == null && widget.catalogMedia != null)
          const Text(
            'Ürünü kaydettikten sonra Ürünlerim ekranından fotoğraflarını ekleyebilirsin.',
          ),
      ],
    ),
  );
}
