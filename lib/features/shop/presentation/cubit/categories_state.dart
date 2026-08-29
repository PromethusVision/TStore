import 'package:equatable/equatable.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<CategoryEntity> categories;
  final TaxonomyRuntimeMode runtimeMode;
  final List<TaxonomyCategoryNode> canonicalNodes;

  const CategoriesLoaded(
    this.categories, {
    this.runtimeMode = TaxonomyRuntimeMode.legacyRuntime,
    this.canonicalNodes = const [],
  });

  TaxonomyCategoryNode? canonicalNodeFor(String categoryId) {
    final normalizedId = categoryId.trim();
    for (final node in canonicalNodes) {
      if (node.id == normalizedId) return node;
    }
    return null;
  }

  @override
  List<Object?> get props => [categories, runtimeMode, canonicalNodes];
}

class CategoriesError extends CategoriesState {
  final String message;

  const CategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}
