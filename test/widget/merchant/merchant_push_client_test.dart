import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/merchant/merchant_app.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/domain/push_coordinator.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import '../../support/push_client_fakes.dart';

void main() {
  late MerchantPreview preview;
  late FakePushProvider provider;
  late FakePushRegistry registry;
  Future<void> host(WidgetTester tester) async {
    preview = MerchantPreview();
    provider = FakePushProvider();
    registry = FakePushRegistry();
    final base = preview.services;
    await tester.pumpWidget(
      MerchantApp(
        services: MerchantServices(
          merchants: base.merchants,
          credentials: base.credentials,
          notifications: base.notifications,
          qr: base.qr,
          preferences: base.preferences,
          sessionChanges: base.sessionChanges,
          currentUserId: base.currentUserId,
          preview: true,
          pushProvider: provider,
          pushFactory: (onOpen) => PushCoordinator(
            provider: provider,
            registry: registry,
            currentIdentity: () => preview.currentId == null
                ? null
                : PushIdentity(
                    preview.currentId!,
                    NotificationAppRole.merchant,
                  ),
            lookup: (id) async => NotificationEntity(
              id: id,
              userId: MerchantPreview.userId,
              title: 'Fixture',
              body: 'Fixture',
              type: NotificationType.system,
              data: const {'app_role': 'merchant', 'target_type': 'admin'},
            ),
            onOpen: onOpen,
            installationId: 'fixture-install',
            platform: PushPlatform.android,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> cleanup(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await provider.close();
      await preview.dispose();
    });
  }

  Future<void> settings(WidgetTester tester) async {
    await tester.tap(find.text('Hesap').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bildirim tercihleri'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'host starts silently and validated tap returns nested editor to shared inbox',
    (tester) async {
      await host(tester);
      expect(provider.permissions, 0);
      await settings(tester);
      await tester.tap(find.byKey(const Key('push-device-action')));
      await tester.pumpAndSettle();
      provider.taps.add(
        const PushOpenEvent(
          notificationId: 'fixture-notification',
          identity: PushIdentity(
            MerchantPreview.userId,
            NotificationAppRole.merchant,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bildirim tercihleri'), findsNothing);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        3,
      );
      expect(find.textContaining('admin'), findsNothing);
      await cleanup(tester);
    },
  );
  testWidgets(
    'logout waits for revocation; failed revocation keeps authenticated account',
    (tester) async {
      await host(tester);
      await settings(tester);
      await tester.tap(find.byKey(const Key('push-device-action')));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      final pending = Completer<void>();
      registry.disabling = () => pending.future;
      await tester.tap(find.text('Çıkış yap'));
      await tester.pump();
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
      expect(registry.disabled, hasLength(1));
      expect(preview.currentId, MerchantPreview.userId);
      pending.completeError(StateError('fixture'));
      await tester.pumpAndSettle();
      expect(preview.currentId, MerchantPreview.userId);
      expect(
        find.textContaining('Güvenli çıkış tamamlanamadı'),
        findsOneWidget,
      );
      registry.disabling = null;
      await tester.tap(find.text('Çıkış yap'));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(preview.currentId, isNull);
      expect(provider.deleted, 1);
      await cleanup(tester);
    },
  );
  testWidgets(
    'external A logout A between frames invalidates old provider listeners',
    (tester) async {
      await host(tester);
      await settings(tester);
      await tester.tap(find.byKey(const Key('push-device-action')));
      await tester.pumpAndSettle();
      preview.currentId = null;
      preview.changes.add(null);
      preview.currentId = MerchantPreview.userId;
      preview.changes.add(preview.currentId);
      await tester.pumpAndSettle();
      provider.taps.add(
        const PushOpenEvent(
          notificationId: 'fixture-notification',
          identity: PushIdentity(
            MerchantPreview.userId,
            NotificationAppRole.merchant,
          ),
        ),
      );
      provider.tokens.add('stale-token');
      await tester.pumpAndSettle();
      expect(registry.registrations, hasLength(1));
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0,
      );
      await cleanup(tester);
    },
  );
}
