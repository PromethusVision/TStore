import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/repositories/canonical_taxonomy_repository.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';
import 'package:t_store/features/shop/domain/usecases/get_categories_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final GetCategoriesUsecase getCategoriesUsecase;
  final TaxonomyRuntimeCapability taxonomyCapability;
  final CanonicalTaxonomyRepository? canonicalTaxonomyRepository;

  CategoriesCubit({
    required this.getCategoriesUsecase,
    this.taxonomyCapability = TaxonomyRuntimeCapability.currentDefault,
    this.canonicalTaxonomyRepository,
  }) : super(CategoriesInitial());

  CanonicalTaxonomyRepository? get activeCanonicalRepository =>
      taxonomyCapability.isCanonicalV1 ? canonicalTaxonomyRepository : null;

  Future<void> getCategories() async {
    emit(CategoriesLoading());

    if (taxonomyCapability.isLegacy) {
      final result = await getCategoriesUsecase(const NoParams());

      result.fold(
        (error) => emit(CategoriesError(error)),
        (categories) => emit(CategoriesLoaded(categories)),
      );
      return;
    }

    final repository = canonicalTaxonomyRepository;
    if (repository == null) {
      emit(
        const CategoriesError(
          'Canonical kategori sözleşmesi bu uygulama yapısında hazır değil.',
        ),
      );
      return;
    }

    final result = await repository.getRoots();
    result.fold(
      (error) => emit(CategoriesError(error)),
      (roots) => _emitCanonicalRoots(roots),
    );
  }

  void _emitCanonicalRoots(List<TaxonomyCategoryNode> roots) {
    try {
      final hierarchy = TaxonomyCategoryHierarchy.fromNodes(roots);
      final orderedRoots = hierarchy.roots;
      if (orderedRoots.length != 24 ||
          orderedRoots.any((node) => !node.isRoot || !node.isDiscoverable)) {
        throw const FormatException(
          'Canonical Home projection must contain 24 discoverable L1 roots.',
        );
      }
      for (final node in orderedRoots) {
        taxonomyCapability.requireCanonicalVersion(node.taxonomyVersion);
      }
      final categories = orderedRoots
          .map(
            (node) => CategoryEntity(
              id: node.id,
              name: node.displayName,
              parentId: node.parentId,
              sortOrder: node.sortOrder,
              isActive: node.isDiscoverable,
            ),
          )
          .toList(growable: false);
      emit(
        CategoriesLoaded(
          categories,
          runtimeMode: TaxonomyRuntimeMode.canonicalV1Runtime,
          canonicalNodes: orderedRoots,
        ),
      );
    } on Object {
      emit(
        const CategoriesError(
          'Canonical kategori kökleri doğrulanamadı. Legacy moda geri dönülmedi.',
        ),
      );
    }
  }
}
