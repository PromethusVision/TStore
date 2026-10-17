import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/features/cart/domain/repositories/qr_claim_repository.dart';
import 'package:t_store/features/merchant/data/pending_purchase_return_store.dart';
import 'package:t_store/features/merchant/presentation/merchant_return_controller.dart';
import 'package:t_store/features/purchases/domain/repositories/purchase_evidence_repository.dart';
import '../../widget/merchant/merchant_qr_slice_b_test.dart' show purchase;

const requestA = '10000000-0000-4000-8000-000000000001';
const requestB = '10000000-0000-4000-8000-000000000002';
PendingPurchaseReturn intent([String id = requestA]) => PendingPurchaseReturn(
  requestId: id,
  reason: 'Ürün iadesi',
  quantities: {'item': 1},
);

class ReturnStore extends Fake implements PendingPurchaseReturnStore {
  PendingPurchaseReturn? value;
  bool failRead = false, failSave = false, failClear = false;
  int clears = 0;
  Completer<void>? saving, clearing;
  @override
  Future<PendingPurchaseReturn?> read(PurchaseEvidence p) async {
    if (failRead) throw StateError('disk');
    return value;
  }

  @override
  Future<PendingPurchaseReturn> preserve(
    PendingPurchaseReturn v,
    PurchaseEvidence p,
  ) async {
    if (saving != null) await saving!.future;
    if (failSave) throw StateError('disk');
    return value ??= v;
  }

  @override
  Future<void> clear(PendingPurchaseReturn expected, PurchaseEvidence p) async {
    clears++;
    if (clearing != null) await clearing!.future;
    if (failClear) throw StateError('disk');
    if (value != null && !value!.sameAs(expected)) throw StateError('replaced');
    value = null;
  }
}

