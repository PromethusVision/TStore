import 'package:t_store/features/merchant/presentation/merchant_workspace_continuation.dart';
import 'package:flutter/material.dart';
import 'package:t_store/features/merchant/presentation/merchant_read.dart';
import 'package:t_store/features/merchant/presentation/merchant_edit_recovery.dart';
import 'dart:math';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/presentation/merchant_products.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';

class MerchantProductSubmission extends StatefulWidget {
  const MerchantProductSubmission({
    super.key,
    required this.catalog,
    required this.repository,
    required this.access,
    this.initialName = '',
    this.initialGtin = '',
  });
  final CatalogMediaRepository catalog;
  final MerchantRepository repository;
  final MerchantAccess access;
  final String initialName;
  final String initialGtin;
  @override
  State<MerchantProductSubmission> createState() =>
      _MerchantProductSubmissionState();
}

class _MerchantProductSubmissionState extends State<MerchantProductSubmission>
    with MerchantWorkspaceContinuation<MerchantProductSubmission> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  final _brand = TextEditingController(),
      _model = TextEditingController(),
      _variant = TextEditingController(),
      _gtin = TextEditingController();
  // UUID v4 without adding a runtime dependency for one idempotency key.
  final _requestId = _newRequestId();
  List<CatalogCategory> _categories = [];
  CatalogLookup? _suggestions;
  String? _category, _error;
  bool _unique = false, _busy = false, _categoriesLoading = true;
  bool _categoriesFailed = false;
  ProductSubmissionDraft? _sentDraft;
  ProductEntity? _resolvedProduct;
  bool _opening = false;
  int _readEpoch = 0;
  static String _newRequestId() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
    _gtin.text = widget.initialGtin;
    for (final c in [_name, _brand, _model, _variant, _gtin]) {
      c.addListener(() {
        if (workspaceCurrent) {
          setState(() => _suggestions = null);
        }
      });
    }
    _load();
  }

  @override
  void dispose() {
    for (final c in [_name, _brand, _model, _variant, _gtin]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted || !workspaceCurrent) return;
    final epoch = ++_readEpoch;
    setState(() => _categoriesLoading = true);
    final result = await merchantRead(
      () => widget.catalog.categories(widget.access),
    );
    if (!workspaceCurrent || epoch != _readEpoch) return;
    setState(() {
      _categoriesLoading = false;
      result.fold(
        (e) {
          _categoriesFailed = true;
          _error = e;
        },
        (v) {
          _categoriesFailed = false;
          _categories = v;
          _error = null;
        },
      );
    });
  }

  ProductSubmissionDraft get _draft => ProductSubmissionDraft(
    name: _name.text,
    categoryId: _category ?? '',
    brand: _brand.text,
    model: _model.text,
    variant: _variant.text,
    gtin: _gtin.text,
    uniqueToShop: _unique,
  );
  Future<void> _existing(ProductEntity product) async {
    if (!workspaceCurrent || _opening) return;
    _opening = true;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MerchantListingForm(
          repository: widget.repository,
          access: widget.access,
          product: product,
          catalogMedia: widget.catalog,
        ),
      ),
    );
    _opening = false;
    if (mounted && workspaceCurrent && saved == true) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _send({bool continueNew = false}) async {
    if (!workspaceCurrent || _busy || !_form.currentState!.validate()) return;
    final draft = _sentDraft ?? _draft;
    if (draft.error != null) {
      setState(() => _error = draft.error);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    FocusScope.of(context).unfocus();
    try {
      if (!continueNew && _sentDraft == null) {
        final lookup = await merchantRead(
          () => widget.catalog.lookup(widget.access, draft.name, draft.gtin),
        );
        if (!mounted || !workspaceCurrent) return;
        final value = lookup.fold((e) {
          _error = e;
          return null;
        }, (v) => v);
        if (value == null) return;
        if (value.products.isNotEmpty) {
          setState(() => _suggestions = value);
          return;
        }
      }
      _sentDraft = draft; // A retry uses the exact same idempotency payload.
      final result = await widget.catalog.submit(
        widget.access,
        _requestId,
        draft,
      );
      if (!mounted || !workspaceCurrent) return;
      final saved = result.fold((e) {
        _error = e;
        return null;
      }, (v) => v);
      if (saved?.existing != null) {
        setState(() => _resolvedProduct = saved!.existing);
        await _existing(saved!.existing!);
      } else if (saved?.submission != null) {
        merchantSaved(context, 'Ürün başvurun alındı. İnceleniyor.');
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (workspaceCurrent) {
        setState(() => _error = 'Başvuru gönderilemedi. Yeniden dene.');
      }
    } finally {
      if (workspaceCurrent) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => MerchantDraftGuard(
    uncertain: _sentDraft != null && _resolvedProduct == null,
    busy: _busy,
    dirty:
        _sentDraft != null ||
        _category != null ||
        _unique ||
        _name.text != widget.initialName ||
        _gtin.text != widget.initialGtin ||
        [_brand, _model, _variant].any((c) => c.text.isNotEmpty),
    child: MerchantPage(
      title: 'Yeni ürün ekle',
      children: [
        const Text(
          'Ürün bilgilerini incelemeye gönder. Onaylandığında mağaza fiyatını ve fotoğraflarını ekleyebilirsin.',
        ),
        if (_error != null)
          MerchantNotice(
            _error!,
            error: true,
            onRetry: _categoriesFailed && !_categoriesLoading ? _load : null,
          ),
        if (_sentDraft != null && _resolvedProduct == null && !_busy)
          const MerchantNotice(
            'Başvuru sonucu doğrulanamadı. Yeniden gönderim aynı başvuruyu kontrol eder; yeni başvuru oluşturmaz.',
          ),
        if (_resolvedProduct != null) ...[
          const MerchantNotice(
            'Bu ürün katalogda bulunuyor. Mevcut ürünü mağazana ekleyebilirsin.',
          ),
          OutlinedButton(
            onPressed: _busy || _opening
                ? null
                : () => _existing(_resolvedProduct!),
            child: const Text('Mevcut ürünü mağazama ekle'),
          ),
        ],
        if (_categoriesLoading)
          const Center(child: CircularProgressIndicator()),
        if (!_categoriesLoading && !_categoriesFailed && _categories.isEmpty)
          MerchantNotice(
            'Şu anda başvuruya açık kategori bulunmuyor.',
            onRetry: _load,
          ),
        Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                enabled: !_busy && _sentDraft == null,
                maxLength: 200,
                decoration: const InputDecoration(labelText: 'Ürün adı'),
                validator: (v) =>
                    v?.trim().isEmpty ?? true ? 'Ürün adını girin.' : null,
              ),
              for (final entry in [
                (_brand, 'Marka (isteğe bağlı)'),
                (_model, 'Model (isteğe bağlı)'),
                (_variant, 'Varyant / boyut (isteğe bağlı)'),
              ])
                TextFormField(
                  controller: entry.$1,
                  enabled: !_busy && _sentDraft == null,
                  maxLength: 120,
                  decoration: InputDecoration(labelText: entry.$2),
                ),
              TextFormField(
                controller: _gtin,
                enabled: !_busy && _sentDraft == null,
                maxLength: 14,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Barkod / GTIN (isteğe bağlı)',
                ),
                validator: (v) {
                  try {
                    normalizeGtin(v ?? '');
                    return null;
                  } on FormatException catch (e) {
                    return e.message;
                  }
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _category,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Ürün kategorisi'),
                items: [
                  for (final c in _categories)
                    DropdownMenuItem(
                      value: c.id,
                      child: Text(
                        c.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: _busy || _sentDraft != null
                    ? null
                    : (v) => setState(() {
                        _category = v;
                        _suggestions = null;
                      }),
                validator: (v) => v == null ? 'Kategori seçin.' : null,
              ),
              SwitchListTile(
                title: const Text('Mağazama özel ürün'),
                subtitle: const Text(
                  'Kendi üretimin veya yalnızca mağazana ait bir ürünse seç.',
                ),
                value: _unique,
                onChanged: _busy || _sentDraft != null
                    ? null
                    : (v) => setState(() => _unique = v),
              ),
            ],
          ),
        ),
        if (_suggestions != null) ...[
          Text(
            _suggestions!.exact
                ? 'Bu barkod katalogda var. Mevcut ürünü mağazana ekleyebilirsin.'
                : 'Benzer ürünler bulundu. Aynı ürünse mevcut kaydı seç.',
          ),
          for (final p in _suggestions!.products)
            Card(
              child: ListTile(
                title: Text(p.name),
                subtitle: Text(p.brandName ?? ''),
                trailing: const Icon(Icons.add_circle_outline),
                onTap: _busy ? null : () => _existing(p),
              ),
            ),
          if (!_suggestions!.exact)
            OutlinedButton(
              onPressed: _busy ? null : () => _send(continueNew: true),
              child: const Text('Farklı bir ürün; başvuruyla devam et'),
            ),
        ],
        if (_resolvedProduct == null)
          FilledButton(
            onPressed:
                _busy ||
                    (_sentDraft == null &&
                        (_categoriesLoading ||
                            _categoriesFailed ||
                            _categories.isEmpty))
                ? null
                : () => _send(),
            child: Text(
              _busy
                  ? 'Gönderiliyor…'
                  : _sentDraft != null
                  ? 'Aynı başvuruyu tekrar kontrol et'
                  : 'İncelemeye gönder',
            ),
          ),
      ],
    ),
  );
}

class MerchantSubmissions extends StatefulWidget {
  const MerchantSubmissions({
    super.key,
    required this.catalog,
    required this.repository,
    required this.access,
  });
  final CatalogMediaRepository catalog;
  final MerchantRepository repository;
  final MerchantAccess access;
  @override
  State<MerchantSubmissions> createState() => _MerchantSubmissionsState();
}

class _MerchantSubmissionsState extends State<MerchantSubmissions>
    with MerchantWorkspaceContinuation<MerchantSubmissions> {
  List<ProductSubmission> _items = [];
  String? _error;
  bool _loading = false, _more = false;
  int _page = 0;
  int _epoch = 0;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = true}) async {
    if (!workspaceCurrent || _loading) return;
    final epoch = ++_epoch;
    setState(() {
      _loading = true;
      _error = null;
      if (refresh) {
        _page = 0;
        _items = [];
      }
    });
    try {
      final r = await merchantRead(
        () => _page == 0
            ? widget.catalog.submissions(widget.access)
            : widget.catalog.submissions(widget.access, page: _page),
      );
      if (!workspaceCurrent || epoch != _epoch) return;
      setState(() {
        _loading = false;
        r.fold((e) => _error = e, (v) {
          _items = {
            ...{for (final s in _items) s.id: s},
            for (final s in v) s.id: s,
          }.values.toList();
          ++_page;
          _more = v.length == 100;
        });
      });
    } catch (_) {
      if (workspaceCurrent && epoch == _epoch) {
        setState(() {
          _loading = false;
          _error = 'Başvurular yüklenemedi. Yeniden dene.';
        });
      }
    }
  }

  Future<void> _add(ProductSubmission s) async {
    if (!workspaceCurrent || _loading || s.productId == null) return;
    setState(() => _loading = true);
    final r = await merchantRead(
      () => widget.catalog.approvedProduct(widget.access, s.productId!),
    );
    if (!mounted || !workspaceCurrent) return;
    setState(() => _loading = false);
    final p = r.fold((e) {
      setState(() => _error = e);
      return null;
    }, (p) => p);
    if (p == null) {
      setState(() => _error ??= 'Bu ürün şu anda katalogda görünmüyor.');
      return;
    }
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MerchantListingForm(
          repository: widget.repository,
          access: widget.access,
          product: p,
          catalogMedia: widget.catalog,
        ),
      ),
    );
    if (mounted && workspaceCurrent && saved == true) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) => MerchantPage(
    title: 'Ürün başvurularım',
    onRefresh: _load,
    children: [
      if (_loading) const Center(child: CircularProgressIndicator()),
      if (_error != null)
        MerchantNotice(
          _error!,
          error: true,
          onRetry: () => _load(refresh: _items.isEmpty),
        ),
      if (!_loading && _items.isEmpty && _error == null)
        const MerchantNotice('Henüz ürün başvurun yok.'),
      for (final s in _items)
        Card(
          child: ListTile(
            title: Text(s.name),
            subtitle: Text(
              '${s.statusLabel}${s.reason == null ? '' : '\n${s.reason}'}',
            ),
            trailing: s.status == 'approved'
                ? TextButton(
                    onPressed: _loading ? null : () => _add(s),
                    child: const Text('Mağazama ekle'),
                  )
                : null,
          ),
        ),
      if (!_loading && _error == null && _more)
        OutlinedButton(
          onPressed: () => _load(refresh: false),
          child: const Text('Daha fazla başvuru'),
        ),
    ],
  );
}
