import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/entities/brand_entity.dart';
import 'package:t_store/features/shop/domain/repositories/canonical_taxonomy_repository.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/usecases/get_categories_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/get_brands_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/brands_cubit.dart';
import '../../helpers/canonical_taxonomy_test_support.dart';

class _Legacy extends Mock implements GetCategoriesUsecase {}

class _Canonical extends Mock implements CanonicalTaxonomyRepository {}

class _Brands extends Mock implements GetBrandsUsecase {}

void main() {
  setUpAll(() => registerFallbackValue(const NoParams()));
  test('closing preview discards pending canonical roots', () async {
    final pending = Completer<Either<String, List<TaxonomyCategoryNode>>>();
    final repository = _Canonical();
    when(() => repository.getRoots()).thenAnswer((_) => pending.future);
    final cubit = CategoriesCubit(
      getCategoriesUsecase: _Legacy(),
      taxonomyCapability: canonicalCapability(),
      canonicalTaxonomyRepository: repository,
    );
    final request = cubit.getCategories();
    await cubit.close();
    pending.complete(Right(canonicalRoots()));
    await expectLater(request, completes);
  });
  test('closing app discards pending legacy roots', () async {
    final pending = Completer<Either<String, List<CategoryEntity>>>();
    final legacy = _Legacy();
    when(() => legacy(any())).thenAnswer((_) => pending.future);
    final cubit = CategoriesCubit(getCategoriesUsecase: legacy);
    final request = cubit.getCategories();
    await cubit.close();
    pending.complete(const Right([]));
    await expectLater(request, completes);
  });
  test('closing preview discards pending public brands', () async {
    final pending = Completer<Either<String, List<BrandEntity>>>();
    final brands = _Brands();
    when(() => brands(any())).thenAnswer((_) => pending.future);
    final cubit = BrandsCubit(getBrandsUsecase: brands);
    final request = cubit.getBrands();
    await cubit.close();
    pending.complete(const Left('late response'));
    await expectLater(request, completes);
  });
}
