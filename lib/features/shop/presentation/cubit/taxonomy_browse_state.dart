import 'package:equatable/equatable.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_navigation.dart';

abstract class TaxonomyBrowseState extends Equatable {
  const TaxonomyBrowseState();

  @override
  List<Object?> get props => [];
}

class TaxonomyBrowseInitial extends TaxonomyBrowseState {}

class TaxonomyBrowseLoading extends TaxonomyBrowseState {
  const TaxonomyBrowseLoading(this.category);

  final TaxonomyCategoryNode category;

  @override
  List<Object?> get props => [category];
}

class TaxonomyBrowseLoaded extends TaxonomyBrowseState {
  const TaxonomyBrowseLoaded({
    required this.category,
    required this.breadcrumb,
    required this.children,
    required this.navigationDecision,
  });

  final TaxonomyCategoryNode category;
  final TaxonomyBreadcrumb breadcrumb;
  final List<TaxonomyCategoryNode> children;
  final TaxonomyCategoryNavigationDecision navigationDecision;

  @override
  List<Object?> get props => [
    category,
    breadcrumb,
    children,
    navigationDecision,
  ];
}

class TaxonomyBrowseBlocked extends TaxonomyBrowseState {
  const TaxonomyBrowseBlocked(this.reason);

  final TaxonomyCategoryBlockReason reason;

  @override
  List<Object?> get props => [reason];
}

class TaxonomyBrowseError extends TaxonomyBrowseState {
  const TaxonomyBrowseError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
