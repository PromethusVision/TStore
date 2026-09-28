import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
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
  });
  final MerchantRepository repository;
  final MerchantAccess access;
  final VoidCallback? onChanged;
  @override
  State<MerchantProducts> createState() => _MerchantProductsState();
}

class _MerchantProductsState extends State<MerchantProducts> {
  late final MerchantCatalogCubit _cubit;
  final _search = TextEditingController();
  @override
  void initState() {
    super.initState();
    _cubit = MerchantCatalogCubit(widget.repository, widget.access)..load();
  }

  @override
  void dispose() {
    _search.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _edit({ShopProductEntity? listing}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => listing == null
            ? MerchantCatalogPicker(
                repository: widget.repository,
                access: widget.access,
              )
            : MerchantListingForm(
                repository: widget.repository,
                access: widget.access,
                product: listing.product,
                existing: listing,
              ),
      ),
    );
    if (saved == true && mounted) {
      _cubit.load(refresh: true);
      widget.onChanged?.call();
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
          ],
        ),
      );
}

class MerchantCatalogPicker extends StatefulWidget {
  const MerchantCatalogPicker({
    super.key,
    required this.repository,
    required this.access,
  });
  final MerchantRepository repository;
  final MerchantAccess access;
  @override
  State<MerchantCatalogPicker> createState() => _MerchantCatalogPickerState();
}

class _MerchantCatalogPickerState extends State<MerchantCatalogPicker> {
  final _search = TextEditingController();
  List<ProductEntity> _items = [];
  String? _error;
  String _query = '';
  bool _loading = false, _more = true;
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
      final result = await widget.repository.searchCatalog(
        widget.access,
        query: _query,
        page: _page,
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
          _more = items.length == merchantPageSize;
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
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MerchantListingForm(
          repository: widget.repository,
          access: widget.access,
          product: product,
        ),
      ),
    );
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
          labelText: 'Ürün adıyla ara',
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
        const MerchantNotice(
          'Ürün bulunamadı. Katalogda olmayan bir ürün için pilot ekibiyle iletişime geçin.',
        ),
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
  });
  final MerchantRepository repository;
  final MerchantAccess access;
  final ProductEntity? product;
  final ShopProductEntity? existing;
  @override
  State<MerchantListingForm> createState() => _MerchantListingFormState();
}

class _MerchantListingFormState extends State<MerchantListingForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _price, _description;
  late bool _available, _active;
  bool _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    final old = widget.existing;
    _price = TextEditingController(
      text: old?.price.toStringAsFixed(2).replaceAll('.', ','),
    );
    _description = TextEditingController(text: old?.description);
    _available = old?.isAvailable ?? true;
    _active = old?.isActive ?? true;
  }

  @override
  void dispose() {
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
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
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await widget.repository.saveListing(
        widget.access,
        draft,
        existing: widget.existing,
      );
      if (!mounted) return;
      setState(() => _saving = false);
      result.fold((e) => setState(() => _error = e), (_) {
        merchantSaved(context, 'Ürün bilgileri kaydedildi.');
        Navigator.pop(context, true);
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Ürün kaydedilemedi. Tekrar deneyin.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
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
        Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _price,
                enabled: !_saving,
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
                enabled: !_saving,
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
          onChanged: _saving ? null : (v) => setState(() => _available = v),
        ),
        if (widget.existing != null)
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ürün aktif'),
            subtitle: const Text(
              'Pasife alınan ürün müşterilerden gizlenir; kaydı korunur.',
            ),
            value: _active,
            onChanged: _saving ? null : (v) => setState(() => _active = v),
          ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Kaydediliyor…' : 'Ürünü kaydet'),
        ),
      ],
    ),
  );
}
