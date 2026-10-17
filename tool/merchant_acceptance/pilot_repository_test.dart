import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/cart/data/repositories/qr_session_repository_impl.dart';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/runtime/merchant_runtime.dart';
import 'package:t_store/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:t_store/features/shop/data/repositories/supabase_listing_hero_media_repository.dart';

// Explicit local runner only; outside test/ so ordinary CI never opens a socket.
// Service facade forwards actual SDK state. No Auth, RPC, Storage or repository
// response is mocked; no widget binding that substitutes HTTP with status 400.
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

class _LoopbackClient extends http.BaseClient {
  final _inner = IOClient(HttpClient()..findProxy = (_) => 'DIRECT');
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final uri = request.url;
    if (uri.scheme != 'http' ||
        uri.host != '127.0.0.1' ||
        uri.port != 55431 ||
        uri.userInfo.isNotEmpty) {
      throw StateError('Only the owned local acceptance API is allowed');
    }
    request.followRedirects = false;
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}

T _ok<T>(Either<String, T> result) => result.fold(
  (error) => throw StateError('Repository operation failed: $error'),
  (value) => value,
);

void main() {
  test(
    'base-core pilot repositories: complete local merchant and Customer journey',
    () async {
      final path = Platform.environment['MERCHANT_PILOT_LOCAL_FIXTURE'];
      if (path == null) {
        throw StateError('Use the owned local pilot.mjs runner');
      }
      final file = File(path);
      final parent = await file.parent.resolveSymbolicLinks();
      final base = await Directory(
        '.buildlog/merchant-acceptance',
      ).resolveSymbolicLinks();
      final suffix = parent.substring(base.length);
      expect(parent.startsWith('$base${Platform.pathSeparator}'), isTrue);
      expect(
        RegExp(r'^[\\/]ev-merchant-ab-[a-f0-9]{12}$').hasMatch(suffix),
        isTrue,
      );
      expect(
        await file.resolveSymbolicLinks(),
        '$parent${Platform.pathSeparator}pilot-client-fixture.json',
      );
      final f = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      expect(f['kind'], 'merchant-pilot-base-core-local');
      expect(f['url'], 'http://127.0.0.1:55431');
      expect(f['project'], parent.split(Platform.pathSeparator).last);
      final httpClient = _LoopbackClient();
      final clients = <SupabaseClient>[];
      final checks = <Map<String, String>>[];
      Future<void> check(String name, Future<void> Function() action) async {
        await action();
        checks.add({'name': name, 'result': 'PASS'});
      }

      Future<SupabaseClient> login(String who) async {
        final c = SupabaseClient(
          f['url'],
          f['key'],
          httpClient: httpClient,
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        );
        clients.add(c);
        final account = f[who] as Map<String, dynamic>;
        final result = await c.auth.signInWithPassword(
          email: account['email'],
          password: account['password'],
        );
        expect(result.session, isNotNull);
        return c;
      }

      try {
        final merchant = await login('merchant');
        final customer = await login('customer');
        final other = await login('other');
        final services = createMerchantServices(_Service(merchant));
        final merchants = services.merchants;
        final media = services.catalogMedia!;
        final operations = services.operations!;
        final shopReads = ShopRepositoryImpl(
          supabaseService: _Service(customer),
        );
        final hero = SupabaseListingHeroMediaRepository(customer);
        var access = _ok(await merchants.loadAccess())!;
        await check(
          'shared runtime keeps downstream business and provider capabilities OFF',
          () async {
            expect([
              services.purchaseEvidence,
              services.evaluations,
              services.trustCommerce,
              services.rewardProgram,
              services.statement,
              services.promotions,
            ], everyElement(isNull));
            final qr = services.qr as QrSessionRepositoryImpl;
            expect(qr.claimsEnabled, isFalse);
            expect(qr.rewardEarningEnabled, isFalse);
            expect(qr.couponCheckoutEnabled, isFalse);
          },
        );
        await check(
          'authoritative role and shop onboarding through real application repository',
          () async {
            expect(access.hasRole, isTrue);
            expect(access.shop, isNull);
            final shop = _ok(
              await merchants.saveShop(
                access,
                const MerchantShopDraft(
                  name: 'Yerel Pilot Esnaf',
                  description: 'Sentetik kabul kaydı',
                  openingHours: {'monday': '09:00-18:00'},
                ),
              ),
            );
            expect(shop.ownerUserId, merchant.auth.currentUser!.id);
            access = _ok(await merchants.loadAccess())!;
            expect(access.canManage, isTrue);
          },
        );
        await check(
          'profile edits survive fresh read and stale revision cannot overwrite',
          () async {
            final stale = access;
            _ok(
              await merchants.saveShop(
                access,
                const MerchantShopDraft(name: 'Yerel Pilot Güncel'),
              ),
            );
            expect(
              (await merchants.saveShop(
                stale,
                const MerchantShopDraft(name: 'Eski taslak'),
              )).isLeft(),
              isTrue,
            );
            access = _ok(await merchants.loadAccess())!;
            expect(access.shop!.name, 'Yerel Pilot Güncel');
          },
        );
        await check(
          'catalog search, categories and existing identity are usable with core only',
          () async {
            final products = _ok(
              await merchants.searchCatalog(access, query: 'Local acceptance'),
            );
            expect(products.any((p) => p.id == f['product']), isTrue);
            expect(
              _ok(
                await media.categories(access),
              ).any((c) => c.id == f['category']),
              isTrue,
            );
            expect(
              _ok(
                await media.lookup(access, 'Local acceptance', ''),
              ).products.any((p) => p.id == f['product']),
              isTrue,
            );
          },
        );
        var listing = _ok(
          await merchants.saveListing(
            access,
            MerchantListingDraft(productId: f['product'], priceMinor: 12345),
          ),
        );
        await check(
          'listing create and duplicate submission preserve exact listing price',
          () async {
            expect(listing.price, 123.45);
            expect(
              (await merchants.saveListing(
                access,
                MerchantListingDraft(productId: f['product'], priceMinor: 1),
              )).isLeft(),
              isTrue,
            );
            expect(_ok(await merchants.listings(access)).single.price, 123.45);
            final overview = _ok(await merchants.overview(access));
            expect(
              [
                overview.total,
                overview.available,
                overview.unavailable,
                overview.inactive,
              ],
              [1, 1, 0, 0],
            );
          },
        );
        await check(
          'price, boolean stock and stale revision are enforced by actual server',
          () async {
            final stale = listing;
            listing = _ok(
              await merchants.saveListing(
                access,
                MerchantListingDraft(
                  productId: f['product'],
                  priceMinor: 23456,
                  available: false,
                ),
                existing: listing,
              ),
            );
            expect(
              (await merchants.saveListing(
                access,
                MerchantListingDraft(productId: f['product'], priceMinor: 999),
                existing: stale,
              )).isLeft(),
              isTrue,
            );
            final overview = _ok(await merchants.overview(access));
            expect(
              [
                overview.total,
                overview.available,
                overview.unavailable,
                overview.inactive,
              ],
              [1, 0, 1, 0],
            );
            expect(listing.price, 234.56);
          },
        );
        await check(
          'deactivation hides Customer purchase eligibility and remains owner-editable',
          () async {
            listing = _ok(
              await merchants.saveListing(
                access,
                MerchantListingDraft(
                  productId: f['product'],
                  priceMinor: 23456,
                  active: false,
                ),
                existing: listing,
              ),
            );
            expect(_ok(await merchants.listings(access)).single.id, listing.id);
            expect(
              _ok(
                await shopReads.getShopProductsByProduct(f['product']),
              ).where((p) => p.id == listing.id),
              isEmpty,
            );
            expect(_ok(await merchants.overview(access)).inactive, 1);
            listing = _ok(
              await merchants.saveListing(
                access,
                MerchantListingDraft(
                  productId: f['product'],
                  priceMinor: 23456,
                ),
                existing: listing,
              ),
            );
          },
        );
        await check(
          'fresh login reads the committed listing through nested production DTOs',
          () async {
            final fresh = await login('merchant');
            final repo = createMerchantServices(_Service(fresh)).merchants;
            final freshAccess = _ok(await repo.loadAccess())!;
            final rows = _ok(
              await repo.listings(freshAccess, query: 'Local acceptance'),
            );
            expect(rows.single.id, listing.id);
            expect(rows.single.price, 234.56);
            expect(rows.single.product?.id, f['product']);
          },
        );
        final png = base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=',
        );
        await check(
          'real SDK Storage upload, publish, signed Customer hero and byte download',
          () async {
            _ok(await media.upload(access, listing.id, png));
            final images = _ok(await media.media(access, listing.id));
            expect(images.images.single.primary, isTrue);
            expect(images.images.single.state, 'published');
            final rows = _ok(
              await shopReads.getShopProductsByProduct(f['product']),
            );
            final photos = await hero.photos(rows);
            expect(photos.single.listingId, listing.id);
            final download = await httpClient.get(
              Uri.parse(photos.single.source),
            );
            expect(download.statusCode, 200);
            expect(download.bodyBytes, png);
          },
        );
        await check(
          'foreign merchant cannot read private media metadata or change owner photo',
          () async {
            final foreignServices = createMerchantServices(_Service(other));
            final foreignAccess = _ok(
              await foreignServices.merchants.loadAccess(),
            )!;
            expect(
              (await foreignServices.catalogMedia!.media(
                foreignAccess,
                listing.id,
              )).isLeft(),
              isTrue,
            );
            expect(
              (await foreignServices.catalogMedia!.upload(
                foreignAccess,
                listing.id,
                png,
              )).isLeft(),
              isTrue,
            );
            expect(_ok(await media.media(access, listing.id)).images.length, 1);
          },
        );
        await check(
          'pending photo appears on dashboard and explicit retirement clears task',
          () async {
            final intent = await merchant.rpc(
              'merchant_prepare_listing_image_v1',
              params: {
                'p_listing_id': listing.id,
                'p_mime': 'image/png',
                'p_bytes': png.length,
              },
            );
            var result = _ok(await operations.read(access));
            expect(result.pendingListings, 1);
            expect(result.uploads.single.listingId, listing.id);
            expect(result.uploads.single.photoCount, 1);
            _ok(
              await media.changeMedia(
                access,
                listing.id,
                'retire',
                imageId: intent['id'],
              ),
            );
            result = _ok(await operations.read(access));
            expect(result.pendingListings, 0);
          },
        );
        await check(
          'retired photo is removed from fresh Customer hero projection',
          () async {
            final photo = _ok(
              await media.media(access, listing.id),
            ).images.firstWhere((p) => p.state == 'published');
            _ok(
              await media.changeMedia(
                access,
                listing.id,
                'retire',
                imageId: photo.id,
              ),
            );
            expect(
              await hero.photos(
                _ok(await shopReads.getShopProductsByProduct(f['product'])),
              ),
              isEmpty,
            );
          },
        );
        await check(
          'new product request retries once, stays pending and appears on dashboard',
          () async {
            final requestId = f['submission_request_id'] as String;
            final draft = ProductSubmissionDraft(
              name: 'Yerel yeni ürün talebi',
              categoryId: f['category'],
            );
            final first = _ok(await media.submit(access, requestId, draft));
            final retry = _ok(await media.submit(access, requestId, draft));
            expect(retry.submission!.id, first.submission!.id);
            expect(retry.submission!.status, 'pending');
            expect(_ok(await media.submissions(access)).length, 1);
            final result = _ok(await operations.read(access));
            expect(
              [
                result.pendingSubmissions,
                result.approvedSubmissions,
                result.rejectedSubmissions,
              ],
              [1, 0, 0],
            );
          },
        );
        await check(
          'existing notification inbox scopes reads, count and marking to current account',
          () async {
            expect(_ok(await services.notifications.getUnreadCount()), 1);
            expect(
              _ok(await services.notifications.getNotifications()).single.id,
              f['notification'],
            );
            _ok(
              await services.notifications.markAsRead(
                f['foreign_notification'],
              ),
            );
            final foreign = createMerchantServices(
              _Service(other),
            ).notifications;
            expect(_ok(await foreign.getUnreadCount()), 1);
            _ok(await services.notifications.markAsRead(f['notification']));
            expect(_ok(await services.notifications.getUnreadCount()), 0);
          },
        );
        await check(
          'Customer legacy QR creation and merchant preview preserve base-core contract',
          () async {
            final cartId = f['cart_id'] as String;
            await customer.from('carts').insert({
              'id': cartId,
              'user_id': customer.auth.currentUser!.id,
              'shop_id': access.shop!.id,
            });
            await customer.from('cart_items_v2').insert({
              'cart_id': cartId,
              'shop_product_id': listing.id,
              'quantity': 2,
            });
            final qr = QrSessionRepositoryImpl(
              supabaseService: _Service(customer),
            );
            final session = _ok(await qr.createQrSession(cartId: cartId));
            expect(session.protocolVersion, 1);
            final preview = _ok(
              await services.qr.getQrVerification(
                sessionToken: session.sessionToken,
              ),
            );
            expect(preview.totalAmount, 469.12);
            expect(preview.items.single.quantity, 2);
            final confirmed = _ok(
              await services.qr.confirmQrVerification(
                sessionToken: session.sessionToken,
              ),
            );
            expect(confirmed.status, 'used');
            // Legacy v1 rejects replay as already used. Idempotent v2 completion
            // belongs to the separately enabled claims protocol, not this profile.
            expect(
              (await services.qr.confirmQrVerification(
                sessionToken: session.sessionToken,
              )).isLeft(),
              isTrue,
            );
            expect(
              _ok(await qr.getQrSessionStatus(sessionId: session.id)),
              'used',
            );
          },
        );
        await check(
          'notification delete does not affect foreign account',
          () async {
            _ok(await services.notifications.deleteAllNotifications());
            expect(
              _ok(await services.notifications.getNotifications()),
              isEmpty,
            );
            expect(
              _ok(
                await createMerchantServices(
                  _Service(other),
                ).notifications.getNotifications(),
              ).any((n) => n.id == f['foreign_notification']),
              isTrue,
            );
          },
        );
        await check('Customer has no merchant management authority', () async {
          final customerServices = createMerchantServices(_Service(customer));
          expect(
            _ok(await customerServices.merchants.loadAccess())!.hasRole,
            isFalse,
          );
          expect(
            (await customerServices.merchants.saveListing(
              access,
              MerchantListingDraft(productId: f['product'], priceMinor: 1),
            )).isLeft(),
            isTrue,
          );
        });
        await check(
          'logout removes local access and rejects further application edits',
          () async {
            await merchant.auth.signOut(scope: SignOutScope.local);
            expect(_ok(await merchants.loadAccess()), isNull);
            expect(
              (await merchants.saveShop(
                access,
                const MerchantShopDraft(name: 'Forbidden'),
              )).isLeft(),
              isTrue,
            );
          },
        );
        await File(
          '$parent${Platform.pathSeparator}pilot-client-result.json',
        ).writeAsString(
          jsonEncode({'result': 'PASS', 'nonce': f['nonce'], 'checks': checks}),
        );
      } finally {
        for (final client in clients) {
          await client.dispose();
        }
        httpClient.close();
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
