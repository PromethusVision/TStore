import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/personalization/presentation/widgets/account_deletion_confirmation_dialog.dart';

void main() {
  Widget buildSubject({required AccountDeletionSubmitter onConfirm}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            key: const Key('open-account-deletion-dialog'),
            onPressed: () => showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (_) =>
                  AccountDeletionConfirmationDialog(onConfirm: onConfirm),
            ),
            child: const Text('Hesabı Sil'),
          ),
        ),
      ),
    );
  }

  Future<void> openDialog(
    WidgetTester tester, {
    required AccountDeletionSubmitter onConfirm,
  }) async {
    await tester.pumpWidget(buildSubject(onConfirm: onConfirm));
    await tester.tap(find.byKey(const Key('open-account-deletion-dialog')));
    await tester.pumpAndSettle();
  }

  testWidgets('requires the customer to type SİL before enabling deletion', (
    tester,
  ) async {
    var submissionCount = 0;
    await openDialog(
      tester,
      onConfirm: () async {
        submissionCount += 1;
        return null;
      },
    );

    FilledButton confirmButton() => tester.widget<FilledButton>(
      find.byKey(const Key('account-deletion-confirm-button')),
    );

    expect(find.textContaining('Bu işlem geri alınamaz.'), findsOneWidget);
    expect(
      find.byKey(const Key('account-deletion-warning-card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('account-deletion-retention-note')),
      findsOneWidget,
    );
    expect(confirmButton().onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('account-deletion-confirmation-field')),
      'sil',
    );
    await tester.pump();
    expect(confirmButton().onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('account-deletion-confirm-button')));
    await tester.pumpAndSettle();

    expect(submissionCount, 1);
    expect(find.byKey(const Key('account-deletion-dialog')), findsNothing);
  });

  testWidgets('cancel closes the warning without deleting anything', (
    tester,
  ) async {
    var submissionCount = 0;
    await openDialog(
      tester,
      onConfirm: () async {
        submissionCount += 1;
        return null;
      },
    );

    final cancelAction = tester.widget<OutlinedButton>(
      find.byKey(const Key('account-deletion-cancel-button')),
    );
    cancelAction.onPressed?.call();
    cancelAction.onPressed?.call();
    await tester.pumpAndSettle();

    expect(submissionCount, 0);
    expect(find.byKey(const Key('account-deletion-dialog')), findsNothing);
    expect(
      find.byKey(const Key('open-account-deletion-dialog')),
      findsOneWidget,
    );
  });

  testWidgets('close button leaves the account untouched', (tester) async {
    var submissionCount = 0;
    await openDialog(
      tester,
      onConfirm: () async {
        submissionCount += 1;
        return null;
      },
    );

    final closeAction = tester.widget<IconButton>(
      find.byKey(const Key('account-deletion-close-button')),
    );
    closeAction.onPressed?.call();
    closeAction.onPressed?.call();
    await tester.pumpAndSettle();

    expect(submissionCount, 0);
    expect(find.byKey(const Key('account-deletion-dialog')), findsNothing);
    expect(
      find.byKey(const Key('open-account-deletion-dialog')),
      findsOneWidget,
    );
  });

  testWidgets('blocks double submit and shows progress while deleting', (
    tester,
  ) async {
    final result = Completer<String?>();
    var submissionCount = 0;
    await openDialog(
      tester,
      onConfirm: () {
        submissionCount += 1;
        return result.future;
      },
    );
    await tester.enterText(
      find.byKey(const Key('account-deletion-confirmation-field')),
      'SİL',
    );
    await tester.pump();

    final confirmAction = tester.widget<FilledButton>(
      find.byKey(const Key('account-deletion-confirm-button')),
    );
    confirmAction.onPressed?.call();
    confirmAction.onPressed?.call();
    await tester.pump();

    expect(submissionCount, 1);
    expect(find.byKey(const Key('account-deletion-progress')), findsOneWidget);
    expect(
      tester
          .widget<TextField>(
            find.byKey(const Key('account-deletion-confirmation-field')),
          )
          .enabled,
      isFalse,
    );
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const Key('account-deletion-close-button')),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<OutlinedButton>(
            find.byKey(const Key('account-deletion-cancel-button')),
          )
          .onPressed,
      isNull,
    );

    result.complete(null);
    await tester.pumpAndSettle();
  });

  testWidgets('keeps the dialog open and shows a safe retry message on error', (
    tester,
  ) async {
    await openDialog(
      tester,
      onConfirm: () async =>
          'İnternet bağlantınızı kontrol edip tekrar deneyin.',
    );
    await tester.enterText(
      find.byKey(const Key('account-deletion-confirmation-field')),
      'SİL',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('account-deletion-confirm-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('account-deletion-dialog')), findsOneWidget);
    expect(
      find.text('İnternet bağlantınızı kontrol edip tekrar deneyin.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('account-deletion-confirm-button')),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('stays scrollable without overflow on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await openDialog(tester, onConfirm: () async => null);

    expect(find.byKey(const Key('account-deletion-header')), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('account-deletion-confirm-button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hesabımı Sil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
