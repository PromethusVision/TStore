import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/merchant/merchant_app.dart';
import 'package:t_store/features/merchant/presentation/merchant_listing_media.dart';
import 'package:t_store/features/merchant/runtime/merchant_runtime.dart';
import 'package:t_store/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:t_store/features/shop/data/repositories/supabase_listing_hero_media_repository.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';

// Only explicitly launched by pilot_ui.mjs. All Auth, REST, Storage and
// repository responses are real. The facade forwards SDK operations because
// the production singleton cannot be initialized twice in a widget test.
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
  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) => client.auth.signInWithPassword(email: email, password: password);
  @override
  Future<void> signOut() => client.auth.signOut();
  @override
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await client.removeChannel(channel);
  }
}

class _RealHttp extends HttpOverrides {}

class _LoopbackClient extends http.BaseClient {
  String? loseNextPatchTo;
  int lostAcknowledgements = 0;
  final patchCounts = <String, int>{};
  // Widget tests replace HttpClient with an HTTP-400 stub. Bypass it only for
  // this guarded client, never by enabling arbitrary network access globally.
  final _inner = IOClient(
    HttpOverrides.runWithHttpOverrides(
      () => HttpClient()..findProxy = (_) => 'DIRECT',
      _RealHttp(),
    ),
  );
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final uri = request.url;
    if (uri.scheme != 'http' ||
        uri.host != '127.0.0.1' ||
        uri.port != 55431 ||
        uri.userInfo.isNotEmpty) {
      throw StateError('Only the owned loopback API is allowed');
    }
    request.followRedirects = false;
    final loseAcknowledgement =
        request.method == 'PATCH' && request.url.path == loseNextPatchTo;
    if (request.method == 'PATCH') {
      patchCounts.update(uri.path, (value) => value + 1, ifAbsent: () => 1);
    }
    if (loseAcknowledgement) loseNextPatchTo = null;
    final response = await _inner.send(request);
    if (loseAcknowledgement) {
      await response.stream.drain<void>();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError('Fault injection requires a successful local commit');
      }
      lostAcknowledgements++;
      throw http.ClientException(
        'Synthetic acknowledgement loss after local commit',
      );
    }
    return response;
  }

  @override
  void close() => _inner.close();
}

T _ok<T>(Either<String, T> value) => value.fold(
  (_) => throw StateError('Local repository assertion failed'),
  (v) => v,
);

