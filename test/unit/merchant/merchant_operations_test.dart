import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/merchant/data/supabase_merchant_operations_repository.dart';
import 'package:t_store/features/merchant/data/supabase_catalog_media_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'catalog_media_test.dart' show access, response;

void main() {
  test(
    'bounded RPC projects exact counts, not the first recovery page length',
    () async {
      final requests = <http.Request>[];
      final client = SupabaseClient(
        'http://localhost:54321',
        'local-test',
        httpClient: MockClient((r) async {
          requests.add(r);
          return response({
            'pending_submissions': 105,
            'approved_submissions': 2,
            'rejected_submissions': 1,
            'pending_listings': 44,
            'uploads': [
              {'listing_id': 'l', 'product_name': 'Süt', 'photo_count': 2},
            ],
          }, request: r);
        }),
      );
      addTearDown(client.dispose);
      final repo = SupabaseMerchantOperationsRepository(
        client,
        currentUserId: () => 'user',
      );
      final result = await repo.read(access, page: 2);
      final value = result.getOrElse(() => throw StateError('expected result'));
      expect(value.pendingSubmissions, 105);
      expect(value.pendingListings, 44);
      expect(value.uploads.single.photoCount, 2);
      expect(jsonDecode(requests.single.body), {
        'p_shop_id': 'shop',
        'p_offset': 40,
        'p_limit': 20,
      });
      expect(requests.single.method, 'POST');
      expect(
        requests.single.url.path,
        '/rest/v1/rpc/merchant_operations_read_v1',
      );
    },
  );
  test(
    'session change discards response and invalid access makes no request',
    () async {
      final pending = Completer<http.Response>();
      var current = 'user', calls = 0;
      final client = SupabaseClient(
        'http://localhost:54321',
        'local-test',
        httpClient: MockClient((r) {
          calls++;
          return pending.future;
        }),
      );
      addTearDown(client.dispose);
      final repo = SupabaseMerchantOperationsRepository(
        client,
        currentUserId: () => current,
      );
      expect((await repo.read(access, page: -1)).isLeft(), true);
      final read = repo.read(access);
      await Future<void>.delayed(Duration.zero);
      current = 'other';
      pending.complete(
        response({
          'pending_submissions': 0,
          'approved_submissions': 0,
          'rejected_submissions': 0,
          'pending_listings': 0,
          'uploads': [],
        }),
      );
      expect((await read).fold((e) => e, (_) => ''), merchantSessionChanged);
      expect((await repo.read(access)).isLeft(), true);
      expect(calls, 1);
    },
  );
  test(
    'missing capability and permission errors never become an empty success',
    () async {
      for (final code in ['PGRST202', '42501', 'XX000']) {
        var calls = 0;
        final client = SupabaseClient(
          'http://localhost:54321',
          'local-test',
          httpClient: MockClient((r) async {
            calls++;
            return response(
              {'code': code, 'message': 'private SQL detail'},
              status: 403,
              request: r,
            );
          }),
        );
        final result = await SupabaseMerchantOperationsRepository(
          client,
          currentUserId: () => 'user',
        ).read(access);
        expect(result.isLeft(), true);
        expect(
          result.fold((e) => e, (_) => ''),
          isNot(contains('private SQL')),
        );
        expect(calls, 1);
        await client.dispose();
      }
    },
  );
  test(
    'submission pagination keeps deterministic order and owner filter',
    () async {
      final requests = <http.Request>[];
      final client = SupabaseClient(
        'http://localhost:54321',
        'local-test',
        httpClient: MockClient((r) async {
          requests.add(r);
          return response([], request: r);
        }),
      );
      addTearDown(client.dispose);
      final repo = SupabaseCatalogMediaRepository(
        client,
        currentUserId: () => 'user',
      );
      expect((await repo.submissions(access, page: 1)).isRight(), true);
      expect(requests.single.url.queryParameters['shop_id'], 'eq.shop');
      expect(requests.single.url.queryParameters['offset'], '100');
      expect(requests.single.url.queryParameters['limit'], '100');
      expect(
        requests.single.url.queryParameters['order'],
        'created_at.desc.nullslast,id.desc.nullslast',
      );
      expect((await repo.submissions(access, page: -1)).isLeft(), true);
      expect(requests.length, 1);
    },
  );
}
