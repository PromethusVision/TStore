import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/common/widgets/progress_indicator.dart';
import 'package:t_store/core/enums/status.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_state.dart';
import 'package:t_store/features/cart/presentation/widgets/cart_qr_session_bottom_sheet.dart';
import 'w48_fixture.dart';

void main() {
  setUpAll(w48Fonts);
  for (final width in [320.0, 390.0, 430.0]) {
    for (final status in [
      'active',
      'loading',
      'failure',
      'cancelled',
      'expired',
      'invalid',
      'changed',
      'delayed',
    ]) {
      testWidgets('W48 QR $status $width 130%', (tester) async {
        w48Viewport(tester, width);
        final state = switch (status) {
          'loading' => QrSessionLoading(),
          'failure' => const QrSessionFailure(
            'Bağlantı kurulamadı. Lütfen bağlantını kontrol edip yeniden dene.',
          ),
          'cancelled' => const QrSessionCancelled(),
          'expired' => const QrSessionExpired(),
          'invalid' => QrSessionCreated(w48Session(count: null)),
          'changed' => QrSessionCreated(w48Session(count: 3, total: 499.90)),
          'delayed' => QrSessionCreated(
            w48Session(),
            isStatusCheckDelayed: true,
          ),
          _ => QrSessionCreated(w48Session()),
        };
        final fixture = W48Fixture(session: state);
        await tester.pumpWidget(
          fixture.host(
            Scaffold(
              body: CartQrSessionBottomSheet(
                cartId: 'fixture-cart',
                shopName: 'Şükran Çiçekçi Tasarım ve El Sanatları Atölyesi',
                itemCount: 2,
                totalAmount: 249.90,
                onViewPurchases: (_) {},
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 250));
        await w48Accessibility(tester);
        if ([
          'invalid',
          'changed',
          'cancelled',
          'expired',
          'failure',
        ].contains(status)) {
          expect(
            find.byKey(const Key('purchase-verification-qr-code')),
            findsNothing,
          );
        }
        if (['active', 'delayed'].contains(status)) {
          expect(
            find.byKey(const Key('purchase-verification-qr-code')),
            findsOneWidget,
          );
        }
        if (status == 'changed' && width == 390) {
          await w48Golden(tester, 'qr_changed_390_130');
        }
        if (status == 'invalid' && width == 320) {
          await w48Golden(tester, 'qr_invalid_320_130');
        }
      });
    }
    for (final type in SnackBarType.values) {
      testWidgets('W48 feedback ${type.name} $width 130%', (tester) async {
        w48Viewport(tester, width);
        final fixture = W48Fixture();
        await tester.pumpWidget(
          fixture.host(
            Scaffold(
              body: Builder(
                builder: (context) => FilledButton(
                  onPressed: () => THelperFunctions.showSnackBar(
                    context: context,
                    message:
                        'İşlem sonucu: Şükran Çiçekçi Tasarım Atölyesi için bilgilerin güncellendiğini kontrol edebilirsin.',
                    type: type,
                    duration: const Duration(seconds: 8),
                  ),
                  child: const Text('İşlem sonucu'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('İşlem sonucu'));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(SnackBar), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (width == 390 && type == SnackBarType.error) {
          await w48Golden(tester, 'feedback_error_390_130');
        }
      });
    }
    testWidgets('W48 loader semantic label $width', (tester) async {
      w48Viewport(tester, width);
      final fixture = W48Fixture();
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          fixture.host(
            const Scaffold(
              body: Center(
                child: TLoadingIndicator(label: 'Konum belirleniyor'),
              ),
            ),
          ),
        );
        expect(find.bySemanticsLabel('Konum belirleniyor'), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    });
  }
}
