import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/chat/domain/entities/chat_message_entity.dart';
import 'package:t_store/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_conversations_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_conversations_state.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_state.dart';
import 'package:t_store/features/chat/presentation/views/chat_view.dart';
import 'package:t_store/features/chat/presentation/views/conversations_view.dart';
import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_cubit.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_state.dart';
import 'package:t_store/features/purchases/presentation/views/customer_ratings_view.dart';
import 'package:t_store/features/purchases/presentation/views/purchases_view.dart';
import 'package:t_store/features/reviews/domain/entities/review_entity.dart';
import 'package:t_store/features/reviews/presentation/cubit/reviews_cubit.dart';
import 'package:t_store/features/reviews/presentation/cubit/reviews_state.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_cubit.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_state.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/views/product_reviews_view.dart';

class W49Purchases extends MockCubit<PurchaseHistoryState>
    implements PurchaseHistoryCubit {}

class W49Ratings extends MockCubit<ShopRatingState>
    implements ShopRatingCubit {}

class W49Reviews extends MockCubit<ReviewsState> implements ReviewsCubit {}

class W49Inbox extends MockCubit<ChatConversationsState>
    implements ChatConversationsCubit {}

class W49Chat extends MockCubit<ChatState> implements ChatCubit {}

// Synthetic, deterministic fixtures; no service, personal data or network access.
const w49LongShop =
    'Çınarlı Mahallesi Öğretmen Şükrü Bey Geleneksel Kahve ve Yöresel Ürünler Mağazası';
const w49LongProduct =
    'Geleneksel yöntemle kavrulmuş, özel harman öğütülmüş Türk kahvesi';
const w49LongComment =
    'Mağazada ürünü inceleyip aldım. Türk kahvesinin kokusu ve öğütülme inceliği çok güzel. Çalışanlar hazırlama önerilerini ayrıntılı biçimde anlattı. Uzun süre sonra aradığım tadı buldum.';

class W49Fixture {
  W49Fixture({this.long = false});
  final bool long;
  final purchases = W49Purchases();
  final ratings = W49Ratings();
  final reviews = W49Reviews();
  final inbox = W49Inbox();
  final chat = W49Chat();
  String get shopName => long ? w49LongShop : 'Çınar Mahalle Marketi';
  ProductEntity get product => ProductEntity(
    id: 'w49-product',
    name: long ? w49LongProduct : 'Öğütülmüş Türk kahvesi 250 g',
    price: 129.9,
    categoryId: 'w49-category',
    stock: 10,
    images: const [],
  );
  VerifiedPurchaseEntity purchase({int index = 0, bool rated = false}) =>
      VerifiedPurchaseEntity(
        id: 'w49-purchase-$index',
        sourceQrSessionId: 'w49-qr-$index',
        shopId: 'w49-shop-$index',
        shopName: shopName,
        itemCount: 2,
        totalAmount: long ? 9999999.98 : 259.8,
        confirmedAt: DateTime(2026, 9, 4, 14, 30),
        customerRating: rated ? 5 : null,
        customerRatedAt: rated ? DateTime(2026, 9, 5, 9) : null,
        items: [
          VerifiedPurchaseItemEntity(
            id: 'w49-item-$index',
            shopProductId: 'w49-offer-$index',
            productName: product.name,
            quantity: 2,
            unitPrice: long ? 4999999.99 : 129.9,
            lineTotal: long ? 9999999.98 : 259.8,
          ),
        ],
      );
  ReviewEntity get ownReview => ReviewEntity(
    id: 'w49-own',
    userId: 'w49-customer',
    productId: product.id,
    rating: 5,
    title: 'Taze ve özenli hazırlanmış',
    comment: long
        ? w49LongComment
        : 'Mağazada inceleyip aldım. Kokusu ve tadı çok güzel.',
    isVerifiedPurchase: true,
    canEdit: true,
    createdAt: DateTime(2026, 9, 4),
  );
  ReviewsLoaded get reviewState => ReviewsLoaded(
    reviews: [
      ownReview,
      ReviewEntity(
        id: 'w49-other',
        userId: 'w49-other-customer',
        productId: product.id,
        rating: 4,
        comment: 'Kahvesi çok lezzetli.',
        isVerifiedPurchase: false,
        createdAt: DateTime(2026, 9, 3),
      ),
    ],
    stats: const ProductReviewStats(
      averageRating: 4.7,
      totalReviews: 36,
      ratingDistribution: {5: 28, 4: 6, 3: 1, 2: 1, 1: 0},
    ),
    eligibility: const ProductReviewEligibility(
      productId: 'w49-product',
      eligible: true,
      canSubmit: false,
      existingReviewId: 'w49-own',
      verifiedTransactionItemId: 'w49-proof',
      verifiedTransactionId: 'w49-transaction',
    ),
    hasReachedMax: true,
  );
  List<ChatMessageEntity> messages({int count = 3}) => List.generate(
    count,
    (i) => ChatMessageEntity(
      id: 'w49-message-$i',
      senderId: i.isEven ? 'w49-owner' : 'w49-customer',
      receiverId: i.isEven ? 'w49-customer' : 'w49-owner',
      content: long
          ? w49LongComment
          : [
              'Elbette, öğleden sonra mağazada görebilirsiniz.',
              'Kahvenin öğütülmüş çeşidi var mı?',
              'Merhaba, size nasıl yardımcı olabiliriz?',
            ][i % 3],
      createdAt: DateTime(2026, 9, 5, 10, 30 - i),
      isRead: true,
    ),
  );
  Future<void> init() async {
    when(() => purchases.loadPurchases()).thenAnswer((_) async {});
    when(() => purchases.refreshPurchasesSilently()).thenAnswer((_) async {});
    when(() => purchases.close()).thenAnswer((_) async {});
    whenListen(
      purchases,
      const Stream<PurchaseHistoryState>.empty(),
      initialState: PurchaseHistoryLoaded([
        purchase(),
        purchase(index: 1, rated: true),
      ]),
    );
    whenListen(
      ratings,
      const Stream<ShopRatingState>.empty(),
      initialState: ShopRatingInitial(),
    );
    when(() => ratings.close()).thenAnswer((_) async {});
    when(
      () => ratings.submitRating(
        qrSessionId: any(named: 'qrSessionId'),
        rating: any(named: 'rating'),
      ),
    ).thenAnswer((_) async {});
    sl.registerFactory<ShopRatingCubit>(() => ratings);
    whenListen(
      reviews,
      const Stream<ReviewsState>.empty(),
      initialState: reviewState,
    );
    when(
      () => reviews.getProductReviews(any(), refresh: any(named: 'refresh')),
    ).thenAnswer((_) async {});
    when(() => reviews.loadMoreReviews(any())).thenAnswer((_) async {});
    when(() => reviews.retryEligibility(any())).thenAnswer((_) async {});
    when(() => reviews.close()).thenAnswer((_) async {});
    when(() => inbox.loadConversations()).thenAnswer((_) async {});
    when(() => inbox.refreshConversations()).thenAnswer((_) async {});
    when(() => inbox.refreshConversationsSilently()).thenAnswer((_) async {});
    when(() => inbox.close()).thenAnswer((_) async {});
    whenListen(
      inbox,
      const Stream<ChatConversationsState>.empty(),
      initialState: ChatConversationsLoaded(
        List.generate(
          6,
          (i) => ChatThreadEntity(
            otherUserId: 'w49-owner-$i',
            displayName: i == 0 ? shopName : 'Mahalle Mağazası $i',
            lastMessage: long
                ? w49LongComment
                : 'Kahvenin öğütülmüş çeşidi var mı?',
            lastMessageAt: DateTime(2026, 9, 5, 10, 30 - i),
            unreadCount: i.isEven ? 2 : 0,
            lastMessageIsMine: i.isOdd,
            lastMessageIsRead: i.isOdd,
          ),
        ),
      ),
    );
    when(() => chat.startListening()).thenAnswer((_) {});
    when(() => chat.markAllAsRead(any())).thenAnswer((_) async {});
    when(
      () => chat.getMessages(any(), refresh: any(named: 'refresh')),
    ).thenAnswer((_) async {});
    when(() => chat.loadMoreMessages(any())).thenAnswer((_) async {});
    when(() => chat.refreshMessagesSilently(any())).thenAnswer((_) async {});
    when(
      () => chat.sendMessage(
        receiverId: any(named: 'receiverId'),
        content: any(named: 'content'),
      ),
    ).thenAnswer((_) async {});
    when(() => chat.close()).thenAnswer((_) async {});
    whenListen(
      chat,
      Stream<ChatState>.value(
        ChatLoaded(messages: messages(), hasReachedMax: true),
      ),
      initialState: ChatLoading(),
    );
  }

