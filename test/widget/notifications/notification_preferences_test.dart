import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/features/notifications/data/repositories/notification_preferences_repository.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/presentation/views/notification_preferences_view.dart';

void main() {
  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets(
      'local preferences at $width, large text, marketing opt-out persists',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repo = LocalNotificationPreferencesRepository();
        const identity = PushIdentity(
          'fixture-user',
          NotificationAppRole.customer,
        );
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
              child: Scaffold(
                body: NotificationPreferenceControls(
                  identity: identity,
                  repository: repo,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining('henüz etkin değil'), findsOneWidget);
        final toggle = find.byKey(
          const Key('notification-marketing-preference'),
        );
        expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
        await tester.ensureVisible(toggle);
        await tester.pumpAndSettle();
        await tester.tap(toggle);
        await tester.pumpAndSettle();
        expect((await repo.read(identity)).marketing, isTrue);
        await tester.tap(toggle);
        await tester.pumpAndSettle();
        expect((await repo.read(identity)).marketing, isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
