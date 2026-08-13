import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_config.dart';

const _enabled = bool.fromEnvironment('W4A2_RUN_LIVE_DEVELOPMENT_QR');
const _phase = String.fromEnvironment(
  'W4A2_LIVE_PHASE',
  defaultValue: 'integration',
);
const _runId = String.fromEnvironment('W4A2_RUN_ID');
const _password = String.fromEnvironment('W4A2_TEST_PASSWORD');
const _developmentUrl = String.fromEnvironment(
  SupabaseConfig.developmentUrlDartDefine,
);
const _developmentAnonKey = String.fromEnvironment(
  SupabaseConfig.developmentAnonKeyDartDefine,
);
const _expectedProjectRef = 'tnipyxnvhgelwdpykyez';

void main() {
  test(
    'Development QR purchase flow uses independent customer and merchant sessions',
    () async {
      final harness = _LiveQrHarness.create();
      addTearDown(harness.dispose);

      final principals = await harness.authenticatePrincipals();
      if (_phase == 'bootstrap') {
        _printPrincipalSummary(principals);
        return;
      }

      expect(
        _phase,
        'integration',
        reason: 'W4A2_LIVE_PHASE must be bootstrap or integration.',
      );
      await harness.verifyMerchantRoles(principals);
      final fixtures = await harness.createFixtures(principals);
      _printFixtureSummary(fixtures);

      await harness.verifySuccessfulFlow(principals, fixtures);
      await harness.verifyCancelledAndExpiredSessions(principals, fixtures);
    },
    skip: _enabled
        ? false
        : 'Set W4A2_RUN_LIVE_DEVELOPMENT_QR=true and explicit Development '
              'dart-defines to run this remote integration test.',
    timeout: const Timeout(Duration(minutes: 5)),
  );
}

final class _LiveQrHarness {
  _LiveQrHarness({
    required this.customerClient,
    required this.merchantClient,
    required this.concurrentMerchantClient,
    required this.wrongMerchantClient,
    required this.prefix,
  });

  factory _LiveQrHarness.create() {
    expect(_runId, matches(RegExp(r'^[a-z0-9]+$')));
    expect(_password.length, greaterThanOrEqualTo(12));

    final config = SupabaseConfig.forEnvironment(
      environment: AppEnvironment.development,
      supabaseUrl: _developmentUrl,
      supabaseAnonKey: _developmentAnonKey,
    );
    final uri = Uri.parse(config.supabaseUrl);
    expect(uri.host, '$_expectedProjectRef.supabase.co');

    SupabaseClient client() => SupabaseClient(
      config.supabaseUrl,
      config.supabaseAnonKey,
      authOptions: const AuthClientOptions(
        autoRefreshToken: false,
        authFlowType: AuthFlowType.implicit,
      ),
    );

    return _LiveQrHarness(
      customerClient: client(),
      merchantClient: client(),
      concurrentMerchantClient: client(),
      wrongMerchantClient: client(),
      prefix: 'w4a2_$_runId',
    );
  }

  final SupabaseClient customerClient;
  final SupabaseClient merchantClient;
  final SupabaseClient concurrentMerchantClient;
  final SupabaseClient wrongMerchantClient;
  final String prefix;

  Future<_Principals> authenticatePrincipals() async {
    final customer = await _signUpOrSignIn(
      customerClient,
      email: 'w4a2-customer@$_runId.esnaftavar.dev',
      fullName: '${prefix}_customer',
    );
    final merchant = await _signUpOrSignIn(
      merchantClient,
      email: 'w4a2-merchant@$_runId.esnaftavar.dev',
      fullName: '${prefix}_merchant',
    );
    final concurrentMerchant = await _signIn(
      concurrentMerchantClient,
      email: merchant.email!,
    );
    expect(concurrentMerchant.id, merchant.id);

    final wrongMerchant = await _signUpOrSignIn(
      wrongMerchantClient,
      email: 'w4a2-wrong-merchant@$_runId.esnaftavar.dev',
      fullName: '${prefix}_wrong_merchant',
    );

    expect(customer.id, isNot(merchant.id));
    expect(customerClient.auth.currentSession, isNotNull);
    expect(merchantClient.auth.currentSession, isNotNull);
    expect(concurrentMerchantClient.auth.currentSession, isNotNull);
    expect(wrongMerchantClient.auth.currentSession, isNotNull);

    return _Principals(
      customer: customer,
      merchant: merchant,
      wrongMerchant: wrongMerchant,
    );
  }

