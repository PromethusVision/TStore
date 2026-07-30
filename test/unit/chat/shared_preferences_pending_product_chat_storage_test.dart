import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/features/chat/data/services/shared_preferences_pending_product_chat_storage.dart';
import 'package:t_store/features/chat/domain/services/pending_product_chat_storage.dart';

void main() {
  final now = DateTime.utc(2026, 7, 30, 12);
  late SharedPreferencesPendingProductChatStorage storage;

  PendingProductChatIntent intent({
    DateTime? createdAt,
    String receiverId = 'owner-1',
    String receiverName = 'Mahalle Marketi',
    String initialDraft = 'Merhaba, ürün mağazanızda mevcut mu?',
  }) {
    return PendingProductChatIntent(
      receiverId: receiverId,
      receiverName: receiverName,
      initialDraft: initialDraft,
      createdAt: createdAt ?? now,
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = SharedPreferencesPendingProductChatStorage(
      nowProvider: () => now,
    );
  });

  test('bekleyen mesaj hedefini kaydeder ve geri getirir', () async {
    await storage.save(intent());

    expect(await storage.getPending(), intent());
  });

  test('yirmi dört saatten eski mesaj hedefini siler', () async {
    await storage.save(
      intent(
        createdAt: now.subtract(
          PendingProductChatStorage.maximumAge + const Duration(seconds: 1),
        ),
      ),
    );

    expect(await storage.getPending(), isNull);
    expect(await storage.getPending(), isNull);
  });

  test('bozuk yerel kaydı güvenli biçimde temizler', () async {
    SharedPreferences.setMockInitialValues({
      'pending_product_chat_v1': '{bozuk-json',
    });

    expect(await storage.getPending(), isNull);
    expect(
      (await SharedPreferences.getInstance()).getString(
        'pending_product_chat_v1',
      ),
      isNull,
    );
  });

  test('eksik veya aşırı uzun alanları kabul etmez', () async {
    expect(() => storage.save(intent(receiverId: '')), throwsArgumentError);
    expect(
      () => storage.save(intent(initialDraft: List.filled(1001, 'a').join())),
      throwsArgumentError,
    );
  });

  test('bekleyen mesaj hedefini açıkça temizler', () async {
    await storage.save(intent());
    await storage.clear();

    expect(await storage.getPending(), isNull);
  });

  test('beklenmeyen veri türünü güvenli biçimde temizler', () async {
    SharedPreferences.setMockInitialValues({
      'pending_product_chat_v1': jsonEncode({
        'receiver_id': 42,
        'receiver_name': 'Mahalle Marketi',
        'initial_draft': 'Taslak',
        'created_at_milliseconds': now.millisecondsSinceEpoch,
      }),
    });

    expect(await storage.getPending(), isNull);
  });
}
