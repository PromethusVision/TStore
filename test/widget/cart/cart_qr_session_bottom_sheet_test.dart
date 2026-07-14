import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_state.dart';
import 'package:t_store/features/cart/presentation/widgets/cart_qr_session_bottom_sheet.dart';

class MockQrSessionCubit extends MockCubit<QrSessionState>
    implements QrSessionCubit {}

void main() {
  late MockQrSessionCubit qrSessionCubit;

  final activeSession = QrSessionEntity(
    id: 'session-1',
    sessionToken: 'token-1',
    userId: 'customer-1',
    cartId: 'cart-1',
    shopId: 'shop-1',
    status: 'active',
    expiresAt: DateTime.utc(2099, 1, 1),
    createdAt: DateTime.utc(2098, 12, 1),
    updatedAt: DateTime.utc(2098, 12, 1),
    itemCount: 2,
    totalAmount: 249.90,
  );

  setUp(() {
    qrSessionCubit = MockQrSessionCubit();
    when(() => qrSessionCubit.createQrSession(any())).thenAnswer((_) async {});
  });

  Widget buildSubject(QrSessionState initialState) {
    whenListen(
      qrSessionCubit,
      const Stream<QrSessionState>.empty(),
      initialState: initialState,
    );

    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<QrSessionCubit>.value(
          value: qrSessionCubit,
          child: const CartQrSessionBottomSheet(
            cartId: 'cart-1',
            shopName: 'Mahalle Mağazası',
            itemCount: 1,
            totalAmount: 100,
          ),
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

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('esnaf onayından sonra yeşil onay durumu gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(QrSessionCompleted()));
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
}
