import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/auth/presentation/views/on_boarding/customer_launch_gate.dart';

void main() {
  Widget buildSubject(CustomerLaunchStatusProvider statusProvider) {
    return MaterialApp(
      home: CustomerLaunchGate(
        statusProvider: statusProvider,
        onboardingBuilder: (_) => const Scaffold(
          key: Key('onboarding-destination'),
          body: Text('Tanıtım'),
        ),
        homeBuilder: (_) => const Scaffold(
          key: Key('customer-home-destination'),
          body: Text('Ana sayfa'),
        ),
      ),
    );
  }

  testWidgets('karar beklenirken markali yuklenme durumunu gosterir', (
    tester,
  ) async {
    final status = Completer<bool>();

    await tester.pumpWidget(buildSubject(() => status.future));

    expect(find.byKey(const Key('customer-launch-loading')), findsOneWidget);
    expect(find.text('EsnaftaVar'), findsOneWidget);
    expect(tester.takeException(), isNull);

    status.complete(false);
    await tester.pumpAndSettle();
  });

  testWidgets('ilk kullanimda onboarding ekranini acar', (tester) async {
    await tester.pumpWidget(buildSubject(() async => false));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('onboarding-destination')), findsOneWidget);
    expect(find.byKey(const Key('customer-home-destination')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tamamlanan onboarding sonrasi ana sayfayi acar', (tester) async {
    await tester.pumpWidget(buildSubject(() async => true));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-home-destination')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-destination')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('yerel kayit okunamazsa urun kesfini engellemez', (tester) async {
    await tester.pumpWidget(
      buildSubject(() => Future<bool>.error(StateError('storage failed'))),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-home-destination')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-destination')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
