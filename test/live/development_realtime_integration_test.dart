import 'dart:convert';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:t_store/features/chat/domain/entities/chat_message_entity.dart';
import 'package:t_store/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_state.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_state.dart';
import 'package:t_store/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';

const _liveTestEnabled = bool.fromEnvironment(
  'ESNAFTAVAR_RUN_DEVELOPMENT_LIVE_TESTS',
);
const _developmentUrl = String.fromEnvironment('SUPABASE_DEVELOPMENT_URL');
const _developmentAnonKey = String.fromEnvironment(
  'SUPABASE_DEVELOPMENT_ANON_KEY',
);
const _expectedProjectRef = 'tnipyxnvhgelwdpykyez';
const _expectedProjectHost = '$_expectedProjectRef.supabase.co';
const _testDataPrefix = 'w4a3_';

class _MockSupabaseService extends Mock implements SupabaseService {}

class _FakeRealtimeChannel extends Fake implements RealtimeChannel {}

void main() {
  final skipReason = _liveTestEnabled
      ? false
      : 'Development live tests require the explicit '
            'ESNAFTAVAR_RUN_DEVELOPMENT_LIVE_TESTS=true Dart define.';

  group('Wave 4 Development Realtime integration', () {
    late _LiveFixture fixture;
    var fixtureInitialized = false;

    setUpAll(() async {
      final config = SupabaseConfig.forEnvironment(
        environment: AppEnvironment.development,
        supabaseUrl: _developmentUrl,
        supabaseAnonKey: _developmentAnonKey,
      );
      expect(
        Uri.parse(config.supabaseUrl).host,
        _expectedProjectHost,
        reason: 'Live tests are locked to EsnaftaVar Development.',
      );
      await _verifyDisposableSignupIsSafe(config);

      registerFallbackValue(_FakeRealtimeChannel());
      fixture = _LiveFixture(config: config);
      fixtureInitialized = true;
      try {
        await fixture.createPrincipals();
      } catch (_) {
        await fixture.dispose();
        rethrow;
      }
    });

    tearDownAll(() async {
      if (fixtureInitialized) await fixture.dispose();
    });

    test(
      'chat Realtime preserves participant RLS and lifecycle semantics',
      () async {
        final clientA = fixture.clientA;
        final clientB = fixture.clientB;
        final userA = fixture.userA;
        final userB = fixture.userB;
        final repositoryA = fixture.chatRepositoryA;
        final repositoryB = fixture.chatRepositoryB;
        final cubitB = ChatCubit(repository: repositoryB);
        final unreadCubitB = ChatUnreadCubit(chatRepository: repositoryB);
        final states = <ChatState>[];
        final stateSubscription = cubitB.stream.listen(states.add);

        try {
          await cubitB.getMessages(userA.id);
          expect(cubitB.state, isA<ChatLoaded>());
          expect((cubitB.state as ChatLoaded).messages, isEmpty);

          // Starting twice exercises the production generation guards. Only the
          // latest stream/channel may remain active.
          cubitB
            ..startListening()
            ..startListening();
          await _waitUntil(
            () => _connectedChannelCount(clientB) == 1,
            description: 'one joined chat channel for User B',
          );

          final firstMessage = _expectRight(
            await repositoryA.sendMessage(
              receiverId: userB.id,
              content: '${_testDataPrefix}chat_first_${fixture.runId}',
            ),
          );
          await _waitUntil(
            () => _loadedChatMessages(
              cubitB,
            ).any((message) => message.id == firstMessage.id),
            description: 'first A-to-B chat Realtime event',
          );

          final matchingFirstMessages = _loadedChatMessages(
            cubitB,
          ).where((message) => message.id == firstMessage.id);
          expect(matchingFirstMessages, hasLength(1));
          expect(firstMessage.senderId, userA.id);
          expect(firstMessage.receiverId, userB.id);
          expect(
            states.whereType<NewMessageReceived>().where(
              (state) => state.message.id == firstMessage.id,
            ),
            hasLength(1),
          );

          final spoofedSenderError = await _expectPostgrestDenied(
            () => clientB.from(SupabaseTables.chatMessages).insert({
              'sender_id': userA.id,
              'receiver_id': userB.id,
              'content': '${_testDataPrefix}spoof_${fixture.runId}',
            }),
          );
          expect(spoofedSenderError.code, '42501');

          final userAReadAttempt = await clientA
              .from(SupabaseTables.chatMessages)
              .update({'is_read': true})
              .eq('id', firstMessage.id)
              .select('id');
          expect(userAReadAttempt, isEmpty);

          await Future.wait([
            unreadCubitB.loadUnreadCount(),
            unreadCubitB.refreshUnreadCountSilently(),
          ]);
          expect(unreadCubitB.state, const ChatUnreadLoaded(1));

          final newMessageStateCountBeforeReconnect = states
              .whereType<NewMessageReceived>()
              .length;
          final channelCountBeforeReconnect = clientB.getChannels().length;
          await _reconnect(clientB);
          await _waitUntil(
            () =>
                clientB.getChannels().length == channelCountBeforeReconnect &&
                _connectedChannelCount(clientB) == channelCountBeforeReconnect,
            description: 'User B chat channel rejoin',
          );
          await Future<void>.delayed(const Duration(milliseconds: 600));
          expect(
            states.whereType<NewMessageReceived>().length,
            newMessageStateCountBeforeReconnect,
            reason: 'The reconnect snapshot must not replay an unchanged row.',
          );

          final secondMessage = _expectRight(
            await repositoryA.sendMessage(
              receiverId: userB.id,
              content: '${_testDataPrefix}chat_second_${fixture.runId}',
            ),
          );
          await _waitUntil(
            () => _loadedChatMessages(
              cubitB,
            ).any((message) => message.id == secondMessage.id),
            description: 'post-reconnect A-to-B chat event',
          );
          expect(
            states.whereType<NewMessageReceived>().where(
              (state) => state.message.id == secondMessage.id,
            ),
            hasLength(1),
          );

          final unreadCount = _expectRight(await repositoryB.getUnreadCount());
          expect(unreadCount, 2);
          final userBThreads = _expectRight(
            await repositoryB.getConversations(),
          );
          _expectConversationSummary(
            userBThreads,
            otherUserId: userA.id,
            lastMessage: secondMessage.content,
            unreadCount: 2,
            lastMessageIsMine: false,
          );
          final userAThreads = _expectRight(
            await repositoryA.getConversations(),
          );
          _expectConversationSummary(
            userAThreads,
            otherUserId: userB.id,
            lastMessage: secondMessage.content,
            unreadCount: 0,
            lastMessageIsMine: true,
          );

          _expectRight(await repositoryB.markAllAsRead(userA.id));
          expect(_expectRight(await repositoryB.getUnreadCount()), 0);

          await cubitB.close();
          await _waitUntil(
            () => clientB.getChannels().isEmpty,
            description: 'chat channel removal after Cubit disposal',
          );
          final stateCountAfterDispose = states.length;
          _expectRight(
            await repositoryA.sendMessage(
              receiverId: userB.id,
              content: '${_testDataPrefix}chat_after_dispose_${fixture.runId}',
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 900));
          expect(states, hasLength(stateCountAfterDispose));
        } finally {
          await stateSubscription.cancel();
          if (!cubitB.isClosed) await cubitB.close();
          await unreadCubitB.close();
          await _waitUntil(
            () => clientB.getChannels().isEmpty,
            description: 'chat test channel cleanup',
          );
          await clientB
              .from(SupabaseTables.notifications)
              .delete()
              .eq('user_id', userB.id);
        }
      },
      timeout: const Timeout(Duration(minutes: 4)),
    );

    test(
      'notification trigger Realtime isolates recipients and lifecycle',
      () async {
        final clientA = fixture.clientA;
        final clientB = fixture.clientB;
        final userA = fixture.userA;
        final userB = fixture.userB;
        final chatRepositoryA = fixture.chatRepositoryA;
        final repositoryA = fixture.notificationRepositoryA;
        final repositoryB = fixture.notificationRepositoryB;
        final cubitA = NotificationsCubit(repository: repositoryA);
        final cubitB = NotificationsCubit(repository: repositoryB);
        final statesA = <NotificationsState>[];
        final statesB = <NotificationsState>[];
        final stateSubscriptionA = cubitA.stream.listen(statesA.add);
        final stateSubscriptionB = cubitB.stream.listen(statesB.add);

        try {
          await Future.wait([
            cubitA.getNotifications(),
            cubitB.getNotifications(),
          ]);
          expect(_loadedNotifications(cubitA), isEmpty);
          expect(_loadedNotifications(cubitB), isEmpty);
          await _waitUntil(
            () =>
                _connectedChannelCount(clientA) == 1 &&
                _connectedChannelCount(clientB) == 1,
            description: 'independent User A and User B notification channels',
          );

          final directInsertError = await _expectPostgrestDenied(
            () => clientB.from(SupabaseTables.notifications).insert({
              'user_id': userB.id,
              'title': '${_testDataPrefix}forbidden_${fixture.runId}',
              'body': '${_testDataPrefix}direct_insert_${fixture.runId}',
              'type': 'system',
            }),
          );
          expect(directInsertError.code, '42501');

          final triggerMessage = _expectRight(
            await chatRepositoryA.sendMessage(
              receiverId: userB.id,
              content: '${_testDataPrefix}notification_first_${fixture.runId}',
            ),
          );
          await _waitUntil(
            () => _loadedNotifications(cubitB).any(
              (notification) =>
                  notification.actionId == userA.id &&
                  notification.type == NotificationType.chat,
            ),
            description: 'chat-triggered notification for User B',
          );

          final firstNotification = _loadedNotifications(cubitB).singleWhere(
            (notification) =>
                notification.actionId == userA.id &&
                notification.type == NotificationType.chat,
          );
          expect(firstNotification.userId, userB.id);
          expect(firstNotification.isRead, isFalse);
          expect(cubitB.unreadCount, 1);
          expect(_loadedNotifications(cubitA), isEmpty);
          expect(
            statesB.whereType<NewNotificationReceived>().where(
              (state) => state.notification.id == firstNotification.id,
            ),
            hasLength(1),
          );

          final foreignNotificationRows = await clientA
              .from(SupabaseTables.notifications)
              .select('id')
              .eq('id', firstNotification.id);
          expect(foreignNotificationRows, isEmpty);

          await cubitB.markAsRead(firstNotification.id);
          await _waitUntil(
            () => _loadedNotifications(cubitB).any(
              (notification) =>
                  notification.id == firstNotification.id &&
                  notification.isRead,
            ),
            description: 'notification read update Realtime event',
          );
          expect(cubitB.unreadCount, 0);
          expect(_expectRight(await repositoryB.getUnreadCount()), 0);

          final firstNotificationEventsBeforeReconnect = statesB
              .whereType<NewNotificationReceived>()
              .where((state) => state.notification.id == firstNotification.id)
              .length;
          final channelsABeforeReconnect = clientA.getChannels().length;
          final channelsBBeforeReconnect = clientB.getChannels().length;
          await Future.wait([_reconnect(clientA), _reconnect(clientB)]);
          await _waitUntil(
            () =>
                clientA.getChannels().length == channelsABeforeReconnect &&
                clientB.getChannels().length == channelsBBeforeReconnect &&
                _connectedChannelCount(clientA) == channelsABeforeReconnect &&
                _connectedChannelCount(clientB) == channelsBBeforeReconnect,
            description: 'notification channels rejoin without duplication',
          );
          await Future<void>.delayed(const Duration(milliseconds: 600));
          expect(
            statesB
                .whereType<NewNotificationReceived>()
                .where((state) => state.notification.id == firstNotification.id)
                .length,
            firstNotificationEventsBeforeReconnect,
          );

          _expectRight(
            await chatRepositoryA.sendMessage(
              receiverId: userB.id,
              content: '${_testDataPrefix}notification_second_${fixture.runId}',
            ),
          );
          await _waitUntil(
            () => _loadedNotifications(cubitB).length == 2,
            description: 'post-reconnect notification for User B',
          );
          final notificationIds = _loadedNotifications(
            cubitB,
          ).map((notification) => notification.id).toSet();
          expect(notificationIds, hasLength(2));
          expect(
            statesB
                .whereType<NewNotificationReceived>()
                .map((state) => state.notification.id)
                .toSet(),
            hasLength(2),
          );
          expect(_loadedNotifications(cubitA), isEmpty);

          await cubitB.close();
          await _waitUntil(
            () => clientB.getChannels().isEmpty,
            description: 'notification channel removal after Cubit disposal',
          );
          final stateCountAfterDispose = statesB.length;
          _expectRight(
            await chatRepositoryA.sendMessage(
              receiverId: userB.id,
              content:
                  '${_testDataPrefix}notification_after_dispose_${fixture.runId}',
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 900));
          expect(statesB, hasLength(stateCountAfterDispose));
          expect(_loadedNotifications(cubitA), isEmpty);

          final triggerRows = await clientB
              .from(SupabaseTables.notifications)
              .select('id, data')
              .eq('type', 'chat');
          expect(triggerRows, hasLength(3));
          expect(
            triggerRows.every(
              (row) =>
                  (row['data'] as Map<String, dynamic>)['action_id'] ==
                  userA.id,
            ),
            isTrue,
          );
          expect(triggerMessage.senderId, userA.id);
        } finally {
          await stateSubscriptionA.cancel();
          await stateSubscriptionB.cancel();
          if (!cubitA.isClosed) await cubitA.close();
          if (!cubitB.isClosed) await cubitB.close();
          await _waitUntil(
            () =>
                clientA.getChannels().isEmpty && clientB.getChannels().isEmpty,
            description: 'notification test channel cleanup',
          );
        }
      },
      timeout: const Timeout(Duration(minutes: 4)),
    );
  }, skip: skipReason);
}

