import 'package:equatable/equatable.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_product_query_scope.dart';

enum TaxonomyCategoryNavigationAction {
  navigateDeeper,
  openProductListing,
  unavailable,
}

enum TaxonomyCategoryNavigationEvidence {
  canonicalHierarchy,
  currentRuntimeFallback,
}

enum TaxonomyCategoryBlockReason { notActive, notAssignable, policyBlocked }

class TaxonomyCategoryNavigationDecision extends Equatable {
  const TaxonomyCategoryNavigationDecision._({
    required this.action,
    required this.evidence,
    this.productQueryScope,
    this.blockReason,
  });

  factory TaxonomyCategoryNavigationDecision.forCanonicalNode(
    TaxonomyCategoryNode node,
  ) {
    if (!node.isActive) {
      return const TaxonomyCategoryNavigationDecision._(
        action: TaxonomyCategoryNavigationAction.unavailable,
        evidence: TaxonomyCategoryNavigationEvidence.canonicalHierarchy,
        blockReason: TaxonomyCategoryBlockReason.notActive,
      );
    }
    if (!node.isDiscoverable) {
      return const TaxonomyCategoryNavigationDecision._(
        action: TaxonomyCategoryNavigationAction.unavailable,
        evidence: TaxonomyCategoryNavigationEvidence.canonicalHierarchy,
        blockReason: TaxonomyCategoryBlockReason.policyBlocked,
      );
    }
    if (node.isContainer) {
      return const TaxonomyCategoryNavigationDecision._(
        action: TaxonomyCategoryNavigationAction.navigateDeeper,
        evidence: TaxonomyCategoryNavigationEvidence.canonicalHierarchy,
      );
    }
    if (!node.canAssignProducts) {
      final blockReason = node.isPolicyClearedForAssignment
          ? TaxonomyCategoryBlockReason.notAssignable
          : TaxonomyCategoryBlockReason.policyBlocked;
      return TaxonomyCategoryNavigationDecision._(
        action: TaxonomyCategoryNavigationAction.unavailable,
        evidence: TaxonomyCategoryNavigationEvidence.canonicalHierarchy,
        blockReason: blockReason,
      );
    }
    return TaxonomyCategoryNavigationDecision._(
      action: TaxonomyCategoryNavigationAction.openProductListing,
      evidence: TaxonomyCategoryNavigationEvidence.canonicalHierarchy,
      productQueryScope: TaxonomyProductQueryScope.exactLeaf(
        categoryId: node.id,
      ),
    );
  }

  factory TaxonomyCategoryNavigationDecision.currentRuntimeFallback(
    CategoryEntity category,
  ) {
    return TaxonomyCategoryNavigationDecision._(
      action: TaxonomyCategoryNavigationAction.openProductListing,
      evidence: TaxonomyCategoryNavigationEvidence.currentRuntimeFallback,
      productQueryScope: TaxonomyProductQueryScope.exactLeaf(
        categoryId: category.id,
        hasCanonicalHierarchyEvidence: false,
      ),
    );
  }

  static TaxonomyCategoryNavigationDecision resolve({
    required CategoryEntity currentCategory,
    TaxonomyCategoryNode? canonicalNode,
  }) {
    if (canonicalNode == null) {
      return TaxonomyCategoryNavigationDecision.currentRuntimeFallback(
        currentCategory,
      );
    }
    if (currentCategory.id.trim() != canonicalNode.id) {
      throw ArgumentError.value(
        canonicalNode.id,
        'canonicalNode',
        'Canonical and current category ids must match.',
      );
    }
    return TaxonomyCategoryNavigationDecision.forCanonicalNode(canonicalNode);
  }

  final TaxonomyCategoryNavigationAction action;
  final TaxonomyCategoryNavigationEvidence evidence;
  final TaxonomyProductQueryScope? productQueryScope;
  final TaxonomyCategoryBlockReason? blockReason;

  @override
  List<Object?> get props => [action, evidence, productQueryScope, blockReason];
}
