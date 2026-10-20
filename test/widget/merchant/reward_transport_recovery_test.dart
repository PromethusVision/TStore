import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/merchant/presentation/merchant_rewards.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/features/rewards/data/supabase_reward_program_repository.dart';
import 'package:t_store/features/rewards/domain/reward_progress.dart';
import 'package:t_store/features/rewards/presentation/reward_center.dart';
import 'package:t_store/features/rewards/presentation/reward_reservation_card.dart';
import '../../support/reward_fixtures.dart';

class RewardAuth extends MockCubit<AuthState> implements AuthCubit {}

// Subscription cancellation may use a root-zone future. Drain that event loop
// before advancing widget time, so fake deadlines cannot outrun transport cleanup.
Future<void> settle(WidgetTester t) async {
  for (var i = 0; i < 3; i++) {
    await t.pump();
    await t.runAsync(() => pumpEventQueue());
  }
  await t.pumpAndSettle();
}

void main() {
  late SupabaseClient client;
  late SupabaseRewardProgramRepository repo;
  late StreamController<String?> actors, keys;
  late Future<dynamic> Function(String, Map<String, dynamic>) respond;
  late String? identity, actor;
  final calls = <String>[];
  Map<String, dynamic> merchant({bool preferred = false, int revision = 7}) => {
    ...rewardMerchant(),
    'preferred_acceptance': preferred,
    'forced_acceptance': false,
    'effective_acceptance': preferred,
    'preference_revision': revision,
    'packages': [],
  };
  // Keep SDK/transport lifecycle on the real event loop and drain it explicitly
  // between frames; fake clock advancement must not manufacture transport loss.
  Future<void> setUpHarness(WidgetTester t) async {
    t.view.physicalSize = const Size(390, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(() async {
      await t.pumpWidget(const SizedBox());
      await t.runAsync(() => pumpEventQueue());
      await t.runAsync(() async {
        await actors.close();
        await keys.close();
        await client.dispose();
      });
      t.view.resetPhysicalSize();
      t.view.resetDevicePixelRatio();
    });
    await t.runAsync(() async {
      calls.clear();
      identity = 'S1';
      actor = rewardUser;
      actors = StreamController<String?>.broadcast();
      keys = StreamController<String?>.broadcast();
      client = SupabaseClient(
        'http://127.0.0.1:1',
        'synthetic-reward-only',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
      respond = (name, args) async => name == 'reward_capabilities_v1'
          ? rewardCaps()
          : name == 'read_reward_state_v1'
          ? rewardCustomer()
          : merchant();
      repo = SupabaseRewardProgramRepository(
        client,
        currentUserId: () => actor,
        sessionIdentity: () => identity,
        sessionChanges: actors.stream,
        sessionKeyChanges: keys.stream,
        pollInterval: const Duration(hours: 1),
        rpc: (name, args) {
          calls.add(name);
          return respond(name, args);
        },
      );
    });
  }

  Widget page({Key? key}) => MaterialApp(
    home: MerchantRewardsView(
      key: key,
      repository: repo,
      shopId: rewardShop,
      ownerId: rewardUser,
      currentUserId: () => actor,
      sessionChanges: actors.stream,
    ),
  );

  testWidgets(
    'reopening waits for pending preference and then shows authoritative receipt',
    (t) async {
      await setUpHarness(t);
      final pending = Completer<dynamic>();
      var preferred = false;
      var revision = 7;
      respond = (name, args) async {
        if (name == 'reward_capabilities_v1') return rewardCaps();
        if (name.startsWith('set_')) return pending.future;
        return merchant(preferred: preferred, revision: revision);
      };
      await t.pumpWidget(page(key: const ValueKey('first')));
      await settle(t);
      expect(
        find.byType(SwitchListTile),
        findsOneWidget,
        reason:
            'RPCs: $calls; screen: ${t.widgetList<Text>(find.byType(Text)).map((w) => w.data).toList()}',
      );
      await t.tap(find.byType(SwitchListTile));
      await t.pump();
      await t.pumpWidget(page(key: const ValueKey('reopened')));
      await t.pump();
      await t.pump();
      expect(calls.where((c) => c == 'read_merchant_reward_v1').length, 1);
      expect(find.byType(SwitchListTile), findsNothing);
      preferred = true;
      revision = 8;
      pending.complete(merchant(preferred: true, revision: 8));
      await settle(t);
      expect(t.widget<SwitchListTile>(find.byType(SwitchListTile)).value, true);
      expect(calls.where((c) => c.startsWith('set_')).length, 1);
      expect(calls.where((c) => c == 'read_merchant_reward_v1').length, 2);
      await t.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'lost acknowledgement hides toggle until explicit owner read; no write replay',
    (t) async {
      await setUpHarness(t);
      var preferred = false;
      var revision = 7;
      respond = (name, args) async {
        if (name == 'reward_capabilities_v1') return rewardCaps();
        if (name.startsWith('set_')) {
          preferred = true;
          revision = 8;
          throw StateError('synthetic lost receipt');
        }
        return merchant(preferred: preferred, revision: revision);
      };
      await t.pumpWidget(page());
      await settle(t);
      await t.tap(find.byType(SwitchListTile));
      await settle(t);
      expect(find.byType(SwitchListTile), findsNothing);
      await t.tap(find.byTooltip('Yenile'));
      await settle(t);
      expect(t.widget<SwitchListTile>(find.byType(SwitchListTile)).value, true);
      expect(calls.where((c) => c.startsWith('set_')).length, 1);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
    },
  );
  for (final change in ['replacement', 'round trip', 'renewal']) {
    testWidgets('navigation origin protects first mount during $change', (
      t,
    ) async {
      await setUpHarness(t);
      final preview = MerchantPreview();
      addTearDown(preview.dispose);
      final s = preview.services;
      final services = MerchantServices(
        merchants: s.merchants,
        credentials: s.credentials,
        notifications: s.notifications,
        qr: s.qr,
        preferences: s.preferences,
        currentUserId: () => actor,
        sessionChanges: actors.stream,
        rewardProgram: repo,
      );
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MerchantRewardEntry(
              services: services,
              access: MerchantAccess(
                user: const UserEntity(
                  id: rewardUser,
                  email: 'fixture@example.test',
                  role: UserEntity.merchantRole,
                ),
                shop: preview.repository.shop,
              ),
            ),
          ),
        ),
      );
      await settle(t);
      await t.tap(find.text('Yönlendirme paketi'));
      if (change == 'replacement') {
        identity = 'S2';
        keys.add('S2');
      }
      if (change == 'round trip') {
        keys.add('S2');
        keys.add('S1');
      }
      if (change == 'renewal') {
        actors.add(rewardUser);
        keys.add('S1');
      }
      await settle(t);
      expect(
        find.byType(SwitchListTile),
        change == 'renewal' ? findsOneWidget : findsNothing,
      );
      expect(calls.contains('read_merchant_reward_v1'), change == 'renewal');
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
    });
  }
  testWidgets(
    'home counter and center recover same account session and keep following refresh',
    (t) async {
      await setUpHarness(t);
      await sl.reset();
      addTearDown(sl.reset);
      sl.registerSingleton<RewardRepository>(repo);
      final auth = RewardAuth();
      whenListen(
        auth,
        const Stream<AuthState>.empty(),
        initialState: const AuthAuthenticated(
          UserEntity(id: rewardUser, email: 'fixture@example.test'),
        ),
      );
      var count = 1;
      respond = (name, args) async => {
        ...rewardCustomer(),
        'pending_count': count,
        'pending_minor': '${count * 5000}',
      };
      await t.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: auth,
            child: Scaffold(
              body: HomeRewardCounter(currentUserIdProvider: () => actor),
            ),
          ),
        ),
      );
      await settle(t);
      expect(find.text('1 / 5'), findsOneWidget);
      identity = 'S2';
      count = 2;
      actors.add(rewardUser);
      keys.add('S2');
      await settle(t);
      expect(find.text('2 / 5'), findsOneWidget);
      count = 3;
      repo.refresh();
      await settle(t);
      expect(find.text('3 / 5'), findsOneWidget);
      await t.pumpWidget(
        MaterialApp(
          home: RewardCenter(repository: repo, customerId: rewardUser),
        ),
      );
      await settle(t);
      expect(find.textContaining('150,00 TL'), findsOneWidget);
      actor = null;
      identity = null;
      actors.add(null);
      keys.add(null);
      await settle(t);
      expect(find.textContaining('150,00 TL'), findsNothing);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'reopened reservation refuses overlap then safely rechecks same attempt',
    (t) async {
      await setUpHarness(t);
      final pending = Completer<dynamic>();
      var first = true;
      final starts = <bool>[];
      respond = (name, args) async {
        starts.add(args['p_start_new'] as bool);
        if (first) {
          first = false;
          return pending.future;
        }
        return {'status': 'no_capacity', 'server_now': rewardNow};
      };
      Widget cart(String key) => MaterialApp(
        home: Scaffold(
          body: RewardReservationCard(
            key: ValueKey(key),
            repository: repo,
            cartId: rewardId,
            revision: 'one',
            currentUserId: () => actor,
            sessionChanges: actors.stream,
          ),
        ),
      );
      await t.pumpWidget(cart('first'));
      await t.pump();
      await t.pumpWidget(cart('reopen'));
      await settle(t);
      expect(starts, [false]);
      expect(find.text('Durumu kontrol et'), findsOneWidget);
      pending.complete({'status': 'no_capacity', 'server_now': rewardNow});
      await settle(t);
      await t.tap(find.text('Durumu kontrol et'));
      await settle(t);
      expect(starts, [false, false]);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
    },
  );
}
