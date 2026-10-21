import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/runtime/merchant_runtime.dart';
import 'package:t_store/features/shop/data/repositories/shop_repository_impl.dart';

class _Service extends Fake implements SupabaseService {
  _Service(this.client);
  @override
  final SupabaseClient client;
  @override
  User? get currentUser => client.auth.currentUser;
  @override
  Session? get currentSession => client.auth.currentSession;
  @override
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}

class _LocalHttp extends http.BaseClient {
  final _inner = IOClient(HttpClient()..findProxy = (_) => 'DIRECT');
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final u = request.url;
    if (u.scheme != 'http' ||
        u.host != '127.0.0.1' ||
        u.port != 55431 ||
        u.userInfo.isNotEmpty) {
      throw StateError('Owned loopback only');
    }
    request.followRedirects = false;
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}

T _ok<T>(Either<String, T> v) => v.fold((e) => throw StateError(e), (v) => v);

void main() {
  test(
    'approved Powerbank leaf through current Merchant and Customer repositories',
    () async {
      final path = Platform.environment['MERCHANT_POWERBANK_LOCAL_FIXTURE'];
      if (path == null) throw StateError('Use the local Powerbank runner');
      final file = File(path);
      final parent = await file.parent.resolveSymbolicLinks();
      final base = await Directory(
        '.buildlog/merchant-acceptance',
      ).resolveSymbolicLinks();
      expect(parent.startsWith('$base${Platform.pathSeparator}'), isTrue);
      expect(
        RegExp(
          r'^[\\/]ev-merchant-ab-[a-f0-9]{12}$',
        ).hasMatch(parent.substring(base.length)),
        isTrue,
      );
      expect(
        await file.resolveSymbolicLinks(),
        '$parent${Platform.pathSeparator}powerbank-client-fixture.json',
      );
      final f = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      expect(f['kind'], 'powerbank-local-client-v1');
      expect(f['url'], 'http://127.0.0.1:55431');
      expect(f['project'], parent.split(Platform.pathSeparator).last);
      expect(['submission', 'listing'], contains(f['phase']));
      final transport = _LocalHttp();
      final clients = <SupabaseClient>[];
      final checks = <String>[];
      final result = <String, dynamic>{};
      Future<SupabaseClient> login(String role) async {
        final c = SupabaseClient(f['url'], f['key'], httpClient: transport);
        clients.add(c);
        await c.auth.signInWithPassword(
          email: f[role]['email'],
          password: f[role]['password'],
        );
        expect(c.auth.currentSession, isNotNull);
        return c;
      }

      try {
        final merchant = await login('merchant');
        final services = createMerchantServices(_Service(merchant));
        final repo = services.merchants;
        var access = _ok(await repo.loadAccess())!;
        expect(access.hasRole, isTrue);
        expect([
          services.trustCommerce,
          services.rewardProgram,
          services.purchaseEvidence,
        ], everyElement(isNull));
        if (f['phase'] == 'submission') {
          expect(access.shop, isNull);
          _ok(
            await repo.saveShop(
              access,
              const MerchantShopDraft(name: 'Sentetik Powerbank Provası'),
            ),
          );
          access = _ok(await repo.loadAccess())!;
          expect(access.canManage, isTrue);
          checks.add('current repository onboarding');
          final categories = _ok(
            await services.catalogMedia!.categories(access),
          );
          expect(categories, hasLength(1));
          expect(categories.single.id, f['category']);
          expect(
            categories.single.name,
            'Elektronik > Güç, Şarj & Bağlantı > Powerbank',
          );
          checks.add(
            'exact newly approved leaf is the only selectable category',
          );
          expect(
            _ok(await repo.searchCatalog(access, query: 'Powerbank')),
            isEmpty,
          );
          const draft = ProductSubmissionDraft(
            name: 'Yerel Powerbank Provası 10000 mAh',
            categoryId: 'e704d61e-72ca-4609-ba79-e431c780881d',
            brand: 'Yerel Prova',
            model: 'FM11',
            variant: '10000 mAh',
          );
          expect(draft.error, isNull);
          final first = _ok(
            await services.catalogMedia!.submit(access, f['request_id'], draft),
          );
          final retry = _ok(
            await services.catalogMedia!.submit(access, f['request_id'], draft),
          );
          expect(first.submission?.id, isNotNull);
          expect(retry.submission?.id, first.submission!.id);
          expect(first.submission!.status, 'pending');
          expect(
            _ok(await repo.searchCatalog(access, query: 'Powerbank')),
            isEmpty,
          );
          checks.add(
            'barcode-less submission retries return one pending identity without publishing',
          );
          result.addAll({
            'submission_id': first.submission!.id,
            'shop_id': access.shop!.id,
          });
        } else {
          expect(access.canManage, isTrue);
          final products = _ok(
            await repo.searchCatalog(access, query: 'Powerbank'),
          );
          expect(products, hasLength(1));
          expect(products.single.id, f['product']);
          var listing = _ok(
            await repo.saveListing(
              access,
              MerchantListingDraft(productId: f['product'], priceMinor: 99000),
            ),
          );
          expect(_ok(await repo.listings(access)).single.price, 990);
          checks.add('published identity supports owner listing at TRY 990');
          final customer = await login('customer');
          final reads = ShopRepositoryImpl(supabaseService: _Service(customer));
          expect(
            _ok(
              await reads.getShopProductsByProduct(f['product']),
            ).single.price,
            990,
          );
          checks.add('Customer reads the merchant price');
          final stale = listing;
          listing = _ok(
            await repo.saveListing(
              access,
              MerchantListingDraft(
                productId: f['product'],
                priceMinor: 99000,
                available: false,
              ),
              existing: listing,
            ),
          );
          expect(
            _ok(await reads.getShopProductsByProduct(f['product'])),
            isEmpty,
          );
          expect(
            (await repo.saveListing(
              access,
              MerchantListingDraft(productId: f['product'], priceMinor: 1),
              existing: stale,
            )).isLeft(),
            isTrue,
          );
          checks.add(
            'unavailable listing disappears and stale price update is rejected',
          );
          listing = _ok(
            await repo.saveListing(
              access,
              MerchantListingDraft(productId: f['product'], priceMinor: 99000),
              existing: listing,
            ),
          );
          final other = await login('other');
          final otherRepo = createMerchantServices(_Service(other)).merchants;
          expect(
            (await otherRepo.saveListing(
              access,
              MerchantListingDraft(productId: f['product'], priceMinor: 1),
              existing: listing,
            )).isLeft(),
            isTrue,
          );
          expect(
            _ok(
              await reads.getShopProductsByProduct(f['product']),
            ).single.price,
            990,
          );
          checks.add(
            'stock recovery preserves price and another merchant cannot edit',
          );
        }
        await File(
          '$parent${Platform.pathSeparator}powerbank-client-${f['phase']}.json',
        ).writeAsString(
          jsonEncode({
            'result': 'PASS',
            'nonce': f['nonce'],
            'checks': checks,
            ...result,
          }),
        );
      } finally {
        for (final c in clients) {
          await c.dispose();
        }
        transport.close();
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
