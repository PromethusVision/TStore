import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:t_store/features/chat/domain/repositories/chat_repository.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_conversations_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_conversations_state.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';

class MockChatRepository extends Mock implements ChatRepository {}

class MockShopRepository extends Mock implements ShopRepository {}

void main() {
  late MockChatRepository chatRepository;
  late MockShopRepository shopRepository;
  late ChatConversationsCubit cubit;

  const firstThread = ChatThreadEntity(
    otherUserId: 'owner-1',
    displayName: 'Mahalle Marketi',
    lastMessage: 'Merhaba',
    lastMessageAt: null,
    unreadCount: 1,
  );
  const updatedThread = ChatThreadEntity(
    otherUserId: 'owner-1',
    displayName: 'Mahalle Marketi',
    lastMessage: 'Ürün hazır',
    lastMessageAt: null,
    unreadCount: 2,
  );
  const fallbackThread = ChatThreadEntity(
    otherUserId: 'owner-1',
    displayName: ChatThreadEntity.fallbackDisplayName,
    lastMessage: 'Merhaba',
    lastMessageAt: null,
    unreadCount: 1,
  );
  const shop = ShopEntity(
    id: 'shop-1',
    ownerUserId: 'owner-1',
    name: ' Mahalle Marketi ',
  );

  setUp(() {
    chatRepository = MockChatRepository();
    shopRepository = MockShopRepository();
    cubit = ChatConversationsCubit(
      repository: chatRepository,
      shopRepository: shopRepository,
    );

    when(
      () => shopRepository.getShops(),
    ).thenAnswer((_) async => const Right([]));
  });

  tearDown(() async {
    await cubit.close();
  });

  test('ilk yüklemede yükleniyor ve konuşma listesini gösterir', () async {
    when(
      () => chatRepository.getConversations(),
    ).thenAnswer((_) async => const Right([firstThread]));
    final emittedStates = <ChatConversationsState>[];
    final subscription = cubit.stream.listen(emittedStates.add);

    await cubit.loadConversations();
    await pumpEventQueue();

    expect(emittedStates, [
      ChatConversationsLoading(),
      const ChatConversationsLoaded([firstThread]),
    ]);
    await subscription.cancel();
  });

  test(
    'sessiz yenileme yükleniyor ekranı göstermeden listeyi günceller',
    () async {
      var callCount = 0;
      when(() => chatRepository.getConversations()).thenAnswer((_) async {
        callCount++;
        return Right(callCount == 1 ? [firstThread] : [updatedThread]);
      });
      await cubit.loadConversations();
      final emittedStates = <ChatConversationsState>[];
      final subscription = cubit.stream.listen(emittedStates.add);

      await cubit.refreshConversationsSilently();
      await pumpEventQueue();

      expect(emittedStates, const [
        ChatConversationsLoaded([updatedThread]),
      ]);
      expect(emittedStates.whereType<ChatConversationsLoading>(), isEmpty);
      await subscription.cancel();
    },
  );

  test('sessiz yenileme hatasında mevcut listeyi ekranda tutar', () async {
    var callCount = 0;
    when(() => chatRepository.getConversations()).thenAnswer((_) async {
      callCount++;
      return callCount == 1
          ? const Right([firstThread])
          : const Left('Bağlantı kurulamadı');
    });
    await cubit.loadConversations();
    final emittedStates = <ChatConversationsState>[];
    final subscription = cubit.stream.listen(emittedStates.add);

    await cubit.refreshConversationsSilently();
    await pumpEventQueue();

    expect(emittedStates, isEmpty);
    expect(cubit.state, const ChatConversationsLoaded([firstThread]));
    await subscription.cancel();
  });

  test('devam eden istek varken ikinci yenilemeyi başlatmaz', () async {
    final response = Completer<Either<String, List<ChatThreadEntity>>>();
    when(
      () => chatRepository.getConversations(),
    ).thenAnswer((_) => response.future);

    final firstLoad = cubit.loadConversations();
    await cubit.refreshConversationsSilently();

    verify(() => chatRepository.getConversations()).called(1);
    response.complete(const Right([firstThread]));
    await firstLoad;
  });

  test('konuşmayı gerçek mağaza adıyla gösterir', () async {
    when(
      () => chatRepository.getConversations(),
    ).thenAnswer((_) async => const Right([fallbackThread]));
    when(
      () => shopRepository.getShops(),
    ).thenAnswer((_) async => const Right([shop]));

    await cubit.loadConversations();

    final state = cubit.state as ChatConversationsLoaded;
    expect(state.threads.single.displayName, 'Mahalle Marketi');
  });

  test('mağaza bilgisi yüklenemezse teknik kimlik göstermez', () async {
    when(
      () => chatRepository.getConversations(),
    ).thenAnswer((_) async => const Right([fallbackThread]));
    when(
      () => shopRepository.getShops(),
    ).thenAnswer((_) async => const Left('Geçici mağaza bilgisi hatası'));

    await cubit.loadConversations();

    final state = cubit.state as ChatConversationsLoaded;
    expect(
      state.threads.single.displayName,
      ChatThreadEntity.fallbackDisplayName,
    );
    expect(state.threads.single.displayName, isNot(contains('owner-1')));
  });

  test(
    'sonraki yenilemede genel adı gerçek mağaza adıyla değiştirir',
    () async {
      when(
        () => chatRepository.getConversations(),
      ).thenAnswer((_) async => const Right([fallbackThread]));
      var shopCallCount = 0;
      when(() => shopRepository.getShops()).thenAnswer((_) async {
        shopCallCount++;
        return Right(shopCallCount == 1 ? const [] : const [shop]);
      });

      await cubit.loadConversations();
      expect(
        (cubit.state as ChatConversationsLoaded).threads.single.displayName,
        ChatThreadEntity.fallbackDisplayName,
      );

      await cubit.refreshConversationsSilently();

      expect(
        (cubit.state as ChatConversationsLoaded).threads.single.displayName,
        'Mahalle Marketi',
      );
    },
  );
}