class ReturnRepo extends Fake
    implements PurchaseEvidenceRepository, QrSessionIdentity {
  @override
  String? currentQrSessionIdentity = 'owner:session';
  final sent = <PendingPurchaseReturn>[];
  int reads = 0;
  PurchaseEvidence value = purchase();
  String? readError;
  Future<Either<PurchaseReturnFailure, PurchaseEvidence>> Function()? write;
  @override
  Future<Either<String, PurchaseEvidence>> read(String id) async {
    reads++;
    return readError == null ? Right(value) : Left(readError!);
  }

  @override
  Future<Either<PurchaseReturnFailure, PurchaseEvidence>> recordReturn({
    required String purchaseId,
    required String requestId,
    required Map<String, int> quantities,
    required String reason,
  }) async {
    sent.add(
      PendingPurchaseReturn(
        requestId: requestId,
        reason: reason,
        quantities: quantities,
      ),
    );
    return write == null ? Right(purchase(returned: 1)) : write!();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'original B record is readable even when all quantities were returned',
    () {
      final value = PendingPurchaseReturn.decode(
        jsonEncode(intent().toJson()),
        purchase(returned: 3),
      );
      expect(value.sameAs(intent()), true);
    },
  );
  final malformed = <String, Object>{
    'missing key': {'request_id': requestA, 'reason': 'r'},
    'bad id': {...intent().toJson(), 'request_id': 'bad'},
    'extra data': {...intent().toJson(), 'amount': 50},
    'empty reason': {...intent().toJson(), 'reason': '   '},
    'long reason': {...intent().toJson(), 'reason': 'a' * 501},
    'empty quantities': {...intent().toJson(), 'quantities': {}},
    'unknown item': {
      ...intent().toJson(),
      'quantities': {'foreign': 1},
    },
    'fraction': {
      ...intent().toJson(),
      'quantities': {'item': 1.1},
    },
    'string': {
      ...intent().toJson(),
      'quantities': {'item': '1'},
    },
    'zero': {
      ...intent().toJson(),
      'quantities': {'item': 0},
    },
    'negative': {
      ...intent().toJson(),
      'quantities': {'item': -1},
    },
    'over original quantity': {
      ...intent().toJson(),
      'quantities': {'item': 4},
    },
  };
  for (final entry in malformed.entries) {
    test('pending return fails closed: ${entry.key}', () {
      expect(
        () => PendingPurchaseReturn.decode(jsonEncode(entry.value), purchase()),
        throwsFormatException,
      );
    });
  }
  test('concurrent local editors preserve one original intent', () async {
    final a = LocalPendingPurchaseReturnStore(
      userId: 'owner',
      purchaseId: 'purchase',
    );
    final b = LocalPendingPurchaseReturnStore(
      userId: 'owner',
      purchaseId: 'purchase',
    );
    final values = await Future.wait([
      a.preserve(intent(), purchase()),
      b.preserve(intent(requestB), purchase()),
    ]);
    expect(values[0].sameAs(values[1]), true);
    expect((await a.read(purchase()))!.sameAs(intent()), true);
  });
  test('compare before clear cannot remove a newer request', () async {
    final store = LocalPendingPurchaseReturnStore(
      userId: 'owner',
      purchaseId: 'purchase',
    );
    await store.preserve(intent(requestB), purchase());
    await expectLater(store.clear(intent(), purchase()), throwsStateError);
    expect((await store.read(purchase()))!.requestId, requestB);
  });
  test('local retry records stay isolated by account and purchase', () async {
    final store = LocalPendingPurchaseReturnStore(
      userId: 'owner',
      purchaseId: 'purchase',
    );
    await store.preserve(intent(), purchase());
    for (final other in [
      LocalPendingPurchaseReturnStore(userId: 'other', purchaseId: 'purchase'),
      LocalPendingPurchaseReturnStore(userId: 'owner', purchaseId: 'other'),
    ]) {
      expect(await other.read(purchase()), null);
    }
  });
  test('corrupt stored record is retained and cannot be overwritten', () async {
    SharedPreferences.setMockInitialValues({
      'pending_return_b:owner:purchase': '{',
    });
    final store = LocalPendingPurchaseReturnStore(
      userId: 'owner',
      purchaseId: 'purchase',
    );
    await expectLater(store.read(purchase()), throwsFormatException);
    await expectLater(
      store.preserve(intent(), purchase()),
      throwsFormatException,
    );
    expect(
      (await SharedPreferences.getInstance()).getString(
        'pending_return_b:owner:purchase',
      ),
      '{',
    );
  });

  late ReturnRepo repo;
  late ReturnStore store;
  late MerchantReturnController controller;
  setUp(() {
    repo = ReturnRepo();
    store = ReturnStore();
    controller = MerchantReturnController(
      repository: repo,
      store: store,
      purchase: purchase(),
    );
  });
  tearDown(() {
    controller.dispose();
  });
  Future<void> submit() =>
      controller.submit(quantities: {'item': 1}, reason: 'İade');
  test(
    'missing disk acknowledgement retains exact key and never sends first attempt',
    () async {
      await controller.restore();
      store.failSave = true;
      await submit();
      expect(repo.sent, isEmpty);
      final original = controller.pending!;
      store.failSave = false;
      await submit();
      expect(repo.sent.single.sameAs(original), true);
      expect(controller.confirmed, true);
    },
  );
  test(
    'read failure blocks a new request and retry restores saved intent',
    () async {
      store
        ..failRead = true
        ..value = intent();
      await controller.restore();
      await submit();
      expect(repo.sent, isEmpty);
      expect(controller.ready, false);
      store.failRead = false;
      await controller.restore();
      expect(controller.pending!.requestId, requestA);
    },
  );
  test('uncertain write keeps immutable original payload for retry', () async {
    repo.write = () async => const Left(PurchaseReturnFailure('offline'));
    await controller.restore();
    await submit();
    await controller.submit(quantities: {'item': 2}, reason: 'changed');
    expect(repo.sent.length, 2);
    expect(repo.sent[0].sameAs(repo.sent[1]), true);
    expect(store.value!.sameAs(repo.sent[0]), true);
  });
  test('throwing transport is uncertain, never a released draft', () async {
    repo.write = () async => throw StateError('raw transport');
    await controller.restore();
    await submit();
    expect(controller.pending, isNotNull);
    expect(controller.error, isNot(contains('raw transport')));
    expect(controller.busy, false);
  });
  test(
    'server success and failed disk cleanup only retry cleanup, never RPC',
    () async {
      store.failClear = true;
      await controller.restore();
      await submit();
      expect(controller.confirmed, true);
      expect(controller.cleanupRequired, true);
      await submit();
      store.failClear = false;
      await controller.retryCleanup();
      expect(repo.sent.length, 1);
      expect(controller.pending, null);
      expect(controller.cleanupRequired, false);
    },
  );
  test(
    'known rejection refreshes remaining quantity before another edit',
    () async {
      repo
        ..value = purchase(returned: 3)
        ..write = () async => const Left(
          PurchaseReturnFailure('quantity', definitelyRejected: true),
        );
      await controller.restore();
      await submit();
      expect(store.value, null);
      expect(repo.reads, 1);
      expect(controller.purchase.items.single.remaining, 0);
      expect(controller.canSubmit, false);
    },
  );
  test(
    'rejection followed by failed read cannot start another request',
    () async {
      repo
        ..readError = 'offline'
        ..write = () async => const Left(
          PurchaseReturnFailure('quantity', definitelyRejected: true),
        );
      await controller.restore();
      await submit();
      await submit();
      expect(controller.ready, false);
      expect(repo.sent.length, 1);
      repo.readError = null;
      await controller.refresh();
      expect(controller.canSubmit, true);
    },
  );
  test(
    'existing other editor intent is presented before any submission',
    () async {
      await controller.restore();
      store.value = intent();
      await submit();
      expect(repo.sent, isEmpty);
      expect(controller.pending!.requestId, requestA);
      await submit();
      expect(repo.sent.single.requestId, requestA);
    },
  );
  test('double tap during persistence makes one server request', () async {
    await controller.restore();
    store.saving = Completer<void>();
    final first = submit();
    await submit();
    store.saving!.complete();
    await first;
    expect(repo.sent.length, 1);
  });
  test('same account replacement during disk save prevents RPC', () async {
    await controller.restore();
    store.saving = Completer<void>();
    final first = submit();
    repo.currentQrSessionIdentity = 'owner:replacement';
    store.saving!.complete();
    await first;
    expect(repo.sent, isEmpty);
    expect(store.value, isNotNull);
  });
  test(
    'synchronous session loss on persisted-state notification prevents RPC',
    () async {
      await controller.restore();
      controller.addListener(() {
        if (controller.pending != null) repo.currentQrSessionIdentity = null;
      });
      await submit();
      expect(repo.sent, isEmpty);
      expect(store.value, isNotNull);
    },
  );
  test('replacement session response cannot clear persisted intent', () async {
    final pending =
        Completer<Either<PurchaseReturnFailure, PurchaseEvidence>>();
    repo.write = () => pending.future;
    await controller.restore();
    final first = submit();
    await Future<void>.delayed(Duration.zero);
    repo.currentQrSessionIdentity = 'owner:replacement';
    pending.complete(Right(purchase(returned: 1)));
    await first;
    expect(store.clears, 0);
    expect(controller.confirmed, false);
  });
  test('fully returned record can still replay stored exact request', () async {
    controller.dispose();
    store.value = intent();
    controller = MerchantReturnController(
      repository: repo,
      store: store,
      purchase: purchase(returned: 3),
    );
    await controller.restore();
    await submit();
    expect(repo.sent.single.requestId, requestA);
    expect(controller.confirmed, true);
  });
  test(
    'foreign response is uncertain and never clears original intent',
    () async {
      repo.write = () async => Right(
        PurchaseEvidence(
          id: 'foreign',
          shopId: 'other',
          confirmedAt: DateTime(2026),
          items: purchase().items,
          returns: [],
          classification: 'quote_only_b_v1',
          invalidated: false,
        ),
      );
      await controller.restore();
      await submit();
      expect(controller.confirmed, false);
      expect(store.clears, 0);
      expect(controller.pending, isNotNull);
    },
  );
}
