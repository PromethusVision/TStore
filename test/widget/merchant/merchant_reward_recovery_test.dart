import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';
import 'package:t_store/features/merchant/presentation/merchant_rewards.dart';
import 'package:t_store/features/rewards/domain/reward_program.dart';
import 'package:t_store/features/rewards/presentation/reward_reservation_card.dart';
import '../../support/reward_fixtures.dart';

class RecoveringReward extends RewardFake
    implements AuthenticatedSessionEvents {
  final keys = StreamController<String?>.broadcast();
  String? identity = 'S1';
  bool throwRead = false,
      throwCaps = false,
      throwWrite = false,
      throwReserve = false;
  Completer<Either<String, RewardProgramCapabilities>>? capsWait;
  @override
  String? get currentSessionKey => identity;
  @override
  Stream<String?> get sessionKeyChanges => keys.stream;
  @override
  Future<Either<String, RewardProgramCapabilities>> capabilities() {
    if (throwCaps) throw StateError('caps failed');
    return capsWait?.future ?? super.capabilities();
  }

  @override
  Future<Either<String, MerchantRewardState>> readMerchant(String shop) {
    if (throwRead) throw StateError('read failed');
    return super.readMerchant(shop);
  }

  @override
  Future<Either<String, MerchantRewardState>> setAcceptance(
    String shop,
    bool preferred,
    int revision,
  ) {
    if (throwWrite) throw StateError('write failed');
    return super.setAcceptance(shop, preferred, revision);
  }

  @override
  Future<Either<String, RewardReservation>> reserve(
    String cart, {
    bool startNew = false,
  }) {
    if (throwReserve) throw StateError('reserve failed');
    return super.reserve(cart, startNew: startNew);
  }
}

