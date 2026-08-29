import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_alias_resolution.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_search_context.dart';
import 'package:t_store/features/shop/domain/usecases/get_categories_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/get_products_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/get_shops_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/search_products_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_state.dart';

import '../../helpers/canonical_taxonomy_test_support.dart';

class _MockSearchProductsUsecase extends Mock
    implements SearchProductsUsecase {}

class _MockGetProductsUsecase extends Mock implements GetProductsUsecase {}

class _MockGetCategoriesUsecase extends Mock implements GetCategoriesUsecase {}

class _MockGetShopsUsecase extends Mock implements GetShopsUsecase {}

void main() {
  late _MockSearchProductsUsecase searchProductsUsecase;
  late _MockGetProductsUsecase getProductsUsecase;
  late _MockGetCategoriesUsecase getCategoriesUsecase;
  late _MockGetShopsUsecase getShopsUsecase;
  late FakeCanonicalTaxonomyRepository repository;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(GetProductsParams());
  });

  setUp(() {
    searchProductsUsecase = _MockSearchProductsUsecase();
    getProductsUsecase = _MockGetProductsUsecase();
    getCategoriesUsecase = _MockGetCategoriesUsecase();
    getShopsUsecase = _MockGetShopsUsecase();
    repository = FakeCanonicalTaxonomyRepository();

    when(
      () => searchProductsUsecase(any()),
    ).thenAnswer((_) async => const Right([]));
    when(() => getShopsUsecase(any())).thenAnswer((_) async => const Right([]));
  });

  CustomerSearchCubit buildCubit({
    FakeCanonicalTaxonomyRepository? canonicalRepository,
  }) {
    return CustomerSearchCubit(
      searchProductsUsecase: searchProductsUsecase,
      getProductsUsecase: getProductsUsecase,
      getCategoriesUsecase: getCategoriesUsecase,
      getShopsUsecase: getShopsUsecase,
      taxonomyCapability: canonicalCapability(),
      canonicalTaxonomyRepository: canonicalRepository,
    );
  }

  blocTest<CustomerSearchCubit, CustomerSearchState>(
    'canonical search uses server contract and skips legacy first-match merge',
    setUp: () {
      repository.searchResult = Right([_searchContext(alias: true)]);
    },
    build: () => buildCubit(canonicalRepository: repository),
    act: (cubit) => cubit.search('düzleştirici'),
    expect: () => [
      const CustomerSearchLoading('düzleştirici'),
      isA<CustomerSearchLoaded>()
          .having((state) => state.categories.single.id, 'category', 'leaf')
          .having(
            (state) => state.runtimeMode.name,
            'runtime mode',
            'canonicalV1Runtime',
          )
          .having(
            (state) => state.canonicalCategoryResults.single.aliasContext,
            'alias context',
            isNotNull,
          )
          .having(
            (state) => state.canOpenCategory('leaf'),
            'leaf navigation',
            isTrue,
          ),
    ],
    verify: (_) {
      expect(repository.searchCallCount, 1);
      verifyNever(() => getCategoriesUsecase(any()));
      verifyNever(() => getProductsUsecase(any()));
    },
  );

  blocTest<CustomerSearchCubit, CustomerSearchState>(
    'policy-blocked canonical leaf remains visible but cannot open as listing',
    setUp: () {
      repository.searchResult = Right([_searchContext(policyBlocked: true)]);
    },
    build: () => buildCubit(canonicalRepository: repository),
    act: (cubit) => cubit.search('medikal'),
    expect: () => [
      const CustomerSearchLoading('medikal'),
      isA<CustomerSearchLoaded>().having(
        (state) => state.canOpenCategory('leaf'),
        'blocked category action',
        isFalse,
      ),
    ],
    verify: (_) {
      verifyNever(() => getCategoriesUsecase(any()));
      verifyNever(() => getProductsUsecase(any()));
    },
  );

  blocTest<CustomerSearchCubit, CustomerSearchState>(
    'missing canonical repository fails only category section without legacy read',
    build: buildCubit,
    act: (cubit) => cubit.search('kategori'),
    expect: () => [
      const CustomerSearchLoading('kategori'),
      isA<CustomerSearchLoaded>()
          .having((state) => state.categories, 'categories', isEmpty)
          .having((state) => state.warningMessage, 'warning', isNotNull),
    ],
    verify: (_) => verifyNever(() => getCategoriesUsecase(any())),
  );
}

TaxonomyCategorySearchContext _searchContext({
  bool alias = false,
  bool policyBlocked = false,
}) {
  final root = canonicalNode(
    id: 'root',
    name: 'Beyaz Eşya & Ev Aletleri',
    level: TaxonomyCategoryLevel.l1,
    kind: TaxonomyCategoryKind.container,
  );
  final leaf = canonicalNode(
    id: 'leaf',
    name: policyBlocked
        ? 'Profesyonel Medikal Cihazlar'
        : 'Saç Düzleştirici & Şekillendiriciler',
    parentId: 'root',
    level: TaxonomyCategoryLevel.l2,
    kind: TaxonomyCategoryKind.leaf,
    assignable: true,
    policyClass: policyBlocked
        ? TaxonomyPolicyClass.regulated
        : TaxonomyPolicyClass.normal,
    professionalReviewStatus: policyBlocked
        ? TaxonomyProfessionalReviewStatus.pending
        : TaxonomyProfessionalReviewStatus.notRequired,
  );
  final hierarchy = TaxonomyCategoryHierarchy.fromNodes([root, leaf]);
  return TaxonomyCategorySearchContext.fromHierarchy(
    hierarchy: hierarchy,
    matchedCategoryId: leaf.id,
    aliasContext: alias
        ? TaxonomySearchAliasContext(
            matchedText: 'düzleştirici',
            locator: 'search/duzlestirici',
          )
        : null,
  );
}
