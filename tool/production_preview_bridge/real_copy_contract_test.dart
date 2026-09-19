// Explicit local proof runner, outside test/ so missing private data is never a
// new suite skip. Captured payloads remain outside Git. No network is used here.
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/taxonomy_dependency_configuration.dart';
import 'package:t_store/features/shop/data/repositories/canonical_taxonomy_repository_impl.dart';
import 'package:t_store/features/shop/data/repositories/production_preview_product_repository.dart';
import 'package:t_store/features/shop/data/services/production_preview_taxonomy_adapter.dart';
import 'package:t_store/features/shop/domain/repositories/canonical_taxonomy_repository.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_alias_resolution.dart';
import 'package:t_store/features/shop/domain/usecases/get_categories_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_state.dart';
import 'package:t_store/features/shop/presentation/widgets/home_categories.dart';
import '../../test/helpers/production_preview_test_support.dart';

class _UnusedLegacy extends Mock implements GetCategoriesUsecase {}

void main() {
  final path = Platform.environment['W52KB_CONTRACT_PATH'];
  if (path == null || !File(path).isAbsolute) {
    throw StateError('Private real-copy capture required.');
  }
  final capture =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  late ProductionPreviewTaxonomyAdapter adapter;
  late CanonicalTaxonomyRepositoryImpl repository;
  late ProductionPreviewProductRepository products;
  late TaxonomyDependencyPlan plan;
  setUp(() async {
    adapter = ProductionPreviewTaxonomyAdapter(
      config: previewTestConfig(),
      currentUserId: () =>
          (capture['taxonomy_capabilities_v2'] as List)
                  .single['preview_subject']
              as String,
      rpcCaller: (name, args) async {
        if (name == 'taxonomy_children_v2' ||
            name == 'taxonomy_breadcrumb_v2') {
          for (final path in capture['browse_paths'] as List) {
            if (name == 'taxonomy_children_v2' &&
                path['children'][0]['parent_id'] == args['p_parent_id']) {
              return path['children'];
            }
            if (name == 'taxonomy_breadcrumb_v2' &&
                path['node_id'] == args['p_category_id']) {
              return path['breadcrumb'];
            }
          }
        }
        if (name == 'production_preview_products_v1' &&
            args['p_product_id'] != null) {
          return (capture[name] as List)
              .where((p) => p['product_id'] == args['p_product_id'])
              .toList();
        }
        return capture[name];
      },
    );
    plan = const TaxonomyDependencyPlanner().resolve(
      TaxonomyDependencyConfiguration.productionPrivatePreview(
        await adapter.authorize(),
      ),
    );
    repository = CanonicalTaxonomyRepositoryImpl(adapter: adapter);
    products = ProductionPreviewProductRepository(adapter: adapter);
  });
  test(
    'real-copy capability and 24 roots pass existing Flutter domain validation',
    () async {
      expect(plan.registerProductionPreviewAdapter, isTrue);
      final roots = (await repository.getRoots()).getOrElse(
        () => throw StateError('roots rejected'),
      );
      expect(roots.length, 24);
      expect(roots.every((n) => n.isRoot && n.isPreviewContext), isTrue);
    },
  );
  test(
    'real-copy L2/L3/L4 children and breadcrumbs pass existing domain contract',
    () async {
      for (final path in capture['browse_paths'] as List) {
        final children = (await repository.getChildren(
          path['children'][0]['parent_id'] as String,
        )).getOrElse(() => throw StateError('children rejected'));
        expect(
          children.any(
            (n) => n.id == path['node_id'] && n.level.depth == path['depth'],
          ),
          isTrue,
        );
        final breadcrumb = (await repository.getBreadcrumb(
          path['node_id'] as String,
        )).getOrElse(() => throw StateError('breadcrumb rejected'));
        expect(breadcrumb.current.categoryId, path['node_id']);
      }
      expect(
        (await adapter.qualifyExactLeaf(
          (capture['taxonomy_exact_leaf_v2'] as List).single['id'] as String,
        )).single.toDomain().canAssignProducts,
        isTrue,
      );
      expect(
        (await repository.getDescendants(
          (capture['taxonomy_roots_v2'] as List).first['id'] as String,
        )).isRight(),
        isTrue,
      );
    },
  );
  test(
    'real-copy search and alias are accepted without custom translation',
    () async {
      final alias = (await repository.resolveAlias(
        TaxonomyAliasLookup(locator: 'powerbank'),
      )).getOrElse(() => throw StateError('alias rejected'));
      expect(alias.canRedirect, isTrue);
      final search = (await repository.searchTaxonomy(
        TaxonomySearchRequest(query: 'Defterler'),
      )).getOrElse(() => throw StateError('search rejected'));
      expect(search, isNotEmpty);
    },
  );
  test(
    'real-copy exact mappings produce canonical details for 14, gate 6',
    () async {
      final mappings = capture['production_preview_mappings_v1'] as List;
      expect(mappings.length, 20);
      expect((await products.getProducts()).getOrElse(() => []).length, 14);
      for (final mapping in mappings) {
        final detail = await products.getProductById(
          mapping['product_id'] as String,
        );
        if (mapping['eligible'] == true) {
          expect(
            detail
                .getOrElse(() => throw StateError('detail rejected'))
                .categoryId,
            mapping['canonical_category_id'],
          );
        } else {
          expect(detail.isLeft(), isTrue);
        }
      }
    },
  );
  testWidgets('real-copy roots use accepted Home eight and All categories 24', (
    tester,
  ) async {
    final cubit = CategoriesCubit(
      getCategoriesUsecase: _UnusedLegacy(),
      taxonomyCapability: plan.capability,
      canonicalTaxonomyRepository: repository,
    );
    addTearDown(cubit.close);
    await cubit.getCategories();
    expect((cubit.state as CategoriesLoaded).categories.length, 24);
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(value: cubit, child: const HomeCategories()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final grid = tester.widget<GridView>(find.byType(GridView));
    expect(grid.childrenDelegate.estimatedChildCount, 8);
    await tester.tap(find.byKey(const Key('home-all-categories')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<GridView>(find.byType(GridView))
          .childrenDelegate
          .estimatedChildCount,
      24,
    );
    expect(tester.takeException(), isNull);
  });
}
