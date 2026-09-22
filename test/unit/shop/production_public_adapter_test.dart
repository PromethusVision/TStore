import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/core/dependency_injection/taxonomy_dependency_configuration.dart';
import 'package:t_store/features/shop/data/services/production_public_taxonomy_adapter.dart';
import 'package:t_store/features/shop/data/repositories/production_public_product_repository.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_product_query_scope.dart';
import 'package:t_store/main_production.dart';
import '../../helpers/production_public_test_support.dart';

void main() {
  test('compiled public define selects the same explicit runtime', () {
    expect(
      selectProductionRuntime(),
      productionCanonicalPublic
          ? ProductionRuntimeSelection.publicCanonical
          : productionCanonicalPreview
          ? ProductionRuntimeSelection.privatePreview
          : ProductionRuntimeSelection.legacy,
    );
  });
  test(
    'explicit public mode is distinct and preview/public are mutually exclusive',
    () {
      expect(
        selectProductionRuntime(publicCanonical: false, privatePreview: false),
        ProductionRuntimeSelection.legacy,
      );
      expect(
        selectProductionRuntime(publicCanonical: true, privatePreview: false),
        ProductionRuntimeSelection.publicCanonical,
      );
      expect(
        selectProductionRuntime(publicCanonical: false, privatePreview: true),
        ProductionRuntimeSelection.privatePreview,
      );
      expect(
        () => selectProductionRuntime(
          publicCanonical: true,
          privatePreview: true,
        ),
        throwsStateError,
      );
    },
  );
  test(
    'public adapter rejects wrong host and Development environment before requests',
    () {
      expect(
        () => ProductionPublicTaxonomyAdapter(
          config: previewTestConfig(host: 'other.invalid'),
          rpcCaller: (_, _) async => null,
        ),
        throwsStateError,
      );
      final dev = SupabaseConfig.forEnvironment(
        environment: AppEnvironment.development,
        supabaseUrl: 'https://mefhfvrgkwciubeajjeb.supabase.co',
        supabaseAnonKey: 'sb_publishable_unit_test_only',
      );
      expect(
        () => ProductionPublicTaxonomyAdapter(
          config: dev,
          rpcCaller: (_, _) async => null,
        ),
        throwsStateError,
      );
    },
  );
  test(
    'anonymous handshake creates public-only proof, no tester or preview capability',
    () async {
      final calls = <String>[];
      final adapter = ProductionPublicTaxonomyAdapter(
        config: previewTestConfig(),
        rpcCaller: (name, _) async {
          calls.add(name);
          return publicHandshakeFixture(name);
        },
      );
      final auth = await adapter.authorize();
      final plan = const TaxonomyDependencyPlanner().resolve(
        TaxonomyDependencyConfiguration.productionPublicCanonical(auth),
      );
      expect(
        plan.capability.mode,
        TaxonomyRuntimeMode.productionPublicCanonical,
      );
      expect(plan.capability.isCanonicalV1, true);
      expect(plan.registerProductionPublicAdapter, true);
      expect(plan.registerProductionPreviewAdapter, false);
      expect(plan.registerDevelopmentRpcAdapter, false);
      expect(auth.contractProof.supportsCanonicalV1, false);
      expect(auth.contractProof.supportsProductionPublic, true);
      expect(calls, [
        'production_taxonomy_runtime_v1',
        'production_taxonomy_capabilities_v1',
        'production_public_read_capabilities_v1',
      ]);
    },
  );
  for (final entry in <String, dynamic>{
    'rpc_generation': 2,
    'public_active_root_count': 23,
    'preview_root_count': 24,
    'pilot_active_root_count': 1,
    'preview_enabled': true,
    'preview_support': true,
    'product_scope_contract': 'legacy',
    'product_scope_requires_assignable': false,
    'product_scope_policy_fail_closed': false,
    'taxonomy_version': 'wrong',
    'client_contract_version': 'taxonomy-client-v1',
    'rpc_contract_version': 'taxonomy-rpc-v2',
    'path_metadata': false,
    'supported_features': ['roots'],
    'verified_evidence': [],
  }.entries) {
    test('public proof rejects ${entry.key}', () async {
      final adapter = ProductionPublicTaxonomyAdapter(
        config: previewTestConfig(),
        rpcCaller: (name, _) async =>
            name == 'production_taxonomy_capabilities_v1'
            ? [publicCapabilityFixture()..[entry.key] = entry.value]
            : publicHandshakeFixture(name),
      );
      await expectLater(adapter.authorize(), throwsA(isA<Object>()));
      expect(adapter.isVerified, false);
    });
  }
  for (final entry in <String, dynamic>{
    'public_enabled': false,
    'preview_required': true,
    'tester_required': true,
    'project_ref': 'wrong-project',
    'policy_fail_closed': false,
    'products_rpc': 'products',
  }.entries) {
    test('facade proof rejects ${entry.key}', () async {
      final adapter = ProductionPublicTaxonomyAdapter(
        config: previewTestConfig(),
        rpcCaller: (name, _) async =>
            name == 'production_public_read_capabilities_v1'
            ? (publicReadsFixture()..[entry.key] = entry.value)
            : publicHandshakeFixture(name),
      );
      await expectLater(adapter.authorize(), throwsStateError);
      expect(adapter.isVerified, false);
    });
  }
  for (final value in [
    null,
    {},
    [],
    [publicCapabilityFixture(), publicCapabilityFixture()],
  ]) {
    test(
      'reject malformed capability ${value.runtimeType}/${value is List ? value.length : 0}',
      () async {
        final adapter = ProductionPublicTaxonomyAdapter(
          config: previewTestConfig(),
          rpcCaller: (name, _) async =>
              name == 'production_taxonomy_capabilities_v1'
              ? value
              : publicHandshakeFixture(name),
        );
        await expectLater(adapter.authorize(), throwsA(isA<Object>()));
        expect(adapter.isVerified, false);
      },
    );
  }
  for (final code in ['42501', 'PGRST202']) {
    test(
      'permission or missing RPC $code never chooses another runtime',
      () async {
        final calls = <String>[];
        final adapter = ProductionPublicTaxonomyAdapter(
          config: previewTestConfig(),
          rpcCaller: (name, _) async {
            calls.add(name);
            throw PostgrestException(message: 'safe test', code: code);
          },
        );
        await expectLater(
          adapter.authorize(),
          throwsA(isA<PostgrestException>()),
        );
        expect(calls, ['production_taxonomy_runtime_v1']);
        expect(adapter.isVerified, false);
      },
    );
  }
  test(
    'cached successful proof cannot read after public OFF; no alternate RPC',
    () async {
      var enabled = true, invalidations = 0;
      final dataCalls = <String>[];
      final adapter = ProductionPublicTaxonomyAdapter(
        config: previewTestConfig(),
        onUnavailable: () => invalidations++,
        rpcCaller: (name, _) async {
          if (name == 'production_taxonomy_runtime_v1') {
            return publicRuntimeFixture()..['public_enabled'] = enabled;
          }
          if (name.contains('capabilities')) {
            return publicHandshakeFixture(name);
          }
          dataCalls.add(name);
          return [];
        },
      );
      await adapter.authorize();
      await adapter.getRoots();
      enabled = false;
      await expectLater(
        adapter.getChildren('00000000-0000-4000-8000-000000000001'),
        throwsA(isA<Object>()),
      );
      expect(dataCalls, ['production_taxonomy_roots_v1']);
      expect(invalidations, 1);
      expect(adapter.isVerified, false);
    },
  );
  test('old response cannot invalidate a newer authorization', () async {
    final response = Completer<dynamic>(), started = Completer<void>();
    final adapter = ProductionPublicTaxonomyAdapter(
      config: previewTestConfig(),
      rpcCaller: (name, _) async {
        if (name == 'production_public_products_v1') {
          started.complete();
          return response.future;
        }
        return publicHandshakeFixture(name);
      },
    );
    await adapter.authorize();
    final pending = ProductionPublicProductRepository(
      adapter: adapter,
    ).getProducts();
    await started.future;
    adapter.invalidate();
    await adapter.authorize();
    response.complete([previewProductFixture()]);
    expect((await pending).isLeft(), true);
    expect(adapter.isVerified, true);
  });
  test(
    'products use public projection for scope/paging/detail/search/featured/brand',
    () async {
      final calls = <Map<String, dynamic>>[], row = previewProductFixture();
      final adapter = ProductionPublicTaxonomyAdapter(
        config: previewTestConfig(),
        rpcCaller: (name, args) async {
          if (name == 'production_public_products_v1') {
            calls.add(args);
            return [row];
          }
          return publicHandshakeFixture(name);
        },
      );
      await adapter.authorize();
      final repo = ProductionPublicProductRepository(adapter: adapter);
      expect(
        (await repo.getProductsByTaxonomyScope(
          scope: TaxonomyProductQueryScope.exactLeaf(
            categoryId: row['canonical_category_id'] as String,
          ),
          page: 2,
          limit: 5,
          sortBy: 'rating',
          ascending: false,
        )).isRight(),
        true,
      );
      expect(calls.last, containsPair('p_offset', 10));
      expect(calls.last, containsPair('p_exact_leaf', true));
      expect(
        (await repo.getProductById(row['product_id'] as String)).isRight(),
        true,
      );
      expect((await repo.searchProducts('unit')).isRight(), true);
      expect(calls.last, containsPair('p_term', 'unit'));
      await repo.getFeaturedProducts();
      expect(calls.last, containsPair('p_is_featured', true));
      await repo.getProductsByBrand('brand');
      expect(calls.last, containsPair('p_brand_id', 'brand'));
      expect(
        calls.every(
          (c) =>
              c['p_client_contract_version'] == 'production-taxonomy-client-v1',
        ),
        true,
      );
      expect((await repo.getProducts(limit: 101)).isLeft(), true);
    },
  );
  test(
    'gated detail and corrupt canonical mapping cannot return legacy products',
    () async {
      dynamic data = [];
      final row = previewProductFixture();
      final adapter = ProductionPublicTaxonomyAdapter(
        config: previewTestConfig(),
        rpcCaller: (name, _) async => name == 'production_public_products_v1'
            ? data
            : publicHandshakeFixture(name),
      );
      await adapter.authorize();
      final repo = ProductionPublicProductRepository(adapter: adapter);
      expect(
        (await repo.getProductById(row['product_id'] as String)).isLeft(),
        true,
      );
      (row['product'] as Map)['category_id'] = 'legacy';
      data = [row];
      expect((await repo.getProducts()).isLeft(), true);
    },
  );
}
