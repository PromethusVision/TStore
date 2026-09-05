import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_state.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_conversations_state.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_state.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';
import 'package:t_store/features/reviews/presentation/cubit/reviews_state.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_state.dart';
import 'w49_domain_fixture.dart';

void main() {
  setUpAll(loadW49Fonts);
  setUp(() async => sl.reset());
  tearDown(() async => sl.reset());

  for (final surface in [
    'purchases',
    'shop_ratings',
    'reviews',
    'inbox',
    'chat',
  ]) {
    for (final state in ['loading', 'empty', 'error']) {
      testWidgets('$surface $state supports 320px and enlarged Turkish text', (
        tester,
      ) async {
        final f = W49Fixture(long: true);
        await f.init();
        if (surface == 'purchases' || surface == 'shop_ratings') {
          whenListen(
            f.purchases,
            const Stream<PurchaseHistoryState>.empty(),
            initialState: switch (state) {
              'loading' => PurchaseHistoryLoading(),
              'error' => const PurchaseHistoryError(
                'Bağlantı kurulamadı. İnternet bağlantını kontrol ederek yeniden deneyebilirsin.',
              ),
              _ => const PurchaseHistoryLoaded([]),
            },
          );
        } else if (surface == 'reviews') {
          whenListen(
            f.reviews,
            const Stream<ReviewsState>.empty(),
            initialState: switch (state) {
              'loading' => ReviewsLoading(),
              'error' => const ReviewsError(
                ReviewFailure(
                  ReviewFailureKind.network,
                  'Bağlantı kurulamadı. Yeniden deneyebilirsin.',
                ),
              ),
              _ => f.reviewState.copyWith(reviews: []),
            },
          );
        } else if (surface == 'inbox') {
          whenListen(
            f.inbox,
            const Stream<ChatConversationsState>.empty(),
            initialState: switch (state) {
              'loading' => ChatConversationsLoading(),
              'error' => const ChatConversationsError(
                'Bağlantı kurulamadı. Yeniden deneyebilirsin.',
              ),
              _ => const ChatConversationsLoaded([]),
            },
          );
        } else {
          whenListen(
            f.chat,
            const Stream<ChatState>.empty(),
            initialState: switch (state) {
              'loading' => ChatLoading(),
              'error' => const ChatError(
                'Bağlantı kurulamadı. Yeniden deneyebilirsin.',
              ),
              _ => const ChatLoaded(messages: []),
            },
          );
        }
        await pumpW49(tester, f.page(surface), width: 320, scale: 1.3);
        expect(tester.takeException(), isNull);
        if (state == 'error') {
          final retry = surface == 'chat'
              ? find.byKey(const Key('customer-chat-load-retry-action'))
              : find.text('Tekrar Dene');
          await tester.ensureVisible(retry);
          await tester.pump();
          expect(tester.getRect(retry).bottom, lessThanOrEqualTo(844));
          await tester.tap(retry);
          await tester.pump();
        }
        if (surface == 'chat' && state != 'empty') {
          expect(
            tester
                .widget<IconButton>(
                  find.byKey(const Key('chat-message-send-action')),
                )
                .onPressed,
            isNull,
          );
        }
        if (surface == 'purchases' && state == 'error') {
          await expectLater(
            find.byKey(const Key('w49-evidence')),
            matchesGoldenFile('goldens/w49_purchases_error_320_130.png'),
          );
        }
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }

  for (final surface in [
    'purchases',
    'shop_ratings',
    'reviews',
    'inbox',
    'chat',
    'shop_rating_editor',
    'review_editor',
    'review_delete',
  ]) {
    for (final width in [320.0, 390.0, 430.0]) {
      for (final scale in [1.0, 1.3]) {
        testWidgets(
          '$surface $width at $scale keeps real content and actions accessible',
          (tester) async {
            final fixture = W49Fixture(long: scale > 1);
            await fixture.init();
            await pumpW49(
              tester,
              fixture.page(surface),
              width: width,
              scale: scale,
            );
            await openW49Surface(tester, surface);
            expect(tester.takeException(), isNull);
            if (surface == 'purchases') {
              expect(
                tester.widget<TabBar>(find.byType(TabBar)).tabs,
                hasLength(2),
              );
              expect(find.text('Mağazada doğrulandı'), findsWidgets);
            }
            if (surface == 'chat') {
              final input = find.byKey(const Key('chat-message-input'));
              expect(tester.getRect(input).bottom, lessThanOrEqualTo(844));
              expect(
                tester
                    .getSize(find.byKey(const Key('chat-message-send-action')))
                    .shortestSide,
                greaterThanOrEqualTo(48),
              );
            }
            if (surface == 'shop_rating_editor') {
              expect(
                tester
                    .getSize(
                      find.byKey(const Key('purchase-shop-rating-star-5')),
                    )
                    .shortestSide,
                greaterThanOrEqualTo(48),
              );
              await tester.ensureVisible(
                find.byKey(const Key('purchase-shop-rating-submit-action')),
              );
              expect(
                tester
                    .widget<FilledButton>(
                      find.byKey(
                        const Key('purchase-shop-rating-submit-action'),
                      ),
                    )
                    .onPressed,
                isNotNull,
              );
            }
            if (surface == 'review_editor') {
              expect(
                tester
                    .widget<TextField>(
                      find.byKey(const Key('product-review-title-field')),
                    )
                    .controller!
                    .text,
                fixture.ownReview.title,
              );
            }
            if ((width == 390 && scale == 1) ||
                (width == 320 && scale == 1.3)) {
              await expectLater(
                find.byKey(const Key('w49-evidence')),
                matchesGoldenFile(
                  'goldens/w49_${surface}_${width.toInt()}_${(scale * 100).round()}.png',
                ),
              );
            }
            await tester.pumpWidget(const SizedBox.shrink());
          },
        );
      }
    }
  }

  testWidgets(
    'short conversation begins directly below the header and keeps chronological order',
    (tester) async {
      final f = W49Fixture();
      await f.init();
      await pumpW49(tester, f.page('chat'));
      final header = tester.getRect(
        find.byKey(const Key('customer-chat-header')),
      );
      final oldest = tester.getRect(
        find.byKey(const Key('chat-message-w49-message-2')),
      );
      final newest = tester.getRect(
        find.byKey(const Key('chat-message-w49-message-0')),
      );
      expect(oldest.top - header.bottom, lessThan(120));
      expect(oldest.top, lessThan(newest.top));
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'review editing remains keyboard safe and preserves text after a save failure',
    (tester) async {
      final f = W49Fixture(long: true);
      await f.init();
      when(
        () => f.reviews.updateReview(
          productId: any(named: 'productId'),
          reviewId: any(named: 'reviewId'),
          rating: any(named: 'rating'),
          title: any(named: 'title'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer(
        (_) async => const ReviewMutationResult.failure(
          'Bağlantı kurulamadı. Yeniden deneyebilirsin.',
        ),
      );
      await pumpW49(tester, f.page('review_editor'), width: 320, scale: 1.3);
      await openW49Surface(tester, 'review_editor');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pump();
      await tester.ensureVisible(
        find.byKey(const Key('product-review-comment-field')),
      );
      await tester.enterText(
        find.byKey(const Key('product-review-comment-field')),
        'Düzenlenen yorum korunmalı.',
      );
      final submit = find.byKey(const Key('product-review-submit'));
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      expect(tester.getRect(submit).bottom, lessThanOrEqualTo(544));
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(
              find.byKey(const Key('product-review-comment-field')),
            )
            .controller!
            .text,
        'Düzenlenen yorum korunmalı.',
      );
      expect(
        find.text('Bağlantı kurulamadı. Yeniden deneyebilirsin.'),
        findsOneWidget,
      );
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('w49-evidence')),
        matchesGoldenFile('goldens/w49_review_keyboard_failure_320_130.png'),
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'refund preparation remains a separate action and returns to history',
    (tester) async {
      final f = W49Fixture(long: true);
      await f.init();
      await pumpW49(tester, f.page('refund'), width: 320, scale: 1.3);
      await tester.tap(find.text('İade Taleplerim'));
      await tester.pumpAndSettle();
      expect(find.text('Henüz iade talebin yok'), findsOneWidget);
      await expectLater(
        find.byKey(const Key('w49-evidence')),
        matchesGoldenFile('goldens/w49_refund_history_320_130.png'),
      );
      await openW49Surface(tester, 'refund');
      expect(find.text('İade talebi oluşturma hazırlanıyor'), findsOneWidget);
      await expectLater(
        find.byKey(const Key('w49-evidence')),
        matchesGoldenFile('goldens/w49_refund_action_320_130.png'),
      );
      await tester.tap(find.text('Alışverişlerimi Gör'));
      await tester.pumpAndSettle();
      expect(
        DefaultTabController.of(tester.element(find.byType(TabBar))).index,
        0,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'rating eligibility failure keeps selected stars and source QR on retry',
    (tester) async {
      final f = W49Fixture(long: true);
      await f.init();
      whenListen(
        f.ratings,
        const Stream<ShopRatingState>.empty(),
        initialState: const ShopRatingFailure(
          'Puan vermek için doğrulanmış bir alışveriş gerekiyor.',
        ),
      );
      await pumpW49(
        tester,
        f.page('shop_rating_editor'),
        width: 320,
        scale: 1.3,
      );
      await openW49Surface(tester, 'shop_rating_editor');
      final submit = find.byKey(
        const Key('purchase-shop-rating-submit-action'),
      );
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      await tester.tap(submit);
      verify(
        () => f.ratings.submitRating(qrSessionId: 'w49-qr-0', rating: 5),
      ).called(1);
      expect(find.byKey(const Key('purchase-rating-error')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('w49-evidence')),
        matchesGoldenFile('goldens/w49_shop_rating_failure_320_130.png'),
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('many purchases preserve records when scrolled', (tester) async {
    final f = W49Fixture(long: true);
    await f.init();
    whenListen(
      f.purchases,
      const Stream<PurchaseHistoryState>.empty(),
      initialState: PurchaseHistoryLoaded(
        List.generate(40, (i) => f.purchase(index: i, rated: true)),
      ),
    );
    await pumpW49(tester, f.page('purchases'), width: 320, scale: 1.3);
    await tester.scrollUntilVisible(
      find.byKey(const Key('customer-purchase-card-w49-purchase-39')),
      600,
      scrollable: find.descendant(
        of: find.byKey(const Key('customer-purchases-list')),
        matching: find.byType(Scrollable),
      ),
      maxScrolls: 60,
    );
    expect(
      find.byKey(const Key('customer-purchase-card-w49-purchase-39')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'composer clears only after confirmed send and remains above keyboard',
    (tester) async {
      final f = W49Fixture();
      await f.init();
      final states = StreamController<ChatState>();
      whenListen(f.chat, states.stream, initialState: ChatLoading());
      await pumpW49(
        tester,
        f.page('chat'),
        width: 320,
        scale: 1.3,
        keyboard: 300,
      );
      states.add(ChatLoaded(messages: f.messages(), hasReachedMax: true));
      await tester.pumpAndSettle();
      final input = find.byKey(const Key('chat-message-input'));
      await tester.enterText(input, 'Öğleden sonra mağazaya geleceğim.');
      await tester.pump();
      await tester.tap(find.byKey(const Key('chat-message-send-action')));
      await tester.pump();
      verify(
        () => f.chat.sendMessage(
          receiverId: 'w49-owner',
          content: 'Öğleden sonra mağazaya geleceğim.',
        ),
      ).called(1);
      expect(
        tester.widget<TextField>(input).controller!.text,
        'Öğleden sonra mağazaya geleceğim.',
      );
      expect(tester.getRect(input).bottom, lessThanOrEqualTo(544));
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('w49-evidence')),
        matchesGoldenFile('goldens/w49_chat_keyboard_320_130.png'),
      );
      states.add(MessageSent(f.messages()[1]));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(input).controller!.text, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
      await states.close();
    },
  );
}
