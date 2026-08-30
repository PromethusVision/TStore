import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/shop/data/services/supabase_canonical_taxonomy_rpc_adapter.dart';
import 'package:t_store/features/shop/domain/repositories/canonical_taxonomy_repository.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_alias_resolution.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_navigation.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_product_query_scope.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';
import 'package:t_store/features/shop/domain/usecases/get_products_by_taxonomy_scope_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_state.dart';
import 'package:t_store/features/shop/presentation/cubit/taxonomy_browse_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/taxonomy_browse_state.dart';
import 'package:t_store/main_development.dart' as development;

const _liveOptIn = bool.fromEnvironment(
  'ESNAFTAVAR_RUN_W38G_TAXONOMY_ACCEPTANCE',
);
const _canonicalOptIn = bool.fromEnvironment(
  development.developmentCanonicalTaxonomyDartDefine,
);
const _developmentUrl = String.fromEnvironment(
  SupabaseConfig.developmentUrlDartDefine,
);
const _developmentAnonKey = String.fromEnvironment(
  SupabaseConfig.developmentAnonKeyDartDefine,
);
const _expectedProjectRef = 'tnipyxnvhgelwdpykyez';
const _expectedUrl = 'https://$_expectedProjectRef.supabase.co';
const _taxonomyVersion = 'canonical-v1.0.0';

const _expectedRoots = <String, String>{
  '714f42ff-37ee-466c-9726-796097910936': 'Gıda & İçecek',
  '737eb7ae-eb06-442b-83e0-f02834950be7': 'Giyim & Moda',
  '3767cb95-6117-49cc-9298-4f0e8eb5dbb3': 'Ayakkabı',
  'ea3a65e3-02c1-4e3a-a281-cd4205243cba': 'Çanta & Aksesuar',
  'dae0270c-90ac-4248-919b-05531cf7c0e8': 'Elektronik',
  '7d59f4a3-8828-4231-9502-ac91b7b0baa0': 'Bilgisayar & Tablet',
  '49b1fa71-f885-4e5f-86dc-66f32f7687a5': 'Beyaz Eşya & Ev Aletleri',
  '8ff9e12d-e19b-4fc9-8a42-b3ddbd8b7c5a': 'Ev & Yaşam',
  '4ad28c36-e233-461d-9c28-87accfc43adb': 'Züccaciye & Mutfak',
  '27523f6b-a340-418b-985a-c806b5d59eb4': 'Yapı, Hırdavat & Tesisat',
  '8b7bf2c6-fb37-4bc3-9826-564ba9c021f5': 'Otomotiv & Motosiklet',
  '18a06d0f-4e85-4f02-8ca3-90070c5e506d': 'Kozmetik & Kişisel Bakım',
  '8d28867d-0ee1-43e3-8027-22b428b55f3d': 'Anne & Bebek',
  '52adad9e-8fcf-48e0-9418-33ee5d51abc4': 'Oyuncak & Hobi',
  '6de8a72c-5c18-4aed-9ddd-41ec87c6af08': 'Müzik & Enstrüman',
  '7de86dff-38db-41b3-803a-9163af5e55a5': 'Spor & Outdoor',
  'a6dc7c8c-d0ad-4347-b3f8-db4a7a5d5ea7': 'Kitap',
  'b4a582c3-9e08-446f-a15c-6ee06316b14d': 'Kırtasiye & Ofis',
  'b5c2618f-4c71-42d5-aa80-d443377ee469': 'Evcil Hayvan Ürünleri',
  '78aa2d4d-c9dd-4baf-8816-3ec4d8a6e120': 'Gözlük & Optik',
  'd8f58e32-2a1e-4f8e-a630-ca5e84dea554': 'Saat & Takı',
  '315cd0bc-ec9c-4452-825a-3122937d663e': 'Sağlık & Medikal',
  '47b0a29e-19bb-4a92-9a2e-ad4ccf42ff28': 'Çiçek & Bahçe',
  '5c661f4e-ac89-4737-a2d8-911811fabe5c': 'Hediyelik & Parti',
};

