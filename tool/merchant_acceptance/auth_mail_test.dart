// ignore_for_file: invalid_use_of_visible_for_testing_member
// Explicit local runner only. Actual GoTrue, SMTP, verification and PostgREST.
// Preferences are in-memory; this is not Android lifecycle/app-link acceptance.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/auth_callback_contract.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/merchant/data/supabase_merchant_recovery_backend.dart';
import 'package:t_store/features/merchant/data/supabase_merchant_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_account_recovery.dart';

class _Store extends GotrueAsyncStorage {
  final values = <String, String>{};
  @override
  Future<String?> getItem({required String key}) async => values[key];
  @override
  Future<void> setItem({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    values.remove(key);
  }
}

class _Wire extends http.BaseClient {
  final inner = IOClient(HttpClient()..findProxy = (_) => 'DIRECT');
  String? hold;
  bool loseAcknowledgement = false;
  Completer<void>? entered, release;
  int pkce = 0, updates = 0, recoveries = 0;
  void delay(String operation, {bool lose = false}) {
    hold = operation;
    loseAcknowledgement = lose;
    entered = Completer<void>();
    release = Completer<void>();
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final uri = request.url;
    if (uri.scheme != 'http' ||
        uri.host != '127.0.0.1' ||
        ![55431, 55434].contains(uri.port) ||
        uri.userInfo.isNotEmpty) {
      throw StateError('Only literal owned loopback services allowed');
    }
    request.followRedirects = false;
    final operation = uri.queryParameters['grant_type'] == 'pkce'
        ? 'pkce'
        : request.method == 'PUT' && uri.path.endsWith('/user')
        ? 'update'
        : '';
    if (operation == 'pkce') pkce++;
    if (operation == 'update') updates++;
    if (uri.path.endsWith('/recover')) recoveries++;
    final response = await inner.send(request);
    if (operation.isNotEmpty && operation == hold) {
      hold = null;
      // Buffer a REAL server response, then delay/drop its delivery to the SDK.
      final bytes = await response.stream.toBytes();
      entered!.complete();
      await release!.future;
      if (loseAcknowledgement) {
        throw const SocketException('Local response intentionally lost');
      }
      return http.StreamedResponse(
        Stream.value(bytes),
        response.statusCode,
        headers: response.headers,
      );
    }
    return response;
  }

