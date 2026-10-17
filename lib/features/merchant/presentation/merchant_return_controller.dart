import 'package:flutter/foundation.dart';
import 'package:t_store/features/cart/data/qr_installation.dart';
import 'package:t_store/features/merchant/data/pending_purchase_return_store.dart';
import 'package:t_store/features/merchant/presentation/merchant_purchase_scope.dart';
import 'package:t_store/features/merchant/presentation/merchant_read.dart';
import 'package:t_store/features/purchases/domain/repositories/purchase_evidence_repository.dart';

/// Durable exact-request retry with separate server and local acknowledgement.
/// A missing response never becomes a new return or a cash refund.
class MerchantReturnController extends ChangeNotifier {
  MerchantReturnController({
    required this.repository,
    required this.store,
    required this.purchase,
  }) : _scope = MerchantPurchaseScope(repository);
  final PurchaseEvidenceRepository repository;
  final PendingPurchaseReturnStore store;
  final MerchantPurchaseScope _scope;
  PurchaseEvidence purchase;
  PendingPurchaseReturn? pending;
  bool busy = false, ready = false, confirmed = false, cleanupRequired = false;
  bool _disposed = false;
  String? error;
  bool get current => !_disposed && _scope.current;
  bool get canEdit =>
      current && ready && !busy && pending == null && !confirmed;
  bool get canSubmit =>
      current &&
      ready &&
      !busy &&
      !confirmed &&
      (pending != null || purchase.canRecordReturn);
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> restore() async {
    if (!current || busy || confirmed) return;
    busy = true;
    ready = false;
    error = null;
    _notify();
    try {
      final saved = await store.read(purchase);
      if (!current) return;
      pending = saved;
      ready = true;
    } catch (_) {
      error =
          'Bekleyen istek okunamadı. Yeni kayıt göndermeden önce yeniden deneyin.';
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> refresh() async {
    if (!current || busy || pending != null || confirmed) return;
    busy = true;
    ready = false;
    error = null;
    _notify();
    final result = await merchantRead(() => repository.read(purchase.id));
    if (current) {
      result.fold((e) => error = e, (value) {
        if (value.id != purchase.id || value.shopId != purchase.shopId) {
          error = 'Alışveriş bilgisi doğrulanamadı.';
        } else {
          purchase = value;
          ready = true;
        }
      });
    }
    busy = false;
    _notify();
  }

  Future<void> submit({
    required Map<String, int> quantities,
    required String reason,
  }) async {
    if (!canSubmit) return;
    busy = true;
    error = null;
    _notify();
    var needsRefresh = false;
    try {
      if (pending == null) {
        if (reason.trim().isEmpty ||
            reason.trim().length > 500 ||
            quantities.isEmpty ||
            quantities.length > 100 ||
            quantities.entries.any((entry) {
              final matches = purchase.items.where((i) => i.id == entry.key);
              return matches.isEmpty ||
                  entry.value <= 0 ||
                  entry.value > matches.first.remaining;
            })) {
          throw const FormatException('İade adedini ve nedenini kontrol edin.');
        }
        final draft = PendingPurchaseReturn(
          requestId: newQrRequestId(),
          reason: reason.trim(),
          quantities: quantities,
        );
        // Capture before any await so storage ambiguity cannot lose the key.
        pending = draft;
        final preserved = await store.preserve(draft, purchase);
        if (!current) return;
        pending = preserved;
        if (!draft.sameAs(preserved)) {
          error =
              'Önceden saklanan istek bulundu. Bilgileri inceleyip aynı isteği kontrol edin.';
          return;
        }
      } else {
        // Also after a failed disk acknowledgement, prove which intent survived.
        final preserved = await store.preserve(pending!, purchase);
        if (!current) return;
        if (!pending!.sameAs(preserved)) {
          pending = preserved;
          error =
              'Önceden saklanan istek bulundu. Bilgileri inceleyip aynı isteği kontrol edin.';
          return;
        }
      }
      final sent = pending!;
      _notify();
      if (!current) return;
      final result = await repository.recordReturn(
        purchaseId: purchase.id,
        requestId: sent.requestId,
        reason: sent.reason,
        quantities: sent.quantities,
      );
      if (!current) return;
      await result.fold(
        (failure) async {
          error = failure.message;
          if (failure.definitelyRejected) {
            await store.clear(sent, purchase);
            if (!current) return;
            pending = null;
            ready = false;
            needsRefresh = true;
          }
        },
        (value) async {
          if (value.id != purchase.id || value.shopId != purchase.shopId) {
            throw const FormatException('İade sonucu doğrulanamadı.');
          }
          purchase = value;
          confirmed = true;
          cleanupRequired = true;
          await store.clear(sent, purchase);
          if (!current) return;
          pending = null;
          cleanupRequired = false;
        },
      );
    } on FormatException catch (e) {
      if (current) error = e.message;
    } catch (_) {
      if (current) {
        error = confirmed
            ? 'İade sunucuda doğrulandı. Cihazdaki bekleyen kayıt temizlenemedi; temizlemeyi yeniden deneyin.'
            : 'İşlem sonucu kesinleşmedi. Aynı isteği yeniden kontrol edin.';
      }
    } finally {
      busy = false;
      _notify();
    }
    if (current && needsRefresh) {
      final rejection = error;
      await refresh();
      if (current && error == null) {
        error = rejection;
        _notify();
      }
    }
  }

  /// A known server success must not be submitted again to fix a disk failure.
  Future<void> retryCleanup() async {
    if (!current || busy || !confirmed || !cleanupRequired || pending == null) {
      return;
    }
    busy = true;
    error = null;
    _notify();
    try {
      await store.clear(pending!, purchase);
      if (!current) return;
      pending = null;
      cleanupRequired = false;
    } catch (_) {
      if (current) {
        error =
            'İade doğrulandı; cihazdaki bekleyen kayıt henüz temizlenemedi.';
      }
    } finally {
      busy = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _scope.close();
    super.dispose();
  }
}
