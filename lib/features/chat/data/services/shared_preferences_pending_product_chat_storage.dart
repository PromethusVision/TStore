import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/features/chat/domain/services/pending_product_chat_storage.dart';

typedef PendingProductChatNowProvider = DateTime Function();

class SharedPreferencesPendingProductChatStorage
    implements PendingProductChatStorage {
  SharedPreferencesPendingProductChatStorage({
    PendingProductChatNowProvider? nowProvider,
  }) : _nowProvider = nowProvider ?? DateTime.now;

  static const String _storageKey = 'pending_product_chat_v1';
  static const int _maximumReceiverIdLength = 128;
  static const int _maximumReceiverNameLength = 200;
  static const int _maximumDraftLength = 1000;

  final PendingProductChatNowProvider _nowProvider;

  @override
  Future<PendingProductChatIntent?> getPending() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null || encoded.isEmpty) return null;

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) {
        await preferences.remove(_storageKey);
        return null;
      }

      final receiverId = decoded['receiver_id'];
      final receiverName = decoded['receiver_name'];
      final initialDraft = decoded['initial_draft'];
      final createdAtMilliseconds = decoded['created_at_milliseconds'];

      if (receiverId is! String ||
          receiverName is! String ||
          initialDraft is! String ||
          createdAtMilliseconds is! int) {
        await preferences.remove(_storageKey);
        return null;
      }

      final intent = PendingProductChatIntent(
        receiverId: receiverId.trim(),
        receiverName: receiverName.trim(),
        initialDraft: initialDraft.trim(),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          createdAtMilliseconds,
          isUtc: true,
        ),
      );
      if (!_isValid(intent) || _isExpired(intent)) {
        await preferences.remove(_storageKey);
        return null;
      }

      return intent;
    } on FormatException {
      await preferences.remove(_storageKey);
      return null;
    }
  }

  @override
  Future<void> save(PendingProductChatIntent intent) async {
    final normalizedIntent = PendingProductChatIntent(
      receiverId: intent.receiverId.trim(),
      receiverName: intent.receiverName.trim(),
      initialDraft: intent.initialDraft.trim(),
      createdAt: intent.createdAt.toUtc(),
    );
    if (!_isValid(normalizedIntent)) {
      throw ArgumentError.value(
        intent,
        'intent',
        'Bekleyen mesaj bilgileri geçerli değil.',
      );
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode({
        'receiver_id': normalizedIntent.receiverId,
        'receiver_name': normalizedIntent.receiverName,
        'initial_draft': normalizedIntent.initialDraft,
        'created_at_milliseconds':
            normalizedIntent.createdAt.millisecondsSinceEpoch,
      }),
    );
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }

  bool _isValid(PendingProductChatIntent intent) {
    return intent.receiverId.isNotEmpty &&
        intent.receiverId.length <= _maximumReceiverIdLength &&
        intent.receiverName.isNotEmpty &&
        intent.receiverName.length <= _maximumReceiverNameLength &&
        intent.initialDraft.isNotEmpty &&
        intent.initialDraft.length <= _maximumDraftLength;
  }

  bool _isExpired(PendingProductChatIntent intent) {
    final age = _nowProvider().toUtc().difference(intent.createdAt.toUtc());
    return age.isNegative || age > PendingProductChatStorage.maximumAge;
  }
}
