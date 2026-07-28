import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_state.dart';
import 'package:t_store/features/cart/presentation/widgets/cart_qr_session_bottom_sheet.dart';
import 'package:t_store/features/reviews/domain/entities/shop_rating_entity.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_cubit.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_state.dart';

class MockQrSessionCubit extends MockCubit<QrSessionState>
    implements QrSessionCubit {}

class MockShopRatingCubit extends MockCubit<ShopRatingState>
    implements ShopRatingCubit {}

void main() {
  late MockQrSessionCubit qrSessionCubit;
  late MockShopRatingCubit shopRatingCubit;

  QrSessionEntity buildSession({
    String id = 'session-1',
    int? itemCount = 2,
    double? totalAmount = 249.90,
    DateTime? expiresAt,
  }) {
    return QrSessionEntity(
      id: id,
      sessionToken: 'token-$id',
      userId: 'customer-1',
      cartId: 'cart-1',
      shopId: 'shop-1',
      status: 'active',
      expiresAt: expiresAt ?? DateTime.utc(2099, 1, 1),
      createdAt: DateTime.utc(2098, 12, 1),
      updatedAt: DateTime.utc(2098, 12, 1),
      itemCount: itemCount,
      totalAmount: totalAmount,
    );
  }

  final activeSession = buildSession();

  setUp(() async {
    await sl.reset();

    qrSessionCubit = MockQrSessionCubit();
    shopRatingCubit = MockShopRatingCubit();
    when(() => qrSessionCubit.createQrSession(any())).thenAnswer((_) async {});
    whenListen(
      shopRatingCubit,
      const Stream<ShopRatingState>.empty(),
      initialState: ShopRatingInitial(),
    );
    when(
      () => shopRatingCubit.submitRating(
        qrSessionId: any(named: 'qrSessionId'),
        rating: any(named: 'rating'),
      ),
    ).thenAnswer((_) async {});
    when(() => shopRatingCubit.close()).thenAnswer((_) async {});

    sl.registerFactory<ShopRatingCubit>(() => shopRatingCubit);
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildSubject(
    QrSessionState initialState, {
    int itemCount = 2,
    double totalAmount = 249.90,
    Stream<QrSessionState> stateStream = const Stream<QrSessionState>.empty(),
    ValueChanged<String>? onViewPurchases,
  }) {
    whenListen(qrSessionCubit, stateStream, initialState: initialState);

    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<QrSessionCubit>.value(
          value: qrSessionCubit,
          child: CartQrSessionBottomSheet(
            cartId: 'cart-1',
            shopName: 'Mahalle Mağazası',
            itemCount: itemCount,
            totalAmount: totalAmount,
            onViewPurchases: onViewPurchases ?? (_) {},
          ),
        ),
      ),
    );
  }

  Widget buildModalSubject(
    QrSessionState initialState, {
    int itemCount = 2,
    double totalAmount = 249.90,
  }) {
    whenListen(
      qrSessionCubit,
      const Stream<QrSessionState>.empty(),
      initialState: initialState,
    );

    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return FilledButton(
              key: const Key('open-qr-sheet'),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                builder: (_) => BlocProvider<QrSessionCubit>.value(
                  value: qrSessionCubit,
                  child: CartQrSessionBottomSheet(
                    cartId: 'cart-1',
                    shopName: 'Mahalle Mağazası',
                    itemCount: itemCount,
                    totalAmount: totalAmount,
                    onViewPurchases: (_) {},
                  ),
                ),
              ),
              child: const Text('QR ekranını aç'),
            );
          },
        ),
      ),
    );
  }

  testWidgets('QR ekranı alışverişi doğrulama yönlendirmesini gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(QrSessionCreated(activeSession)));
    await tester.pump();

    expect(find.text('Alışverişi doğrula'), findsOneWidget);
    expect(find.text('Bu QR ödeme değildir.'), findsNothing);
    expect(
      find.textContaining('Onay verildiğinde bu ekran otomatik güncellenir.'),
      findsOneWidget,
    );
    expect(find.text('2'), findsOneWidget);
    expect(find.text('TL 249.90'), findsOneWidget);
    expect(
      find.byKey(const Key('purchase-verification-qr-code')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('qr-status-check-warning')), findsNothing);
    expect(find.text('Sepet bilgileri güncellendi'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('durum kontrolü gecikince QR kalır ve bağlantı uyarısı görünür', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(QrSessionCreated(activeSession, isStatusCheckDelayed: true)),
    );
    await tester.pump();

    expect(
      find.text('Bağlantı zayıf. Onay durumu yeniden kontrol ediliyor.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('qr-status-check-warning')), findsOneWidget);
    expect(
      find.byKey(const Key('purchase-verification-qr-code')),
      findsOneWidget,
    );
    expect(find.text('Alışverişi doğrula'), findsOneWidget);
  });

  testWidgets('bağlantı düzelince uyarı kalkar ve QR ekranda kalır', (
    tester,
  ) async {
    final stateController = StreamController<QrSessionState>();
    addTearDown(stateController.close);

    await tester.pumpWidget(
      buildSubject(
        QrSessionCreated(activeSession, isStatusCheckDelayed: true),
        stateStream: stateController.stream,
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('qr-status-check-warning')), findsOneWidget);

    stateController.add(QrSessionCreated(activeSession));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('qr-status-check-warning')), findsNothing);
    expect(
      find.byKey(const Key('purchase-verification-qr-code')),
      findsOneWidget,
    );
  });

  testWidgets('QR hazırlanırken yüklenme durumunu gösterir', (tester) async {
    await tester.pumpWidget(buildSubject(QrSessionLoading()));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      find.byKey(const Key('purchase-verification-qr-code')),
      findsNothing,
    );
    expect(find.text('Sepet bilgileri güncellendi'), findsNothing);
  });

  testWidgets('eksik QR özeti kodu gizler ve çift yeniden denemeyi engeller', (
    tester,
  ) async {
    final incompleteSession = buildSession(itemCount: null, totalAmount: null);

    await tester.pumpWidget(buildSubject(QrSessionCreated(incompleteSession)));
    await tester.pump();

    expect(find.text('QR bilgileri doğrulanamadı'), findsOneWidget);
    expect(find.text('Yeniden dene'), findsOneWidget);
    expect(find.text('Sepete dön'), findsOneWidget);
    expect(
      find.byKey(const Key('purchase-verification-qr-code')),
      findsNothing,
    );

    final retryAction = find.byKey(
      const Key('qr-invalid-snapshot-retry-action'),
    );
    await tester.tap(retryAction);
    await tester.tap(retryAction);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    verify(() => qrSessionCubit.createQrSession('cart-1')).called(2);
  });

  testWidgets('geçersiz QR toplamında kodu göstermez', (tester) async {
    final invalidTotalSession = buildSession(totalAmount: double.nan);

    await tester.pumpWidget(
      buildSubject(QrSessionCreated(invalidTotalSession)),
    );
    await tester.pump();

    expect(find.text('QR bilgileri doğrulanamadı'), findsOneWidget);
    expect(
      find.byKey(const Key('purchase-verification-qr-code')),
      findsNothing,
    );
    expect(find.text('Sepet bilgileri güncellendi'), findsNothing);
  });

  testWidgets('sıfır toplamlı geçerli QR özetini kabul eder', (tester) async {
    final zeroTotalSession = buildSession(totalAmount: 0);

    await tester.pumpWidget(
      buildSubject(QrSessionCreated(zeroTotalSession), totalAmount: 0),
    );
    await tester.pump();

    expect(find.text('QR bilgileri doğrulanamadı'), findsNothing);
    expect(find.text('TL 0.00'), findsOneWidget);
    expect(
      find.byKey(const Key('purchase-verification-qr-code')),
      findsOneWidget,
    );
  });

  testWidgets('geçersiz QR özetinde sepete dön pencereyi kapatır', (
    tester,
  ) async {
    final incompleteSession = buildSession(itemCount: 0);

    await tester.pumpWidget(
      buildModalSubject(QrSessionCreated(incompleteSession)),
    );
    await tester.tap(find.byKey(const Key('open-qr-sheet')));
    await tester.pumpAndSettle();

    expect(find.text('QR bilgileri doğrulanamadı'), findsOneWidget);
    await tester.tap(find.byKey(const Key('qr-invalid-snapshot-back-action')));
    await tester.pumpAndSettle();

    expect(find.text('QR bilgileri doğrulanamadı'), findsNothing);
    expect(find.byKey(const Key('open-qr-sheet')), findsOneWidget);
  });

  testWidgets('sunucu toplamı değişince QR onaya kadar gizlenir', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(QrSessionCreated(activeSession), totalAmount: 100),
    );
    await tester.pump();

    expect(find.text('Sepet bilgileri güncellendi'), findsOneWidget);
    expect(find.text('Az önceki toplam'), findsOneWidget);
    expect(find.text('₺100.00'), findsOneWidget);
    expect(find.text('Güncel toplam'), findsOneWidget);
    expect(find.text('₺249.90'), findsOneWidget);
    expect(find.text('Az önceki ürün adedi'), findsNothing);
    expect(
      find.byKey(const Key('purchase-verification-qr-code')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const Key('qr-summary-change-continue-action')),
    );
    await tester.tap(
      find.byKey(const Key('qr-summary-change-continue-action')),
    );
    await tester.pump();

    expect(find.text('Sepet bilgileri güncellendi'), findsNothing);
    expect(find.text('Alışverişi doğrula'), findsOneWidget);
    expect(find.text('TL 249.90'), findsOneWidget);
    expect(
      find.byKey(const Key('purchase-verification-qr-code')),
      findsOneWidget,
    );
    verify(() => qrSessionCubit.createQrSession('cart-1')).called(1);
  });

  testWidgets('sunucu ürün adedi değişince toplam aynı olsa da QR gizlenir', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(QrSessionCreated(activeSession), itemCount: 1),
    );
    await tester.pump();

    expect(find.text('Sepet bilgileri güncellendi'), findsOneWidget);
    expect(find.text('Az önceki ürün adedi'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Güncel ürün adedi'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Az önceki toplam'), findsNothing);
    expect(find.text('Güncel toplam'), findsNothing);
    expect(find.text('Güncel sepetle devam et'), findsOneWidget);
    expect(find.text('Sepete dön'), findsOneWidget);
    expect(
      find.byKey(const Key('purchase-verification-qr-code')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const Key('qr-summary-change-continue-action')),
    );
    await tester.pump();

    expect(find.text('Sepet bilgileri güncellendi'), findsNothing);
    expect(find.text('Alışverişi doğrula'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(
      find.byKey(const Key('purchase-verification-qr-code')),
      findsOneWidget,
    );
    verify(() => qrSessionCubit.createQrSession('cart-1')).called(1);
  });

  testWidgets('güncel QR sepeti reddedilince pencere kapanır', (tester) async {
    await tester.pumpWidget(
      buildModalSubject(QrSessionCreated(activeSession), totalAmount: 100),
    );

    await tester.tap(find.byKey(const Key('open-qr-sheet')));
    await tester.pumpAndSettle();
    expect(find.text('Sepet bilgileri güncellendi'), findsOneWidget);

    final cancelAction = find.byKey(
      const Key('qr-summary-change-cancel-action'),
    );
    await tester.ensureVisible(cancelAction);
    await tester.pumpAndSettle();
    await tester.tap(cancelAction);
    await tester.pumpAndSettle();

    expect(find.text('Sepet bilgileri güncellendi'), findsNothing);
    expect(
      find.byKey(const Key('purchase-verification-qr-code')),
      findsNothing,
    );
    expect(find.byKey(const Key('open-qr-sheet')), findsOneWidget);
  });

  testWidgets('süresi dolan QR gizlenir ve çift yenileme isteği engellenir', (
    tester,
  ) async {
    final expiredSession = buildSession(
      id: 'expired-session',
      expiresAt: DateTime.utc(2000, 1, 1),
    );

    await tester.pumpWidget(buildSubject(QrSessionCreated(expiredSession)));
    await tester.pump();

    expect(find.text('QR süresi doldu'), findsOneWidget);
    expect(find.text('Yeni QR oluştur'), findsOneWidget);
    expect(find.text('QR oturumu oluşturulamadı'), findsNothing);
    expect(
      find.byKey(const Key('purchase-verification-qr-code')),
      findsNothing,
    );

    final refreshAction = find.byKey(const Key('qr-expired-refresh-action'));
    await tester.tap(refreshAction);
    await tester.tap(refreshAction);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.widget<ElevatedButton>(refreshAction).onPressed, isNull);
    verify(() => qrSessionCubit.createQrSession('cart-1')).called(2);
  });

  testWidgets('sunucunun süresi doldu cevabı aynı güvenli ekranı gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(const QrSessionExpired()));
    await tester.pump();

    expect(find.text('QR süresi doldu'), findsOneWidget);
    expect(
      find.text(
        'Güvenliğiniz için bu QR artık kullanılamaz. '
        'Güncel sepetiniz için yeni bir QR oluşturun.',
      ),
      findsOneWidget,
    );
    expect(find.text('Yeni QR oluştur'), findsOneWidget);
    expect(find.text('Yeniden Dene'), findsNothing);
    expect(find.text('QR oturumu oluşturulamadı'), findsNothing);
    expect(
      find.byKey(const Key('purchase-verification-qr-code')),
      findsNothing,
    );
  });

  testWidgets('yenilenen QR değişmiş sepet için tekrar onay ister', (
    tester,
  ) async {
    final stateController = StreamController<QrSessionState>();
    addTearDown(stateController.close);
    final expiredSession = buildSession(
      id: 'expired-session',
      expiresAt: DateTime.utc(2000, 1, 1),
    );
    final refreshedSession = buildSession(
      id: 'refreshed-session',
      itemCount: 3,
      totalAmount: 299.90,
    );

    await tester.pumpWidget(
      buildSubject(
        QrSessionCreated(expiredSession),
        stateStream: stateController.stream,
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('qr-expired-refresh-action')));
    stateController.add(QrSessionCreated(refreshedSession));
    await tester.pump();

    expect(find.text('Sepet bilgileri güncellendi'), findsOneWidget);
    expect(find.text('Az önceki ürün adedi'), findsOneWidget);
    expect(find.text('Güncel ürün adedi'), findsOneWidget);
    expect(find.text('Az önceki toplam'), findsOneWidget);
    expect(find.text('Güncel toplam'), findsOneWidget);
    expect(
      find.byKey(const Key('purchase-verification-qr-code')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const Key('qr-summary-change-continue-action')),
    );
    await tester.pump();

    expect(find.text('3'), findsOneWidget);
    expect(find.text('TL 299.90'), findsOneWidget);
    expect(
      find.byKey(const Key('purchase-verification-qr-code')),
      findsOneWidget,
    );
    verify(() => qrSessionCubit.createQrSession('cart-1')).called(2);
  });

  testWidgets('esnaf onayından sonra yeşil onay durumu gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(const QrSessionCompleted(sessionId: 'session-1')),
    );
    await tester.pump();

    expect(find.text('Alışveriş onaylandı'), findsOneWidget);
    expect(
      find.text(
        'Esnaf alışverişinizi doğruladı. Sepetiniz başarıyla tamamlandı.',
      ),
      findsOneWidget,
    );

    final successIcon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
    expect(successIcon.color, Colors.green.shade600);
    expect(find.text('Esnafa puan ver'), findsOneWidget);
    expect(find.text('Alışverişlerimde gör'), findsOneWidget);
  });

  testWidgets(
    'alışveriş geçmişi düğmesi oturum kimliğini yalnız bir kez gönderir',
    (tester) async {
      final openedSessionIds = <String>[];

      await tester.pumpWidget(
        buildSubject(
          const QrSessionCompleted(sessionId: 'session-1'),
          onViewPurchases: openedSessionIds.add,
        ),
      );
      await tester.pump();

      final action = find.byKey(const Key('view-completed-purchase-action'));
      await tester.tap(action);
      await tester.tap(action);
      await tester.pump();

      expect(openedSessionIds, ['session-1']);
      expect(find.text('Alışverişlerim açılıyor…'), findsOneWidget);
      expect(tester.widget<FilledButton>(action).onPressed, isNull);
    },
  );

  testWidgets('doğrulanmış alışveriş için beş yıldız gönderir', (tester) async {
    await tester.pumpWidget(
      buildSubject(const QrSessionCompleted(sessionId: 'session-1')),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('shop-rating-open-action')));
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('shop-rating-submit-action')),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const Key('shop-rating-star-5')));
    await tester.pump();

    expect(find.text('Çok iyi'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('shop-rating-submit-action')),
          )
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.byKey(const Key('shop-rating-submit-action')));
    await tester.pump();

    verify(
      () => shopRatingCubit.submitRating(qrSessionId: 'session-1', rating: 5),
    ).called(1);
  });

  testWidgets('puan kaydedilince teşekkür durumunu gösterir', (tester) async {
    whenListen(
      shopRatingCubit,
      const Stream<ShopRatingState>.empty(),
      initialState: const ShopRatingSuccess(
        ShopRatingEntity(
          id: 'rating-1',
          shopId: 'shop-1',
          rating: 5,
          averageRating: 4.8,
          ratingCount: 10,
        ),
      ),
    );

    await tester.pumpWidget(
      buildSubject(const QrSessionCompleted(sessionId: 'session-1')),
    );
    await tester.pump();

    expect(find.text('Puanınız kaydedildi. Teşekkür ederiz.'), findsOneWidget);
    expect(find.text('Esnafa puan ver'), findsNothing);
    expect(find.text('Tamam'), findsOneWidget);
  });

  testWidgets('QR oluşturma hatasında yeniden deneme çalışır', (tester) async {
    await tester.pumpWidget(
      buildSubject(const QrSessionFailure('Bağlantı kurulamadı')),
    );
    await tester.pump();

    await tester.tap(find.text('Yeniden Dene'));
    await tester.pump();

    verify(() => qrSessionCubit.createQrSession('cart-1')).called(2);
  });

  testWidgets('iptal edilen QR kodu gizler ve yeniden deneme sunmaz', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(const QrSessionCancelled()));
    await tester.pump();

    expect(find.text('QR iptal edildi'), findsOneWidget);
    expect(
      find.text(
        'Sepetiniz değiştiği için eski QR artık geçerli değil. '
        'Güncel sepetinizi kontrol edin.',
      ),
      findsOneWidget,
    );
    expect(find.text('Sepete dön ve güncelle'), findsOneWidget);
    expect(find.text('Yeniden Dene'), findsNothing);
    expect(
      find.byKey(const Key('purchase-verification-qr-code')),
      findsNothing,
    );
    verify(() => qrSessionCubit.createQrSession('cart-1')).called(1);
  });

  testWidgets('iptal edilen QR ekranından sepete dönüş pencereyi kapatır', (
    tester,
  ) async {
    await tester.pumpWidget(buildModalSubject(const QrSessionCancelled()));
    await tester.tap(find.byKey(const Key('open-qr-sheet')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('qr-cancelled-back-to-cart-action')));
    await tester.pumpAndSettle();

    expect(find.text('QR iptal edildi'), findsNothing);
    expect(find.byKey(const Key('open-qr-sheet')), findsOneWidget);
    verify(() => qrSessionCubit.createQrSession('cart-1')).called(1);
  });
}