  Future<void> verifyMerchantRoles(_Principals principals) async {
    final merchantProfile = await merchantClient
        .from('profiles')
        .select('id, role')
        .eq('id', principals.merchant.id)
        .single();
    final wrongMerchantProfile = await wrongMerchantClient
        .from('profiles')
        .select('id, role')
        .eq('id', principals.wrongMerchant.id)
        .single();

    expect(merchantProfile['role'], 'merchant');
    expect(wrongMerchantProfile['role'], 'merchant');
  }

  Future<_Fixtures> createFixtures(_Principals principals) async {
    final products = await customerClient
        .from('products')
        .select('id, name')
        .inFilter('name', ['${prefix}_product_1', '${prefix}_product_2']);
    expect(products, hasLength(2));
    final productIds = {
      for (final product in products)
        product['name'] as String: product['id'] as String,
    };

    final shop = await merchantClient
        .from('shops')
        .insert({
          'owner_user_id': principals.merchant.id,
          'name': '${prefix}_shop',
          'description': 'Wave 4 Agent 2 Development fixture',
          'is_active': true,
        })
        .select('id, name')
        .single();
    final wrongShop = await wrongMerchantClient
        .from('shops')
        .insert({
          'owner_user_id': principals.wrongMerchant.id,
          'name': '${prefix}_wrong_shop',
          'description': 'Wave 4 Agent 2 negative fixture',
          'is_active': true,
        })
        .select('id, name')
        .single();

    final shopProducts = await merchantClient
        .from('shop_products')
        .insert([
          {
            'shop_id': shop['id'],
            'product_id': productIds['${prefix}_product_1'],
            'price': 10.25,
            'is_available': true,
            'is_active': true,
          },
          {
            'shop_id': shop['id'],
            'product_id': productIds['${prefix}_product_2'],
            'price': 20.50,
            'is_available': true,
            'is_active': true,
          },
        ])
        .select('id, product_id, price');
    expect(shopProducts, hasLength(2));

    return _Fixtures(
      shopId: shop['id'] as String,
      wrongShopId: wrongShop['id'] as String,
      shopProductIds: [
        for (final product in shopProducts) product['id'] as String,
      ],
    );
  }

  Future<void> verifySuccessfulFlow(
    _Principals principals,
    _Fixtures fixtures,
  ) async {
    final cart = await _createCart(fixtures, quantity: 2);
    final qr = await _createQr(cart.id);
    final sessionId = qr['id'] as String;
    final token = qr['session_token'] as String;

    expect(qr['user_id'], principals.customer.id);
    expect(qr['shop_id'], fixtures.shopId);
    expect(qr['status'], 'active');
    expect(qr['item_count'], 4);
    expect(_decimal(qr['total_amount']), 61.50);

    final snapshots = await customerClient
        .from('qr_session_items')
        .select(
          'shop_product_id, product_name, quantity, unit_price, line_total',
        )
        .eq('qr_session_id', sessionId)
        .order('shop_product_id');
    expect(snapshots, hasLength(2));
    expect(
      snapshots.every(
        (item) => (item['product_name'] as String).startsWith(prefix),
      ),
      isTrue,
    );
    expect(
      snapshots.map((item) => _decimal(item['unit_price'])),
      containsAll([10.25, 20.50]),
    );

    final merchantPayload = _jsonObject(
      await merchantClient.rpc(
        'get_qr_session_for_verification',
        params: {'p_session_token': token},
      ),
    );
    expect(merchantPayload['session_id'], sessionId);
    expect(merchantPayload['status'], 'active');

    await _expectPostgrestFailure(
      () => wrongMerchantClient.rpc(
        'get_qr_session_for_verification',
        params: {'p_session_token': token},
      ),
    );
    await _expectPostgrestFailure(
      () => wrongMerchantClient.rpc(
        'confirm_qr_session',
        params: {'p_session_token': token},
      ),
    );
    await _expectPostgrestFailure(
      () => customerClient.rpc(
        'confirm_qr_session',
        params: {'p_session_token': token},
      ),
    );

    await merchantClient
        .from('shop_products')
        .update({'price': 99.99})
        .eq('id', fixtures.shopProductIds.first)
        .select('id')
        .single();

    final attempts = await Future.wait([
      _captureConfirmation(merchantClient, token),
      _captureConfirmation(concurrentMerchantClient, token),
    ]);
    expect(attempts.where((attempt) => attempt.succeeded), hasLength(1));
    expect(attempts.where((attempt) => !attempt.succeeded), hasLength(1));

    final transactions = await customerClient
        .from('verified_transactions')
        .select(
          'id, source_qr_session_id, customer_user_id, shop_id, shop_name, '
          'confirmed_by_user_id, item_count, total_amount, '
          'verified_transaction_items('
          'shop_product_id, product_name, quantity, unit_price, line_total)',
        )
        .eq('source_qr_session_id', sessionId);
    expect(transactions, hasLength(1));
    final transaction = transactions.single;
    expect(transaction['customer_user_id'], principals.customer.id);
    expect(transaction['confirmed_by_user_id'], principals.merchant.id);
    expect(transaction['shop_id'], fixtures.shopId);
    expect(transaction['shop_name'], '${prefix}_shop');
    expect(transaction['item_count'], 4);
    expect(_decimal(transaction['total_amount']), 61.50);

    final verifiedItems = transaction['verified_transaction_items'] as List;
    expect(verifiedItems, hasLength(2));
    expect(
      verifiedItems.map((item) => _decimal((item as Map)['unit_price'])),
      containsAll([10.25, 20.50]),
    );
    expect(
      verifiedItems.map((item) => _decimal((item as Map)['unit_price'])),
      isNot(contains(99.99)),
    );

    await _expectPostgrestFailure(
      () => merchantClient.rpc(
        'confirm_qr_session',
        params: {'p_session_token': token},
      ),
    );

    final usedSession = await customerClient
        .from('qr_sessions')
        .select('status, used_at, confirmed_by_user_id')
        .eq('id', sessionId)
        .single();
    expect(usedSession['status'], 'used');
    expect(usedSession['used_at'], isNotNull);
    expect(usedSession['confirmed_by_user_id'], principals.merchant.id);
  }

