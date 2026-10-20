import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/reviews/domain/entities/purchase_evaluation.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';
import 'package:t_store/features/reviews/presentation/widgets/purchase_evaluation_sheet.dart';
import '../../helpers/fake_evaluation_repository.dart';

void main() {
  late FakeEvaluationRepository repository;
  setUp(() => repository = FakeEvaluationRepository());
  tearDown(() async {
    await repository.dispose();
  });
  Future<void> open(
    WidgetTester tester, {
    bool selected = false,
    double width = 390,
    double scale = 1,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showPurchaseEvaluation(
                context,
                repository: repository,
                purchaseId: evaluationPurchase,
                selectedProductId: selected ? evaluationProduct : null,
              ),
              child: const Text('Aç'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Aç'));
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> criteria(WidgetTester tester) async {
    for (final label in ['Güleryüz', 'İletişim', 'Temizlik']) {
      await tapVisible(tester, find.byTooltip('$label: 4 yıldız'));
    }
  }

  testWidgets(
    'refresh after an uncertain submit retains the exact pending command',
    (tester) async {
      await open(tester, selected: true);
      await criteria(tester);
      await tapVisible(tester, find.byTooltip('Ürün puanı: 5 yıldız'));
      repository.mutationFailure = const ReviewFailure(
        ReviewFailureKind.network,
        'Yanıt kayboldu',
      );
      await tapVisible(tester, find.byKey(const Key('evaluation-submit')));
      final sent = repository.submissions.single;
      await tapVisible(tester, find.text('Güncel durumu kontrol et'));
      expect(find.text('Aynı işlemi tekrar dene'), findsOneWidget);
      repository.mutationFailure = null;
      await tapVisible(tester, find.byKey(const Key('evaluation-submit')));
      expect(identical(repository.submissions.last, sent), true);
    },
  );
  testWidgets(
    'closing and reopening an uncertain purchase restores the immutable request',
    (tester) async {
      await open(tester, selected: true);
      await criteria(tester);
      await tapVisible(tester, find.byTooltip('Ürün puanı: 5 yıldız'));
      repository.mutationFailure = const ReviewFailure(
        ReviewFailureKind.network,
        'Yanıt kayboldu',
      );
      await tapVisible(tester, find.byKey(const Key('evaluation-submit')));
      final sent = repository.submissions.single;
      await tapVisible(tester, find.byTooltip('Kapat'));
      await tester.tap(find.text('Aç'));
      await tester.pumpAndSettle();
      expect(find.text('Aynı işlemi tekrar dene'), findsOneWidget);
      repository.mutationFailure = null;
      await tapVisible(tester, find.byKey(const Key('evaluation-submit')));
      expect(identical(repository.submissions.last, sent), true);
    },
  );
  testWidgets(
    'normal refresh preserves drafts and same-account new session permanently clears them',
    (tester) async {
      await open(tester, selected: true);
      await criteria(tester);
      await tester.ensureVisible(find.byType(TextField).first);
      await tester.enterText(
        find.byType(TextField).first,
        'Özel müşteri taslağı',
      );
      repository.replaceSession('$evaluationActor:S1');
      await tester.pump();
      expect(find.text('Özel müşteri taslağı'), findsOneWidget);
      repository.replaceSession('$evaluationActor:S2');
      repository.replaceSession('$evaluationActor:S1');
      await tester.pump();
      expect(find.text('Özel müşteri taslağı'), findsNothing);
      expect(find.textContaining('Oturumunuz değişti.'), findsOneWidget);
      expect(find.byKey(const Key('evaluation-submit')), findsNothing);
      expect(tester.takeException(), null);
    },
  );
  testWidgets(
    'session stream failure clears an open draft and permits closing',
    (tester) async {
      await open(tester, selected: true);
      repository.sessionKeys.addError(StateError('synthetic'));
      await tester.pump();
      expect(find.text('Mahalle Market'), findsNothing);
      await tapVisible(tester, find.byTooltip('Kapat'));
      expect(find.byType(PurchaseEvaluationSheet), findsNothing);
      expect(tester.takeException(), null);
    },
  );
  testWidgets(
    'all criteria are required, products optional and a successful service-only submission closes',
    (tester) async {
      await open(tester);
      await tapVisible(tester, find.byKey(const Key('evaluation-submit')));
      expect(repository.submissions, isEmpty);
      expect(
        find.text('Güleryüz, iletişim ve temizlik puanlarının tümünü seçin.'),
        findsOneWidget,
      );
      await criteria(tester);
      await tapVisible(tester, find.byKey(const Key('evaluation-submit')));
      expect(repository.submissions.single.products, isEmpty);
      expect(repository.submissions.single.service!.friendliness, 4);
      expect(find.byType(PurchaseEvaluationSheet), findsNothing);
    },
  );
  testWidgets(
    'selected products require stars and uncertain retries keep identical command',
    (tester) async {
      await open(tester, selected: true);
      await criteria(tester);
      await tapVisible(tester, find.byKey(const Key('evaluation-submit')));
      expect(repository.submissions, isEmpty);
      expect(
        find.text('Seçtiğiniz her ürün için bir puan verin.'),
        findsOneWidget,
      );
      await tapVisible(tester, find.byTooltip('Ürün puanı: 5 yıldız'));
      repository.mutationFailure = const ReviewFailure(
        ReviewFailureKind.network,
        'Yanıt alınamadı.',
      );
      await tapVisible(tester, find.byKey(const Key('evaluation-submit')));
      final sent = repository.submissions.single;
      expect(
        tester.widget<TextField>(find.byType(TextField).first).readOnly,
        true,
      );
      repository.mutationFailure = null;
      await tapVisible(tester, find.byKey(const Key('evaluation-submit')));
      expect(identical(repository.submissions.last, sent), true);
    },
  );
  testWidgets(
    'double submit is suppressed and session change clears the open form',
    (tester) async {
      await open(tester, selected: true);
      await criteria(tester);
      await tapVisible(tester, find.byTooltip('Ürün puanı: 5 yıldız'));
      final waiting = Completer<Either<ReviewFailure, Unit>>();
      repository.submitWait = () => waiting.future;
      await tester.ensureVisible(find.byKey(const Key('evaluation-submit')));
      await tester.tap(find.byKey(const Key('evaluation-submit')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('evaluation-submit')));
      await tester.pump();
      expect(repository.submissions.length, 1);
      repository.switchAccount(evaluationShop);
      await tester.pump();
      expect(find.text('Mahalle Market'), findsNothing);
      expect(find.textContaining('Oturumunuz değişti.'), findsOneWidget);
      waiting.complete(const Right(unit));
      await tester.pumpAndSettle();
      expect(find.byType(PurchaseEvaluationSheet), findsOneWidget);
      await tester.tap(find.byTooltip('Kapat'));
      await tester.pumpAndSettle();
      expect(find.byType(PurchaseEvaluationSheet), findsNothing);
    },
  );
  testWidgets(
    'remaining products reuse immutable service scores at narrow large-text size',
    (tester) async {
      repository.value = const PurchaseEvaluation(
        purchaseId: evaluationPurchase,
        shopId: evaluationShop,
        shopName: 'Mahalle Market',
        enabled: true,
        valid: true,
        service: exampleCriteria,
        products: [
          EvaluationProduct(
            productId: evaluationProduct,
            name: 'Uzun isimli mahalle ürünü ve açıklaması',
            canSubmit: true,
          ),
        ],
      );
      await open(tester, selected: true, width: 320, scale: 1.5);
      expect(
        tester
            .widget<IconButton>(
              find.byWidgetPredicate(
                (w) => w is IconButton && w.tooltip == 'Güleryüz: 4 yıldız',
              ),
            )
            .onPressed,
        null,
      );
      await tapVisible(tester, find.byTooltip('Ürün puanı: 3 yıldız'));
      await tapVisible(tester, find.byKey(const Key('evaluation-submit')));
      expect(repository.submissions.single.service, null);
      expect(repository.submissions.single.products.single.rating, 3);
      expect(tester.takeException(), null);
    },
  );
  testWidgets(
    'invalid evidence and failed loads do not expose a submit action',
    (tester) async {
      repository.readFailure = const ReviewFailure(
        ReviewFailureKind.network,
        'Bağlantı yok',
      );
      await open(tester);
      expect(find.text('Bağlantı yok'), findsOneWidget);
      expect(find.byKey(const Key('evaluation-submit')), findsNothing);
      repository.readFailure = null;
      repository.value = const PurchaseEvaluation(
        purchaseId: evaluationPurchase,
        shopId: evaluationShop,
        shopName: 'Mahalle Market',
        enabled: true,
        valid: false,
        products: [],
      );
      await tapVisible(tester, find.text('Güncel durumu kontrol et'));
      expect(
        find.text('Bu alışveriş için değerlendirme hakkı kullanılamıyor.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('evaluation-submit')), findsNothing);
    },
  );
}
