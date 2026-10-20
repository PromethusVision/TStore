import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';
import 'package:t_store/features/trust_commerce/domain/trust_commerce.dart';
import 'package:t_store/features/trust_commerce/presentation/trust_views.dart';
import 'package:t_store/features/trust_commerce/preview/trust_commerce_preview.dart';

class ReadTrust extends PreviewTrustCommerceRepository
    implements AuthenticatedSessionEvents {
  ReadTrust(this.events)
    : super(user: () => previewTrustActor, sessionChanges: events.stream);
  final StreamController<String?> events;
  final keys = StreamController<String?>.broadcast();
  String? keyValue = 'S1';
  @override
  String? get currentSessionKey => keyValue;
  @override
  Stream<String?> get sessionKeyChanges => keys.stream;
  final cursors = <int?>[], shops = <String?>[];
  Future<Either<TrustFailure, TrustSnapshot>> Function(int?)? read;
  Future<Either<TrustFailure, List<TrustBadge>>> Function()? publicBadges;
  Future<Either<TrustFailure, List<Campaign>>> Function()? publicOffers;
  @override
  Future<Either<TrustFailure, List<TrustBadge>>> shopBadges(String shopId) =>
      publicBadges?.call() ?? Future.value(Right(page().badges));
  @override
  Future<Either<TrustFailure, List<Campaign>>> shopCampaigns(String shopId) =>
      publicOffers?.call() ?? Future.value(const Right([]));
  @override
  Future<Either<TrustFailure, TrustSnapshot>> trust({
    String? shopId,
    int? before,
  }) {
    cursors.add(before);
    shops.add(shopId);
    return read?.call(before) ?? Future.value(Right(page()));
  }
}

TrustSnapshot page({
  String title = 'Güvenilir esnaf',
  int id = 90,
  int? next = 90,
  bool enabled = true,
}) => TrustSnapshot(
  enabled: enabled,
  nextBefore: next,
  badges: [
    TrustBadge(
      code: 'friendliness',
      family: 'friendliness',
      level: 1,
      title: title,
      explanation: 'Doğrulanmış deneyim.',
      eligible: true,
    ),
  ],
  history: [
    TrustEvent(
      id,
      'friendliness',
      'awarded',
      'qualification_changed',
      DateTime(2026, 10, 15),
    ),
  ],
);
const failure = TrustFailure(TrustFailureKind.unavailable, 'Bağlantı kesildi');