  Future<void> verifyCancelledAndExpiredSessions(
    _Principals principals,
    _Fixtures fixtures,
  ) async {
    final cart = await _createCart(fixtures, quantity: 1);
    final cancelledQr = await _createQr(cart.id);
    final cancelledToken = cancelledQr['session_token'] as String;
    final cancelledSessionId = cancelledQr['id'] as String;

    await customerClient
        .from('cart_items_v2')
        .update({'quantity': 3})
        .eq('id', cart.itemIds.first)
        .select('id')
        .single();

    final cancelledSession = await customerClient
        .from('qr_sessions')
        .select('status')
        .eq('id', cancelledSessionId)
        .single();
    expect(cancelledSession['status'], 'cancelled');
    await _expectPostgrestFailure(
      () => merchantClient.rpc(
        'confirm_qr_session',
        params: {'p_session_token': cancelledToken},
      ),
    );

    final expiringQr = await _createQr(cart.id);
    final expiringToken = expiringQr['session_token'] as String;
    final expiresAt = DateTime.parse(expiringQr['expires_at'] as String);
    final wait =
        expiresAt.difference(DateTime.now().toUtc()) +
        const Duration(seconds: 2);
    if (wait.inMilliseconds > 0) await Future<void>.delayed(wait);

    final expiredPayload = _jsonObject(
      await merchantClient.rpc(
        'get_qr_session_for_verification',
        params: {'p_session_token': expiringToken},
      ),
    );
    expect(expiredPayload['status'], 'expired');
    await _expectPostgrestFailure(
      () => merchantClient.rpc(
        'confirm_qr_session',
        params: {'p_session_token': expiringToken},
      ),
    );

    final transactionCount = await customerClient
        .from('verified_transactions')
        .select('id')
        .eq('customer_user_id', principals.customer.id);
    expect(transactionCount, hasLength(1));
  }

  Future<_CartFixture> _createCart(
    _Fixtures fixtures, {
    required int quantity,
  }) async {
    final cart = await customerClient
        .from('carts')
        .insert({
          'user_id': customerClient.auth.currentUser!.id,
          'shop_id': fixtures.shopId,
          'status': 'active',
        })
        .select('id, shop_id, status')
        .single();
    expect(cart['shop_id'], fixtures.shopId);
    expect(cart['status'], 'active');

    final cartItems = await customerClient
        .from('cart_items_v2')
        .insert([
          {
            'cart_id': cart['id'],
            'shop_product_id': fixtures.shopProductIds[0],
            'quantity': quantity,
          },
          {
            'cart_id': cart['id'],
            'shop_product_id': fixtures.shopProductIds[1],
            'quantity': quantity,
          },
        ])
        .select('id, cart_id, shop_product_id, quantity');
    expect(cartItems, hasLength(2));
    expect(cartItems.every((item) => item['cart_id'] == cart['id']), isTrue);

    return _CartFixture(
      id: cart['id'] as String,
      itemIds: [for (final item in cartItems) item['id'] as String],
    );
  }