void main() {
  late RecoveringReward repo;
  late StreamController<String?> actors;
  setUp(() {
    repo = RecoveringReward();
    actors = StreamController<String?>.broadcast();
  });
  tearDown(() async {
    await actors.close();
    if (!repo.keys.isClosed) await repo.keys.close();
    await repo.progress.close();
  });
  Widget view({
    bool cart = false,
    RewardProgramRepository? repository,
    String revision = 'one',
  }) => MaterialApp(
    home: Scaffold(
      body: cart
          ? RewardReservationCard(
              repository: repository ?? repo,
              cartId: rewardId,
              revision: revision,
              currentUserId: () => rewardUser,
              sessionChanges: actors.stream,
            )
          : MerchantRewardsView(
              repository: repository ?? repo,
              shopId: rewardShop,
              ownerId: rewardUser,
              currentUserId: () => rewardUser,
              sessionChanges: actors.stream,
            ),
    ),
  );
  for (final cart in [false, true]) {
    for (final change in [
      'replacement',
      'round trip',
      'actor departure',
      'error',
      'closed',
    ]) {
      testWidgets(
        '${cart ? 'reservation' : 'merchant'} retires old session on $change',
        (t) async {
          await t.pumpWidget(view(cart: cart));
          await t.pump();
          await t.pump();
          switch (change) {
            case 'replacement':
              repo.identity = 'S2';
              repo.keys.add('S2');
            case 'round trip':
              repo.keys.add('S2');
              repo.keys.add('S1');
            case 'actor departure':
              actors.add(null);
              actors.add(rewardUser);
            case 'error':
              repo.keys.addError(StateError('observation failed'));
            case 'closed':
              unawaited(repo.keys.close());
          }
          await t.pumpAndSettle();
          expect(find.byType(SwitchListTile), findsNothing);
          expect(find.textContaining('Ödül kontenjanı ayrıldı'), findsNothing);
          expect(t.takeException(), isNull);
          await t.pumpWidget(const SizedBox());
          expect(actors.hasListener, false);
          expect(repo.keys.hasListener, false);
        },
      );
    }
  }
  for (final failing in ['caps', 'read', 'write', 'reserve']) {
    testWidgets('unexpected $failing error is retryable and contained', (
      t,
    ) async {
      repo.merchant = merchantState(forced: false, packages: false);
      repo.throwCaps = failing == 'caps';
      repo.throwRead = failing == 'read';
      repo.throwReserve = failing == 'reserve';
      await t.pumpWidget(view(cart: failing == 'reserve'));
      await t.pump();
      await t.pump();
      if (failing == 'write') {
        repo.throwWrite = true;
        await t.tap(find.byType(SwitchListTile));
      }
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(SwitchListTile), findsNothing);
      await t.pumpWidget(const SizedBox());
    });
  }
  testWidgets(
    'merchant read is bounded and late response cannot restore data',
    (t) async {
      repo.merchantWait = Completer();
      await t.pumpWidget(view());
      await t.pump();
      await t.pump(const Duration(seconds: 16));
      await t.pump();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      repo.merchantWait!.complete(Right(merchantState()));
      await t.pumpAndSettle();
      expect(find.byType(SwitchListTile), findsNothing);
      await t.pumpWidget(const SizedBox());
    },
  );
  testWidgets('repository replacement retires pending merchant read', (
    t,
  ) async {
    repo.merchantWait = Completer();
    await t.pumpWidget(view());
    await t.pump();
    final other = RecoveringReward();
    addTearDown(other.keys.close);
    addTearDown(other.progress.close);
    await t.pumpWidget(view(repository: other));
    await t.pumpAndSettle();
    expect(other.reads, 1);
    repo.merchantWait!.complete(const Left('retired failure'));
    await t.pumpAndSettle();
    expect(find.text('retired failure'), findsNothing);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('normal renewal cannot unlock a still-pending acceptance write', (
    t,
  ) async {
    repo.merchant = merchantState(forced: false, packages: false);
    repo.writeWait = Completer();
    await t.pumpWidget(view());
    await t.pumpAndSettle();
    await t.tap(find.byType(SwitchListTile));
    await t.pump();
    actors.add(rewardUser);
    repo.keys.add('S1');
    await t.pump();
    await t.pump();
    final toggle = find.byType(SwitchListTile);
    if (toggle.evaluate().isNotEmpty) {
      expect(t.widget<SwitchListTile>(toggle).onChanged, isNull);
    }
    expect(repo.reads, 1);
    repo.writeWait!.complete(
      Right(merchantState(forced: false, preferred: true, packages: false)),
    );
    await t.pumpAndSettle();
    await t.pumpWidget(const SizedBox());
  });
  testWidgets(
    'cart changes queue one latest recheck without overlapping reservation mutation',
    (t) async {
      final pending = Completer<Either<String, RewardReservation>>();
      repo.reserveWait = pending;
      await t.pumpWidget(view(cart: true));
      await t.pump();
      await t.pumpWidget(view(cart: true, revision: 'two'));
      await t.pump();
      await t.pumpWidget(view(cart: true, revision: 'three'));
      await t.pump();
      expect(repo.reservations, [false]);
      repo.reserveWait = null;
      pending.complete(Right(reservation()));
      await t.pump();
      await t.pump();
      expect(repo.reservations, [false, false]);
      await t.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'late capability response cannot dispatch owner read after deadline',
    (t) async {
      repo.capsWait = Completer();
      await t.pumpWidget(view());
      await t.pump();
      await t.pump(const Duration(seconds: 16));
      await t.pump();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      final caps = await RewardFake().capabilities();
      repo.capsWait!.complete(caps);
      await t.pumpAndSettle();
      expect(repo.reads, 0);
      expect(find.byType(SwitchListTile), findsNothing);
      await t.pumpWidget(const SizedBox());
    },
  );
  testWidgets('queued cart change is abandoned when its session retires', (
    t,
  ) async {
    repo.reserveWait = Completer();
    await t.pumpWidget(view(cart: true));
    await t.pump();
    await t.pumpWidget(view(cart: true, revision: 'changed'));
    await t.pump();
    repo.keys.add('S2');
    repo.keys.add('S1');
    await t.pump();
    repo.reserveWait!.complete(Right(reservation()));
    await t.pumpAndSettle();
    expect(repo.reservations, [false]);
    expect(find.textContaining('Ödül kontenjanı ayrıldı'), findsNothing);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets(
    'delayed reservation receipt cannot add network time to deadline',
    (t) async {
      repo.reserveWait = Completer();
      await t.pumpWidget(view(cart: true));
      await t.pump();
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1100)),
      );
      repo.reserveWait!.complete(Right(reservation(seconds: 2)));
      await t.pump();
      await t.pump();
      expect(
        find.text('Rezervasyon süresi doldu. Güncel durumu kontrol edin.'),
        findsOneWidget,
      );
      expect(repo.reservations, [false]);
      await t.pumpWidget(const SizedBox());
    },
  );
  for (final cart in [false, true]) {
    testWidgets(
      '${cart ? 'reservation' : 'merchant'} late failure after retirement never resurfaces',
      (t) async {
        if (cart) {
          repo.reserveWait = Completer();
        } else {
          repo.merchantWait = Completer();
        }
        await t.pumpWidget(view(cart: cart));
        await t.pump();
        repo.keys.add('S2');
        repo.keys.add('S1');
        await t.pump();
        if (cart) {
          repo.reserveWait!.completeError(StateError('late private error'));
        } else {
          repo.merchantWait!.completeError(StateError('late private error'));
        }
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expect(find.byType(SwitchListTile), findsNothing);
        expect(find.textContaining('late private error'), findsNothing);
        await t.pumpWidget(const SizedBox());
      },
    );
    testWidgets(
      '${cart ? 'reservation' : 'merchant'} error retry fits narrow display and larger text',
      (t) async {
        t.view.physicalSize = const Size(320, 850);
        t.view.devicePixelRatio = 1;
        t.platformDispatcher.textScaleFactorTestValue = 1.6;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
        repo.throwRead = !cart;
        repo.throwReserve = cart;
        await t.pumpWidget(view(cart: cart));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        repo.throwRead = false;
        repo.throwReserve = false;
        await t.tap(
          cart ? find.text('Durumu kontrol et') : find.byTooltip('Yenile'),
        );
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        if (!cart) {
          await t.scrollUntilVisible(
            find.byType(SwitchListTile),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await t.pumpAndSettle();
        }
        expect(
          cart
              ? find.textContaining('Ödül kontenjanı ayrıldı')
              : find.byType(SwitchListTile),
          findsOneWidget,
        );
        await t.pumpWidget(const SizedBox());
      },
    );
  }
}