void main() {
  late StreamController<String?> actors;
  late ReadTrust repo;
  setUp(() {
    actors = StreamController<String?>.broadcast();
    repo = ReadTrust(actors);
  });
  tearDown(() async {
    await actors.close();
    if (!repo.keys.isClosed) await repo.keys.close();
  });
  testWidgets('public badges clear and reload when repository changes', (
    tester,
  ) async {
    Widget publicView(ReadTrust value) => MaterialApp(
      home: Scaffold(
        body: ShopTrustOffers(repository: value, shopId: previewTrustShop),
      ),
    );
    await tester.pumpWidget(publicView(repo));
    await tester.pumpAndSettle();
    expect(find.text('Güvenilir esnaf'), findsOneWidget);
    final replacement = ReadTrust(actors);
    addTearDown(replacement.keys.close);
    final pending = Completer<Either<TrustFailure, List<TrustBadge>>>();
    replacement.publicBadges = () => pending.future;
    await tester.pumpWidget(publicView(replacement));
    await tester.pump();
    expect(find.text('Güvenilir esnaf'), findsNothing);
    pending.complete(Right(page(title: 'Yeni kaynak').badges));
    await tester.pumpAndSettle();
    expect(find.text('Yeni kaynak'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('public parallel read failures are contained and retryable', (
    tester,
  ) async {
    repo.publicBadges = () async => throw StateError('badges failed');
    repo.publicOffers = () async => throw StateError('offers failed');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShopTrustOffers(repository: repo, shopId: previewTrustShop),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Tekrar dene'), findsOneWidget);
    repo.publicBadges = () async => Right(page().badges);
    repo.publicOffers = () async => const Right([]);
    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();
    expect(find.text('Güvenilir esnaf'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('public timeout allows retry and excludes retired responses', (
    tester,
  ) async {
    final pending = Completer<Either<TrustFailure, List<TrustBadge>>>();
    repo.publicBadges = () => pending.future;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShopTrustOffers(
            repository: repo,
            shopId: previewTrustShop,
            readTimeout: const Duration(seconds: 1),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('Tekrar dene'), findsOneWidget);
    repo.publicBadges = () async => Right(page(title: 'Güncel rozet').badges);
    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();
    pending.complete(Right(page(title: 'Eski rozet').badges));
    await tester.pumpAndSettle();
    expect(find.text('Güncel rozet'), findsOneWidget);
    expect(find.text('Eski rozet'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('private summary all-badges dialog expires at narrow width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    repo.read = (_) async => const Right(
      TrustSnapshot(
        enabled: true,
        badges: PreviewTrustCommerceRepository.badges,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrustSummary(
            repository: repo,
            actor: previewTrustActor,
            shopId: previewTrustShop,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('+1'));
    await tester.pumpAndSettle();
    expect(find.text('Rozetler'), findsOneWidget);
    repo.keys.add('S2');
    repo.keys.add('S1');
    await tester.pumpAndSettle();
    expect(find.text('Rozetler'), findsNothing);
    expect(find.widgetWithText(AlertDialog, 'Oturum değişti'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  Widget view({
    bool summary = false,
    String shop = previewTrustShop,
    ReadTrust? repository,
  }) => MaterialApp(
    home: summary
        ? Scaffold(
            body: TrustSummary(
              repository: repository ?? repo,
              actor: previewTrustActor,
              shopId: shop,
            ),
          )
        : TrustDetailView(
            repository: repository ?? repo,
            actor: previewTrustActor,
            shopId: shop,
          ),
  );
  for (final summary in [true, false]) {
    testWidgets(
      '${summary ? 'summary' : 'detail'} expires on closed key observation and releases listeners',
      (tester) async {
        await tester.pumpWidget(view(summary: summary));
        await tester.pumpAndSettle();
        expect(repo.keys.hasListener, true);
        unawaited(repo.keys.close());
        await tester.pumpAndSettle();
        expect(find.text('Güvenilir esnaf'), findsNothing);
        actors.add(previewTrustActor);
        await tester.pumpAndSettle();
        expect(find.text('Güvenilir esnaf'), findsNothing);
        await tester.pumpWidget(const SizedBox());
        expect(actors.hasListener, false);
      },
    );
    testWidgets(
      '${summary ? 'summary' : 'detail'} bounds reads at narrow width and ignores late completion',
      (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final pending = Completer<Either<TrustFailure, TrustSnapshot>>();
        repo.read = (_) => pending.future;
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.4)),
              child: child!,
            ),
            home: summary
                ? Scaffold(
                    body: TrustSummary(
                      repository: repo,
                      actor: previewTrustActor,
                      readTimeout: const Duration(seconds: 1),
                    ),
                  )
                : TrustDetailView(
                    repository: repo,
                    actor: previewTrustActor,
                    readTimeout: const Duration(seconds: 1),
                  ),
          ),
        );
        await tester.pump(const Duration(seconds: 2));
        await tester.pump();
        expect(find.text('Tekrar dene'), findsOneWidget);
        repo.read = (_) async => Right(page(title: 'Güncel rozet', next: null));
        await tester.tap(find.text('Tekrar dene'));
        await tester.pumpAndSettle();
        pending.complete(Right(page(title: 'Eski rozet')));
        await tester.pumpAndSettle();
        expect(find.text('Güncel rozet'), findsWidgets);
        expect(find.text('Eski rozet'), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
    testWidgets(
      '${summary ? 'summary' : 'detail'} expires when repository is replaced',
      (tester) async {
        await tester.pumpWidget(view(summary: summary));
        await tester.pumpAndSettle();
        final replacement = ReadTrust(actors);
        addTearDown(replacement.keys.close);
        await tester.pumpWidget(
          view(summary: summary, repository: replacement),
        );
        await tester.pumpAndSettle();
        expect(find.text('Güvenilir esnaf'), findsNothing);
        expect(replacement.cursors, isEmpty);
        await tester.pumpWidget(const SizedBox());
      },
    );
    testWidgets(
      '${summary ? 'summary' : 'detail'} rejects captured replacement',
      (tester) async {
        await tester.pumpWidget(view(summary: summary));
        await tester.pumpAndSettle();
        expect(find.text('Güvenilir esnaf'), findsWidgets);
        repo.keys.add('S2');
        repo.keys.add('S1');
        await tester.pumpAndSettle();
        expect(find.text('Güvenilir esnaf'), findsNothing);
        await tester.pumpWidget(const SizedBox());
      },
    );
    testWidgets(
      '${summary ? 'summary' : 'detail'} clears on key observer failure',
      (tester) async {
        await tester.pumpWidget(view(summary: summary));
        await tester.pumpAndSettle();
        repo.keys.addError(StateError('observer stopped'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Güvenilir esnaf'), findsNothing);
        await tester.pumpWidget(const SizedBox());
      },
    );
    testWidgets('${summary ? 'summary' : 'detail'} preserves normal renewal', (
      tester,
    ) async {
      await tester.pumpWidget(view(summary: summary));
      await tester.pumpAndSettle();
      actors.add(previewTrustActor);
      repo.keys.add('S1');
      await tester.pumpAndSettle();
      expect(find.text('Güvenilir esnaf'), findsWidgets);
      expect(repo.cursors, [null]);
      await tester.pumpWidget(const SizedBox());
    });
    testWidgets(
      '${summary ? 'summary' : 'detail'} catches thrown reads and offers retry',
      (tester) async {
        repo.read = (_) async => throw StateError('transport unavailable');
        await tester.pumpWidget(view(summary: summary));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('Tekrar dene'), findsOneWidget);
        repo.read = (_) async => Right(page());
        await tester.tap(find.text('Tekrar dene'));
        await tester.pumpAndSettle();
        expect(find.text('Güvenilir esnaf'), findsWidgets);
        await tester.pumpWidget(const SizedBox());
      },
    );
    testWidgets(
      '${summary ? 'summary' : 'detail'} changes shop without exposing old summary',
      (tester) async {
        await tester.pumpWidget(view(summary: summary));
        await tester.pumpAndSettle();
        final pending = Completer<Either<TrustFailure, TrustSnapshot>>();
        repo.read = (_) => pending.future;
        await tester.pumpWidget(
          view(summary: summary, shop: previewCampaignId),
        );
        await tester.pump();
        expect(find.text('Güvenilir esnaf'), findsNothing);
        expect(repo.shops.last, previewCampaignId);
        pending.complete(Right(page(title: 'Yeni mağaza')));
        await tester.pumpAndSettle();
        expect(find.text('Yeni mağaza'), findsWidgets);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  testWidgets(
    'private badge explanation expires with its originating session',
    (tester) async {
      await tester.pumpWidget(view());
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Güvenilir esnaf koşulları'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Doğrulanmış deneyim.'), findsOneWidget);
      repo.keys.add('S2');
      repo.keys.add('S1');
      await tester.pumpAndSettle();
      expect(find.textContaining('Doğrulanmış deneyim.'), findsNothing);
      expect(
        find.widgetWithText(AlertDialog, 'Oturum değişti'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
  for (final malformed in ['overlap', 'backward-cursor']) {
    testWidgets('history refuses $malformed and retries fresh state', (
      tester,
    ) async {
      await tester.pumpWidget(view());
      await tester.pumpAndSettle();
      repo.read = (_) async =>
          Right(page(id: malformed == 'overlap' ? 90 : 80, next: 90));
      await tester.tap(find.text('Önceki değişiklikler'));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNothing);
      expect(find.text('Tekrar dene'), findsOneWidget);
      repo.read = (_) async => Right(page(next: null));
      await tester.tap(find.text('Tekrar dene'));
      await tester.pumpAndSettle();
      expect(repo.cursors, [null, 90, null]);
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets(
    'failed history page retries the same cursor and preserves loaded history',
    (tester) async {
      repo.read = (before) async =>
          before == null ? Right(page()) : const Left(failure);
      await tester.pumpWidget(view());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Önceki değişiklikler'));
      await tester.pumpAndSettle();
      repo.read = (before) async => Right(page(id: 80, next: null));
      await tester.tap(find.text('Tekrar dene'));
      await tester.pumpAndSettle();
      expect(repo.cursors, [null, 90, 90]);
      expect(find.byType(ListTile), findsNWidgets(2));
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'disabled page clears old history instead of keeping pagination actionable',
    (tester) async {
      await tester.pumpWidget(view());
      await tester.pumpAndSettle();
      repo.read = (_) async => const Right(TrustSnapshot(enabled: false));
      await tester.tap(find.text('Önceki değişiklikler'));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNothing);
      expect(find.text('Önceki değişiklikler'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('resume replaces a pending page and ignores its late result', (
    tester,
  ) async {
    await tester.pumpWidget(view());
    await tester.pumpAndSettle();
    final pending = Completer<Either<TrustFailure, TrustSnapshot>>();
    repo.read = (_) => pending.future;
    await tester.tap(find.text('Önceki değişiklikler'));
    await tester.pump();
    repo.read = (_) async => Right(page(title: 'Güncel rozet', next: null));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(repo.cursors, [null, 90, null]);
    pending.complete(Right(page(title: 'Eski rozet', id: 80)));
    await tester.pumpAndSettle();
    expect(find.text('Güncel rozet'), findsWidgets);
    expect(find.text('Eski rozet'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
