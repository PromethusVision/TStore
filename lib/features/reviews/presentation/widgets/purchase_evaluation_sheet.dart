import 'package:flutter/material.dart';
import 'package:t_store/core/common/widgets/customer_light_input_theme.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/reviews/domain/entities/purchase_evaluation.dart';
import 'package:t_store/features/reviews/domain/repositories/purchase_evaluation_repository.dart';
import 'package:t_store/features/reviews/presentation/widgets/evaluation_session_guard.dart';
import 'package:t_store/features/reviews/presentation/evaluation_recovery.dart';

Future<bool?> showPurchaseEvaluation(
  BuildContext context, {
  required PurchaseEvaluationRepository repository,
  required String purchaseId,
  String? selectedProductId,
}) => showModalBottomSheet<bool>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  isDismissible: false,
  enableDrag: false,
  backgroundColor: EsnaftaVarColors.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  clipBehavior: Clip.antiAlias,
  builder: (_) => PurchaseEvaluationSheet(
    repository: repository,
    purchaseId: purchaseId,
    selectedProductId: selectedProductId,
  ),
);

class PurchaseEvaluationSheet extends StatefulWidget {
  const PurchaseEvaluationSheet({
    super.key,
    required this.repository,
    required this.purchaseId,
    this.selectedProductId,
  });
  final PurchaseEvaluationRepository repository;
  final String purchaseId;
  final String? selectedProductId;
  @override
  State<PurchaseEvaluationSheet> createState() =>
      _PurchaseEvaluationSheetState();
}

class _ProductDraft {
  _ProductDraft(EvaluationProduct product, bool initiallySelected)
    : selected = initiallySelected,
      rating = product.existingReview?.rating ?? 0,
      title = TextEditingController(text: product.existingReview?.title),
      comment = TextEditingController(text: product.existingReview?.comment);
  bool selected;
  int rating;
  final TextEditingController title, comment;
  void dispose() {
    title.dispose();
    comment.dispose();
  }
}

