import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/common/widgets/production_preview_gate.dart';

void main() {
  late StreamController<void> changes;
  String? subject;
  setUp(() {
    changes = StreamController<void>.broadcast();
    subject = null;
  });
  tearDown(() => changes.close());

  Widget gate(Future<void> Function(String?) configure) =>
      ProductionPreviewGate(
        currentSubject: () => subject,
        sessionChanges: changes.stream,
        configure: configure,
        applicationBuilder: (_) =>
            const MaterialApp(home: Text('Canonical application')),
        loginBuilder: (context) => Scaffold(
          body: TextButton(
            onPressed: () {
              subject = 'tester';
              changes.add(null);
              Navigator.of(context).pop();
            },
            child: const Text('Complete existing login'),
          ),
        ),
        signOut: () async {
          subject = null;
          changes.add(null);
        },
      );

  testWidgets('anonymous gate uses existing login before authorization', (
    tester,
  ) async {
    final configured = <String?>[];
    await tester.pumpWidget(
      gate((value) async {
        configured.add(value);
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text('Canonical application'), findsNothing);
    await tester.tap(find.text('Giriş yap'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete existing login'));
    await tester.pumpAndSettle();
    expect(configured, [null, 'tester']);
    expect(find.text('Canonical application'), findsOneWidget);
  });

  testWidgets('denied capability has controlled retry and no legacy success', (
    tester,
  ) async {
    subject = 'normal';
    var calls = 0;
    await tester.pumpWidget(
      gate((_) async {
        calls++;
        throw StateError('denied');
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text('Canonical application'), findsNothing);
    expect(find.textContaining('erişimi doğrulanamadı'), findsOneWidget);
    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('Canonical application'), findsNothing);
  });

  testWidgets('logout discards the preview app and navigation', (tester) async {
    subject = 'tester';
    await tester.pumpWidget(gate((_) async {}));
    await tester.pumpAndSettle();
    expect(find.text('Canonical application'), findsOneWidget);
    subject = null;
    changes.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Canonical application'), findsNothing);
    expect(find.text('Giriş yap'), findsOneWidget);
  });

  testWidgets('account switch cannot reuse previous authorization', (
    tester,
  ) async {
    subject = 'tester';
    await tester.pumpWidget(
      gate((value) async {
        if (value != 'tester') throw StateError('denied');
      }),
    );
    await tester.pumpAndSettle();
    subject = 'normal';
    changes.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Canonical application'), findsNothing);
    expect(find.textContaining('erişimi doğrulanamadı'), findsOneWidget);
  });

  testWidgets('slow old authorization cannot reopen after logout', (
    tester,
  ) async {
    subject = 'tester';
    final pending = Completer<void>();
    await tester.pumpWidget(
      gate((value) async {
        if (value == 'tester') await pending.future;
      }),
    );
    await tester.pump();
    subject = null;
    changes.add(null);
    await tester.pump();
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.text('Canonical application'), findsNothing);
    expect(find.text('Giriş yap'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
