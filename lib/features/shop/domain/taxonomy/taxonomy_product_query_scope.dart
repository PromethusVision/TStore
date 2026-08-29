import 'package:equatable/equatable.dart';

enum TaxonomyProductQueryScopeKind { exactLeaf, descendants }

class TaxonomyProductQueryScope extends Equatable {
  const TaxonomyProductQueryScope._({
    required this.categoryId,
    required this.kind,
    required this.hasCanonicalHierarchyEvidence,
  });

  factory TaxonomyProductQueryScope.exactLeaf({
    required String categoryId,
    bool hasCanonicalHierarchyEvidence = true,
  }) {
    return TaxonomyProductQueryScope._(
      categoryId: _requiredId(categoryId),
      kind: TaxonomyProductQueryScopeKind.exactLeaf,
      hasCanonicalHierarchyEvidence: hasCanonicalHierarchyEvidence,
    );
  }

  factory TaxonomyProductQueryScope.descendants({required String categoryId}) {
    return TaxonomyProductQueryScope._(
      categoryId: _requiredId(categoryId),
      kind: TaxonomyProductQueryScopeKind.descendants,
      hasCanonicalHierarchyEvidence: true,
    );
  }

  final String categoryId;
  final TaxonomyProductQueryScopeKind kind;

  /// False only for the pre-migration exact category filter compatibility path.
  final bool hasCanonicalHierarchyEvidence;

  static String _requiredId(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(value, 'categoryId', 'Value cannot be empty.');
    }
    return normalized;
  }

  @override
  List<Object?> get props => [categoryId, kind, hasCanonicalHierarchyEvidence];
}