class _PurchaseEvaluationSheetState extends State<PurchaseEvaluationSheet>
    with EvaluationSessionGuard<PurchaseEvaluationSheet> {
  late final String? _actor = widget.repository.currentUserId;
  PurchaseEvaluation? _purchase;
  PurchaseEvaluationCommand? _pending;
  late final EvaluationRecovery _recovery;
  int _loadEpoch = 0;
  final _drafts = <String, _ProductDraft>{};
  int _friendliness = 0, _communication = 0, _cleanliness = 0;
  bool _loading = true, _busy = false;
  String? _error;
  @override
  PurchaseEvaluationRepository get evaluationRepository => widget.repository;
  @override
  Object get evaluationResource => widget.purchaseId;
  @override
  String? get evaluationActor => _actor;
  bool get _current => evaluationSessionCurrent;
  @override
  void clearEvaluationSession() {
    _loadEpoch++;
    _busy = false;
    _loading = false;
    _pending = null;
    _purchase = null;
    for (final d in _drafts.values) {
      d.title.clear();
      d.comment.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _recovery = EvaluationRecovery.of(widget.repository);
    _pending = _recovery.purchase(widget.purchaseId);
    _load();
  }

  @override
  void dispose() {
    for (final d in _drafts.values) {
      d.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    if (_busy || !checkEvaluationContinuation()) return;
    final epoch = ++_loadEpoch;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await widget.repository.purchase(widget.purchaseId);
    if (!checkEvaluationContinuation() || epoch != _loadEpoch) return;
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (value) => setState(() {
        for (final d in _drafts.values) {
          d.dispose();
        }
        _drafts.clear();
        _purchase = value;
        _loading = false;
        _pending = _recovery.purchase(widget.purchaseId);
        final service = _pending?.service ?? value.service;
        _friendliness = service?.friendliness ?? 0;
        _communication = service?.communication ?? 0;
        _cleanliness = service?.cleanliness ?? 0;
        final pendingProducts = {
          for (final p in _pending?.products ?? <ProductEvaluationInput>[])
            p.productId: p,
        };
        for (final p in value.products.where(
          (p) => p.canSubmit || pendingProducts.containsKey(p.productId),
        )) {
          final submitted = pendingProducts[p.productId];
          final draft = _drafts[p.productId] = _ProductDraft(
            p,
            _pending == null
                ? p.productId == widget.selectedProductId
                : submitted != null,
          );
          if (submitted != null) {
            draft.rating = submitted.rating;
            draft.title.text = submitted.title ?? '';
            draft.comment.text = submitted.comment ?? '';
          }
        }
      }),
    );
  }

  Future<void> _submit() async {
    final purchase = _purchase;
    if (_busy ||
        !checkEvaluationContinuation() ||
        purchase == null ||
        (_pending == null && (!purchase.enabled || !purchase.valid))) {
      return;
    }
    if (_pending == null) {
      final criteria = purchase.service == null
          ? ServiceCriteria(
              friendliness: _friendliness,
              communication: _communication,
              cleanliness: _cleanliness,
            )
          : null;
      if (criteria != null && !criteria.valid) {
        setState(
          () => _error =
              'Güleryüz, iletişim ve temizlik puanlarının tümünü seçin.',
        );
        return;
      }
      final products = <ProductEvaluationInput>[];
      for (final e in _drafts.entries.where((e) => e.value.selected)) {
        final d = e.value;
        if (d.rating == 0) {
          setState(() => _error = 'Seçtiğiniz her ürün için bir puan verin.');
          return;
        }
        products.add(
          ProductEvaluationInput(
            productId: e.key,
            rating: d.rating,
            title: d.title.text.trim(),
            comment: d.comment.text.trim(),
          ),
        );
      }
      if (products.isEmpty && criteria == null) {
        setState(() => _error = 'Değerlendirmek istediğiniz bir ürün seçin.');
        return;
      }
      _pending = PurchaseEvaluationCommand(
        purchaseId: purchase.purchaseId,
        requestId: newEvaluationRequestId(),
        service: criteria,
        products: products,
      );
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await _recovery.submit(_pending!);
    if (!checkEvaluationContinuation()) return;
    result.fold(
      (failure) => setState(() {
        _busy = false;
        _error = failure.message;
        _pending = _recovery.purchase(widget.purchaseId);
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final purchase = _purchase, locked = _busy || _pending != null;
    return PopScope(
      canPop: !_busy,
      child: CustomerLightInputTheme(
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .88,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                20 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Alışverişi değerlendir',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Kapat',
                        onPressed: _busy
                            ? null
                            : () => Navigator.of(context).pop(false),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  if (!_current)
                    const Text(
                      'Oturumunuz değişti. Bu pencereyi kapatıp yeniden giriş yapın.',
                    )
                  else if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    if (_error != null) ...[
                      Text(
                        _error!,
                        key: const Key('evaluation-error'),
                        style: const TextStyle(color: EsnaftaVarColors.error),
                      ),
                      TextButton(
                        onPressed: _busy ? null : _load,
                        child: const Text('Güncel durumu kontrol et'),
                      ),
                    ],
                    if (purchase != null) ...[
                      Text(
                        purchase.shopName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Doğrulanmış Alışveriş • Değerlendirme isteğe bağlıdır.',
                      ),
                      const SizedBox(height: 16),
                      if (!purchase.valid)
                        const Text(
                          'Bu alışveriş için değerlendirme hakkı kullanılamıyor.',
                        )
                      else if (!purchase.enabled)
                        const Text(
                          'Değerlendirme özelliği henüz kullanıma açılmadı.',
                        )
                      else ...[
                        Text(
                          'Mağaza hizmeti',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          purchase.service == null
                              ? 'Gönderirken üç hizmet kriterini de puanlayın.'
                              : 'Bu alışverişin hizmet puanları kaydedildi; tekrar değiştirilemez.',
                        ),
                        EvaluationStars(
                          label: 'Güleryüz',
                          value: _friendliness,
                          onChanged: locked || purchase.service != null
                              ? null
                              : (v) => setState(() => _friendliness = v),
                        ),
                        EvaluationStars(
                          label: 'İletişim',
                          value: _communication,
                          onChanged: locked || purchase.service != null
                              ? null
                              : (v) => setState(() => _communication = v),
                        ),
                        EvaluationStars(
                          label: 'Temizlik',
                          value: _cleanliness,
                          onChanged: locked || purchase.service != null
                              ? null
                              : (v) => setState(() => _cleanliness = v),
                        ),
                        const Divider(height: 32),
                        Text(
                          'Ürünler',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Text(
                          'İstediğiniz ürünleri seçin. Ürün puanı gereklidir; yazılı yorum isteğe bağlıdır.',
                        ),
                        for (final p in purchase.products) ...[
                          if (_drafts[p.productId] case final d?) ...[
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(p.name),
                              subtitle: p.existingReview == null
                                  ? null
                                  : const Text(
                                      'Yeni alışverişle mevcut değerlendirmeni güncelle',
                                    ),
                              value: d.selected,
                              onChanged: locked
                                  ? null
                                  : (v) =>
                                        setState(() => d.selected = v ?? false),
                            ),
                            if (d.selected) ...[
                              EvaluationStars(
                                label: 'Ürün puanı',
                                value: d.rating,
                                onChanged: locked
                                    ? null
                                    : (v) => setState(() => d.rating = v),
                              ),
                              TextField(
                                controller: d.title,
                                readOnly: locked,
                                maxLength: 120,
                                decoration: const InputDecoration(
                                  labelText: 'Başlık (isteğe bağlı)',
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: d.comment,
                                readOnly: locked,
                                maxLength: 2000,
                                minLines: 2,
                                maxLines: 5,
                                decoration: const InputDecoration(
                                  labelText: 'Yorum (isteğe bağlı)',
                                ),
                              ),
                              const Text(
                                'Gönderdikten sonra 24 saat boyunca düzenleyebilirsiniz. Yeni alışveriş mevcut yorumunuzu günceller; ikinci bir ürün puanı oluşturmaz.',
                              ),
                            ],
                          ] else
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(p.name),
                              subtitle: const Text(
                                'Bu alışverişin değerlendirme hakkı kullanıldı.',
                              ),
                            ),
                        ],
                        const SizedBox(height: 16),
                      ],
                      if (_pending != null && !_busy)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Yanıt doğrulanana kadar gönderilen bilgiler korunur. Tekrar denemek ikinci bir değerlendirme oluşturmaz.',
                          ),
                        ),
                      if ((purchase.enabled &&
                              purchase.valid &&
                              (purchase.service == null ||
                                  _drafts.isNotEmpty)) ||
                          _pending != null)
                        FilledButton(
                          key: const Key('evaluation-submit'),
                          onPressed: _busy ? null : _submit,
                          child: Text(
                            _busy
                                ? 'Kaydediliyor…'
                                : _pending == null
                                ? 'Değerlendirmeyi kaydet'
                                : 'Aynı işlemi tekrar dene',
                          ),
                        ),
                      if (_pending == null &&
                          purchase.enabled &&
                          purchase.valid &&
                          purchase.service != null &&
                          _drafts.isEmpty)
                        const Text(
                          'Bu alışverişin değerlendirmeleri tamamlandı.',
                        ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EvaluationStars extends StatelessWidget {
  const EvaluationStars({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
  });
  final String label;
  final int value;
  final ValueChanged<int>? onChanged;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label${value > 0 ? ' · $value/5' : ''}'),
        Wrap(
          children: [
            for (var i = 1; i <= 5; i++)
              IconButton(
                tooltip: '$label: $i yıldız',
                onPressed: onChanged == null ? null : () => onChanged!(i),
                color: EsnaftaVarColors.primary,
                disabledColor: EsnaftaVarColors.primary,
                icon: Icon(
                  i <= value ? Icons.star_rounded : Icons.star_border_rounded,
                ),
              ),
          ],
        ),
      ],
    ),
  );
}
