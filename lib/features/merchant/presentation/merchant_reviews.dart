import 'package:flutter/material.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';
import 'package:t_store/features/reviews/domain/entities/purchase_evaluation.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';
import 'package:t_store/features/reviews/domain/repositories/purchase_evaluation_repository.dart';
import 'package:t_store/features/reviews/presentation/widgets/evaluation_session_guard.dart';

class MerchantReviewSummary extends StatefulWidget {
  const MerchantReviewSummary({
    super.key,
    required this.repository,
    required this.shopId,
    required this.ownerId,
  });
  final PurchaseEvaluationRepository repository;
  final String shopId, ownerId;
  @override
  State<MerchantReviewSummary> createState() => _MerchantReviewSummaryState();
}

class _MerchantReviewSummaryState extends State<MerchantReviewSummary>
    with EvaluationSessionGuard<MerchantReviewSummary> {
  MerchantReviewsPage? _page;
  String? _error;
  bool _loading = true, _enabled = false, _opening = false;
  int _epoch = 0;
  @override
  PurchaseEvaluationRepository get evaluationRepository => widget.repository;
  @override
  String get evaluationActor => widget.ownerId;
  bool get _current => evaluationSessionCurrent;
  @override
  void clearEvaluationSession() {
    _page = null;
    _epoch++;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final epoch = ++_epoch;
    if (!_current) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final capability = await widget.repository.enabled();
    if (!mounted || !_current || epoch != _epoch) return;
    bool enabled = false;
    String? failure;
    capability.fold((e) => failure = e.message, (v) => enabled = v);
    if (failure != null || !enabled) {
      setState(() {
        _loading = false;
        _enabled = false;
        _error = failure;
      });
      return;
    }
    final result = await widget.repository.merchant(widget.shopId);
    if (!mounted || !_current || epoch != _epoch) return;
    setState(() {
      _enabled = true;
      _loading = false;
      result.fold((e) => _error = e.message, (p) => _page = p);
    });
  }

  Future<void> _open() async {
    if (_opening || !_current) return;
    _opening = true;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MerchantReviewsView(
          repository: widget.repository,
          shopId: widget.shopId,
          ownerId: widget.ownerId,
        ),
      ),
    );
    _opening = false;
    if (mounted && _current) await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_current) return const SizedBox.shrink();
    if (_loading) {
      return const MerchantNotice('Değerlendirme özeti yükleniyor…');
    }
    if (_error != null) {
      return MerchantNotice(_error!, error: true, onRetry: _load);
    }
    if (!_enabled || _page == null) return const SizedBox.shrink();
    return MerchantSection(
      title: 'Müşteri değerlendirmeleri',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MerchantServiceScores(scores: _page!.scores),
          const SizedBox(height: 12),
          Text('Yanıt bekleyen: ${_page!.awaitingReplyCount}'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('merchant-reviews-open'),
            onPressed: _open,
            icon: const Icon(Icons.rate_review_outlined),
            label: const Text('Değerlendirme merkezini aç'),
          ),
        ],
      ),
    );
  }
}

class MerchantServiceScores extends StatelessWidget {
  const MerchantServiceScores({super.key, required this.scores});
  final ServiceScores scores;
  String _score(double? value) => value == null
      ? 'Henüz puan yok'
      : '${value.toStringAsFixed(2).replaceAll('.', ',')} / 5';
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        _score(scores.average),
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      Text(
        '${scores.sampleCount} doğrulanmış müşterinin son geçerli değerlendirmesi',
      ),
      const SizedBox(height: 12),
      for (final e in {
        'Güleryüz': scores.friendliness,
        'İletişim': scores.communication,
        'Temizlik': scores.cleanliness,
      }.entries)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Wrap(
            spacing: 12,
            children: [Text(e.key), Text(_score(e.value))],
          ),
        ),
    ],
  );
}

class MerchantReviewsView extends StatefulWidget {
  const MerchantReviewsView({
    super.key,
    required this.repository,
    required this.shopId,
    required this.ownerId,
  });
  final PurchaseEvaluationRepository repository;
  final String shopId, ownerId;
  @override
  State<MerchantReviewsView> createState() => _MerchantReviewsViewState();
}

