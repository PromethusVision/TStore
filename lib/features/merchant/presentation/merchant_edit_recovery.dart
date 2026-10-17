import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';

bool merchantValuesEqual(Object? a, Object? b) {
  if (a is Map && b is Map) {
    return a.length == b.length &&
        a.keys.every(
          (key) => b.containsKey(key) && merchantValuesEqual(a[key], b[key]),
        );
  }
  if (a is List && b is List) {
    return a.length == b.length &&
        Iterable<int>.generate(
          a.length,
        ).every((i) => merchantValuesEqual(a[i], b[i]));
  }
  return a == b;
}

/// A failed write is not evidence that nothing was saved. Re-read before another
/// edit; never time out a write, auto-retry it, or infer an operation receipt.
class MerchantEditRecovery<T> extends ChangeNotifier {
  MerchantEditRecovery({this.read});
  final Future<Either<String, T?>> Function()? read;
  bool busy = false, needsReview = false, loaded = false;
  T? current;
  String? error;
  bool _disposed = false;

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  Future<T?> save(Future<Either<String, T>> Function() write) async {
    if (busy || needsReview || _disposed) return null;
    busy = true;
    error = null;
    loaded = false;
    current = null;
    _changed();
    T? saved;
    try {
      final result = await write();
      if (_disposed) return null;
      result.fold((e) => error = e, (value) => saved = value);
    } catch (_) {
      error = 'Kayıt sonucu doğrulanamadı. Bilgilerin bu ekranda korunuyor.';
    } finally {
      busy = false;
    }
    if (_disposed) return null;
    if (saved == null && read != null) {
      needsReview = true;
    }
    _changed();
    return saved;
  }

  Future<void> reload() async {
    if (busy || read == null || _disposed) return;
    busy = true;
    loaded = false;
    current = null;
    error = null;
    _changed();
    try {
      final result = await read!().timeout(const Duration(seconds: 15));
      if (_disposed) return;
      result.fold((e) => error = e, (v) {
        current = v;
        loaded = true;
      });
    } catch (_) {
      error = merchantReadTimeout;
    } finally {
      busy = false;
      _changed();
    }
  }

  void reviewed() {
    if (busy || !loaded) return;
    needsReview = false;
    error = null;
    _changed();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class MerchantRecoveryPanel extends StatelessWidget {
  const MerchantRecoveryPanel({
    super.key,
    required this.busy,
    required this.loaded,
    required this.matches,
    required this.summary,
    required this.onReload,
    this.onUseCurrent,
    this.onKeepDraft,
    this.message =
        'Yanıt alınamasa da işlem kaydedilmiş olabilir. Yeniden kaydetmeden önce güncel bilgileri kontrol et.',
  });
  final bool busy, loaded, matches;
  final String summary, message;
  final VoidCallback onReload;
  final VoidCallback? onUseCurrent, onKeepDraft;

  @override
  Widget build(BuildContext context) => MerchantSection(
    title: 'Kayıt durumunu kontrol et',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(message),
        if (loaded) ...[
          const SizedBox(height: 12),
          Text(summary),
          if (matches) const Text('Güncel kayıt, gönderdiğin bilgilerle aynı.'),
          if (onUseCurrent != null) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: busy ? null : onUseCurrent,
              child: Text(
                matches ? 'Güncel kayıtla devam et' : 'Güncel bilgileri kullan',
              ),
            ),
          ],
          if (!matches && onKeepDraft != null) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: busy ? null : onKeepDraft,
              child: const Text('Taslağımı bu kayıt üzerinde düzenle'),
            ),
          ],
        ],
        TextButton(
          onPressed: busy ? null : onReload,
          child: Text(busy ? 'Kontrol ediliyor…' : 'Güncel kaydı kontrol et'),
        ),
      ],
    ),
  );
}

/// In-memory form loss protection only. Authority loss disposes the host rather
/// than asking permission to keep private data. No draft is stored on disk.
class MerchantDraftGuard extends StatefulWidget {
  const MerchantDraftGuard({
    super.key,
    required this.dirty,
    required this.busy,
    required this.child,
    this.uncertain = false,
  });
  final bool dirty, busy, uncertain;
  final Widget child;
  @override
  State<MerchantDraftGuard> createState() => _MerchantDraftGuardState();
}

class _MerchantDraftGuardState extends State<MerchantDraftGuard> {
  bool _asking = false, _leaving = false;

  Future<void> _back(bool didPop, Object? result) async {
    if (didPop || widget.busy || _asking || !widget.dirty) return;
    _asking = true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Değişikliklerden vazgeçilsin mi?'),
        content: Text(
          widget.uncertain
              ? 'Bu ekrandaki düzenlemelerin kaybolacak. Sonucu belirsiz bir kayıt sunucuda tamamlanmış olabilir.'
              : 'Bu ekrandaki kaydedilmemiş düzenlemelerin kaybolacak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Düzenlemeye dön'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Vazgeç ve çık'),
          ),
        ],
      ),
    );
    _asking = false;
    if (!mounted || discard != true || widget.busy) return;
    setState(() => _leaving = true);
    // Let PopScope see the explicit choice before the route is popped.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(result);
    });
  }

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    canPop: !widget.busy && (_leaving || !widget.dirty),
    onPopInvokedWithResult: _back,
    child: widget.child,
  );
}
