import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_state.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';
import 'package:t_store/features/shop/presentation/views/sub_category_view.dart';
import 'package:t_store/features/shop/presentation/views/taxonomy_browse_view.dart';
import 'package:t_store/features/shop/presentation/widgets/home_categories.dart';

import '../../helpers/canonical_taxonomy_test_support.dart';

class _MockCategoriesCubit extends MockCubit<CategoriesState>
    implements CategoriesCubit {}

class _MockProductsCubit extends MockCubit<ProductsState>
    implements ProductsCubit {}

void main() {
  late _MockCategoriesCubit categoriesCubit;

  setUp(() async {
    await sl.reset();
    categoriesCubit = _MockCategoriesCubit();
    when(() => categoriesCubit.getCategories()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await categoriesCubit.close();
    await sl.reset();
  });

  Future<void> openIndex(WidgetTester tester, CategoriesLoaded state) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    whenListen(
      categoriesCubit,
      const Stream<CategoriesState>.empty(),
      initialState: state,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: EsnaftaVarTheme.light,
        home: Scaffold(
          body: BlocProvider<CategoriesCubit>.value(
            value: categoriesCubit,
            child: const HomeCategories(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(Key('home-category-${state.categories.last.id}')),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('home-all-categories')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('all-categories-root')), findsOneWidget);
    final lastRoot = find.byKey(
      Key('home-category-${state.categories.last.id}'),
    );
    await tester.ensureVisible(lastRoot);
    await tester.pumpAndSettle();
    await tester.tap(lastRoot);
    await tester.pumpAndSettle();
  }

  testWidgets('W53B full index opens existing legacy product listing', (
    tester,
  ) async {
    final productsCubit = _MockProductsCubit();
    whenListen(
      productsCubit,
      const Stream<ProductsState>.empty(),
      initialState: const ProductsLoaded(products: []),
    );
    when(
      () => productsCubit.getProducts(categoryId: 'root-10', refresh: true),
    ).thenAnswer((_) async {});
    sl.registerFactory<ProductsCubit>(() => productsCubit);

    await openIndex(
      tester,
      CategoriesLoaded([
        for (var i = 0; i < 11; i++)
          CategoryEntity(id: 'root-$i', name: 'Kategori $i'),
      ]),
    );

    final destination = tester.widget<SubCategoryView>(
      find.byType(SubCategoryView),
    );
    expect(destination.categoryId, 'root-10');
    expect(destination.title, 'Kategori 10');
    expect(find.byKey(const Key('category-products-empty')), findsOneWidget);
    verify(
      () => productsCubit.getProducts(categoryId: 'root-10', refresh: true),
    ).called(1);
    await tester.tap(find.byKey(const Key('category-back-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('all-categories-root')), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-category-root-7')), findsOneWidget);
    expect(find.byKey(const Key('home-category-root-10')), findsNothing);
    verifyNever(() => categoriesCubit.close());
    verifyNever(() => categoriesCubit.getCategories());
    expect(tester.takeException(), isNull);
  });

  testWidgets('W53B full index keeps canonical repository and capability', (
    tester,
  ) async {
    final roots = canonicalRoots();
    final selected = roots.last;
    final repository = FakeCanonicalTaxonomyRepository();
    final capability = canonicalCapability();
    repository.breadcrumbResults[selected.id] = Right(
      TaxonomyBreadcrumb([
        TaxonomyBreadcrumbItem(
          categoryId: selected.id,
          label: selected.displayName,
          level: selected.level,
        ),
      ]),
    );
    when(
      () => categoriesCubit.activeCanonicalRepository,
    ).thenReturn(repository);
    when(() => categoriesCubit.taxonomyCapability).thenReturn(capability);

    await openIndex(
      tester,
      CategoriesLoaded(
        [
          for (final node in roots)
            CategoryEntity(id: node.id, name: node.displayName),
        ],
        runtimeMode: TaxonomyRuntimeMode.canonicalV1Runtime,
        canonicalNodes: roots,
      ),
    );

    final destination = tester.widget<TaxonomyBrowseView>(
      find.byType(TaxonomyBrowseView),
    );
    expect(destination.category, selected);
    expect(destination.repository, same(repository));
    expect(destination.capability, same(capability));
    expect(repository.breadcrumbCalls, [selected.id]);
    expect(repository.childrenCalls, [selected.id]);
    expect(repository.rootsCallCount, 0);
    expect(find.byType(SubCategoryView), findsNothing);
    verifyNever(() => categoriesCubit.getCategories());
    expect(tester.takeException(), isNull);
  });
}
