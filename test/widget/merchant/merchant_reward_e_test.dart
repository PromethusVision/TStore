import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/merchant/presentation/merchant_rewards.dart';
import 'package:t_store/features/merchant/presentation/merchant_qr_view.dart';
import 'package:t_store/features/cart/data/models/qr_verification_model.dart';
import 'package:t_store/features/rewards/domain/reward_program.dart';
import 'package:t_store/features/rewards/domain/reward_progress.dart';
import 'package:t_store/features/rewards/presentation/reward_center.dart';
import 'package:t_store/features/rewards/presentation/reward_reservation_card.dart';
import '../../support/reward_fixtures.dart';
import '../../unit/cart/qr_claim_protocol_test.dart'
    show ClaimTestRepository, claimJson;

void main() {
  setUpAll(() async {
    final fonts = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Bold.ttf'));
    final root = File(Platform.resolvedExecutable).parent.parent.parent;
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        File(
          '${root.path}/material_fonts/MaterialIcons-Regular.otf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await Future.wait([fonts.load(), icons.load()]);
  });
  late RewardFake repo;
  late StreamController<String?> sessions;
  String? user;
  const boundary = Key('reward-e-screen');
  setUp(() {
    repo = RewardFake();
    sessions = StreamController<String?>.broadcast(sync: true);
    user = rewardUser;
  });
  tearDown(() async {
    await sessions.close();
    await repo.progress.close();
  });
  Future<void> host(WidgetTester t, Widget child, {double width = 390}) async {
    t.view.physicalSize = Size(width, 1000);
    t.view.devicePixelRatio = 1;
    t.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(() async {
      await t.pumpWidget(const SizedBox());
      t.view.resetPhysicalSize();
      t.view.resetDevicePixelRatio();
      t.platformDispatcher.clearTextScaleFactorTestValue();
    });
    await t.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: MaterialApp(
          theme: EsnaftaVarTheme.light,
          debugShowCheckedModeBanner: false,
          home: Scaffold(body: child),
        ),
      ),
    );
    await t.pump();
  }

  Widget merchant() => MerchantRewardsView(
    repository: repo,
    shopId: rewardShop,
    ownerId: rewardUser,
    currentUserId: () => user,
    sessionChanges: sessions.stream,
  );
  Widget cart({String revision = 'one'}) => RewardReservationCard(
    repository: repo,
    cartId: rewardId,
    revision: revision,
    currentUserId: () => user,
    sessionChanges: sessions.stream,
  );
  Future<void> screenshot(WidgetTester t, String name) async {
    if (!const bool.fromEnvironment('REWARD_E_CAPTURE')) return;
    await t.pumpAndSettle();
    final render = t.renderObject<RenderRepaintBoundary>(find.byKey(boundary));
    await t.runAsync(() async {
      final picture = await render.toImage();
      final bytes = await picture.toByteData(format: ui.ImageByteFormat.png);
      picture.dispose();
      final dir = Directory('docs/evidence/reward_e');
      await dir.create(recursive: true);
      await File(
        '${dir.path}/$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
    });
  }

  testWidgets(
    'merchant displays authoritative capacity, forced preference and no payment action',
    (t) async {
      await host(t, merchant());
      await t.pumpAndSettle();
      final toggle = t.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(toggle.value, true);
      expect(toggle.onChanged, isNull);
      expect(find.textContaining('ödeme alınmaz'), findsOneWidget);
      expect(repo.writes, 0);
      await t.scrollUntilVisible(find.text('Kalan: 94'), 250);
      expect(find.text('Kalan: 94'), findsOneWidget);
      expect(find.text('Ayrılan: 1'), findsOneWidget);
      await screenshot(t, 'merchant-package');
    },
  );
  testWidgets(
    'merchant slow/error response shows neither an empty package nor invented zero',
    (t) async {
      repo.merchantWait = Completer();
      await host(t, merchant());
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.textContaining('Henüz açılmış'), findsNothing);
      repo.merchantWait!.complete(const Left('Bağlantı kesildi'));
      await t.pumpAndSettle();
      expect(find.text('Bağlantı kesildi'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsNothing);
    },
  );
  testWidgets(
    'merchant double tap writes once with revision and uncertain result needs fresh read',
    (t) async {
      repo.merchant = merchantState(forced: false, packages: false);
      repo.writeWait = Completer();
      await host(t, merchant());
      await t.pumpAndSettle();
      await t.tap(find.byType(SwitchListTile));
      await t.tap(find.byType(SwitchListTile));
      await t.pump();
      expect(repo.writes, 1);
      expect(repo.revisions, [7]);
      repo.writeWait!.complete(const Left('Sonuç alınamadı'));
      await t.pumpAndSettle();
      expect(find.byType(SwitchListTile), findsNothing);
      expect(find.text('Sonuç alınamadı'), findsOneWidget);
      await t.tap(find.byTooltip('Yenile'));
      await t.pumpAndSettle();
      expect(repo.reads, 2);
    },
  );
  testWidgets('merchant account change discards late response', (t) async {
    repo.merchantWait = Completer();
    await host(t, merchant());
    user = null;
    sessions.add(null);
    repo.merchantWait!.complete(Right(merchantState()));
    await t.pumpAndSettle();
    expect(find.textContaining('Oturumunuz değişti'), findsOneWidget);
    expect(find.text('Kalan: 94'), findsNothing);
  });
  testWidgets('merchant narrow screen with large text has no overflow', (
    t,
  ) async {
    await host(t, merchant(), width: 320);
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    await t.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    await screenshot(t, 'merchant-narrow');
  });
  testWidgets(
    'reservation never auto renews, cart revision rechecks with same attempt flag',
    (t) async {
      await host(t, cart());
      await t.pump();
      expect(repo.reservations, [false]);
      await t.pump(const Duration(minutes: 31));
      expect(repo.reservations, [false]);
      await host(t, cart(revision: 'two'));
      await t.pump();
      expect(repo.reservations, [false, false]);
    },
  );
  testWidgets(
    'expired reservation starts a new attempt only from explicit action and once',
    (t) async {
      repo.held = reservation(
        status: RewardReservationStatus.attemptExpired,
        seconds: -1,
      );
      await host(t, cart());
      await t.pumpAndSettle();
      repo.reserveWait = Completer();
      await t.tap(find.text('Yeni rezervasyon denemesi başlat'));
      await t.tap(find.text('Yeni rezervasyon denemesi başlat'));
      await t.pump();
      expect(repo.reservations, [false, true]);
      repo.reserveWait!.complete(Right(reservation()));
      await t.pump();
      expect(find.textContaining('Ödül kontenjanı ayrıldı'), findsOneWidget);
      await screenshot(t, 'customer-reservation');
    },
  );
  testWidgets(
    'reservation session change removes private result and ignores old completion',
    (t) async {
      repo.reserveWait = Completer();
      await host(t, cart());
      user = null;
      sessions.add(null);
      repo.reserveWait!.complete(Right(reservation()));
      await t.pumpAndSettle();
      expect(find.text('Ödül rezervasyonu'), findsNothing);
    },
  );
  testWidgets(
    'disabled reservation hides itself and failure offers a truthful retry',
    (t) async {
      repo.held = reservation(status: RewardReservationStatus.disabled);
      await host(t, cart());
      await t.pumpAndSettle();
      expect(find.text('Ödül rezervasyonu'), findsNothing);
      repo.error = 'Bağlantı kesildi';
      await host(t, cart(revision: 'two'));
      await t.pumpAndSettle();
      expect(find.text('Bağlantı kesildi'), findsOneWidget);
      expect(find.text('Durumu kontrol et'), findsOneWidget);
    },
  );
  testWidgets(
    'Customer loading and errors never display empty history or undefined rules',
    (t) async {
      await host(t, RewardCenter(repository: repo, customerId: rewardUser));
      await t.pump();
      expect(find.text('Henüz bir ödül kaydı yok.'), findsNothing);
      repo.progress.add(const RewardProgress(error: 'Sunucuya ulaşılamadı'));
      await t.pumpAndSettle();
      expect(find.text('Sunucuya ulaşılamadı'), findsOneWidget);
      expect(find.textContaining('henüz belirlenmedi'), findsNothing);
      await t.tap(find.text('Ödül bilgilerini yenile'));
      expect(repo.refreshes, 1);
    },
  );
  testWidgets(
    'Customer distinguishes pending contribution from issued coupon at large text',
    (t) async {
      await host(
        t,
        RewardCenter(repository: repo, customerId: rewardUser),
        width: 320,
      );
      repo.progress.add(
        RewardProgress(steps: 5, available: true, program: customerState()),
      );
      await t.pumpAndSettle();
      expect(find.text('Bekleyen kazanım: 250,00 TL'), findsOneWidget);
      expect(find.text('Oluşturulan kupon değeri: 250,00 TL'), findsOneWidget);
      expect(
        find.textContaining('Kupon harcama henüz açılmadı'),
        findsOneWidget,
      );
      expect(t.takeException(), isNull);
      await screenshot(t, 'customer-rewards');
    },
  );
  testWidgets(
    'E merchant confirmation cancellation does not finalize; explicit confirmation writes once',
    (t) async {
      final qr = ClaimTestRepository()
        ..recovered = QrVerificationModel.fromJson({
          ...claimJson(),
          ...earningQuote(),
          'reward_confirmation_required': true,
          'reward_sale_minor': '50000',
        });
      await host(t, MerchantQrView(repository: qr, shopId: 'shop'));
      await t.pumpAndSettle();
      final confirm = find.text('İşlemi onayla');
      await t.ensureVisible(confirm);
      await t.tap(confirm);
      await t.pumpAndSettle();
      expect(find.text('Gerçek satış tutarını doğrula'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.textContaining('500,00 TL'),
        ),
        findsOneWidget,
      );
      expect(qr.completions, 0);
      await screenshot(t, 'merchant-sale-confirmation');
      await t.tap(find.text('Vazgeç'));
      await t.pumpAndSettle();
      expect(qr.completions, 0);
      await t.tap(confirm);
      await t.pumpAndSettle();
      await t.tap(find.text('Satışı doğrula'));
      await t.pumpAndSettle();
      expect(qr.completions, 1);
    },
  );
}
