import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';
import 'package:t_store/features/shop/domain/usecases/get_categories_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_state.dart';

import '../../helpers/canonical_taxonomy_test_support.dart';

class _MockGetCategoriesUsecase extends Mock implements GetCategoriesUsecase {}

void main() {
  late _MockGetCategoriesUsecase legacyUsecase;
  late FakeCanonicalTaxonomyRepository canonicalRepository;

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() {
    legacyUsecase = _MockGetCategoriesUsecase();
    canonicalRepository = FakeCanonicalTaxonomyRepository();
  });

  blocTest<CategoriesCubit, CategoriesState>(
    'default capability keeps the exact legacy category source',
    setUp: () {
      when(() => legacyUsecase(any())).thenAnswer(
        (_) async =>
            const Right([CategoryEntity(id: 'legacy', name: 'Market')]),
      );
    },
    build: () => CategoriesCubit(
      getCategoriesUsecase: legacyUsecase,
      canonicalTaxonomyRepository: canonicalRepository,
    ),
    act: (cubit) => cubit.getCategories(),
    expect: () => [
      CategoriesLoading(),
      const CategoriesLoaded([CategoryEntity(id: 'legacy', name: 'Market')]),
    ],
    verify: (_) {
      verify(() => legacyUsecase(any())).called(1);
      expect(canonicalRepository.rootsCallCount, 0);
    },
  );

  blocTest<CategoriesCubit, CategoriesState>(
    'compatible canonical mode projects exactly 24 roots without legacy read',
    setUp: () {
      canonicalRepository.rootsResult = Right(canonicalRoots());
    },
    build: () => CategoriesCubit(
      getCategoriesUsecase: legacyUsecase,
      taxonomyCapability: canonicalCapability(),
      canonicalTaxonomyRepository: canonicalRepository,
    ),
    act: (cubit) => cubit.getCategories(),
    expect: () => [
      CategoriesLoading(),
      isA<CategoriesLoaded>()
          .having((state) => state.categories.length, 'root count', 24)
          .having(
            (state) => state.runtimeMode,
            'runtime mode',
            TaxonomyRuntimeMode.canonicalV1Runtime,
          )
          .having(
            (state) => state.canonicalNodes.length,
            'canonical node count',
            24,
          ),
    ],
    verify: (_) {
      verifyNever(() => legacyUsecase(any()));
      expect(canonicalRepository.rootsCallCount, 1);
    },
  );

  blocTest<CategoriesCubit, CategoriesState>(
    '23 roots fail closed and never fall back to the legacy repository',
    setUp: () {
      canonicalRepository.rootsResult = Right(
        canonicalRoots().take(23).toList(),
      );
    },
    build: () => CategoriesCubit(
      getCategoriesUsecase: legacyUsecase,
      taxonomyCapability: canonicalCapability(),
      canonicalTaxonomyRepository: canonicalRepository,
    ),
    act: (cubit) => cubit.getCategories(),
    expect: () => [CategoriesLoading(), isA<CategoriesError>()],
    verify: (_) => verifyNever(() => legacyUsecase(any())),
  );

  blocTest<CategoriesCubit, CategoriesState>(
    'taxonomy version mismatch fails closed',
    setUp: () {
      canonicalRepository.rootsResult = Right(
        canonicalRoots(taxonomyVersion: 'v1.0.1'),
      );
    },
    build: () => CategoriesCubit(
      getCategoriesUsecase: legacyUsecase,
      taxonomyCapability: canonicalCapability(),
      canonicalTaxonomyRepository: canonicalRepository,
    ),
    act: (cubit) => cubit.getCategories(),
    expect: () => [CategoriesLoading(), isA<CategoriesError>()],
    verify: (_) => verifyNever(() => legacyUsecase(any())),
  );
}