final class _LiveFixture {
  _LiveFixture({required this.config})
    : runId = _newRunId(),
      clientA = _newClient(config),
      clientB = _newClient(config);

  final SupabaseConfig config;
  final String runId;
  final SupabaseClient clientA;
  final SupabaseClient clientB;

  _LivePrincipal? _userA;
  _LivePrincipal? _userB;
  bool _disposed = false;

  _LivePrincipal get userA => _userA!;
  _LivePrincipal get userB => _userB!;

  late final SupabaseService serviceA = _serviceFor(clientA);
  late final SupabaseService serviceB = _serviceFor(clientB);
  late final ChatRepositoryImpl chatRepositoryA = ChatRepositoryImpl(
    supabaseService: serviceA,
  );
  late final ChatRepositoryImpl chatRepositoryB = ChatRepositoryImpl(
    supabaseService: serviceB,
  );
  late final NotificationRepositoryImpl notificationRepositoryA =
      NotificationRepositoryImpl(supabaseService: serviceA);
  late final NotificationRepositoryImpl notificationRepositoryB =
      NotificationRepositoryImpl(supabaseService: serviceB);

  Future<void> createPrincipals() async {
    _userA = await _createPrincipal(client: clientA, label: 'a', runId: runId);
    _userB = await _createPrincipal(client: clientB, label: 'b', runId: runId);
    expect(userA.id, isNot(userB.id));
    expect(clientA.auth.currentUser?.id, userA.id);
    expect(clientB.auth.currentUser?.id, userB.id);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    final cleanupErrors = <Object>[];
    for (final client in [clientA, clientB]) {
      try {
        await client.removeAllChannels();
        if (client.auth.currentSession != null) {
          await client.rpc<void>('delete_current_customer_account');
          await client.auth.signOut(scope: SignOutScope.local);
        }
      } catch (error) {
        cleanupErrors.add(error);
      } finally {
        await client.dispose();
      }
    }

    if (cleanupErrors.isNotEmpty) {
      throw TestFailure(
        'Development live test data cleanup failed for '
        '${cleanupErrors.length} principal(s).',
      );
    }
  }
}

