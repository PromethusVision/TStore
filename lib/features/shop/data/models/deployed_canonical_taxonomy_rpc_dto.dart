import 'package:equatable/equatable.dart';

class DeployedTaxonomyNodeRpcDto extends Equatable {
  DeployedTaxonomyNodeRpcDto.fromJson(Map<String, dynamic> json)
    : id = _requiredUuid(json, 'id'),
      parentId = _optionalUuid(json, 'parent_id'),
      name = _requiredString(json, 'name'),
      slug = _requiredString(json, 'slug'),
      level = _requiredLevel(json, 'level'),
      isAssignable = _requiredBool(json, 'is_assignable'),
      sortOrder = _requiredInt(json, 'sort_order'),
      taxonomyVersion = _requiredString(json, 'taxonomy_version');

  final String id;
  final String? parentId;
  final String name;
  final String slug;
  final int level;
  final bool isAssignable;
  final int sortOrder;
  final String taxonomyVersion;

  @override
  List<Object?> get props => [
    id,
    parentId,
    name,
    slug,
    level,
    isAssignable,
    sortOrder,
    taxonomyVersion,
  ];
}

class DeployedTaxonomyDescendantRpcDto extends Equatable {
  DeployedTaxonomyDescendantRpcDto.fromJson(Map<String, dynamic> json)
    : id = _requiredUuid(json, 'id'),
      level = _requiredLevel(json, 'level'),
      isAssignable = _requiredBool(json, 'is_assignable');

  final String id;
  final int level;
  final bool isAssignable;

  @override
  List<Object?> get props => [id, level, isAssignable];
}

class DeployedTaxonomyExactLeafRpcDto extends Equatable {
  DeployedTaxonomyExactLeafRpcDto.fromJson(Map<String, dynamic> json)
    : id = _requiredUuid(json, 'id'),
      name = _requiredString(json, 'name'),
      slug = _requiredString(json, 'slug'),
      taxonomyVersion = _requiredString(json, 'taxonomy_version');

  final String id;
  final String name;
  final String slug;
  final String taxonomyVersion;

  @override
  List<Object?> get props => [id, name, slug, taxonomyVersion];
}

class DeployedTaxonomyBreadcrumbRpcDto extends Equatable {
  DeployedTaxonomyBreadcrumbRpcDto.fromJson(Map<String, dynamic> json)
    : id = _requiredUuid(json, 'id'),
      parentId = _optionalUuid(json, 'parent_id'),
      name = _requiredString(json, 'name'),
      slug = _requiredString(json, 'slug'),
      level = _requiredLevel(json, 'level');

  final String id;
  final String? parentId;
  final String name;
  final String slug;
  final int level;

  @override
  List<Object?> get props => [id, parentId, name, slug, level];
}

class DeployedTaxonomyResolvedAliasRpcDto extends Equatable {
  DeployedTaxonomyResolvedAliasRpcDto.fromJson(Map<String, dynamic> json)
    : categoryId = _requiredUuid(json, 'category_id'),
      canonicalSlug = _requiredString(json, 'canonical_slug'),
      resolutionState = _requiredString(json, 'resolution_state') {
    if (resolutionState != 'RESOLVED') {
      throw const FormatException(
        'The deployed public alias RPC may expose only RESOLVED rows.',
      );
    }
  }

  final String categoryId;
  final String canonicalSlug;
  final String resolutionState;

  @override
  List<Object?> get props => [categoryId, canonicalSlug, resolutionState];
}

class DeployedTaxonomySearchMatchRpcDto extends Equatable {
  DeployedTaxonomySearchMatchRpcDto.fromJson(Map<String, dynamic> json)
    : categoryId = _requiredUuid(json, 'category_id'),
      name = _requiredString(json, 'name'),
      slug = _requiredString(json, 'slug'),
      matchKind = _requiredString(json, 'match_kind');

  final String categoryId;
  final String name;
  final String slug;
  final String matchKind;

  @override
  List<Object?> get props => [categoryId, name, slug, matchKind];
}

String _requiredUuid(Map<String, dynamic> json, String field) {
  final value = _requiredString(json, field);
  if (!_uuidPattern.hasMatch(value)) {
    throw FormatException('$field must be a UUID.');
  }
  return value;
}

String? _optionalUuid(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value == null) return null;
  if (value is! String || !_uuidPattern.hasMatch(value.trim())) {
    throw FormatException('$field must be null or a UUID.');
  }
  return value.trim();
}

String _requiredString(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$field must be a non-empty string.');
  }
  return value.trim();
}

int _requiredLevel(Map<String, dynamic> json, String field) {
  final value = _requiredInt(json, field);
  if (value < 1 || value > 4) {
    throw FormatException('$field must be between 1 and 4.');
  }
  return value;
}

int _requiredInt(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! int) throw FormatException('$field must be an integer.');
  return value;
}

bool _requiredBool(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! bool) throw FormatException('$field must be a boolean.');
  return value;
}

final _uuidPattern = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);