class _MerchantReviewsViewState extends State<MerchantReviewsView>
    with EvaluationSessionGuard<MerchantReviewsView> {
  MerchantReviewFilter _filter = MerchantReviewFilter.all;
  MerchantReviewsPage? _page;
  List<MerchantReview> _reviews = [];
  int _epoch = 0, _offset = 0;
  bool _loading = true, _more = false, _opening = false;
  String? _error;
  @override
  PurchaseEvaluationRepository get evaluationRepository => widget.repository;
  @override
  String get evaluationActor => widget.ownerId;
  bool get _current => evaluationSessionCurrent;
  @override
  void clearEvaluationSession() {
    _page = null;
    _reviews = [];
    _epoch++;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    if (!_current || (more && (_loading || _more))) return;
    final epoch = ++_epoch;
    setState(() {
      _error = null;
      if (more) {
        _more = true;
      } else {
        _loading = true;
        _more = false;
        _offset = 0;
        _reviews = [];
      }
    });
    final result = await widget.repository.merchant(
      widget.shopId,
      filter: _filter,
      offset: more ? _offset : 0,
    );
    if (!mounted || !_current || epoch != _epoch) return;
    setState(() {
      _loading = false;
      _more = false;
      result.fold((e) => _error = e.message, (page) {
        _page = page;
        _offset += page.reviews.length;
        _reviews = {
          for (final r in _reviews) r.id: r,
          for (final r in page.reviews) r.id: r,
        }.values.toList();
      });
    });
  }

  Future<void> _open(MerchantReview review) async {
    if (_opening || !_current) return;
    _opening = true;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _MerchantReviewDetail(
          repository: widget.repository,
          shopId: widget.shopId,
          ownerId: widget.ownerId,
          review: review,
        ),
      ),
    );
    _opening = false;
    if (mounted && _current) await _load();
  }

  @override
  Widget build(BuildContext context) => MerchantPage(
    title: 'Değerlendirme merkezi',
    onRefresh: () => _load(),
    children: [
      if (!_current)
        const MerchantNotice(
          'Oturum değişti. Bu ekranı kapatıp yeniden giriş yapın.',
        )
      else ...[
        if (_page != null) MerchantServiceScores(scores: _page!.scores),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final f in MerchantReviewFilter.values)
              ChoiceChip(
                label: Text(switch (f) {
                  MerchantReviewFilter.all => 'Tümü',
                  MerchantReviewFilter.unanswered => 'Yanıt bekleyen',
                  MerchantReviewFilter.replied => 'Yanıtlanan',
                  MerchantReviewFilter.reported => 'Bildirilen',
                }),
                selected: _filter == f,
                onSelected: (v) {
                  if (v && _filter != f) {
                    setState(() => _filter = f);
                    _load();
                  }
                },
              ),
          ],
        ),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else ...[
          if (_error != null)
            MerchantNotice(
              _error!,
              error: true,
              onRetry: () => _load(more: _reviews.isNotEmpty),
            ),
          if (_reviews.isEmpty && _error == null)
            const MerchantNotice('Bu filtrede değerlendirme bulunmuyor.'),
          for (final r in _reviews)
            Card(
              child: ListTile(
                key: Key('merchant-review-${r.id}'),
                title: Text(r.productName),
                subtitle: Text(
                  r.visible
                      ? '${r.rating}/5 • ${r.replied ? 'Yanıtlandı' : 'Yanıt bekliyor'}\n${r.comment?.isNotEmpty == true ? r.comment : 'Yalnızca puan verildi.'}'
                      : _visibility(r.visibility),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(r),
              ),
            ),
          if (_page != null && _offset < _page!.total)
            TextButton(
              onPressed: _more ? null : () => _load(more: true),
              child: Text(_more ? 'Yükleniyor…' : 'Daha fazla göster'),
            ),
        ],
      ],
    ],
  );
}

String _visibility(String value) => switch (value) {
  'withdrawn' => 'Müşteri tarafından yayından kaldırıldı',
  'hidden' => 'İnceleme sonucunda gizlendi',
  'under_review' => 'İnceleniyor',
  'invalid' => 'Alışveriş kanıtı geçersiz',
  _ => 'Doğrulanmış Alışveriş',
};

class _MerchantReviewDetail extends StatefulWidget {
  const _MerchantReviewDetail({
    required this.repository,
    required this.shopId,
    required this.ownerId,
    required this.review,
  });
  final PurchaseEvaluationRepository repository;
  final String shopId, ownerId;
  final MerchantReview review;
  @override
  State<_MerchantReviewDetail> createState() => _MerchantReviewDetailState();
}