  Future<Map<String, dynamic>> _createQr(String cartId) async {
    final response = await customerClient.rpc(
      'create_qr_session',
      params: {'p_cart_id': cartId},
    );
    return _jsonObject(response);
  }

  Future<User> _signUpOrSignIn(
    SupabaseClient client, {
    required String email,
    required String fullName,
  }) async {
    try {
      return await _signIn(client, email: email);
    } on AuthException {
      final response = await client.auth.signUp(
        email: email,
        password: _password,
        data: {
          'full_name': fullName,
          'privacy_notice_acknowledged': 'true',
          'privacy_notice_version': '2026-07-17',
          'terms_of_use_accepted': 'true',
          'terms_of_use_version': '2026-07-17',
        },
      );
      if (response.session == null) {
        throw StateError(
          'Development Auth email confirmation blocked the live harness. '
          'No Auth setting was changed.',
        );
      }
      final user = response.user;
      if (user == null) {
        throw StateError('Normal Auth signup returned no user.');
      }
      return user;
    }
  }

  Future<User> _signIn(SupabaseClient client, {required String email}) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: _password,
    );
    final user = response.user;
    if (response.session == null || user == null) {
      throw StateError('Normal Auth sign-in returned no session.');
    }
    return user;
  }

  Future<void> dispose() async {
    await Future.wait([
      customerClient.auth.signOut(scope: SignOutScope.local),
      merchantClient.auth.signOut(scope: SignOutScope.local),
      concurrentMerchantClient.auth.signOut(scope: SignOutScope.local),
      wrongMerchantClient.auth.signOut(scope: SignOutScope.local),
    ]);
    customerClient.dispose();
    merchantClient.dispose();
    concurrentMerchantClient.dispose();
    wrongMerchantClient.dispose();
  }
}

final class _Principals {
  const _Principals({
    required this.customer,
    required this.merchant,
    required this.wrongMerchant,
  });

  final User customer;
  final User merchant;
  final User wrongMerchant;
}

final class _Fixtures {
  const _Fixtures({
    required this.shopId,
    required this.wrongShopId,
    required this.shopProductIds,
  });

  final String shopId;
  final String wrongShopId;
  final List<String> shopProductIds;
}

final class _CartFixture {
  const _CartFixture({required this.id, required this.itemIds});

  final String id;
  final List<String> itemIds;
}

final class _ConfirmationAttempt {
  const _ConfirmationAttempt({required this.succeeded});

  final bool succeeded;
}

Future<_ConfirmationAttempt> _captureConfirmation(
  SupabaseClient client,
  String token,
) async {
  try {
    final payload = _jsonObject(
      await client.rpc(
        'confirm_qr_session',
        params: {'p_session_token': token},
      ),
    );
    expect(payload['status'], 'used');
    return const _ConfirmationAttempt(succeeded: true);
  } on PostgrestException {
    return const _ConfirmationAttempt(succeeded: false);
  }
}

Future<void> _expectPostgrestFailure(Future<dynamic> Function() action) async {
  await expectLater(action, throwsA(isA<PostgrestException>()));
}

Map<String, dynamic> _jsonObject(dynamic value) {
  expect(value, isA<Map>());
  return Map<String, dynamic>.from(value as Map);
}

double _decimal(Object? value) => switch (value) {
  num number => number.toDouble(),
  String text => double.parse(text),
  _ => throw FormatException('Expected a numeric JSON value.'),
};

void _printPrincipalSummary(_Principals principals) {
  // IDs are non-secret fixture coordinates required for an exact, Development-
  // only role setup. No URL, key, token, email, or password is logged.
  // ignore: avoid_print
  print(
    'W4A2_PRINCIPALS customer=${principals.customer.id} '
    'merchant=${principals.merchant.id} '
    'wrongMerchant=${principals.wrongMerchant.id}',
  );
}

void _printFixtureSummary(_Fixtures fixtures) {
  // IDs are emitted so cleanup can target only this run's prefixed rows.
  // ignore: avoid_print
  print(
    'W4A2_FIXTURES shop=${fixtures.shopId} '
    'wrongShop=${fixtures.wrongShopId} '
    'shopProducts=${fixtures.shopProductIds.join(',')}',
  );
}