final class _LivePrincipal {
  const _LivePrincipal({required this.id});

  final String id;
}

SupabaseClient _newClient(SupabaseConfig config) {
  return SupabaseClient(
    config.supabaseUrl,
    config.supabaseAnonKey,
    authOptions: const AuthClientOptions(
      authFlowType: AuthFlowType.implicit,
      autoRefreshToken: false,
    ),
  );
}

Future<void> _verifyDisposableSignupIsSafe(SupabaseConfig config) async {
  final settingsUri = Uri.parse(
    config.supabaseUrl,
  ).replace(path: '/auth/v1/settings');
  final response = await http.get(
    settingsUri,
    headers: {'apikey': config.supabaseAnonKey},
  );
  if (response.statusCode != 200) {
    throw TestFailure(
      'AUTH_BLOCKER: Development Auth settings could not be verified before '
      'creating disposable principals.',
    );
  }

  final settings = jsonDecode(response.body) as Map<String, dynamic>;
  if (settings['disable_signup'] == true) {
    throw TestFailure(
      'AUTH_BLOCKER: normal Development Auth signup is disabled.',
    );
  }
  if (settings['mailer_autoconfirm'] != true) {
    throw TestFailure(
      'AUTH_BLOCKER: Development email confirmation is enabled; normal '
      'signup cannot return authenticated, self-cleanable w4a3_ principals.',
    );
  }
}