const _aliasEvidence = <String, TaxonomyAliasResolutionState>{
  'acil-yol-cekme-ekipmani': TaxonomyAliasResolutionState.resolved,
  'ag-harici-depolama-baski': TaxonomyAliasResolutionState.ambiguous,
  'antiseptik-dezenfeksiyon-urunu': TaxonomyAliasResolutionState.tombstone,
  'ahsap-oyuncak': TaxonomyAliasResolutionState.unresolved,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'real Development canonical V2 client accepts the staged preview tree',
    () async {
      if (!_liveOptIn) {
        expect(_canonicalOptIn, isFalse);
        return;
      }

      expect(
        _canonicalOptIn,
        isTrue,
        reason: 'The live run must exercise the actual Development opt-in.',
      );
      final config = development.createSupabaseConfig(
        supabaseUrl: _developmentUrl,
        supabaseAnonKey: _developmentAnonKey,
      );
      expect(config.environment, AppEnvironment.development);
      expect(config.supabaseUrl, _expectedUrl);
      expect(
        Uri.parse(config.supabaseUrl).host,
        '$_expectedProjectRef.supabase.co',
      );
      expect(config.supabaseAnonKey, isNotEmpty);

      SharedPreferences.setMockInitialValues({});
      final testHttpOverrides = HttpOverrides.current;
      HttpOverrides.global = null;
      addTearDown(() => HttpOverrides.global = testHttpOverrides);
      await SupabaseService.initialize(config: config);
      await sl.reset();
      addTearDown(sl.reset);

      final taxonomyConfiguration = await development
          .createDevelopmentTaxonomyConfiguration();
      await setupServiceLocator(taxonomyConfiguration: taxonomyConfiguration);

      final capability = sl<TaxonomyRuntimeCapability>();
      final proof = capability.proof!;
      expect(capability.isCanonicalV1, isTrue);
      expect(capability.isLegacy, isFalse);
      expect(proof.supportsCanonicalV1, isTrue);
      expect(
        proof.runtimeReadiness,
        TaxonomyBackendRuntimeReadiness.supportedPreviewOn,
      );
      expect(proof.canStartDevelopmentAcceptance, isTrue);
      expect(proof.contractVersion, 'taxonomy-client-v1');
      expect(proof.taxonomyVersion, _taxonomyVersion);
      expect(proof.rpcContractVersion, 'taxonomy-rpc-v2');
      expect(proof.rpcGeneration, 2);
      expect(proof.previewSupported, isTrue);
      expect(proof.previewEnabled, isTrue);
      expect(proof.previewRootCount, 24);
      expect(proof.publicActiveRootCount, 0);
      expect(proof.pilotActiveRootCount, 0);
      expect(proof.productScopeRequiresAssignable, isTrue);
      expect(proof.productScopePolicyFailClosed, isTrue);

      final repository = sl<CanonicalTaxonomyRepository>();
      final adapter = sl<SupabaseCanonicalTaxonomyRpcAdapter>();
      expect(adapter.previewRequested, isTrue);

      final categoriesCubit = sl<CategoriesCubit>();
      addTearDown(categoriesCubit.close);
      await categoriesCubit.getCategories();
      final categoriesState = categoriesCubit.state;
      expect(categoriesState, isA<CategoriesLoaded>());
      final loadedRoots = categoriesState as CategoriesLoaded;
      expect(loadedRoots.runtimeMode, TaxonomyRuntimeMode.canonicalV1Runtime);
      expect(loadedRoots.categories, hasLength(24));
      expect(loadedRoots.canonicalNodes, hasLength(24));
      expect({
        for (final node in loadedRoots.canonicalNodes)
          node.id: node.displayName,
      }, _expectedRoots);
      expect(
        loadedRoots.canonicalNodes.map((node) => node.id).toSet(),
        hasLength(24),
      );
      expect(
        loadedRoots.canonicalNodes.every(
          (node) => node.isRoot && node.parentId == null,
        ),
        isTrue,
      );

      final nodesById = <String, TaxonomyCategoryNode>{};
      for (final root in loadedRoots.canonicalNodes) {
        final subtree = _expectRight(await repository.getDescendants(root.id));
        expect(subtree, isNotEmpty);
        expect(subtree.firstWhere((node) => node.id == root.id), root);
        for (final node in subtree) {
          expect(nodesById.putIfAbsent(node.id, () => node), node);
        }
      }
      expect(nodesById, hasLength(1563));
      final hierarchy = TaxonomyCategoryHierarchy.fromNodes(nodesById.values);
      expect(hierarchy.length, 1563);
      expect(hierarchy.maxDepth, 4);
      expect(hierarchy.roots, hasLength(24));

      final levelCounts = <TaxonomyCategoryLevel, int>{
        for (final level in TaxonomyCategoryLevel.values)
          level: nodesById.values.where((node) => node.level == level).length,
      };
      expect(levelCounts, {
        TaxonomyCategoryLevel.l1: 24,
        TaxonomyCategoryLevel.l2: 244,
        TaxonomyCategoryLevel.l3: 1096,
        TaxonomyCategoryLevel.l4: 199,
      });
      expect(nodesById.values.where((node) => node.isLeaf), hasLength(1245));
      expect(
        nodesById.values.every(
          (node) => node.lifecycle == TaxonomyCategoryLifecycle.staged,
        ),
        isTrue,
      );
      expect(
        nodesById.values.every(
          (node) =>
              node.assignability == TaxonomyCategoryAssignability.notAssignable,
        ),
        isTrue,
      );
      expect(nodesById.values.every((node) => node.isPreviewContext), isTrue);
      expect(
        nodesById.values.every(
          (node) => node.taxonomyVersion == _taxonomyVersion,
        ),
        isTrue,
      );

      final slugPaths = nodesById.values.map((node) {
        final breadcrumb = hierarchy.breadcrumbFor(node.id);
        return breadcrumb.items
            .map((item) => hierarchy.nodeById(item.categoryId)!.slug)
            .join('/');
      }).toSet();
      expect(slugPaths, hasLength(1563));

      final l2Leaf = _firstLeaf(nodesById.values, TaxonomyCategoryLevel.l2);
      final l3Leaf = _firstLeaf(nodesById.values, TaxonomyCategoryLevel.l3);
      final l4Leaf = _firstLeaf(nodesById.values, TaxonomyCategoryLevel.l4);
      final multiLevelContainer = nodesById.values.firstWhere(
        (node) =>
            node.level == TaxonomyCategoryLevel.l2 &&
            node.isContainer &&
            hierarchy
                .descendantsOf(node.id)
                .any(
                  (descendant) => descendant.level == TaxonomyCategoryLevel.l4,
                ),
      );

      for (final container in [hierarchy.roots.first, multiLevelContainer]) {
        final browseCubit = TaxonomyBrowseCubit(
          repository: repository,
          capability: capability,
        );
        await browseCubit.load(container);
        expect(browseCubit.state, isA<TaxonomyBrowseLoaded>());
        final loaded = browseCubit.state as TaxonomyBrowseLoaded;
        expect(loaded.category.id, container.id);
        expect(loaded.children, isNotEmpty);
        expect(
          loaded.navigationDecision.action,
          TaxonomyCategoryNavigationAction.navigateDeeper,
        );
        await browseCubit.close();
      }

      for (final leaf in [l2Leaf, l3Leaf, l4Leaf]) {
        final browseCubit = TaxonomyBrowseCubit(
          repository: repository,
          capability: capability,
        );
        await browseCubit.load(leaf);
        expect(browseCubit.state, isA<TaxonomyBrowseBlocked>());
        expect(
          (browseCubit.state as TaxonomyBrowseBlocked).reason,
          anyOf(
            TaxonomyCategoryBlockReason.notAssignable,
            TaxonomyCategoryBlockReason.policyBlocked,
          ),
        );
        await browseCubit.close();
      }

      final deepBreadcrumb = _expectRight(
        await repository.getBreadcrumb(l4Leaf.id),
      );
      expect(
        deepBreadcrumb.items.map((item) => item.level),
        TaxonomyCategoryLevel.values,
      );
      expect(deepBreadcrumb.current.categoryId, l4Leaf.id);
      _expectBreadcrumbMatchesHierarchy(deepBreadcrumb, hierarchy);
      final parentBackStack = deepBreadcrumb.items.sublist(
        0,
        deepBreadcrumb.items.length - 1,
      );
      expect(parentBackStack.last.categoryId, l4Leaf.parentId);

      for (final shallowLeaf in [l2Leaf, l3Leaf]) {
        final breadcrumb = _expectRight(
          await repository.getBreadcrumb(shallowLeaf.id),
        );
        expect(breadcrumb.items, hasLength(shallowLeaf.level.depth));
        _expectBreadcrumbMatchesHierarchy(breadcrumb, hierarchy);
      }

      for (final searchNode in [
        hierarchy.roots.first,
        multiLevelContainer,
        l4Leaf,
      ]) {
        final results = _expectRight(
          await repository.searchTaxonomy(
            TaxonomySearchRequest(query: searchNode.displayName, limit: 50),
          ),
        );
        final context = results.firstWhere(
          (candidate) => candidate.matchedCategory.id == searchNode.id,
        );
        expect(context.taxonomyVersion, _taxonomyVersion);
        expect(
          context.canonicalPathLabel,
          hierarchy.breadcrumbFor(searchNode.id).fullLabel,
        );
        expect(context.isLeaf, searchNode.isLeaf);
        expect(context.isContainer, searchNode.isContainer);
      }

      final aliasResults = <String, String>{};
      for (final entry in _aliasEvidence.entries) {
        final resolution = _expectRight(
          await repository.resolveAlias(
            TaxonomyAliasLookup(locator: entry.key),
          ),
        );
        expect(resolution.state, entry.value);
        expect(resolution.taxonomyVersion, _taxonomyVersion);
        expect(
          resolution.targetCategoryId != null,
          entry.value == TaxonomyAliasResolutionState.resolved,
        );
        if (resolution.targetCategoryId != null) {
          expect(nodesById.containsKey(resolution.targetCategoryId), isTrue);
        }
        aliasResults[entry.key] = resolution.state.name;
      }

      final getProducts = sl<GetProductsByTaxonomyScopeUsecase>();
      for (final leaf in [l2Leaf, l3Leaf, l4Leaf]) {
        expect(await adapter.qualifyExactLeaf(leaf.id), isEmpty);
        final products = _expectRight(
          await getProducts(
            GetProductsByTaxonomyScopeParams(
              scope: TaxonomyProductQueryScope.exactLeaf(categoryId: leaf.id),
            ),
          ),
        );
        expect(products, isEmpty);
        expect(
          TaxonomyCategoryNavigationDecision.forCanonicalNode(leaf).action,
          TaxonomyCategoryNavigationAction.unavailable,
        );
      }

      expect(_countBy(nodesById.values, (node) => node.policyClass), {
        TaxonomyPolicyClass.normal: 770,
        TaxonomyPolicyClass.regulated: 553,
        TaxonomyPolicyClass.legalReviewRequired: 240,
      });
      expect(
        _countBy(nodesById.values, (node) => node.professionalReviewStatus),
        {
          TaxonomyProfessionalReviewStatus.notRequired: 486,
          TaxonomyProfessionalReviewStatus.pending: 1077,
        },
      );

      // The only output is non-secret acceptance evidence for the integration
      // record; URL/key material is intentionally omitted.
      // ignore: avoid_print
      print(
        'W38G_LIVE_EVIDENCE ${jsonEncode({
          'runtime': capability.mode.name,
          'readiness': proof.runtimeReadiness.name,
          'roots': loadedRoots.canonicalNodes.map((node) => {'id': node.id, 'name': node.displayName}).toList(),
          'counts': {'nodes': hierarchy.length, 'l1': levelCounts[TaxonomyCategoryLevel.l1], 'l2': levelCounts[TaxonomyCategoryLevel.l2], 'l3': levelCounts[TaxonomyCategoryLevel.l3], 'l4': levelCounts[TaxonomyCategoryLevel.l4], 'leaves': nodesById.values.where((node) => node.isLeaf).length},
          'variable_depth': {'l2_leaf': l2Leaf.displayName, 'l3_leaf': l3Leaf.displayName, 'l4_leaf': l4Leaf.displayName, 'multi_level_container': multiLevelContainer.displayName},
          'deep_breadcrumb': deepBreadcrumb.fullLabel,
          'aliases': aliasResults,
          'exact_leaf_qualification': 'empty_fail_closed',
          'silent_legacy_fallback': false,
        })}',
      );
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}