  Widget page(String surface) => switch (surface) {
    'purchases' ||
    'shop_rating_editor' ||
    'refund' => PurchasesView(purchaseHistoryCubit: purchases),
    'shop_ratings' => CustomerRatingsView(purchaseHistoryCubit: purchases),
    'reviews' || 'review_editor' || 'review_delete' => ProductReviewsView(
      product: product,
      reviewsCubit: reviews,
    ),
    'inbox' => ConversationsView(
      conversationsCubit: inbox,
      nowProvider: () => DateTime(2026, 9, 5, 12),
    ),
    'chat' => ChatView(
      receiverId: 'w49-owner',
      receiverName: shopName,
      chatCubit: chat,
      currentUserIdProvider: () => 'w49-customer',
    ),
    _ => throw ArgumentError(surface),
  };
}

Future<void> loadW49Fonts() async {
  final fonts = FontLoader('Poppins')
    ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Poppins-Bold.ttf'));
  final iconsax = FontLoader('packages/iconsax_flutter/FlutterIconsax')
    ..addFont(
      rootBundle.load('packages/iconsax_flutter/fonts/FlutterIconsax.ttf'),
    );
  final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
  final icons = FontLoader('MaterialIcons')
    ..addFont(
      File(
        '${artifacts.path}${Platform.pathSeparator}material_fonts${Platform.pathSeparator}MaterialIcons-Regular.otf',
      ).readAsBytes().then(ByteData.sublistView),
    );
  await Future.wait([fonts.load(), iconsax.load(), icons.load()]);
}

Future<void> pumpW49(
  WidgetTester tester,
  Widget page, {
  double width = 390,
  double scale = 1,
  double keyboard = 0,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 844);
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetViewInsets);
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('w49-evidence'),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: EsnaftaVarTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: page,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}

Future<void> openW49Surface(WidgetTester tester, String surface) async {
  final action = switch (surface) {
    'shop_rating_editor' => 'purchase-shop-rating-open-action',
    'review_editor' => 'product-review-edit-w49-own',
    'review_delete' => 'product-review-delete-w49-own',
    'refund' => 'purchase-create-return-action',
    _ => null,
  };
  if (action == null) return;
  final finder = find.byKey(Key(action));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
  if (surface == 'shop_rating_editor') {
    await tester.tap(find.byKey(const Key('purchase-shop-rating-star-5')));
    await tester.pumpAndSettle();
  }
}
