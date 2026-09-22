import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/common/widgets/production_public_gate.dart';

void main() {
  late StreamController<void> changes;
  setUp(() => changes = StreamController<void>.broadcast());
  tearDown(() => changes.close());
  Widget gate(Future<void> Function(VoidCallback) configure) =>
      ProductionPublicGate(
        changes: changes.stream,
        configure: configure,
        invalidate: () {},
        applicationBuilder: (_) =>
            const MaterialApp(home: Text('Public catalog')),
      );
  testWidgets('anonymous publication opens directly without login or tester', (
    tester,
  ) async {
    await tester.pumpWidget(gate((_) async {}));
    await tester.pumpAndSettle();
    expect(find.text('Public catalog'), findsOneWidget);
    expect(find.text('Giriş yap'), findsNothing);
  });
  testWidgets('OFF failure shows retry without a legacy app', (tester) async {
    await tester.pumpWidget(
      gate((_) async {
        throw StateError('off');
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text('Public catalog'), findsNothing);
    expect(find.text('Tekrar dene'), findsOneWidget);
  });
  testWidgets('server unavailable removes catalog and its navigation', (
    tester,
  ) async {
    late VoidCallback reject;
    await tester.pumpWidget(
      gate((callback) async {
        reject = callback;
      }),
    );
    await tester.pumpAndSettle();
    reject();
    await tester.pumpAndSettle();
    expect(find.text('Public catalog'), findsNothing);
    expect(find.text('Tekrar dene'), findsOneWidget);
  });
  testWidgets('stale failure from old session cannot close new session', (
    tester,
  ) async {
    final callbacks = <VoidCallback>[];
    await tester.pumpWidget(
      gate((callback) async {
        callbacks.add(callback);
      }),
    );
    await tester.pumpAndSettle();
    changes.add(null);
    await tester.pumpAndSettle();
    expect(callbacks.length, 2);
    callbacks.first();
    await tester.pumpAndSettle();
    expect(find.text('Public catalog'), findsOneWidget);
    callbacks.last();
    await tester.pumpAndSettle();
    expect(find.text('Public catalog'), findsNothing);
  });
  testWidgets('slow success cannot reopen after a newer failed session', (
    tester,
  ) async {
    final old = Completer<void>();
    var count = 0;
    await tester.pumpWidget(
      gate((_) async {
        count++;
        if (count == 1) {
          await old.future;
        } else {
          throw StateError('off');
        }
      }),
    );
    await tester.pump();
    changes.add(null);
    await tester.pump();
    old.complete();
    await tester.pumpAndSettle();
    expect(find.text('Public catalog'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