class _MerchantReviewDetailState extends State<_MerchantReviewDetail>
    with EvaluationSessionGuard<_MerchantReviewDetail> {
  bool _opening = false, _replied = false, _reported = false;
  @override
  PurchaseEvaluationRepository get evaluationRepository => widget.repository;
  @override
  String get evaluationActor => widget.ownerId;
  bool get _current => evaluationSessionCurrent;
  Future<void> _action(bool report) async {
    if (_opening || !_current) return;
    _opening = true;
    final done = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ReviewResponseDialog(
        repository: widget.repository,
        shopId: widget.shopId,
        ownerId: widget.ownerId,
        review: widget.review,
        report: report,
      ),
    );
    _opening = false;
    if (!mounted || !_current || done != true) return;
    setState(() {
      if (report) {
        _reported = true;
      } else {
        _replied = true;
      }
    });
    merchantSaved(
      context,
      report
          ? 'Bildiriminiz inceleme için kaydedildi.'
          : 'Yanıtınız kaydedildi.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.review;
    return MerchantPage(
      title: 'Değerlendirme ayrıntısı',
      children: [
        if (!_current)
          const MerchantNotice('Oturum değişti. Bu ekranı kapatın.')
        else ...[
          Text(r.productName, style: Theme.of(context).textTheme.titleLarge),
          Text(_visibility(r.visibility)),
          if (r.visible) ...[
            Text(
              '${r.rating}/5',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (r.title?.isNotEmpty == true) Text(r.title!),
            Text(
              r.comment?.isNotEmpty == true
                  ? r.comment!
                  : 'Yalnızca puan verildi.',
            ),
          ],
          if (r.reply != null)
            MerchantSection(title: 'Mağaza yanıtı', child: Text(r.reply!)),
          if (_replied)
            const MerchantNotice(
              'Yanıt kaydedildi. Güncel metni görmek için değerlendirme merkezine dönün.',
            ),
          if (r.canReply && !_replied) ...[
            const Text(
              'Her ürün değerlendirmesine yalnızca bir kez yanıt verebilirsiniz. Göndermeden önce metninizi kontrol edin.',
            ),
            FilledButton(
              onPressed: () => _action(false),
              child: const Text('Yanıt yaz'),
            ),
          ] else if (r.replied && r.reply == null && !_replied)
            const Text(
              'Bu değerlendirme için yanıt hakkı daha önce kullanıldı. Önceki mağazaya ait veya gizlenmiş yanıt burada gösterilmez.',
            ),
          if (r.reported || _reported)
            const Text('Bu sürüm için bildiriminiz kaydedildi.')
          else if (r.visible)
            OutlinedButton(
              onPressed: () => _action(true),
              child: const Text('Değerlendirmeyi bildir'),
            ),
          const Text(
            'Müşterinin puanını veya yorumunu değiştiremezsiniz. Bildirim tek başına değerlendirmeyi yayından kaldırmaz.',
          ),
        ],
      ],
    );
  }
}

class _ReviewResponseDialog extends StatefulWidget {
  const _ReviewResponseDialog({
    required this.repository,
    required this.shopId,
    required this.ownerId,
    required this.review,
    required this.report,
  });
  final PurchaseEvaluationRepository repository;
  final String shopId, ownerId;
  final MerchantReview review;
  final bool report;
  @override
  State<_ReviewResponseDialog> createState() => _ReviewResponseDialogState();
}

class _ReviewResponseDialogState extends State<_ReviewResponseDialog>
    with EvaluationSessionGuard<_ReviewResponseDialog> {
  final _text = TextEditingController();
  final _request = newEvaluationRequestId();
  String? _sent, _error;
  bool _busy = false;
  @override
  PurchaseEvaluationRepository get evaluationRepository => widget.repository;
  @override
  String get evaluationActor => widget.ownerId;
  bool get _current => evaluationSessionCurrent;
  @override
  void clearEvaluationSession() {
    _busy = false;
    _sent = null;
    _text.clear();
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_current) return;
    final text = _sent ?? _text.text.trim();
    if (text.isEmpty) {
      setState(
        () => _error = widget.report
            ? 'Bildirim nedeninizi yazın.'
            : 'Yanıtınızı yazın.',
      );
      return;
    }
    _sent = text;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = widget.report
        ? await widget.repository.report(
            shopId: widget.shopId,
            review: widget.review,
            requestId: _request,
            reason: text,
          )
        : await widget.repository.reply(
            shopId: widget.shopId,
            review: widget.review,
            requestId: _request,
            text: text,
          );
    if (!mounted || !_current) return;
    result.fold(
      (e) => setState(() {
        _busy = false;
        _error = e.message;
        if (e.kind != ReviewFailureKind.network &&
            e.kind != ReviewFailureKind.invalidResponse) {
          _sent = null;
        }
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      scrollable: true,
      title: Text(widget.report ? 'Değerlendirmeyi bildir' : 'Mağaza yanıtı'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_current)
            const Text('Oturum değişti. Bu pencereyi kapatın.')
          else ...[
            TextField(
              key: const Key('merchant-review-response'),
              controller: _text,
              readOnly: _busy || _sent != null,
              maxLength: widget.report ? 500 : 2000,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: widget.report ? 'Bildirim nedeni' : 'Yanıtınız',
              ),
            ),
            if (_error != null) Text(_error!),
            if (_sent != null && !_busy)
              const Text(
                'Gönderim sonucu doğrulanamadı. Aynı metni güvenle tekrar deneyebilirsiniz.',
              ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Kapat'),
        ),
        FilledButton(
          onPressed: _busy || !_current ? null : _submit,
          child: Text(
            _busy
                ? 'Gönderiliyor…'
                : _sent != null
                ? 'Tekrar dene'
                : 'Gönder',
          ),
        ),
      ],
    ),
  );
}
