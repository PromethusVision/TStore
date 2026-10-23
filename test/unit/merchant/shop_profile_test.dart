import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/merchant/data/supabase_merchant_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/shop/data/models/shop_model.dart';
import 'package:t_store/features/shop/domain/entities/shop_opening_hours.dart';
import 'merchant_repository_test.dart' show access, shopRow, user;

void main() {
  test(
    'daily overrides distinguish unspecified from closed without losing legacy text',
    () {
      final hours = {
        'mon_sat': '09:00 - 18:00',
        'sun': 'Kapalı',
        'note': 'Yaz dönemi',
        'tue': '',
      };
      expect(ShopOpeningHours.value(hours, 'mon'), '09:00 - 18:00');
      expect(ShopOpeningHours.value(hours, 'sat'), '09:00 - 18:00');
      expect(ShopOpeningHours.value(hours, 'tue'), isNull);
      final text = ShopOpeningHours.format(hours);
      expect(text, contains('Salı: Belirtilmedi'));
      expect(text, contains('Pazar: Kapalı'));
      expect(text, isNot(contains('mon_sat')));
      expect(hours['note'], 'Yaz dönemi');
      expect(
        ShopOpeningHours.format({'Pazartesi': '09:00 - 18:00'}),
        'Pazartesi: 09:00 - 18:00',
      );
      expect(
        ShopOpeningHours.value({'Pazartesi': 'özel saat'}, 'mon'),
        'özel saat',
      );
    },
  );
  test('time format handles overnight and rejects malformed ranges', () {
    expect(ShopOpeningHours.label('22:00–02:00'), '22:00–02:00 (ertesi gün)');
    expect(ShopOpeningHours.minutes('9:00 - 18:30'), [540, 1110]);
    expect(ShopOpeningHours.minutes('24:00-18:60'), isNull);
    expect(ShopOpeningHours.label('randevu ile'), 'randevu ile');
  });
  test(
    'old drafts do not clear photo/location and profile drafts validate coordinate pairs',
    () {
      expect(
        const MerchantShopDraft(
          name: 'a',
        ).toPayload().containsKey('photo_path'),
        false,
      );
      final clear = const MerchantShopDraft(
        name: 'a',
        profileDetails: true,
      ).toPayload();
      expect(clear['photo_path'], isNull);
      expect(clear.containsKey('latitude'), true);
      for (final coords in [
        [41.0, null],
        [null, 29.0],
        [double.nan, 29.0],
        [41.0, double.infinity],
        [91.0, 29.0],
      ]) {
        expect(
          MerchantShopDraft(
            name: 'a',
            profileDetails: true,
            latitude: coords[0],
            longitude: coords[1],
          ).error,
          isNotNull,
        );
      }
      expect(
        const MerchantShopDraft(
          name: 'a',
          profileDetails: true,
          latitude: 0,
          longitude: 0,
        ).error,
        isNull,
      );
    },
  );
  test('shop roundtrip retains photo and supports explicit removal', () {
    final shop = ShopModel.fromJson({
      ...shopRow(),
      'photo_path': 'shops/a/photo.png',
      'latitude': '41.0',
      'longitude': 29,
    });
    expect(ShopModel.fromEntity(shop).toJson()['photo_path'], shop.photoPath);
    expect(shop.copyWith(name: 'changed').photoPath, shop.photoPath);
    expect(shop.copyWith(clearPhoto: true).photoPath, isNull);
    expect(shop.copyWith(clearLocation: true).latitude, isNull);
    expect(shop.copyWith(clearLocation: true).longitude, isNull);
  });

  group('shop photo transport', () {
    late SupabaseClient client;
    late SupabaseMerchantRepository repo;
    late String? session;
    late String role;
    late List<http.Request> uploads;
    Future<http.Response> Function(http.Request)? upload;
    setUp(() {
      session = 'first';
      role = 'merchant';
      uploads = [];
      upload = null;
      client = SupabaseClient(
        'https://shop-profile.invalid',
        'synthetic-key',
        httpClient: MockClient((r) async {
          Object body;
          if (r.url.path.endsWith('/profiles')) {
            body = [
              {'id': user.id, 'email': 'owner@example.invalid', 'role': role},
            ];
          } else if (r.url.path.endsWith('/shops')) {
            body = [shopRow()];
          } else {
            uploads.add(r);
            if (upload != null) return upload!(r);
            body = {'Key': 'uploaded'};
          }
          return http.Response(
            jsonEncode(body),
            200,
            request: r,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      repo = SupabaseMerchantRepository(
        client: client,
        currentUserId: () => user.id,
        currentSessionKey: () => session,
      );
    });
    tearDown(() => client.dispose());
    final png = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 0]);
    test(
      'immutable upload is shop scoped and never publishes shop row',
      () async {
        final first = (await repo.stageShopPhoto(
          access,
          png,
        )).getOrElse(() => 'failed');
        final second = (await repo.stageShopPhoto(
          access,
          png,
        )).getOrElse(() => 'failed');
        expect(first, matches(RegExp(r'^shops/shop-a/[a-f0-9]{32}\.png$')));
        expect(second, isNot(first));
        expect(uploads, hasLength(2));
        expect(uploads.first.headers['x-upsert'], 'false');
        expect(
          utf8.decode(uploads.first.bodyBytes, allowMalformed: true),
          contains('image/png'),
        );
      },
    );
    test('revoked role and invalid input never upload', () async {
      role = 'customer';
      expect((await repo.stageShopPhoto(access, png)).isLeft(), true);
      role = 'merchant';
      expect((await repo.stageShopPhoto(access, Uint8List(0))).isLeft(), true);
      expect(
        (await repo.stageShopPhoto(
          access,
          Uint8List(shopPhotoMaxBytes + 1),
        )).isLeft(),
        true,
      );
      expect(uploads, isEmpty);
    });
    test('new same-account session discards a delayed upload result', () async {
      final gate = Completer<http.Response>();
      upload = (_) => gate.future;
      final pending = repo.stageShopPhoto(access, png);
      while (uploads.isEmpty) {
        await Future<void>.delayed(Duration.zero);
      }
      session = 'second';
      gate.complete(
        http.Response(
          '{"Key":"uploaded"}',
          200,
          headers: {'content-type': 'application/json'},
        ),
      );
      expect(
        (await pending).swap().getOrElse(() => ''),
        merchantSessionChanged,
      );
    });
  });
}