void main() {
  testWidgets(
    'real local Merchant screens and Customer visibility',
    (tester) async {
      // A fresh device preferences adapter; no Auth/REST/Storage response is
      // replaced. The real push coordinator still runs its logout cleanup.
      // This explicit local test lives outside test/ to keep ordinary CI offline.
      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(430, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.runAsync(() async {
        final path = Platform.environment['MERCHANT_PILOT_UI_FIXTURE'];
        if (path == null) throw StateError('Use the owned pilot_ui.mjs runner');
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
          '$parent${Platform.pathSeparator}pilot-ui-fixture.json',
        );
        final f = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        expect(f['kind'], 'merchant-pilot-ui-local-v1');
        expect(f['url'], 'http://127.0.0.1:55431');
        expect(f['project'], parent.split(Platform.pathSeparator).last);
        final network = _LoopbackClient();
        final clients = <SupabaseClient>[];
        final checks = <Map<String, String>>[];
        SupabaseClient client() {
          final result = SupabaseClient(
            f['url'],
            f['key'],
            httpClient: network,
            authOptions: const AuthClientOptions(autoRefreshToken: false),
          );
          clients.add(result);
          return result;
        }

        Future<void> waitFor(bool Function() ready, String label) async {
          final clock = Stopwatch()..start();
          while (!ready()) {
            if (clock.elapsed > const Duration(seconds: 25)) {
              throw StateError('Screen did not become ready: $label');
            }
            await tester.pump(const Duration(milliseconds: 40));
            await Future<void>.delayed(const Duration(milliseconds: 40));
          }
          await tester.pump(const Duration(milliseconds: 300));
        }

        Future<void> visible(String text) =>
            waitFor(() => find.text(text).evaluate().isNotEmpty, text);
        Future<void> tap(Finder finder) async {
          await tester.ensureVisible(finder);
          await tester.tap(finder);
          await tester.pump(const Duration(milliseconds: 300));
        }

        Future<void> back() async {
          final button = find.byType(BackButton).hitTestable();
          await waitFor(
            () => button.evaluate().length == 1,
            'visible back button',
          );
          await tap(button);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          await tester.pump();
        }

        Future<void> text(String label, String value) =>
            tester.enterText(find.widgetWithText(TextFormField, label), value);
        Future<void> tab(String label) => tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(label),
          ),
        );
        Future<void> login(String who) async {
          await visible('Giriş yap');
          final account = f[who] as Map<String, dynamic>;
          await text('E-posta', account['email']);
          await text('Şifre', account['password']);
          await tap(find.text('Giriş yap'));
        }

        Future<void> check(String name, Future<void> Function() action) async {
          await action();
          expect(tester.takeException(), isNull, reason: name);
          checks.add({'name': name, 'result': 'PASS'});
          // No account address, token, password or signed URL is printed.
          debugPrint('PASS $name');
        }

        final merchant = client();
        final customer = client();
        try {
          final customerLogin = f['customer'] as Map<String, dynamic>;
          await customer.auth.signInWithPassword(
            email: customerLogin['email'],
            password: customerLogin['password'],
          );
          final reads = ShopRepositoryImpl(supabaseService: _Service(customer));
          final hero = SupabaseListingHeroMediaRepository(customer);
          Future<List<ShopProductEntity>> offers() async =>
              _ok(await reads.getShopProductsByProduct(f['product']));
          final services = createMerchantServices(_Service(merchant));
          await tester.pumpWidget(MerchantApp(services: services));
          await check(
            'login and onboarding through Merchant screens',
            () async {
              await login('merchant');
              await visible('Mağazanı oluştur');
              await text('Mağaza adı', 'Yerel Ekran Mağazası');
              await text(
                'Mağaza açıklaması',
                'Yalnız sentetik yerel kabul kaydı',
              );
              await tap(find.text('Mağazayı kaydet'));
              await waitFor(
                () => find.byType(NavigationBar).evaluate().isNotEmpty,
                'onboarding completed',
              );
              await visible('Yerel Ekran Mağazası');
              expect(find.byType(NavigationBar), findsOneWidget);
            },
          );
          await check(
            'profile edit persists after returning to dashboard',
            () async {
              await tap(find.text('Mağaza bilgilerini düzenle'));
              await visible('Mağaza profili');
              await text('Mağaza adı', 'Yerel Güncel Mağaza');
              await tap(find.text('Mağazayı kaydet'));
              await waitFor(
                () =>
                    find.text('Mağaza profili').evaluate().isEmpty &&
                    find.byType(NavigationBar).evaluate().isNotEmpty,
                'profile returned to dashboard',
              );
              await visible('Yerel Güncel Mağaza');
              final access = _ok(await services.merchants.loadAccess())!;
              expect(access.shop!.name, 'Yerel Güncel Mağaza');
            },
          );
          await check(
            'lost profile acknowledgement exits to authoritative shop name',
            () async {
              await tap(find.text('Mağaza bilgilerini düzenle'));
              await visible('Mağaza profili');
              await text('Mağaza adı', 'Yerel Son Mağaza');
              final before = network.patchCounts['/rest/v1/shops'] ?? 0;
              network.loseNextPatchTo = '/rest/v1/shops';
              await tap(find.text('Mağazayı kaydet'));
              await visible('Kayıt durumunu kontrol et');
              await back();
              await visible('Vazgeç ve çık');
              await tap(find.text('Vazgeç ve çık'));
              await waitFor(
                () => find.byType(NavigationBar).evaluate().isNotEmpty,
                'uncertain profile exit',
              );
              await visible('Yerel Son Mağaza');
              expect(network.patchCounts['/rest/v1/shops'], before + 1);
              expect(network.lostAcknowledgements, 1);
              expect(
                _ok(await services.merchants.loadAccess())!.shop!.name,
                'Yerel Son Mağaza',
              );
            },
          );
          String? listingId;
          Future<void> edit() async {
            await visible('Ürünlerim');
            await visible(f['product_name']);
            await tap(find.text(f['product_name']));
            await visible('Ürünü düzenle');
          }

          Future<void> save() async {
            await tap(find.text('Ürünü kaydet'));
            await visible('Ürünlerim');
            await visible(f['product_name']);
          }

          await check(
            'catalog selection creates one listing at exact price',
            () async {
              await tab('Ürünler');
              await tap(find.text('Katalogdan ürün ekle'));
              await visible('Katalogdan ürün seç');
              await visible(f['product_name']);
              await tap(find.text(f['product_name']));
              await visible('Ürün ekle');
              await text('Mağaza fiyatı (TL)', '123,45');
              await save();
              final rows = await offers();
              expect(rows.length, 1);
              listingId = rows.single.id;
              expect(rows.single.price, 123.45);
              expect(
                rows.single.product?.attributes?['_catalog_price_contract'],
                'listing_only_v1',
              );
            },
          );
          await check(
            'price edit reaches Customer without central-price fallback',
            () async {
              await edit();
              await text('Mağaza fiyatı (TL)', '200,01');
              await save();
              expect((await offers()).single.price, 200.01);
              expect(find.textContaining('200,01'), findsOneWidget);
            },
          );
          await check(
            'lost listing acknowledgement exits to authoritative price without retry',
            () async {
              await edit();
              await text('Mağaza fiyatı (TL)', '234,56');
              final before = network.patchCounts['/rest/v1/shop_products'] ?? 0;
              network.loseNextPatchTo = '/rest/v1/shop_products';
              await tap(find.text('Ürünü kaydet'));
              await visible('Kayıt durumunu kontrol et');
              await back();
              await visible('Vazgeç ve çık');
              await tap(find.text('Vazgeç ve çık'));
              await visible('Ürünlerim');
              await waitFor(
                () => find.textContaining('234,56').evaluate().isNotEmpty,
                'authoritative recovered price',
              );
              expect((await offers()).single.price, 234.56);
              expect(network.patchCounts['/rest/v1/shop_products'], before + 1);
              expect(network.lostAcknowledgements, 2);
            },
          );
          await check(
            'availability off is reflected in Customer offers',
            () async {
              await edit();
              await tap(find.widgetWithText(SwitchListTile, 'Stokta var'));
              await save();
              expect(await offers(), isEmpty);
              final access = _ok(await services.merchants.loadAccess())!;
              final owned = _ok(
                await services.merchants.listings(access),
              ).single;
              expect(owned.id, listingId);
              expect(owned.isAvailable, isFalse);
              expect(owned.isActive, isTrue);
            },
          );
          await check(
            'inactive listing disappears from Customer offers',
            () async {
              await edit();
              await tap(find.widgetWithText(SwitchListTile, 'Stokta var'));
              await tap(find.widgetWithText(SwitchListTile, 'Ürün aktif'));
              await save();
              expect(await offers(), isEmpty);
              final access = _ok(await services.merchants.loadAccess())!;
              final owned = _ok(
                await services.merchants.listings(access),
              ).single;
              expect(owned.isAvailable, isTrue);
              expect(owned.isActive, isFalse);
            },
          );
          await check(
            'reactivation and availability restore the same listing',
            () async {
              await edit();
              await tap(find.widgetWithText(SwitchListTile, 'Ürün aktif'));
              await save();
              final offer = (await offers()).single;
              expect(offer.id, listingId);
              expect(offer.isCustomerPurchasable, isTrue);
            },
          );
          final png = base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=',
          );
          await check(
            'real Storage upload through merchant photo screen',
            () async {
              await edit();
              await tap(find.text('Mağaza fotoğraflarını yönet'));
              await visible('Mağaza fotoğrafları');
              final current = tester.widget<MerchantListingMedia>(
                find.byType(MerchantListingMedia),
              );
              // Hardware seam only: keep the exact live repository/access/listing
              // opened by the app; substitute gallery selection with local bytes.
              final navigator = Navigator.of(
                tester.element(find.byType(MerchantListingMedia)),
              );
              navigator.pushReplacement<void, void>(
                MaterialPageRoute(
                  builder: (_) => MerchantListingMedia(
                    repository: current.repository,
                    access: current.access,
                    listingId: current.listingId,
                    pickImage: () async => XFile.fromData(
                      png,
                      mimeType: 'image/png',
                      name: 'local.png',
                    ),
                  ),
                ),
              );
              // Start and finish the route transition before querying controls;
              // both routes legitimately contain the same label mid-animation.
              await tester.pump();
              await tester.pump(const Duration(milliseconds: 400));
              await waitFor(
                () =>
                    find.text('Fotoğraf ekle').evaluate().isNotEmpty &&
                    find.byType(CircularProgressIndicator).evaluate().isEmpty,
                'photo picker ready',
              );
              await tap(find.text('Fotoğraf ekle'));
              await visible('Yayında');
              final photos = await hero.photos(await offers());
              expect(photos.single.listingId, listingId);
              final download = await network.get(
                Uri.parse(photos.single.source),
              );
              expect(download.statusCode, 200);
              expect(download.bodyBytes, png);
            },
          );
          await check('photo removal updates Customer hero', () async {
            await tap(find.text('Kaldır'));
            await waitFor(
              () =>
                  find.text('Yayında').evaluate().isEmpty &&
                  find.byType(CircularProgressIndicator).evaluate().isEmpty,
              'photo removed',
            );
            expect(await hero.photos(await offers()), isEmpty);
            await back();
            await tester.pump(const Duration(milliseconds: 400));
            await visible('Ürünü düzenle');
            await back();
            await tester.pump(const Duration(milliseconds: 400));
            await visible('Ürünlerim');
          });
          await check(
            'shared inbox contains only this account notifications',
            () async {
              await tab('Bildirim');
              await visible('Yerel katılım bildirimi');
              expect(find.text('Başka esnafın bildirimi'), findsNothing);
              await tap(find.text('Yerel katılım bildirimi'));
              await waitFor(
                () =>
                    find.byIcon(Icons.notifications_none).evaluate().isNotEmpty,
                'notification read',
              );
              final row = await merchant
                  .from('notifications')
                  .select('is_read')
                  .eq('id', f['notification'])
                  .single();
              expect(row['is_read'], isTrue);
            },
          );
          await check(
            'sign out clears private workspace and customer role is denied',
            () async {
              await tab('Hesap');
              await tap(find.text('Çıkış yap'));
              await visible('Giriş yap');
              expect(find.text('Yerel Son Mağaza'), findsNothing);
              expect(find.byType(NavigationBar), findsNothing);
              await login('customer');
              await visible('Esnaf erişimi');
              expect(find.byType(NavigationBar), findsNothing);
              expect(
                find.textContaining('Bu hesabın esnaf yetkisi henüz yok.'),
                findsOneWidget,
              );
              await tap(find.text('Başka hesapla giriş yap'));
              await visible('Giriş yap');
            },
          );
          await check(
            'another merchant sees only its own empty workspace',
            () async {
              await login('other');
              await waitFor(
                () => find.byType(NavigationBar).evaluate().isNotEmpty,
                'second merchant workspace',
              );
              await visible('Sentetik hazırlık mağazası');
              expect(find.text('Yerel Son Mağaza'), findsNothing);
              await tab('Ürünler');
              await visible('Ürünlerim');
              await waitFor(
                () => find.byType(CircularProgressIndicator).evaluate().isEmpty,
                'other listings loaded',
              );
              expect(find.text(f['product_name']), findsNothing);
              await tab('Bildirim');
              await visible('Başka esnafın bildirimi');
              expect(find.text('Yerel katılım bildirimi'), findsNothing);
              await tab('Hesap');
              await tap(find.text('Çıkış yap'));
              await visible('Giriş yap');
            },
          );
          await check(
            'new client session reloads persisted merchant workspace',
            () async {
              await tester.pumpWidget(const SizedBox());
              final fresh = client();
              await tester.pumpWidget(
                MerchantApp(services: createMerchantServices(_Service(fresh))),
              );
              await login('merchant');
              await visible('Yerel Son Mağaza');
              await tab('Ürünler');
              await visible(f['product_name']);
              await waitFor(
                () => find.textContaining('234,56').evaluate().isNotEmpty,
                'fresh session listing price',
              );
              expect(find.textContaining('234,56'), findsOneWidget);
              final rows = await offers();
              expect(rows.single.id, listingId);
              expect(rows.single.isCustomerPurchasable, isTrue);
            },
          );
          await File(
            '$parent${Platform.pathSeparator}pilot-ui-result.json',
          ).writeAsString(
            jsonEncode({
              'kind': 'merchant-pilot-ui-client-local-v1',
              'nonce': f['nonce'],
              'result': 'PASS',
              'checks': checks,
            }),
          );
        } finally {
          await tester.pumpWidget(const SizedBox());
          for (final c in clients) {
            await c.dispose();
          }
          network.close();
        }
      });
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );
}
