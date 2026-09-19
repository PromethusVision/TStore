import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/dependency_injection/taxonomy_dependency_configuration.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/features/shop/data/repositories/production_preview_product_repository.dart';
import 'package:t_store/features/shop/data/services/production_preview_taxonomy_adapter.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_product_query_scope.dart';
import '../../helpers/production_preview_test_support.dart';

void main() {
  test(
    'same subject with a new session cannot reuse an in-flight capability',
    () async {
      final response = Completer<dynamic>();
      final adapter = ProductionPreviewTaxonomyAdapter(
        config: previewTestConfig(),
        currentUserId: () => previewTestSubject,
        rpcCaller: (_, _) => response.future,
      );
      final request = adapter.authorize();
      adapter.invalidateAuthorization();
      response.complete([previewCapabilityFixture()]);
      await expectLater(request, throwsStateError);
      expect(adapter.hasCurrentAuthorization, isFalse);
    },
  );
  test(
    'same-subject reauthorization rejects data from the previous session',
    () async {
      final response = Completer<dynamic>();
      final adapter = ProductionPreviewTaxonomyAdapter(
        config: previewTestConfig(),
        currentUserId: () => previewTestSubject,
        rpcCaller: (name, _) async => name == 'taxonomy_capabilities_v2'
            ? [previewCapabilityFixture()]
            : await response.future,
      );
      await adapter.authorize();
      final request = ProductionPreviewProductRepository(
        adapter: adapter,
      ).getProducts();
      adapter.invalidateAuthorization();
      await adapter.authorize();
      response.complete([previewProductFixture()]);
      expect((await request).isLeft(), isTrue);
      expect(adapter.hasCurrentAuthorization, isTrue);
    },
  );
  test('anonymous local intent cannot issue a capability request', () async {
    var calls = 0;
    final adapter = ProductionPreviewTaxonomyAdapter(
      config: previewTestConfig(),
      currentUserId: () => null,
      rpcCaller: (_, _) async {
        calls++;
        return [];
      },
    );
    await expectLater(adapter.authorize(), throwsStateError);
    expect(calls, 0);
  });
  test('Production preview rejects Development and other project configs', () {
    expect(
      () => previewTestConfig(
        host: '${SupabaseConfig.developmentProjectRef}.supabase.co',
      ),
      throwsA(isA<SupabaseConfigurationException>()),
    );
    expect(
      () => ProductionPreviewTaxonomyAdapter(
        config: previewTestConfig(host: 'other-project.supabase.co'),
        currentUserId: () => previewTestSubject,
        rpcCaller: (_, _) async => [],
      ),
      throwsStateError,
    );
    final development = SupabaseConfig.forEnvironment(
      environment: AppEnvironment.development,
      supabaseUrl: 'https://mefhfvrgkwciubeajjeb.supabase.co',
      supabaseAnonKey:
          'sb_publishable_'
          'unit_test_client_key_only',
    );
    expect(
      () => ProductionPreviewTaxonomyAdapter(
        config: development,
        currentUserId: () => previewTestSubject,
        rpcCaller: (_, _) async => [],
      ),
      throwsStateError,
    );
  });
  for (final entry in <String, dynamic>{
    'preview_authorized': false,
    'preview_subject': 'different-user',
    'public_enabled': true,
    'project_ref': 'other-project',
    'preview_bridge_contract': 'old',
    'product_scope_rpc': 'products',
    'rpc_generation': 1,
    'preview_support': false,
    'preview_enabled': false,
    'preview_root_count': 0,
    'public_active_root_count': 1,
    'product_scope_policy_fail_closed': false,
  }.entries) {
    test(
      'rejects incompatible or unauthorized capability: ${entry.key}',
      () async {
        final row = previewCapabilityFixture()..[entry.key] = entry.value;
        final adapter = ProductionPreviewTaxonomyAdapter(
          config: previewTestConfig(),
          currentUserId: () => previewTestSubject,
          rpcCaller: (_, _) async => [row],
        );
        await expectLater(adapter.authorize(), throwsA(isA<Object>()));
        expect(adapter.hasCurrentAuthorization, isFalse);
      },
    );
  }
  test('missing bridge/capability never starts canonical mode', () async {
    for (final raw in [null, [], {}]) {
      final adapter = ProductionPreviewTaxonomyAdapter(
        config: previewTestConfig(),
        currentUserId: () => previewTestSubject,
        rpcCaller: (_, _) async => raw,
      );
      await expectLater(adapter.authorize(), throwsStateError);
      expect(adapter.hasCurrentAuthorization, isFalse);
    }
  });
  test(
    'verified Production proof selects reused canonical bindings, default stays legacy',
    () async {
      final adapter = ProductionPreviewTaxonomyAdapter(
        config: previewTestConfig(),
        currentUserId: () => previewTestSubject,
        rpcCaller: (_, _) async => [previewCapabilityFixture()],
      );
      final authorization = await adapter.authorize();
      final planner = const TaxonomyDependencyPlanner();
      final plan = planner.resolve(
        TaxonomyDependencyConfiguration.productionPrivatePreview(authorization),
      );
      expect(plan.requiresCanonicalBindings, isTrue);
      expect(plan.registerDevelopmentRpcAdapter, isFalse);
      expect(plan.registerProductionPreviewAdapter, isTrue);
      expect(
        planner
            .resolve(
              TaxonomyDependencyConfiguration.legacy(AppEnvironment.production),
            )
            .capability
            .isLegacy,
        isTrue,
      );
      expect(
        () => planner.resolve(
          TaxonomyDependencyConfiguration(
            environment: AppEnvironment.production,
            runtimeRequest: TaxonomyRuntimeRequest.productionPrivatePreview,
            contractProof: authorization.contractProof,
          ),
        ),
        throwsA(isA<TaxonomyDependencyConfigurationException>()),
      );
    },
  );
  test('logout and account switching invalidate adapter reads', () async {
    String? subject = previewTestSubject;
    var dataCalls = 0;
    final adapter = ProductionPreviewTaxonomyAdapter(
      config: previewTestConfig(),
      currentUserId: () => subject,
      rpcCaller: (name, _) async {
        if (name == 'taxonomy_capabilities_v2') {
          return [previewCapabilityFixture()];
        }
        dataCalls++;
        return [];
      },
    );
    await adapter.authorize();
    subject = null;
    await expectLater(adapter.getRoots(), throwsA(isA<Object>()));
    subject = 'other-user';
    await expectLater(adapter.getRoots(), throwsA(isA<Object>()));
    expect(dataCalls, 0);
  });
  test(
    'stale capability response cannot authorize a changed account',
    () async {
      String? subject = previewTestSubject;
      final response = Completer<dynamic>();
      final adapter = ProductionPreviewTaxonomyAdapter(
        config: previewTestConfig(),
        currentUserId: () => subject,
        rpcCaller: (_, _) => response.future,
      );
      final pending = adapter.authorize();
      subject = null;
      response.complete([previewCapabilityFixture()]);
      await expectLater(pending, throwsStateError);
      expect(adapter.hasCurrentAuthorization, isFalse);
    },
  );
  test('stale product response is discarded after logout', () async {
    String? subject = previewTestSubject;
    final response = Completer<dynamic>();
    final adapter = ProductionPreviewTaxonomyAdapter(
      config: previewTestConfig(),
      currentUserId: () => subject,
      rpcCaller: (name, _) async => name == 'taxonomy_capabilities_v2'
          ? [previewCapabilityFixture()]
          : await response.future,
    );
    await adapter.authorize();
    final repository = ProductionPreviewProductRepository(adapter: adapter);
    final pending = repository.getProducts();
    subject = null;
    response.complete([previewProductFixture()]);
    expect((await pending).isLeft(), isTrue);
  });
  test(
    'product scope and details use exact server projection without legacy fallback',
    () async {
      final calls = <(String, Map<String, dynamic>)>[];
      final adapter = ProductionPreviewTaxonomyAdapter(
        config: previewTestConfig(),
        currentUserId: () => previewTestSubject,
        rpcCaller: (name, args) async {
          calls.add((name, args));
          return name == 'taxonomy_capabilities_v2'
              ? [previewCapabilityFixture()]
              : [previewProductFixture()];
        },
      );
      await adapter.authorize();
      final repository = ProductionPreviewProductRepository(adapter: adapter);
      final row = previewProductFixture();
      final scoped = await repository.getProductsByTaxonomyScope(
        scope: TaxonomyProductQueryScope.exactLeaf(
          categoryId: row['canonical_category_id'] as String,
        ),
        sortBy: 'rating',
      );
      expect(scoped.isRight(), isTrue);
      final detail = await repository.getProductById(
        row['product_id'] as String,
      );
      expect(
        detail.getOrElse(() => throw StateError('missing')).categoryId,
        row['canonical_category_id'],
      );
      expect(calls[1].$1, 'production_preview_products_v1');
      expect(calls[1].$2['p_exact_leaf'], true);
      expect(calls[1].$2['p_sort_by'], 'rating');
      expect(calls[2].$2['p_product_id'], row['product_id']);
    },
  );
  test(
    'missing mapping, gated product and RPC failures cannot return a product',
    () async {
      dynamic response = [];
      final adapter = ProductionPreviewTaxonomyAdapter(
        config: previewTestConfig(),
        currentUserId: () => previewTestSubject,
        rpcCaller: (name, _) async => name == 'taxonomy_capabilities_v2'
            ? [previewCapabilityFixture()]
            : response,
      );
      await adapter.authorize();
      final repository = ProductionPreviewProductRepository(adapter: adapter);
      final id = previewProductFixture()['product_id'] as String;
      expect((await repository.getProductById(id)).isLeft(), isTrue);
      final broken = previewProductFixture();
      (broken['product'] as Map)['category_id'] = 'legacy-id';
      response = [broken];
      expect((await repository.getProducts()).isLeft(), isTrue);
      response = {'error': 'unavailable'};
      expect((await repository.searchProducts('test')).isLeft(), isTrue);
    },
  );
}