  @override
  void close() => inner.close();
}

String _random() => List.generate(
  20,
  (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
).join();

void main() {
  test(
    'real local mail and shared merchant Auth chain',
    () async {
      final path = Platform.environment['MERCHANT_AUTH_MAIL_FIXTURE'];
      if (path == null) {
        throw StateError('Use auth_mail.mjs with a fresh owned fixture');
      }
      final file = File(path),
          parent = await File(path).parent.resolveSymbolicLinks();
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
        '$parent${Platform.pathSeparator}auth-mail-fixture.json',
      );
      final f = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      expect(f['kind'], 'merchant-auth-mail-local-v1');
      expect(f['url'], 'http://127.0.0.1:55431');
      final accounts = f['accounts'] as Map<String, dynamic>;
      for (final a in accounts.values) {
        expect((a['email'] as String).endsWith('@fixture.invalid'), isTrue);
      }
      final wire = _Wire(), store = _Store();
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final clients = <SupabaseClient>[],
          controllers = <MerchantAccountRecovery>[];
      final checks = <Map<String, String>>[];
      final mailIds = <String>{};
      SupabaseClient client([_Store? storage]) {
        final c = SupabaseClient(
          f['url'],
          f['key'],
          httpClient: wire,
          authOptions: AuthClientOptions(
            autoRefreshToken: false,
            pkceAsyncStorage: storage ?? store,
          ),
        );
        clients.add(c);
        return c;
      }

      final shared = client();
      final contract = AuthCallbackContract.merchantPilot();
      SupabaseMerchantRecoveryBackend backend([
        SupabaseClient? c,
        _Store? storage,
      ]) => SupabaseMerchantRecoveryBackend(
        c ?? shared,
        contract,
        prefs,
        createRecoveryClient: () => GoTrueClient(
          url: '${f['url']}/auth/v1',
          headers: {'apikey': f['key']},
          httpClient: wire,
          autoRefreshToken: false,
          asyncStorage: storage ?? store,
        ),
      );
      MerchantAccountRecovery recovery([SupabaseMerchantRecoveryBackend? b]) {
        final r = MerchantAccountRecovery(
          backend: b ?? backend(),
          contract: contract,
        );
        controllers.add(r);
        return r;
      }

      Future<void> check(String name, Future<void> Function() action) async {
        await action();
        checks.add({'name': name, 'result': 'PASS'});
        // Names only. Never print mailbox content, addresses, tokens or passwords.
        stdout.writeln('PASS $name');
      }

      Future<Map<String, dynamic>> mailbox() async {
        final r = await wire.get(
          Uri.parse('http://127.0.0.1:55434/api/v1/messages'),
        );
        expect(r.statusCode, 200);
        return jsonDecode(r.body) as Map<String, dynamic>;
      }

      Future<Uri> emailLink(
        String recipient,
        String subject,
        String heading,
      ) async {
        for (var i = 0; i < 60; i++) {
          final messages = (await mailbox())['messages'] as List;
          for (final item in messages) {
            final id = item['ID'] as String;
            if (mailIds.contains(id) ||
                !(item['To'] as List).any((t) => t['Address'] == recipient)) {
              continue;
            }
            mailIds.add(id);
            final response = await wire.get(
              Uri.parse('http://127.0.0.1:55434/api/v1/message/$id'),
            );
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            expect(data['Subject'], subject);
            final html = data['HTML'] as String;
            expect(
              html.contains(heading),
              isTrue,
              reason: 'Custom template must not silently fall back',
            );
            expect(
              html.contains('işlemi başlattığınız telefonda') ||
                  html.contains('isteği gönderdiğiniz telefonda'),
              isTrue,
            );
            expect(
              RegExp(
                r'<(?:img|script|iframe)\b',
                caseSensitive: false,
              ).hasMatch(html),
              isFalse,
            );
            final links = RegExp('href="([^"]+)"').allMatches(html).toList();
            expect(links.length, 1);
            final uri = Uri.parse(
              links.single.group(1)!.replaceAll('&amp;', '&'),
            );
            expect(uri.origin, 'http://127.0.0.1:55431');
            expect(uri.path, '/auth/v1/verify');
            return uri;
          }
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
        throw StateError('Expected locally captured email not found');
      }

      Future<Uri> follow(Uri uri) async {
        final response = await wire.get(uri);
        expect(response.statusCode, 303);
        final location = Uri.parse(response.headers['location']!);
        expect(
          location.queryParameters.containsKey('code'),
          isTrue,
          reason: 'Expected verified PKCE redirect',
        );
        return location;
      }

      Future<Uri> reset(MerchantAccountRecovery r, String who) async {
        r.request();
        await r.send(accounts[who]['email']);
        expect(r.stage, MerchantRecoveryStage.sent);
        return follow(
          await emailLink(
            accounts[who]['email'],
            'EsnaftaVar şifrenizi yenileyin',
            'Şifrenizi yenileyin',
          ),
        );
      }

      Future<void> login(SupabaseClient c, String who) async {
        final a = accounts[who];
        final result = await c.auth.signInWithPassword(
          email: a['email'],
          password: a['password'],
        );
        expect(result.user!.id, a['id']);
      }

      Future<void> logout() async {
        if (shared.auth.currentSession != null) {
          await shared.auth.signOut(scope: SignOutScope.local);
        }
      }

      try {
        late Uri usedCallback;
        await check(
          'Turkish SMTP recovery follows exact Merchant callback and duplicate delivery coalesces',
          () async {
            final r = recovery();
            usedCallback = await reset(r, 'merchant');
            expect(usedCallback.scheme, contract.mobileCallbackUri.scheme);
            expect(
              usedCallback.queryParameters['auth_action'],
              'password_recovery',
            );
            final before = wire.pkce;
            await Future.wait([
              r.receive(usedCallback),
              r.receive(usedCallback),
            ]);
            expect(wire.pkce, before + 1);
            expect(r.stage, MerchantRecoveryStage.password);
            expect(shared.auth.currentUser!.id, accounts['merchant']['id']);
          },
        );
        await check(
          'Password update clears recovery session and accepts only new credentials',
          () async {
            final r = controllers.last,
                a = accounts['merchant'],
                old = a['password'],
                next = _random();
            await r.update(next);
            expect(r.stage, MerchantRecoveryStage.complete);
            expect(shared.auth.currentSession, isNull);
            expect(
              prefs.getBool(SupabaseMerchantRecoveryBackend.pendingKey),
              false,
            );
            final fresh = client(_Store());
            await expectLater(
              fresh.auth.signInWithPassword(email: a['email'], password: old),
              throwsA(isA<AuthException>()),
            );
            a['password'] = next;
            await login(fresh, 'merchant');
            final access = (await SupabaseMerchantRepository(
              client: fresh,
            ).loadAccess()).getOrElse(() => null);
            expect(access?.canManage, isTrue);
            expect(access?.shop?.id, f['shop']);
          },
        );
        await check(
          'Consumed recovery code cannot establish another session',
          () async {
            final c = client(_Store()), r = recovery(backend(c, _Store()));
            await r.receive(usedCallback);
            expect(r.stage, MerchantRecoveryStage.invalid);
            expect(c.auth.currentSession, isNull);
            await r.dismiss();
          },
        );
        await check(
          'Unknown email receives the same generic state without a mailbox message',
          () async {
            final before = (await mailbox())['total'];
            final r = recovery();
            r.request();
            await r.send('unknown-${_random()}@fixture.invalid');
            expect(r.stage, MerchantRecoveryStage.sent);
            expect(r.message, contains('Hesabınız uygunsa'));
            await Future<void>.delayed(const Duration(milliseconds: 250));
            expect((await mailbox())['total'], before);
            await r.dismiss();
          },
        );
        await check(
          'Customer recovery callback is ignored by Merchant without token exchange',
          () async {
            final c = client(_Store());
            final customerContract = AuthCallbackContract.forEnvironment(
              AppEnvironment.development,
            );
            await c.auth.resetPasswordForEmail(
              accounts['customer']['email'],
              redirectTo: customerContract.emailRedirectFor(
                appUri: Uri(),
                isWeb: false,
                action: AuthEmailRedirectAction.passwordRecovery,
              ),
            );
            final callback = await follow(
              await emailLink(
                accounts['customer']['email'],
                'EsnaftaVar şifrenizi yenileyin',
                'Şifrenizi yenileyin',
              ),
            );
            expect(callback.scheme, 'io.supabase.tstore');
            final before = wire.pkce;
            final r = recovery();
            await r.receive(callback);
            expect(wire.pkce, before);
            expect(r.stage, MerchantRecoveryStage.idle);
            final result = await c.auth.exchangeCodeForSession(
              callback.queryParameters['code']!,
            );
            expect(result.redirectType, AuthChangeEvent.passwordRecovery.name);
            expect(result.session.user.id, accounts['customer']['id']);
          },
        );
        await check(
          'Different device storage cannot use a valid recovery callback',
          () async {
            final sender = recovery();
            final callback = await reset(sender, 'merchant');
            final storage = _Store(),
                c = client(storage),
                r = recovery(backend(c, storage));
            await r.receive(callback);
            expect(r.stage, MerchantRecoveryStage.invalid);
            expect(c.auth.currentSession, isNull);
            await r.dismiss();
            await sender.dismiss();
          },
        );
        await check(
          'Incorrect PKCE verifier fails on the real Auth server',
          () async {
            final r = recovery();
            final callback = await reset(r, 'merchant');
            for (final key in store.values.keys.toList()) {
              store.values[key] = '${_random()}/passwordRecovery';
            }
            final before = wire.pkce;
            await r.receive(callback);
            expect(wire.pkce, before + 1);
            expect(r.stage, MerchantRecoveryStage.invalid);
            expect(shared.auth.currentSession, isNull);
            await r.dismiss();
          },
        );
        await check(
          'New recovery request invalidates an older email token',
          () async {
            final r = recovery();
            r.request();
            await r.send(accounts['merchant']['email']);
            final old = await emailLink(
              accounts['merchant']['email'],
              'EsnaftaVar şifrenizi yenileyin',
              'Şifrenizi yenileyin',
            );
            await r.dismiss();
            final next = recovery();
            next.request();
            await next.send(accounts['merchant']['email']);
            await emailLink(
              accounts['merchant']['email'],
              'EsnaftaVar şifrenizi yenileyin',
              'Şifrenizi yenileyin',
            );
            final res = await wire.get(old);
            expect(res.statusCode, 303);
            final invalid = Uri.parse(res.headers['location']!);
            expect(invalid.queryParameters.containsKey('code'), false);
            expect(invalid.fragment, contains('otp_expired'));
            final exchanges = wire.pkce;
            await next.receive(invalid);
            // Provider error fragments are outside the accepted callback
            // contract. The existing request remains blocked; no exchange.
            expect(next.stage, MerchantRecoveryStage.sent);
            expect(next.blocksWorkspace, true);
            expect(wire.pkce, exchanges);
            expect(shared.auth.currentSession, isNull);
            await next.dismiss();
          },
        );
        await check(
          'Malformed local callback stays blocked and cannot submit a password',
          () async {
            final r = recovery(), before = wire.updates;
            await r.receive(
              Uri.parse('${contract.mobileCallbackUri}?code=a&code=b'),
            );
            expect(r.stage, MerchantRecoveryStage.invalid);
            await r.update(_random());
            expect(wire.updates, before);
            await r.dismiss();
          },
        );
        await check(
          'Late real recovery response preserves a replacement account',
          () async {
            final r = recovery();
            final callback = await reset(r, 'merchant');
            wire.delay('pkce');
            final pending = r.receive(callback);
            await wire.entered!.future;
            await login(shared, 'other');
            final identity = shared.auth.currentSession!.accessToken;
            wire.release!.complete();
            await pending;
            expect(r.stage, MerchantRecoveryStage.invalid);
            expect(shared.auth.currentSession!.accessToken, identity);
            await r.dismiss();
            expect(shared.auth.currentUser!.id, accounts['other']['id']);
            await logout();
          },
        );
        await check(
          'Late real password update response cannot corrupt another account',
          () async {
            final r = recovery();
            await r.receive(await reset(r, 'merchant'));
            final next = _random();
            wire.delay('update');
            final pending = r.update(next);
            await wire.entered!.future;
            accounts['merchant']['password'] = next;
            await login(shared, 'other');
            final identity = shared.auth.currentSession!.accessToken;
            wire.release!.complete();
            await pending;
            expect(r.stage, MerchantRecoveryStage.invalid);
            expect(shared.auth.currentSession!.accessToken, identity);
            await r.dismiss();
            expect(shared.auth.currentUser!.id, accounts['other']['id']);
            await logout();
          },
        );
        await check(
          'Lost update acknowledgement blocks retry and fresh login reconciles server result',
          () async {
            final r = recovery();
            await r.receive(await reset(r, 'merchant'));
            final next = _random(), before = wire.updates;
            wire.delay('update', lose: true);
            final pending = r.update(next);
            await wire.entered!.future;
            wire.release!.complete();
            await pending;
            expect(r.stage, MerchantRecoveryStage.invalid);
            await r.update(next);
            expect(wire.updates, before + 1);
            await r.dismiss();
            expect(shared.auth.currentSession, isNull);
            accounts['merchant']['password'] = next;
            await login(client(_Store()), 'merchant');
          },
        );
        await check(
          'Persisted pending marker blocks workspace after controller recreation',
          () async {
            final b = backend(), r = recovery(b);
            await r.receive(await reset(r, 'merchant'));
            expect(b.hasPending, true);
            r.dispose();
            controllers.remove(r);
            final restarted = recovery();
            restarted.restorePending();
            expect(restarted.blocksWorkspace, true);
            expect(restarted.stage, MerchantRecoveryStage.invalid);
            final before = wire.updates;
            await restarted.update(_random());
            expect(wire.updates, before);
            await restarted.dismiss();
            expect(shared.auth.currentSession, isNull);
          },
        );
        await check(
          'Customer password recovery does not acquire merchant role or shop ownership',
          () async {
            final r = recovery();
            await r.receive(await reset(r, 'customer'));
            await r.update(_random());
            expect(r.stage, MerchantRecoveryStage.complete);
            // Recovery session itself must not grant merchant authority either.
            final again = recovery();
            await again.receive(await reset(again, 'customer'));
            final access = (await SupabaseMerchantRepository(
              client: shared,
            ).loadAccess()).getOrElse(() => null);
            expect(access?.hasRole, false);
            expect(access?.canManage, false);
            await again.dismiss();
          },
        );
        await check(
          'Confirmation-required signup uses shared Turkish template and Customer callback',
          () async {
            final c = client(_Store()),
                email = 'signup-${_random()}@fixture.invalid',
                password = _random();
            final result = await c.auth.signUp(
              email: email,
              password: password,
              emailRedirectTo: AuthCallbackContract.developmentMobileCallback,
            );
            expect(result.session, isNull);
            await expectLater(
              c.auth.signInWithPassword(email: email, password: password),
              throwsA(isA<AuthException>()),
            );
            final uri = await follow(
              await emailLink(
                email,
                'EsnaftaVar e-posta adresinizi doğrulayın',
                'E-posta adresinizi doğrulayın',
              ),
            );
            final status =
                await SupabaseService.resolveEmailConfirmationCallback(
                  uri: uri,
                  appUri: Uri(),
                  isWeb: false,
                  contract: AuthCallbackContract.forEnvironment(
                    AppEnvironment.development,
                  ),
                  exchangeCode: (u) async {
                    final response = await c.auth.exchangeCodeForSession(
                      u.queryParameters['code']!,
                    );
                    return response.session.user.id == result.user!.id;
                  },
                );
            expect(status, EmailConfirmationCallbackStatus.authenticated);
            final access = (await SupabaseMerchantRepository(
              client: c,
            ).loadAccess()).getOrElse(() => null);
            expect(access?.hasRole, false);
          },
        );
        await check(
          'Merchant callback cannot treat signup confirmation as a recovery grant',
          () async {
            final email = 'signup-${_random()}@fixture.invalid',
                password = _random();
            await shared.auth.signUp(
              email: email,
              password: password,
              emailRedirectTo: contract.mobileCallbackUri.toString(),
            );
            final uri = await follow(
              await emailLink(
                email,
                'EsnaftaVar e-posta adresinizi doğrulayın',
                'E-posta adresinizi doğrulayın',
              ),
            );
            final r = recovery();
            await r.receive(uri);
            expect(r.stage, MerchantRecoveryStage.invalid);
            expect(shared.auth.currentSession, isNull);
            await r.dismiss();
            await shared.auth.signInWithPassword(
              email: email,
              password: password,
            );
            final access = (await SupabaseMerchantRepository(
              client: shared,
            ).loadAccess()).getOrElse(() => null);
            expect(access?.hasRole, false);
            await logout();
          },
        );
        await File(
          '$parent${Platform.pathSeparator}auth-mail-result.json',
        ).writeAsString(
          jsonEncode({'nonce': f['nonce'], 'result': 'PASS', 'checks': checks}),
        );
      } finally {
        wire.release?.isCompleted == false ? wire.release!.complete() : null;
        for (final r in controllers) {
          r.dispose();
        }
        for (final c in clients) {
          await c.dispose();
        }
        wire.close();
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
