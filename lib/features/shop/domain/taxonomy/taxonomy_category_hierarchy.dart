import 'dart:collection';

import 'package:equatable/equatable.dart';

enum TaxonomyCategoryLevel {
  l1(1),
  l2(2),
  l3(3),
  l4(4);

  const TaxonomyCategoryLevel(this.depth);

  final int depth;
}

enum TaxonomyCategoryKind { container, leaf }

enum TaxonomyCategoryLifecycle { staged, active, retired }

enum TaxonomyCategoryAssignability { assignable, notAssignable }

enum TaxonomyPolicyClass {
  normal,
  ageRestricted,
  regulated,
  legalReviewRequired,
  excluded,
}

enum TaxonomyProfessionalReviewStatus {
  notRequired,
  pending,
  approved,
  rejected,
}

class TaxonomyCategoryNode extends Equatable {
  TaxonomyCategoryNode({
    required String id,
    required String displayName,
    required this.level,
    required this.kind,
    required this.lifecycle,
    required this.assignability,
    String? parentId,
    String? slug,
    this.sortOrder = 0,
    String? taxonomyVersion,
    this.policyClass = TaxonomyPolicyClass.normal,
    this.professionalReviewStatus =
        TaxonomyProfessionalReviewStatus.notRequired,
    this.isPreviewContext = false,
  }) : id = _requiredText(id, 'id'),
       displayName = _requiredText(displayName, 'displayName'),
       parentId = _optionalText(parentId),
       slug = _optionalText(slug),
       taxonomyVersion = _optionalText(taxonomyVersion) {
    _validateLocalContract();
  }

  final String id;
  final String displayName;
  final String? parentId;
  final String? slug;
  final TaxonomyCategoryLevel level;
  final TaxonomyCategoryKind kind;
  final TaxonomyCategoryLifecycle lifecycle;
  final TaxonomyCategoryAssignability assignability;
  final TaxonomyPolicyClass policyClass;
  final TaxonomyProfessionalReviewStatus professionalReviewStatus;
  final int sortOrder;
  final String? taxonomyVersion;
  final bool isPreviewContext;

  bool get isRoot => level == TaxonomyCategoryLevel.l1;
  bool get isLeaf => kind == TaxonomyCategoryKind.leaf;
  bool get isContainer => kind == TaxonomyCategoryKind.container;
  bool get isActive => lifecycle == TaxonomyCategoryLifecycle.active;

  bool get isDiscoverable =>
      (isActive || isPreviewContext) &&
      policyClass != TaxonomyPolicyClass.excluded;

  bool get isPolicyClearedForAssignment =>
      policyClass == TaxonomyPolicyClass.normal &&
      professionalReviewStatus == TaxonomyProfessionalReviewStatus.notRequired;

  bool get canAssignProducts =>
      (isActive || isPreviewContext) &&
      isLeaf &&
      assignability == TaxonomyCategoryAssignability.assignable &&
      isPolicyClearedForAssignment;

  void _validateLocalContract() {
    if (isRoot && parentId != null) {
      throw ArgumentError.value(
        parentId,
        'parentId',
        'L1 category cannot have a parent.',
      );
    }
    if (!isRoot && parentId == null) {
      throw ArgumentError.value(
        parentId,
        'parentId',
        '${level.name.toUpperCase()} category must have a parent.',
      );
    }
    if (isRoot && isLeaf) {
      throw ArgumentError.value(
        kind,
        'kind',
        'Canonical V1 does not allow an L1 leaf.',
      );
    }
    if (level == TaxonomyCategoryLevel.l4 && isContainer) {
      throw ArgumentError.value(
        kind,
        'kind',
        'Canonical V1 maximum depth is L4.',
      );
    }
    if (assignability == TaxonomyCategoryAssignability.assignable &&
        (!isLeaf || (!isActive && !isPreviewContext))) {
      throw ArgumentError.value(
        assignability,
        'assignability',
        'Only an active leaf can be assignable.',
      );
    }
  }

  static String _requiredText(String value, String fieldName) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(value, fieldName, 'Value cannot be empty.');
    }
    return normalized;
  }

  static String? _optionalText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  @override
  List<Object?> get props => [
    id,
    displayName,
    parentId,
    slug,
    level,
    kind,
    lifecycle,
    assignability,
    policyClass,
    professionalReviewStatus,
    sortOrder,
    taxonomyVersion,
    isPreviewContext,
  ];
}

class TaxonomyBreadcrumbItem extends Equatable {
  const TaxonomyBreadcrumbItem({
    required this.categoryId,
    required this.label,
    required this.level,
  });

  final String categoryId;
  final String label;
  final TaxonomyCategoryLevel level;

  @override
  List<Object?> get props => [categoryId, label, level];
}

