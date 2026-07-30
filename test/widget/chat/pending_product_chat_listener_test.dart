import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/chat/domain/services/pending_product_chat_storage.dart';
import 'package:t_store/features/chat/presentation/widgets/pending_product_chat_listener.dart';

class MockPendingProductChatStorage extends Mock
    implements PendingProductChatStorage {}

void main() {
  late MockPendingProductChatStorage storage;
  late GlobalKey<NavigatorState> navigatorKey;
  late GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  String? currentUserId;

  final intent = PendingProductChatIntent(
    receiverId: 'owner-1',
    receiverName: 'Mahalle Marketi',
    initialDraft: 'Merhaba, ürün mağazanızda mevcut mu?',
    createdAt: DateTime.utc(2026, 7, 30, 12),
  );

  setUp(() {
    storage = MockPendingProductChatStorage();
    navigatorKey = GlobalKey<NavigatorState>();
    scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
    currentUserId = null;

    when(() => storage.clear()).thenAnswer((_) async {});
  });

  Widget buildSubject({
    PendingProductChatLoginBuilder? loginBuilder,
    bool enabled = true,
  }) {
    return PendingProductChatListener(
      storage: storage,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      enabled: enabled,
      currentUserIdProvider: () => currentUserId,
      loginBuilder: loginBuilder,
      destinationBuilder: (_, pending) => Scaffold(
        body: Text('Mesaj: ${pending.receiverName} / ${pending.initialDraft}'),
      ),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: const Scaffold(body: Text('Ana sayfa')),
      ),
    );
  }

  testWidgets(
    'uygulama açıldığında giriş yapılmışsa bekleyen mesajı doğrudan açar',
    (tester) async {
      currentUserId = 'customer-1';
      when(() => storage.getPending()).thenAnswer((_) async => intent);

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Mesaj: Mahalle Marketi / Merhaba, ürün mağazanızda mevcut mu?',
        ),
        findsOneWidget,
      );
      verify(() => storage.clear()).called(1);
    },
  );

  testWidgets(
    'misafir açılışında girişten sonra bekleyen mesajı geri getirir',
    (tester) async {
      when(() => storage.getPending()).thenAnswer((_) async => intent);

      await tester.pumpWidget(
        buildSubject(
          loginBuilder: (context) => Scaffold(
            body: FilledButton(
              key: const Key('complete-login'),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Girişi tamamla'),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Girişi tamamla'), findsOneWidget);

      currentUserId = 'customer-1';
      await tester.tap(find.byKey(const Key('complete-login')));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Mesaj: Mahalle Marketi / Merhaba, ürün mağazanızda mevcut mu?',
        ),
        findsOneWidget,
      );
      verify(() => storage.clear()).called(1);
    },
  );

  testWidgets('girişten vazgeçilirse bekleyen mesajı temizler', (tester) async {
    when(() => storage.getPending()).thenAnswer((_) async => intent);

    await tester.pumpWidget(
      buildSubject(
        loginBuilder: (context) => Scaffold(
          body: TextButton(
            key: const Key('cancel-login'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('cancel-login')));
    await tester.pumpAndSettle();

    expect(find.text('Ana sayfa'), findsOneWidget);
    expect(find.textContaining('Mesaj:'), findsNothing);
    verify(() => storage.clear()).called(1);
  });

  testWidgets('mağaza sahibi kendi bekleyen mesajını açamaz', (tester) async {
    currentUserId = 'owner-1';
    when(() => storage.getPending()).thenAnswer((_) async => intent);

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Ana sayfa'), findsOneWidget);
    expect(
      find.text('Bu mağazaya kendi hesabınızla mesaj gönderemezsiniz.'),
      findsOneWidget,
    );
    expect(find.textContaining('Mesaj:'), findsNothing);
    verify(() => storage.clear()).called(1);
  });

  testWidgets('bekleyen mesaj yoksa ana ekranı değiştirmez', (tester) async {
    when(() => storage.getPending()).thenAnswer((_) async => null);

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Ana sayfa'), findsOneWidget);
    verifyNever(() => storage.clear());
  });

  testWidgets('şifre yenileme açılışında bekleyen mesajı öne çıkarmaz', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(enabled: false));
    await tester.pumpAndSettle();

    expect(find.text('Ana sayfa'), findsOneWidget);
    verifyNever(() => storage.getPending());
    verifyNever(() => storage.clear());
  });
}
