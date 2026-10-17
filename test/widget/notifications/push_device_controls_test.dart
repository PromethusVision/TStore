import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/domain/push_coordinator.dart';
import 'package:t_store/features/notifications/presentation/views/notification_preferences_view.dart';
import '../../support/push_client_fakes.dart';

class Preferences implements NotificationPreferencesRepository {
  @override
  bool serverBacked = true;
  NotificationPreferences value = const NotificationPreferences();
  Future<NotificationPreferences> Function(PushIdentity)? loading;
  Future<void> Function()? saving;
  int saves = 0;
  @override
  Future<NotificationPreferences> read(PushIdentity identity) async =>
      loading == null ? value : await loading!(identity);
  @override
  Future<void> save(PushIdentity identity, NotificationPreferences next) async {
    saves++;
    await saving?.call();
    value = next;
  }
}

void main() {
  const identity = PushIdentity('fixture-user', NotificationAppRole.merchant);
  const screen = Key('push-screen');
  late FakePushProvider provider;
  late FakePushRegistry registry;
  late PushCoordinator push;
  late Preferences preferences;
  setUpAll(() async {
    final fonts = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'));
    final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        File(
          '${artifacts.path}/material_fonts/MaterialIcons-Regular.otf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await Future.wait([fonts.load(), icons.load()]);
  });
  setUp(() {
    provider = FakePushProvider();
    registry = FakePushRegistry();
    preferences = Preferences();
    push = PushCoordinator(
      provider: provider,
      registry: registry,
      currentIdentity: () => identity,
      lookup: (_) async => null,
      onOpen: (_) {},
      installationId: 'fixture-install',
      platform: PushPlatform.android,
    );
  });
  Future<void> host(
    WidgetTester tester, {
    double width = 390,
    PushIdentity owner = identity,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      RepaintBoundary(
        key: screen,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: EsnaftaVarTheme.light,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: Scaffold(
              appBar: AppBar(title: const Text('Bildirim tercihleri')),
              body: NotificationPreferenceControls(
                identity: owner,
                repository: preferences,
                push: push,
                readTimeout: timeout,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> cleanup(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    push.dispose();
    await tester.runAsync(provider.close);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  Future<void> capture(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('MERCHANT_PUSH_CAPTURE')) return;
    final render = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(screen),
    );
    await tester.runAsync(() async {
      final image = await render.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final file = File('docs/evidence/merchant_push_client/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
    });
  }

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets(
      'pending and registered states at $width large text keep consent separate',
      (tester) async {
        provider.configured = false;
        preferences.serverBacked = false;
        await host(tester, width: width);
        await tester.pumpAndSettle();
        expect(provider.permissions, 0);
        expect(find.byKey(const Key('push-device-action')), findsNothing);
        await capture(tester, 'pending-${width.toInt()}');
        provider.configured = true;
        await host(tester, width: width);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('push-device-action')));
        await tester.pumpAndSettle();
        expect(push.status, PushClientStatus.registered);
        expect(preferences.value.marketing, isFalse);
        expect(preferences.saves, 0);
        expect(tester.takeException(), isNull);
        await capture(tester, 'registered-${width.toInt()}');
        await cleanup(tester);
      },
    );
  }
  testWidgets(
    'slow permission disables duplicate action and shows denied retry',
    (tester) async {
      final permission = Completer<PushPermission>();
      provider.permission = () => permission.future;
      await host(tester);
      await tester.pumpAndSettle();
      final action = find.byKey(const Key('push-device-action'));
      await tester.tap(action);
      await tester.pump();
      expect(tester.widget<OutlinedButton>(action).onPressed, isNull);
      permission.complete(PushPermission.denied);
      await tester.pumpAndSettle();
      expect(find.textContaining('Telefon izni alınamadı'), findsOneWidget);
      expect(provider.permissions, 1);
      await cleanup(tester);
    },
  );
  testWidgets(
    'failed disable shows cleanup action and retry clears connection',
    (tester) async {
      await host(tester);
      await tester.pumpAndSettle();
      final action = find.byKey(const Key('push-device-action'));
      await tester.tap(action);
      await tester.pumpAndSettle();
      registry.disabling = () async => throw StateError('private-error');
      await tester.tap(action);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(find.text('Bağlantıyı temizle'), findsOneWidget);
      expect(find.textContaining('private-error'), findsNothing);
      registry.disabling = null;
      await tester.tap(action);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(push.status, PushClientStatus.idle);
      await cleanup(tester);
    },
  );
  testWidgets(
    'old account preference read cannot populate a replacement widget',
    (tester) async {
      final first = Completer<NotificationPreferences>();
      preferences.loading = (owner) => owner.userId == identity.userId
          ? first.future
          : Future.value(const NotificationPreferences());
      await host(tester);
      await host(
        tester,
        owner: const PushIdentity('other-user', NotificationAppRole.merchant),
      );
      await tester.pumpAndSettle();
      first.complete(const NotificationPreferences(marketing: true));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SwitchListTile>(
              find.byKey(const Key('notification-marketing-preference')),
            )
            .value,
        isFalse,
      );
      await cleanup(tester);
    },
  );
  testWidgets(
    'read timeout offers retry; late read does not replace newer consent',
    (tester) async {
      final first = Completer<NotificationPreferences>();
      preferences.loading = (_) => first.future;
      await host(tester, timeout: const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 11));
      expect(find.text('Tekrar dene'), findsOneWidget);
      preferences.loading = (_) async => const NotificationPreferences();
      await tester.tap(find.text('Tekrar dene'));
      await tester.pumpAndSettle();
      first.complete(const NotificationPreferences(marketing: true));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SwitchListTile>(
              find.byKey(const Key('notification-marketing-preference')),
            )
            .value,
        isFalse,
      );
      await cleanup(tester);
    },
  );
  testWidgets(
    'uncertain preference write blocks duplicate and never claims success',
    (tester) async {
      final save = Completer<void>();
      preferences.saving = () => save.future;
      await host(tester);
      await tester.pumpAndSettle();
      final toggle = find.byKey(const Key('notification-marketing-preference'));
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pump();
      expect(tester.widget<SwitchListTile>(toggle).onChanged, isNull);
      expect(preferences.saves, 1);
      save.completeError(StateError('fixture'));
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
      expect(find.textContaining('Tercihler kaydedilemedi'), findsOneWidget);
      await cleanup(tester);
    },
  );
  testWidgets(
    'same-account repository replacement cannot overlap an uncertain save',
    (tester) async {
      final save = Completer<void>();
      preferences.saving = () => save.future;
      await host(tester);
      await tester.pumpAndSettle();
      final toggle = find.byKey(const Key('notification-marketing-preference'));
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pump();
      final previous = preferences;
      preferences = Preferences();
      await host(tester);
      await tester.pump();
      expect(tester.widget<SwitchListTile>(toggle).onChanged, isNull);
      expect(previous.saves, 1);
      expect(preferences.saves, 0);
      save.complete();
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(toggle).onChanged, isNotNull);
      expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
      await cleanup(tester);
    },
  );
}