SupabaseService _serviceFor(SupabaseClient client) {
  final service = _MockSupabaseService();
  when(() => service.client).thenReturn(client);
  when(() => service.currentUser).thenAnswer((_) => client.auth.currentUser);
  when(() => service.unsubscribe(any())).thenAnswer((invocation) async {
    final channel = invocation.positionalArguments.single as RealtimeChannel;
    await client.removeChannel(channel);
  });
  return service;
}

Future<_LivePrincipal> _createPrincipal({
  required SupabaseClient client,
  required String label,
  required String runId,
}) async {
  final email = '$_testDataPrefix${label}_$runId@example.com';
  final password = 'W4a3!${runId}z';
  final response = await client.auth.signUp(
    email: email,
    password: password,
    data: {
      'full_name': '${_testDataPrefix}User ${label.toUpperCase()} $runId',
      'privacy_notice_acknowledged': true,
      'privacy_notice_version': '2026-07-17',
      'terms_of_use_accepted': true,
      'terms_of_use_version': '2026-07-17',
    },
  );
  final signedUpUser = response.user;
  if (signedUpUser == null || response.session == null) {
    throw TestFailure(
      'AUTH_BLOCKER: normal Development signup did not return an '
      'authenticated session (email confirmation may be required).',
    );
  }

  await client.auth.signOut(scope: SignOutScope.local);
  final signInResponse = await client.auth.signInWithPassword(
    email: email,
    password: password,
  );
  if (signInResponse.session == null || signInResponse.user == null) {
    throw TestFailure(
      'AUTH_BLOCKER: normal Development password login did not return a '
      'session.',
    );
  }
  return _LivePrincipal(id: signedUpUser.id);
}

