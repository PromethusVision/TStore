import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/chat/domain/repositories/chat_repository.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_state.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository repository;
  late ChatUnreadCubit cubit;

  setUp(() {
    repository = MockChatRepository();
    cubit = ChatUnreadCubit(chatRepository: repository);
  });

  tearDown(() async {
    if (!cubit.isClosed) {
      await cubit.close();
    }
  });

  test('ilk yüklemede okunmamış mesaj sayısını gösterir', () async {
    when(
      () => repository.getUnreadCount(),
    ).thenAnswer((_) async => const Right(3));
    final states = <ChatUnreadState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.loadUnreadCount();
    await pumpEventQueue();

    expect(states, [ChatUnreadLoading(), const ChatUnreadLoaded(3)]);
    await subscription.cancel();
  });

  test(
    'sessiz yenilemede yükleniyor durumu göstermeden sayıyı günceller',
    () async {
      var callCount = 0;
      when(() => repository.getUnreadCount()).thenAnswer((_) async {
        callCount++;
        return Right(callCount == 1 ? 2 : 5);
      });
      await cubit.loadUnreadCount();
      final states = <ChatUnreadState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.refreshUnreadCountSilently();
      await pumpEventQueue();

      expect(states, [const ChatUnreadLoaded(5)]);
      expect(states.whereType<ChatUnreadLoading>(), isEmpty);
      await subscription.cancel();
    },
  );

  test('sessiz yenileme hatasında mevcut sayıyı korur', () async {
    var callCount = 0;
    when(() => repository.getUnreadCount()).thenAnswer((_) async {
      callCount++;
      return callCount == 1
          ? const Right(2)
          : const Left('Bağlantı kurulamadı');
    });
    await cubit.loadUnreadCount();
    final states = <ChatUnreadState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.refreshUnreadCountSilently();

    expect(states, isEmpty);
    expect(cubit.state, const ChatUnreadLoaded(2));
    await subscription.cancel();
  });

  test('devam eden istek varken ikinci yenilemeyi başlatmaz', () async {
    final response = Completer<Either<String, int>>();
    when(() => repository.getUnreadCount()).thenAnswer((_) => response.future);

    final firstLoad = cubit.loadUnreadCount();
    await cubit.refreshUnreadCountSilently();

    verify(() => repository.getUnreadCount()).called(1);
    response.complete(const Right(4));
    await firstLoad;
    expect(cubit.state, const ChatUnreadLoaded(4));
  });

  test('ekran kapanınca geç dönen unread isteğini güvenle yok sayar', () async {
    final response = Completer<Either<String, int>>();
    when(() => repository.getUnreadCount()).thenAnswer((_) => response.future);

    final loadFuture = cubit.loadUnreadCount();
    await cubit.close();
    response.complete(const Right(4));

    await expectLater(loadFuture, completes);
    expect(cubit.isClosed, isTrue);
  });

  test('oturum kapandığında okunmamış mesaj sayısını sıfırlar', () async {
    when(
      () => repository.getUnreadCount(),
    ).thenAnswer((_) async => const Right(4));
    await cubit.loadUnreadCount();

    cubit.resetUnreadCount();

    expect(cubit.state, const ChatUnreadLoaded(0));
    verify(() => repository.getUnreadCount()).called(1);
  });
}
