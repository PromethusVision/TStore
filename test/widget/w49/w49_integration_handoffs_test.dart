import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_state.dart';
import 'package:t_store/features/cart/presentation/widgets/cart_qr_session_bottom_sheet.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_conversations_cubit.dart';
import 'package:t_store/features/chat/presentation/views/conversations_view.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:t_store/features/notifications/presentation/views/customer_notifications_view.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_cubit.dart';
import 'package:t_store/features/purchases/presentation/views/purchases_view.dart';
import 'package:t_store/features/reviews/domain/entities/shop_rating_entity.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_state.dart';

import 'w49_domain_fixture.dart';

class _Qr extends MockCubit<QrSessionState> implements QrSessionCubit {}

class _Notifications extends MockCubit<NotificationsState>
    implements NotificationsCubit {}

void main() {
  setUpAll(loadW49Fonts);
  setUp(() async => sl.reset());
  tearDown(() async => sl.reset());

  for (final target in ['purchase', 'inbox']) {
    testWidgets(
      'W48 notification opens actual W49 $target and returns safely',
      (tester) async {
        final f = W49Fixture();
        await f.init();
        sl.registerFactory<PurchaseHistoryCubit>(() => f.purchases);
        sl.registerFactory<ChatConversationsCubit>(() => f.inbox);
        final notifications = _Notifications();
        final item = NotificationEntity(
          id: 'w49-integration-$target',
          userId: 'w49-customer',
          title: target == 'purchase'
              ? 'Alışverişin doğrulandı'
              : 'Yeni mesajın var',
          body: 'İlgili kaydı görüntüle.',
          type: target == 'purchase'
              ? NotificationType.order
              : NotificationType.chat,
          data: target == 'purchase'
              ? {'action_type': 'order_detail', 'action_id': f.purchase().id}
              : {'action_type': 'chat_detail'},
        );
        whenListen(
          notifications,
          const Stream<NotificationsState>.empty(),
          initialState: NotificationsLoaded(
            notifications: [item],
            unreadCount: 1,
            hasReachedMax: true,
          ),
        );
        when(
          () => notifications.getNotifications(refresh: any(named: 'refresh')),
        ).thenAnswer((_) async {});
        when(() => notifications.markAsRead(any())).thenAnswer((_) async {});
        when(() => notifications.close()).thenAnswer((_) async {});
        await pumpW49(
          tester,
          CustomerNotificationsView(notificationsCubit: notifications),
        );
        expect(
          find.byKey(Key('notification-destination-${item.id}')),
          findsOneWidget,
        );
        await tester.tap(find.text(item.title));
        await tester.pumpAndSettle();
        verify(() => notifications.markAsRead(item.id)).called(1);
        if (target == 'purchase') {
          expect(find.byType(PurchasesView), findsOneWidget);
          expect(
            find.byKey(Key('highlighted-purchase-${f.purchase().id}')),
            findsOneWidget,
          );
          expect(tester.widget<TabBar>(find.byType(TabBar)).tabs, hasLength(2));
          verify(() => f.purchases.loadPurchases()).called(1);
          await tester.tap(
            find.byKey(const Key('customer-purchases-back-button')),
          );
        } else {
          expect(find.byType(ConversationsView), findsOneWidget);
          expect(
            find.byKey(const Key('conversation-card-w49-owner-0')),
            findsOneWidget,
          );
          verify(() => f.inbox.loadConversations()).called(1);
          await tester.tap(
            find.byKey(const Key('customer-conversations-back-button')),
          );
        }
        await tester.pumpAndSettle();
        expect(find.byType(CustomerNotificationsView), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  for (final width in [320.0, 390.0]) {
    testWidgets('W48 QR completion and rating remain usable in W49 at $width', (
      tester,
    ) async {
      final f = W49Fixture(long: width == 320);
      await f.init();
      final qr = _Qr();
      final ratingStates = StreamController<ShopRatingState>();
      addTearDown(ratingStates.close);
      whenListen(
        qr,
        const Stream<QrSessionState>.empty(),
        initialState: QrSessionCompleted(
          sessionId: f.purchase().sourceQrSessionId,
        ),
      );
      when(() => qr.createQrSession(any())).thenAnswer((_) async {});
      whenListen(
        f.ratings,
        ratingStates.stream,
        initialState: ShopRatingInitial(),
      );
      String? openedSession;
      await pumpW49(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                showDragHandle: true,
                backgroundColor: Colors.white,
                builder: (_) => BlocProvider<QrSessionCubit>.value(
                  value: qr,
                  child: CartQrSessionBottomSheet(
                    cartId: 'w49-cart',
                    shopName: f.shopName,
                    itemCount: 2,
                    totalAmount: 259.8,
                    onViewPurchases: (id) {
                      openedSession = id;
                    },
                  ),
                ),
              ),
              child: const Text('QR sonucunu aç'),
            ),
          ),
        ),
        width: width,
        scale: width == 320 ? 1.3 : 1,
      );
      await tester.tap(find.text('QR sonucunu aç'));
      await tester.pumpAndSettle();
      final suffix = width == 320 ? '320_130' : '390_100';
      expect(find.text('Alışveriş onaylandı'), findsOneWidget);
      await expectLater(
        find.byKey(const Key('w49-evidence')),
        matchesGoldenFile('goldens/w49_integration_qr_completed_$suffix.png'),
      );
      await tester.tap(find.byKey(const Key('shop-rating-open-action')));
      await tester.pumpAndSettle();
      final submit = find.byKey(const Key('shop-rating-submit-action'));
      expect(tester.widget<FilledButton>(submit).onPressed, isNull);
      await tester.tap(find.byKey(const Key('shop-rating-star-5')));
      await tester.pumpAndSettle();
      expect(
        tester
            .getSize(find.byKey(const Key('shop-rating-star-5')))
            .shortestSide,
        greaterThanOrEqualTo(48),
      );
      await expectLater(
        find.byKey(const Key('w49-evidence')),
        matchesGoldenFile('goldens/w49_integration_qr_rating_$suffix.png'),
      );
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();
      verify(
        () => f.ratings.submitRating(
          qrSessionId: f.purchase().sourceQrSessionId,
          rating: 5,
        ),
      ).called(1);
      ratingStates.add(ShopRatingSubmitting());
      await tester.pump();
      expect(tester.widget<FilledButton>(submit).onPressed, isNull);
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('shop-rating-star-5')))
            .onPressed,
        isNull,
      );
      ratingStates.add(
        const ShopRatingFailure('Puan kaydedilemedi. Yeniden deneyin.'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Puan kaydedilemedi. Yeniden deneyin.'), findsOneWidget);
      expect(find.text('Çok iyi'), findsOneWidget);
      expect(tester.widget<FilledButton>(submit).onPressed, isNotNull);
      ratingStates.add(
        const ShopRatingSuccess(
          ShopRatingEntity(
            id: 'w49-rating',
            shopId: 'w49-shop-0',
            rating: 5,
            averageRating: 4.8,
            ratingCount: 10,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Puanınız kaydedildi. Teşekkür ederiz.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('shop-rating-open-action')), findsNothing);
      final purchases = find.byKey(const Key('view-completed-purchase-action'));
      await tester.ensureVisible(purchases);
      await tester.tap(purchases);
      await tester.pump();
      expect(openedSession, f.purchase().sourceQrSessionId);
      expect(tester.widget<FilledButton>(purchases).onPressed, isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
