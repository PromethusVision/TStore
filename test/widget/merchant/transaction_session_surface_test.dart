import 'dart:async';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';
import 'package:t_store/features/cart/data/models/qr_session_model.dart';
import 'package:t_store/features/cart/data/models/qr_verification_model.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/merchant/presentation/merchant_purchases_view.dart';
import 'package:t_store/features/merchant/presentation/merchant_qr_view.dart';
import 'package:t_store/features/merchant/presentation/merchant_return_form.dart';
import 'package:t_store/features/rewards/presentation/coupon_checkout_approval.dart';
import '../../support/coupon_checkout_fixtures.dart';
import '../../support/reward_fixtures.dart';
import '../../unit/cart/qr_claim_protocol_test.dart';
import '../../unit/merchant/transaction_lifetime_test.dart'
    show SessionQr, SessionReturn;
import '../../unit/merchant/merchant_return_recovery_test.dart'
    show ReturnStore;
import 'merchant_qr_slice_b_test.dart' show Evidence, host, purchase;
import 'coupon_checkout_widget_test.dart' show CheckoutFake;

class SessionEvidence extends Evidence implements AuthenticatedSessionEvents {
  final keys = StreamController<String?>.broadcast();
  @override
  String? currentSessionKey = 'S1';
  @override
  Stream<String?> get sessionKeyChanges => keys.stream;
  void bounce() {
    keys.add('S2');
    keys.add('S1');
  }
}

class SessionCheckout extends CheckoutFake
    implements AuthenticatedSessionEvents {
  final keys = StreamController<String?>.broadcast();
  @override
  String? currentSessionKey = 'S1';
  @override
  Stream<String?> get sessionKeyChanges => keys.stream;
  void bounce() {
    keys.add('S2');
    keys.add('S1');
  }
}

void main() {
  testWidgets(
    'purchase list removes private content on same-account session bounce',
    (t) async {
      final repo = SessionEvidence();
      await host(
        t,
        MerchantPurchasesView(
          repository: repo,
          shopId: 'shop',
          userId: 'owner',
        ),
        width: 360,
      );
      await t.pumpAndSettle();
      expect(find.byType(ListTile), findsOneWidget);
      repo.bounce();
      await t.pumpAndSettle();
      expect(find.byType(ListTile), findsNothing);
      expect(find.text('Oturum değişti. Bu ekranı kapatın.'), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await repo.keys.close();
    },
  );
  for (final beforeMount in [true, false]) {
    testWidgets(
      'purchase detail hides prior session, before mount=$beforeMount',
      (t) async {
        final repo = SessionEvidence();
        await host(
          t,
          MerchantPurchasesView(
            repository: repo,
            shopId: 'shop',
            userId: 'owner',
          ),
        );
        await t.pumpAndSettle();
        await t.tap(find.byType(ListTile));
        if (!beforeMount) await t.pumpAndSettle();
        repo.bounce();
        await t.pumpAndSettle();
        expect(find.text('İşlem no: purchase'), findsNothing);
        expect(find.text('Örnek ürün'), findsNothing);
        expect(find.text('Oturum değişti. Bu ekranı kapatın.'), findsOneWidget);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        await repo.keys.close();
      },
    );
  }
  testWidgets(
    'return form hides input while pending return remains preserved',
    (t) async {
      final repo = SessionReturn(), store = ReturnStore();
      await host(
        t,
        MerchantReturnForm(
          repository: repo,
          purchase: purchase(),
          userId: 'owner',
          store: store,
        ),
        width: 360,
      );
      await t.pumpAndSettle();
      expect(find.byType(TextField), findsWidgets);
      repo.bounce();
      await t.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(repo.sent, isEmpty);
      expect(store.clears, 0);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await repo.keys.close();
    },
  );
  for (final beforeMount in [true, false]) {
    testWidgets(
      'sale confirmation conceals stale terms, before mount=$beforeMount',
      (t) async {
        final repo = SessionQr()
          ..recovered = QrVerificationModel.fromJson({
            ...claimJson(),
            ...earningQuote(),
            'reward_confirmation_required': true,
            'reward_sale_minor': '50000',
          });
        await host(
          t,
          MerchantQrView(repository: repo, shopId: 'shop'),
          width: 360,
        );
        await t.pumpAndSettle();
        await t.scrollUntilVisible(find.text('İşlemi onayla'), 200);
        await t.tap(find.text('İşlemi onayla'));
        if (!beforeMount) await t.pumpAndSettle();
        repo.bounce();
        await t.pumpAndSettle();
        expect(find.text('Gerçek satış tutarını doğrula'), findsNothing);
        expect(find.text('Satışı doğrula'), findsNothing);
        expect(find.text('Oturum değişti. Bu ekranı kapatın.'), findsOneWidget);
        expect(repo.completions, 0);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        await repo.keys.close();
      },
    );
  }
  testWidgets('coupon renewal keeps chosen amount; replacement hides it', (
    t,
  ) async {
    final repo = SessionCheckout();
    var approved = 0, without = 0;
    await host(
      t,
      CouponCheckoutApproval(
        cartId: rewardId,
        repository: repo,
        onApproved: (_) => approved++,
        onWithoutCoupon: () => without++,
      ),
      width: 360,
    );
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), '123,45');
    repo.keys.add('S1');
    await t.pumpAndSettle();
    expect(find.text('123,45'), findsOneWidget);
    repo.bounce();
    await t.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    expect(approved + without, 0);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    await repo.keys.close();
    await repo.changes.close();
  });
  testWidgets(
    'late coupon success after session replacement cannot advance to QR',
    (t) async {
      final repo = SessionCheckout()
        ..pendingApproval = Completer<Either<String, QrSessionEntity>>();
      var approved = 0;
      await host(
        t,
        CouponCheckoutApproval(
          cartId: rewardId,
          repository: repo,
          onApproved: (_) => approved++,
          onWithoutCoupon: () {},
        ),
      );
      await t.pumpAndSettle();
      await t.scrollUntilVisible(find.text('Kuponu onayla ve QR oluştur'), 200);
      await t.tap(find.text('Kuponu onayla ve QR oluştur'));
      await t.pump();
      repo.bounce();
      await t.pump();
      repo.pendingApproval!.complete(
        Right(QrSessionModel.fromJson(checkoutQr())),
      );
      await t.pumpAndSettle();
      expect(approved, 0);
      expect(repo.requests.length, 1);
      expect(find.byType(TextField), findsNothing);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await repo.keys.close();
      await repo.changes.close();
    },
  );
}