String _newRunId() {
  final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
  final random = Random.secure().nextInt(0x7fffffff).toRadixString(16);
  return '${timestamp}_$random';
}

T _expectRight<T>(Either<String, T> result) {
  return result.fold((error) => throw TestFailure(error), (value) => value);
}

Future<PostgrestException> _expectPostgrestDenied(
  Future<dynamic> Function() action,
) async {
  try {
    await action();
  } on PostgrestException catch (error) {
    return error;
  }
  throw TestFailure('Expected the Development RLS/grant boundary to deny.');
}

List<ChatMessageEntity> _loadedChatMessages(ChatCubit cubit) {
  final state = cubit.state;
  return state is ChatLoaded ? state.messages : const [];
}

List<NotificationEntity> _loadedNotifications(NotificationsCubit cubit) {
  final state = cubit.state;
  return state is NotificationsLoaded ? state.notifications : const [];
}

void _expectConversationSummary(
  List<ChatThreadEntity> threads, {
  required String otherUserId,
  required String lastMessage,
  required int unreadCount,
  required bool lastMessageIsMine,
}) {
  final thread = threads.singleWhere(
    (candidate) => candidate.otherUserId == otherUserId,
  );
  expect(thread.lastMessage, lastMessage);
  expect(thread.unreadCount, unreadCount);
  expect(thread.lastMessageIsMine, lastMessageIsMine);
}

int _connectedChannelCount(SupabaseClient client) {
  if (!client.realtime.isConnected) return 0;

  return client.getChannels().where((channel) {
    // The SDK currently exposes no public subscription-ready signal. A socket
    // can be connected before its channels have completed their server join.
    // ignore: invalid_use_of_internal_member
    return channel.isJoined;
  }).length;
}

Future<void> _reconnect(SupabaseClient client) async {
  final channelCount = client.getChannels().length;
  final connection = client.realtime.conn;
  if (connection == null || !client.realtime.isConnected) {
    throw TestFailure('Cannot interrupt a disconnected Realtime client.');
  }

  // Closing the transport directly models an unexpected network loss. Calling
  // RealtimeClient.disconnect() would mark the close as user initiated and,
  // by design, suppress the SDK's reconnect and channel-rejoin lifecycle.
  // ignore: invalid_use_of_internal_member
  await connection.sink.close(4001, 'w4a3_live_reconnect');

  await _waitUntil(
    () => _connectedChannelCount(client) == 0,
    description: 'Realtime channels to observe the interrupted connection',
  );
  await _waitUntil(
    () =>
        client.getChannels().length == channelCount &&
        _connectedChannelCount(client) == channelCount,
    description: 'Realtime channels to rejoin after automatic reconnect',
    timeout: const Duration(seconds: 35),
  );
}

Future<void> _waitUntil(
  bool Function() predicate, {
  required String description,
  Duration timeout = const Duration(seconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (predicate()) return;
    await Future<void>.delayed(const Duration(milliseconds: 75));
  }
  throw TestFailure('Timed out waiting for $description.');
}