class TaxonomyBreadcrumb extends Equatable {
  TaxonomyBreadcrumb(Iterable<TaxonomyBreadcrumbItem> items)
    : items = List.unmodifiable(items) {
    if (this.items.isEmpty) {
      throw ArgumentError.value(items, 'items', 'Breadcrumb cannot be empty.');
    }
    for (var index = 0; index < this.items.length; index++) {
      if (this.items[index].level.depth != index + 1) {
        throw ArgumentError.value(
          items,
          'items',
          'Breadcrumb levels must be contiguous and start at L1.',
        );
      }
    }
  }

  final List<TaxonomyBreadcrumbItem> items;

  String get fullLabel => items.map((item) => item.label).join(' > ');
  TaxonomyBreadcrumbItem get current => items.last;

  @override
  List<Object?> get props => [items];
}

class TaxonomyCategoryHierarchy {
  TaxonomyCategoryHierarchy._(Map<String, TaxonomyCategoryNode> nodesById)
    : _nodesById = UnmodifiableMapView(nodesById);

  factory TaxonomyCategoryHierarchy.fromNodes(
    Iterable<TaxonomyCategoryNode> nodes,
  ) {
    final nodesById = <String, TaxonomyCategoryNode>{};
    for (final node in nodes) {
      if (nodesById.containsKey(node.id)) {
        throw ArgumentError.value(node.id, 'nodes', 'Duplicate category id.');
      }
      nodesById[node.id] = node;
    }

    final hierarchy = TaxonomyCategoryHierarchy._(nodesById);
    hierarchy._validateRelationships();
    return hierarchy;
  }

  final Map<String, TaxonomyCategoryNode> _nodesById;

  int get length => _nodesById.length;

  int get maxDepth {
    if (_nodesById.isEmpty) return 0;
    return _nodesById.values
        .map((node) => node.level.depth)
        .reduce((first, second) => first > second ? first : second);
  }

  List<TaxonomyCategoryNode> get roots =>
      _sorted(_nodesById.values.where((node) => node.isRoot));

  List<TaxonomyCategoryNode> get activeRoots =>
      roots.where((node) => node.isActive).toList(growable: false);

  TaxonomyCategoryNode? nodeById(String categoryId) =>
      _nodesById[categoryId.trim()];

  List<TaxonomyCategoryNode> childrenOf(String categoryId) {
    final parent = _requiredNode(categoryId);
    return _sorted(
      _nodesById.values.where((node) => node.parentId == parent.id),
    );
  }

  List<TaxonomyCategoryNode> descendantsOf(String categoryId) {
    final descendants = <TaxonomyCategoryNode>[];

    void visit(String parentId) {
      for (final child in childrenOf(parentId)) {
        descendants.add(child);
        visit(child.id);
      }
    }

    visit(_requiredNode(categoryId).id);
    return List.unmodifiable(descendants);
  }

  TaxonomyBreadcrumb breadcrumbFor(String categoryId) {
    final reversedItems = <TaxonomyBreadcrumbItem>[];
    var current = _requiredNode(categoryId);

    while (true) {
      reversedItems.add(
        TaxonomyBreadcrumbItem(
          categoryId: current.id,
          label: current.displayName,
          level: current.level,
        ),
      );
      final parentId = current.parentId;
      if (parentId == null) break;
      current = _requiredNode(parentId);
    }

    return TaxonomyBreadcrumb(reversedItems.reversed);
  }

  void _validateRelationships() {
    for (final node in _nodesById.values) {
      final parentId = node.parentId;
      if (parentId == null) continue;

      final parent = _nodesById[parentId];
      if (parent == null) {
        throw ArgumentError.value(
          parentId,
          'nodes',
          'Category ${node.id} has a missing parent.',
        );
      }
      if (!parent.isContainer) {
        throw ArgumentError.value(
          parentId,
          'nodes',
          'Category ${node.id} cannot be a child of a leaf.',
        );
      }
      if (parent.level.depth + 1 != node.level.depth) {
        throw ArgumentError.value(
          node.level,
          'nodes',
          'Category ${node.id} must be exactly one level below its parent.',
        );
      }
    }
  }

  TaxonomyCategoryNode _requiredNode(String categoryId) {
    final normalizedId = categoryId.trim();
    final node = _nodesById[normalizedId];
    if (node == null) {
      throw ArgumentError.value(
        categoryId,
        'categoryId',
        'Unknown category id.',
      );
    }
    return node;
  }

  static List<TaxonomyCategoryNode> _sorted(
    Iterable<TaxonomyCategoryNode> nodes,
  ) {
    final sorted = nodes.toList();
    sorted.sort((first, second) {
      final sortComparison = first.sortOrder.compareTo(second.sortOrder);
      if (sortComparison != 0) return sortComparison;
      final nameComparison = first.displayName.compareTo(second.displayName);
      if (nameComparison != 0) return nameComparison;
      return first.id.compareTo(second.id);
    });
    return List.unmodifiable(sorted);
  }
}
