import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/core/common/widgets/customer_brand_logo.dart';
import 'package:t_store/features/auth/data/services/customer_onboarding_preferences.dart';
import 'package:t_store/features/auth/presentation/views/on_boarding/customer_launch_gate.dart';

void main() {
  Widget buildSubject(CustomerLaunchStatusProvider statusProvider) {
    return MaterialApp(
      home: CustomerLaunchGate(
        startupWait: () async {},
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
    expect(find.byType(CustomerBrandLogo), findsOneWidget);
    expect(find.text('Kargo bekleme, EsnaftaVar'), findsOneWidget);
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

  testWidgets(
    'cold startup lasts two seconds; auth subtree rebuild does not repeat it',
    (tester) async {
      final timing = CustomerStartupTiming();
      Widget app(Key key) => MaterialApp(
        home: CustomerLaunchGate(
          key: key,
          startupWait: timing.wait,
          statusProvider: () async => true,
          homeBuilder: (_) => const Text('ready'),
        ),
      );
      await tester.pumpWidget(app(const ValueKey(1)));
      await tester.pump(const Duration(milliseconds: 1999));
      expect(find.byType(CustomerBrandLogo), findsOneWidget);
      expect(find.text('ready'), findsNothing);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      expect(find.text('ready'), findsOneWidget);
      await tester.pumpWidget(app(const ValueKey(2)));
      await tester.pump();
      expect(find.text('ready'), findsOneWidget);
    },
  );

  testWidgets('startup completion never replaces a pushed deep link', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    final timing = CustomerStartupTiming();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        home: CustomerLaunchGate(
          startupWait: timing.wait,
          statusProvider: () async => true,
          homeBuilder: (_) => const Text('home'),
        ),
      ),
    );
    navigator.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('deep link')),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('deep link'), findsOneWidget);
    expect(find.text('home'), findsNothing);
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets(
    'default persisted completion bypasses onboarding on subsequent launch',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      Widget app(Key key) => MaterialApp(
        home: CustomerLaunchGate(
          key: key,
          startupWait: () async {},
          onboardingBuilder: (_) => const Text('first run'),
          homeBuilder: (_) => const Text('returning'),
        ),
      );
      await tester.pumpWidget(app(const ValueKey(1)));
      await tester.pumpAndSettle();
      expect(find.text('first run'), findsOneWidget);
      await CustomerOnboardingPreferences.markCompleted();
      await tester.pumpWidget(app(const ValueKey(2)));
      await tester.pumpAndSettle();
      expect(find.text('returning'), findsOneWidget);
    },
  );

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets(
      'startup at $width and large text/reduced motion does not overflow',
      (tester) async {
        tester.view.physicalSize = Size(width, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final ready = Completer<void>();
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.5),
                disableAnimations: true,
              ),
              child: child!,
            ),
            home: CustomerLaunchGate(
              startupWait: () => ready.future,
              statusProvider: () async => true,
              homeBuilder: (_) => const Text('done'),
            ),
          ),
        );
        expect(find.text('Kargo bekleme, EsnaftaVar'), findsOneWidget);
        expect(tester.takeException(), isNull);
        ready.complete();
        await tester.pumpAndSettle();
      },
    );
  }
}
