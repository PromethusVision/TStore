import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/shop/domain/repositories/canonical_taxonomy_repository.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_navigation.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';
import 'package:t_store/features/shop/presentation/cubit/taxonomy_browse_state.dart';

class TaxonomyBrowseCubit extends Cubit<TaxonomyBrowseState> {
  TaxonomyBrowseCubit({required this.repository, required this.capability})
    : super(TaxonomyBrowseInitial());

  final CanonicalTaxonomyRepository repository;
  final TaxonomyRuntimeCapability capability;
  int _requestId = 0;

  Future<void> load(TaxonomyCategoryNode category) async {
    final requestId = ++_requestId;
    if (!capability.isCanonicalV1) {
      emit(
        const TaxonomyBrowseError('Canonical kategori gezintisi etkin değil.'),
      );
      return;
    }

    try {
      capability.requireCanonicalVersion(category.taxonomyVersion);
    } on Object {
      emit(
        const TaxonomyBrowseError(
          'Kategori sürümü doğrulanamadı. Legacy moda otomatik dönülmedi.',
        ),
      );
      return;
    }

    final decision = TaxonomyCategoryNavigationDecision.forCanonicalNode(
      category,
    );
    if (decision.action == TaxonomyCategoryNavigationAction.unavailable) {
      emit(
        TaxonomyBrowseBlocked(
          decision.blockReason ?? TaxonomyCategoryBlockReason.notAssignable,
        ),
      );
      return;
    }

    emit(TaxonomyBrowseLoading(category));
    final breadcrumbResult = await repository.getBreadcrumb(category.id);
    if (!_canHandle(requestId)) return;

    await breadcrumbResult.fold(
      (error) async => emit(TaxonomyBrowseError(error)),
      (breadcrumb) async {
        if (decision.action ==
            TaxonomyCategoryNavigationAction.openProductListing) {
          emit(
            TaxonomyBrowseLoaded(
              category: category,
              breadcrumb: breadcrumb,
              children: const [],
              navigationDecision: decision,
            ),
          );
          return;
        }

        final childrenResult = await repository.getChildren(category.id);
        if (!_canHandle(requestId)) return;
        childrenResult.fold((error) => emit(TaxonomyBrowseError(error)), (
          children,
        ) {
          try {
            _validateChildren(parent: category, children: children);
            emit(
              TaxonomyBrowseLoaded(
                category: category,
                breadcrumb: breadcrumb,
                children: List.unmodifiable(children),
                navigationDecision: decision,
              ),
            );
          } on Object {
            emit(
              const TaxonomyBrowseError(
                'Alt kategori sözleşmesi doğrulanamadı.',
              ),
            );
          }
        });
      },
    );
  }

  void _validateChildren({
    required TaxonomyCategoryNode parent,
    required List<TaxonomyCategoryNode> children,
  }) {
    final ids = <String>{};
    for (final child in children) {
      capability.requireCanonicalVersion(child.taxonomyVersion);
      if (!ids.add(child.id) ||
          child.parentId != parent.id ||
          child.level.depth != parent.level.depth + 1 ||
          !child.isDiscoverable) {
        throw const FormatException('Invalid canonical child projection.');
      }
    }
  }

  bool _canHandle(int requestId) => !isClosed && requestId == _requestId;
}
