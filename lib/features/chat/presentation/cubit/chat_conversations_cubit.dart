import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:t_store/features/chat/domain/repositories/chat_repository.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_conversations_state.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';

class ChatConversationsCubit extends Cubit<ChatConversationsState> {
  final ChatRepository repository;
  final ShopRepository shopRepository;
  bool _isLoading = false;

  ChatConversationsCubit({
    required this.repository,
    required this.shopRepository,
  }) : super(ChatConversationsInitial());

  Future<void> loadConversations() async {
    await _loadConversations(showLoading: true, preserveLoadedState: false);
  }

  Future<void> refreshConversations() async {
    await _loadConversations(showLoading: true, preserveLoadedState: false);
  }

  Future<void> refreshConversationsSilently() async {
    await _loadConversations(showLoading: false, preserveLoadedState: true);
  }

  Future<void> _loadConversations({
    required bool showLoading,
    required bool preserveLoadedState,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    final previousState = state;
    if (showLoading) {
      emit(ChatConversationsLoading());
    }

    try {
      final result = await repository.getConversations();

      await result.fold(
        (error) async {
          if (preserveLoadedState && previousState is ChatConversationsLoaded) {
            return;
          }
          emit(ChatConversationsError(error));
        },
        (threads) async {
          final enrichedThreads = await _enrichWithShopNames(threads);
          emit(ChatConversationsLoaded(enrichedThreads));
        },
      );
    } finally {
      _isLoading = false;
    }
  }

  Future<List<ChatThreadEntity>> _enrichWithShopNames(
    List<ChatThreadEntity> threads,
  ) async {
    if (threads.isEmpty) return threads;

    final shopsResult = await shopRepository.getShops();

    return shopsResult.fold((_) => threads, (shops) {
      final shopNameByOwnerId = <String, String>{};

      for (final shop in shops) {
        final ownerUserId = shop.ownerUserId?.trim();
        if (ownerUserId == null || ownerUserId.isEmpty) continue;

        final shopName = shop.name.trim();
        if (shopName.isEmpty) continue;

        shopNameByOwnerId.putIfAbsent(ownerUserId, () => shopName);
      }

      return threads.map((thread) {
        final shopName = shopNameByOwnerId[thread.otherUserId];
        if (shopName == null || shopName.isEmpty) return thread;

        return thread.copyWith(displayName: shopName);
      }).toList();
    });
  }
}
