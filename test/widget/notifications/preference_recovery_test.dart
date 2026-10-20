import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/domain/repositories/notification_repository.dart';
import 'package:t_store/features/notifications/presentation/views/notification_preferences_view.dart';

class Preferences
    implements NotificationPreferencesRepository, NotificationSessionSource {
  @override
  bool get serverBacked => true;
  @override
  String? currentUserId = 'fixture';
  @override
  String? currentSessionKey = 'S1';
  final sessions = StreamController<String?>.broadcast(sync: true);
  @override
  Stream<String?> get sessionKeyChanges => sessions.stream;
  NotificationPreferences value = const NotificationPreferences();
  Future<NotificationPreferences> Function()? loading;
  Future<void> Function(NotificationPreferences)? saving;
  int reads = 0, writes = 0;
  @override
  Future<NotificationPreferences> read(PushIdentity identity) async {
    reads++;
    return loading == null ? value : loading!();
  }

  @override
  Future<void> save(PushIdentity identity, NotificationPreferences next) async {
    writes++;
    if (saving != null) return saving!(next);
    value = next;
  }
}

void main() {
  const identity = PushIdentity('fixture', NotificationAppRole.merchant);
  final toggle = find.byKey(const Key('notification-marketing-preference'));
  Future<void> host(WidgetTester tester, Preferences repo) async {
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(repo.sessions.close);
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationPreferenceControls(
            identity: identity,
            repository: repo,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'lost save acknowledgement requires authoritative read before another edit',
    (tester) async {
      final repo = Preferences();
      repo.saving = (next) async {
        repo.value = next;
        throw StateError('synthetic lost acknowledgement');
      };
      await host(tester, repo);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
      expect(tester.widget<SwitchListTile>(toggle).onChanged, isNull);
      expect(find.text('Kaydı kontrol et'), findsOneWidget);
      await tester.tap(find.text('Kaydı kontrol et'));
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
      expect(tester.widget<SwitchListTile>(toggle).onChanged, isNotNull);
      expect(repo.writes, 1);
      expect(repo.reads, 2);
    },
  );
  for (final replace in [false, true]) {
    testWidgets(
      'preference state ${replace ? 'expires on replacement' : 'survives normal renewal'}',
      (tester) async {
        final repo = Preferences();
        await host(tester, repo);
        repo.currentSessionKey = replace ? 'S2' : 'S1';
        repo.sessions.add(repo.currentSessionKey);
        await tester.pumpAndSettle();
        expect(toggle, replace ? findsNothing : findsOneWidget);
        if (replace) {
          expect(find.textContaining('Oturumunuz değişti'), findsOneWidget);
        }
        expect(repo.writes, 0);
      },
    );
  }
  testWidgets('failed reconciliation remains locked and never replays save', (
    tester,
  ) async {
    final repo = Preferences();
    repo.saving = (_) async => throw StateError('synthetic unknown result');
    await host(tester, repo);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    repo.loading = () async => throw StateError('synthetic offline');
    await tester.tap(find.text('Kaydı kontrol et'));
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(toggle).onChanged, isNull);
    expect(find.textContaining('Tercihler yüklenemedi'), findsOneWidget);
    expect(repo.writes, 1);
    repo.loading = () async => const NotificationPreferences(marketing: true);
    await tester.tap(find.text('Kaydı kontrol et'));
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
    expect(tester.widget<SwitchListTile>(toggle).onChanged, isNotNull);
    expect(repo.writes, 1);
  });
  testWidgets(
    'pending save survives normal refresh and ignores duplicate callbacks',
    (tester) async {
      final repo = Preferences();
      final gate = Completer<void>();
      repo.saving = (_) => gate.future;
      await host(tester, repo);
      final change = tester.widget<SwitchListTile>(toggle).onChanged!;
      change(true);
      change(true);
      repo.sessions.add('S1');
      await tester.pump();
      expect(tester.widget<SwitchListTile>(toggle).onChanged, isNull);
      expect(repo.writes, 1);
      gate.complete();
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
      expect(tester.widget<SwitchListTile>(toggle).onChanged, isNotNull);
    },
  );
  for (final transition in [
    'replacement',
    'signout',
    'account',
    'error',
    'done',
    'S1-S2-S1',
  ]) {
    for (final pending in ['read', 'write']) {
      testWidgets('$transition fences pending $pending and its late result', (
        tester,
      ) async {
        final repo = Preferences();
        final read = Completer<NotificationPreferences>();
        final write = Completer<void>();
        await host(tester, repo);
        if (pending == 'write') {
          repo.saving = (_) => write.future;
          await tester.tap(toggle);
        } else {
          // Reach explicit reread with a still-pending network response.
          repo.saving = (_) async => throw StateError('synthetic');
          await tester.tap(toggle);
          await tester.pumpAndSettle();
          repo.loading = () => read.future;
          await tester.tap(find.text('Kaydı kontrol et'));
        }
        await tester.pump();
        switch (transition) {
          case 'replacement':
            repo.currentSessionKey = 'S2';
            repo.sessions.add('S2');
          case 'signout':
            repo.currentUserId = null;
            repo.currentSessionKey = null;
            repo.sessions.add(null);
          case 'account':
            repo.currentUserId = 'other';
            repo.sessions.add('S1');
          case 'error':
            repo.sessions.addError(StateError('synthetic observer error'));
          case 'done':
            await tester.runAsync(repo.sessions.close);
          case 'S1-S2-S1':
            repo.sessions.add('S2');
            repo.sessions.add('S1');
        }
        await tester.pump();
        expect(toggle, findsNothing);
        expect(find.textContaining('Oturumunuz değişti'), findsOneWidget);
        if (pending == 'write') {
          write.completeError(StateError('synthetic late failure'));
        } else {
          read.complete(const NotificationPreferences(marketing: true));
        }
        await tester.pumpAndSettle();
        expect(toggle, findsNothing);
        expect(find.textContaining('Tercihler yüklenemedi'), findsNothing);
        expect(find.textContaining('Kayıt sonucu doğrulanamadı'), findsNothing);
        expect(tester.takeException(), isNull);
        expect(repo.writes, 1);
      });
    }
  }
  testWidgets(
    'close and reopen reads current server value after lost acknowledgement',
    (tester) async {
      final repo = Preferences();
      final gate = Completer<void>();
      repo.saving = (next) async {
        await gate.future;
        repo.value = next;
        throw StateError('synthetic lost acknowledgement');
      };
      await host(tester, repo);
      await tester.tap(toggle);
      await tester.pumpWidget(const SizedBox());
      gate.complete();
      await tester.pump();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationPreferenceControls(
              identity: identity,
              repository: repo,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
      expect(repo.writes, 1);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'narrow large-text recovery view shows loading, error and retry without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = Preferences();
      final gate = Completer<NotificationPreferences>();
      repo.loading = () => gate.future;
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(repo.sessions.close);
      });
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
            child: Scaffold(
              body: NotificationPreferenceControls(
                identity: identity,
                repository: repo,
              ),
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      gate.completeError(StateError('synthetic offline'));
      await tester.pumpAndSettle();
      expect(find.text('Tekrar dene'), findsOneWidget);
      repo.loading = () async => const NotificationPreferences();
      await tester.tap(find.text('Tekrar dene'));
      await tester.pumpAndSettle();
      repo.saving = (_) async => throw StateError('synthetic unknown write');
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Kaydı kontrol et'), 200);
      expect(find.text('Kaydı kontrol et').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Kaydı kontrol et'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(toggle, -200);
      expect(tester.widget<SwitchListTile>(toggle).onChanged, isNotNull);
      expect(tester.takeException(), isNull);
    },
  );
}