TaxonomyCategoryNode _firstLeaf(
  Iterable<TaxonomyCategoryNode> nodes,
  TaxonomyCategoryLevel level,
) {
  return nodes.firstWhere((node) => node.level == level && node.isLeaf);
}

void _expectBreadcrumbMatchesHierarchy(
  TaxonomyBreadcrumb breadcrumb,
  TaxonomyCategoryHierarchy hierarchy,
) {
  for (var index = 0; index < breadcrumb.items.length; index++) {
    final item = breadcrumb.items[index];
    final node = hierarchy.nodeById(item.categoryId)!;
    expect(item.label, node.displayName);
    expect(item.level, node.level);
    if (index == 0) {
      expect(node.parentId, isNull);
    } else {
      expect(node.parentId, breadcrumb.items[index - 1].categoryId);
    }
  }
}

Map<T, int> _countBy<T>(
  Iterable<TaxonomyCategoryNode> nodes,
  T Function(TaxonomyCategoryNode node) select,
) {
  final counts = <T, int>{};
  for (final node in nodes) {
    counts.update(select(node), (count) => count + 1, ifAbsent: () => 1);
  }
  return counts;
}

T _expectRight<T>(Either<String, T> result) {
  return result.fold((error) => throw TestFailure(error), (value) => value);
}
