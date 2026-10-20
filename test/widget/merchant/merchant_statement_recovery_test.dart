import 'dart:async';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';
import 'package:t_store/features/commerce_ledger/domain/merchant_statement.dart';
import 'package:t_store/features/merchant/presentation/merchant_statement.dart';
import '../../support/statement_fixtures.dart';

class SessionStatement extends StatementFake
    implements AuthenticatedSessionEvents {
  @override
  String? currentSessionKey = 'S1';
  final keys = StreamController<String?>.broadcast(sync: true);
  @override
  Stream<String?> get sessionKeyChanges => keys.stream;
}

void main() {
  late SessionStatement repo;
  late StreamController<String?> actors;
  String? actor;
  setUp(() {
    repo = SessionStatement();
    actors = StreamController<String?>.broadcast(sync: true);
    actor = statementUser;
  });
  Future<void> host(
    WidgetTester t, {
    String shop = statementShop,
    Duration timeout = const Duration(seconds: 15),
    Stream<String?>? sessionStream,
  }) async {
    final boundRepo = repo, boundActors = actors;
    addTearDown(() async {
      await t.pumpWidget(const SizedBox());
      await t.runAsync(() async {
        await boundActors.close();
        await boundRepo.keys.close();
      });
    });
    await t.pumpWidget(
      MaterialApp(
        home: MerchantStatementView(
          repository: repo,
          shopId: shop,
          ownerId: statementUser,
          currentUserId: () => actor,
          sessionChanges: sessionStream ?? actors.stream,
          readTimeout: timeout,
        ),
      ),
    );
    await t.pump();
  }

  testWidgets(
    'normal renewal preserves loaded statement without another read',
    (t) async {
      await host(t);
      await t.pumpAndSettle();
      actors.add(statementUser);
      repo.keys.add('S1');
      await t.pumpAndSettle();
      expect(repo.requests, hasLength(1));
      expect(find.text('750,00 TL'), findsOneWidget);
    },
  );
  for (final transition in [
    'replacement',
    'S1-S2-S1',
    'observer-error',
    'observer-done',
    'key-error',
    'key-done',
    'logout-relogin',
  ]) {
    testWidgets(
      '$transition retires private state without reviving a late response',
      (t) async {
        repo.wait =
            Completer<Either<CommerceLedgerFailure, MerchantStatement>>();
        final waiting = repo.wait!;
        await host(t);
        switch (transition) {
          case 'replacement':
            repo.currentSessionKey = 'S2';
            repo.keys.add('S2');
          case 'S1-S2-S1':
            repo.keys.add('S2');
            repo.keys.add('S1');
          case 'observer-error':
            actors.addError(StateError('synthetic'));
            actors.add(statementUser);
          case 'observer-done':
            await t.runAsync(actors.close);
          case 'key-error':
            repo.keys.addError(StateError('synthetic'));
            repo.keys.add('S1');
          case 'key-done':
            await t.runAsync(repo.keys.close);
          case 'logout-relogin':
            actor = null;
            actors.add(null);
            actor = statementUser;
            actors.add(actor);
        }
        waiting.complete(Right(repo.value));
        await t.pumpAndSettle();
        expect(find.text('750,00 TL'), findsNothing);
        expect(find.textContaining('Oturumunuz değişti'), findsOneWidget);
        expect(repo.requests, hasLength(1));
      },
    );
  }
  for (final mismatch in [
    'balances',
    'reserve-cap',
    'page-order',
    'id-order',
  ]) {
    testWidgets(
      'same revision with conflicting $mismatch discards the combined statement',
      (t) async {
        repo.value = statementValue(next: statementId, revision: '2');
        await host(t);
        await t.pumpAndSettle();
        await t.scrollUntilVisible(find.text('Önceki hareketleri yükle'), 300);
        final next = statementValue(
          revision: '2',
          entries: [
            statementEntry(
              id: statementOlderId,
              stamp: mismatch == 'page-order'
                  ? '2026-10-16T10:00:00Z'
                  : mismatch == 'id-order'
                  ? '2026-10-15T10:00:00Z'
                  : '2026-10-14T10:00:00Z',
            ),
          ],
          amounts: mismatch == 'balances' ? {'merchant_reserve': '1'} : {},
        );
        repo.value = mismatch == 'reserve-cap'
            ? MerchantStatement(
                enabled: true,
                shopId: next.shopId,
                revision: next.revision,
                nextBefore: null,
                reserveCap: BigInt.one,
                accounts: next.accounts,
                entries: next.entries,
              )
            : next;
        await t.tap(find.text('Önceki hareketleri yükle'));
        await t.pumpAndSettle();
        expect(find.text('Bekleyen alacak'), findsNothing);
        expect(find.byKey(const ValueKey(statementId)), findsNothing);
        expect(
          find.textContaining('Hesap bilgileri yüklenemedi'),
          findsOneWidget,
        );
        repo.value = statementValue(enabled: false);
        await t.tap(find.text('Tekrar dene'));
        await t.pumpAndSettle();
        expect(repo.requests.last.before, isNull);
        expect(repo.requests.last.revision, isNull);
        expect(find.textContaining('kullanıma açık değil'), findsOneWidget);
      },
    );
  }
  testWidgets(
    'equal timestamps retain the servers descending ID order across pages',
    (t) async {
      repo.value = statementValue(
        next: statementOlderId,
        revision: '2',
        entries: [statementEntry(id: statementOlderId)],
      );
      await host(t);
      await t.pumpAndSettle();
      await t.scrollUntilVisible(find.text('Önceki hareketleri yükle'), 300);
      repo.value = statementValue(revision: '2');
      await t.tap(find.text('Önceki hareketleri yükle'));
      await t.pumpAndSettle();
      await t.scrollUntilVisible(find.byKey(const ValueKey(statementId)), 200);
      expect(find.byKey(const ValueKey(statementId)), findsOneWidget);
      expect(find.text('Tekrar dene'), findsNothing);
    },
  );
  testWidgets(
    'normal renewal preserves pending next page and current history',
    (t) async {
      repo.value = statementValue(next: statementId, revision: '2');
      await host(t);
      await t.pumpAndSettle();
      await t.scrollUntilVisible(find.text('Önceki hareketleri yükle'), 300);
      repo.wait = Completer();
      await t.tap(find.text('Önceki hareketleri yükle'));
      actors.add(statementUser);
      repo.keys.add('S1');
      await t.pump();
      expect(repo.requests, hasLength(2));
      expect(find.byKey(const ValueKey(statementId)), findsOneWidget);
      repo.wait!.complete(
        Right(
          statementValue(
            revision: '2',
            entries: [
              statementEntry(
                id: statementOlderId,
                stamp: '2026-10-14T10:00:00Z',
              ),
            ],
          ),
        ),
      );
      await t.pumpAndSettle();
      await t.scrollUntilVisible(
        find.byKey(const ValueKey(statementOlderId)),
        200,
      );
      expect(find.byKey(const ValueKey(statementOlderId)), findsOneWidget);
      expect(repo.requests, hasLength(2));
    },
  );
  testWidgets(
    'read timeout at narrow large text offers retry and ignores the late read',
    (t) async {
      t.view.physicalSize = const Size(320, 900);
      t.view.devicePixelRatio = 1;
      t.platformDispatcher.textScaleFactorTestValue = 1.4;
      addTearDown(() {
        t.view.resetPhysicalSize();
        t.view.resetDevicePixelRatio();
        t.platformDispatcher.clearTextScaleFactorTestValue();
      });
      repo.wait = Completer();
      final old = repo.wait!;
      await host(t, timeout: const Duration(milliseconds: 10));
      await t.pump(const Duration(milliseconds: 11));
      expect(find.text('Tekrar dene'), findsOneWidget);
      expect(find.text('0,00 TL'), findsNothing);
      repo.wait = null;
      repo.value = statementValue(enabled: false);
      await t.tap(find.text('Tekrar dene'));
      await t.pumpAndSettle();
      old.complete(Right(statementValue()));
      await t.pumpAndSettle();
      expect(find.textContaining('kullanıma açık değil'), findsOneWidget);
      expect(find.text('Bekleyen alacak'), findsNothing);
      repo.currentSessionKey = 'S2';
      repo.keys.add('S2');
      await t.pumpAndSettle();
      expect(find.textContaining('Oturumunuz değişti'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'resume replaces a pending page; its late failure cannot erase the new read',
    (t) async {
      repo.value = statementValue(next: statementId, revision: '2');
      await host(t);
      await t.pumpAndSettle();
      await t.scrollUntilVisible(find.text('Önceki hareketleri yükle'), 300);
      repo.wait = Completer();
      final old = repo.wait!;
      await t.tap(find.text('Önceki hareketleri yükle'));
      repo.wait = null;
      repo.value = statementValue(enabled: false);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await t.pumpAndSettle();
      old.completeError(StateError('synthetic late failure'));
      await t.pumpAndSettle();
      expect(repo.requests, hasLength(3));
      expect(repo.requests.last.before, isNull);
      expect(find.textContaining('kullanıma açık değil'), findsOneWidget);
      expect(find.text('Tekrar dene'), findsNothing);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('shop replacement rejects pending old-shop results', (t) async {
    repo.wait = Completer();
    final old = repo.wait!;
    await host(t);
    repo.wait = null;
    final value = statementValue(enabled: false);
    repo.value = MerchantStatement(
      enabled: false,
      shopId: statementOlderId,
      revision: null,
      nextBefore: null,
      reserveCap: null,
      accounts: value.accounts,
      entries: value.entries,
    );
    await host(t, shop: statementOlderId);
    await t.pumpAndSettle();
    old.complete(Right(statementValue()));
    await t.pumpAndSettle();
    expect(repo.requests.map((r) => r.shop), [statementShop, statementOlderId]);
    expect(find.textContaining('kullanıma açık değil'), findsOneWidget);
    expect(find.text('Bekleyen alacak'), findsNothing);
  });
  testWidgets(
    'repository replacement reads fresh data and retires old listeners',
    (t) async {
      repo.wait = Completer();
      final oldRepo = repo;
      await host(t);
      repo = SessionStatement()..value = statementValue(enabled: false);
      await host(t);
      await t.pumpAndSettle();
      oldRepo.keys.add('S2');
      oldRepo.wait!.complete(Right(statementValue()));
      await t.pumpAndSettle();
      expect(oldRepo.keys.hasListener, isFalse);
      expect(find.textContaining('kullanıma açık değil'), findsOneWidget);
      expect(find.text('Oturumunuz değişti'), findsNothing);
    },
  );
  testWidgets(
    'stream wrapper replacement preserves renewal but cannot revive expired route',
    (t) async {
      await host(t);
      await t.pumpAndSettle();
      await host(t, sessionStream: actors.stream.map((value) => value));
      await t.pumpAndSettle();
      expect(repo.requests, hasLength(1));
      repo.keys.add('S2');
      await t.pumpAndSettle();
      await host(t, sessionStream: actors.stream.map((value) => value));
      actors.add(statementUser);
      repo.keys.add('S1');
      await t.pumpAndSettle();
      expect(find.textContaining('Oturumunuz değişti'), findsOneWidget);
      expect(repo.requests, hasLength(1));
    },
  );
  testWidgets('disposal releases owned streams and ignores delayed failure', (
    t,
  ) async {
    repo.wait = Completer();
    await host(t);
    await t.pumpWidget(const SizedBox());
    await t.pump();
    expect(actors.hasListener || repo.keys.hasListener, isFalse);
    repo.wait!.completeError(StateError('synthetic late failure'));
    await t.pump();
    expect(t.takeException(), isNull);
  });
}
