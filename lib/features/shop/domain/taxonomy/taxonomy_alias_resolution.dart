import 'package:equatable/equatable.dart';

enum TaxonomyAliasResolutionState { resolved, ambiguous, tombstone, unresolved }

class TaxonomyAliasLookup extends Equatable {
  TaxonomyAliasLookup({required String locator, String locale = 'tr-TR'})
    : locator = _requiredText(locator, 'locator'),
      locale = _requiredText(locale, 'locale');

  final String locator;
  final String locale;

  @override
  List<Object?> get props => [locator, locale];
}

class TaxonomyAliasResolution extends Equatable {
  TaxonomyAliasResolution({
    required String locator,
    required this.state,
    required String taxonomyVersion,
    String? targetCategoryId,
  }) : locator = _requiredText(locator, 'locator'),
       taxonomyVersion = _requiredText(taxonomyVersion, 'taxonomyVersion'),
       targetCategoryId = _optionalText(targetCategoryId) {
    final hasTarget = this.targetCategoryId != null;
    if ((state == TaxonomyAliasResolutionState.resolved) != hasTarget) {
      throw ArgumentError.value(
        targetCategoryId,
        'targetCategoryId',
        'Only a resolved alias may have exactly one direct target.',
      );
    }
  }

  final String locator;
  final TaxonomyAliasResolutionState state;
  final String taxonomyVersion;
  final String? targetCategoryId;

  bool get canRedirect =>
      state == TaxonomyAliasResolutionState.resolved &&
      targetCategoryId != null;

  @override
  List<Object?> get props => [
    locator,
    state,
    taxonomyVersion,
    targetCategoryId,
  ];
}

class TaxonomySearchAliasContext extends Equatable {
  TaxonomySearchAliasContext({
    required String matchedText,
    required String locator,
  }) : matchedText = _requiredText(matchedText, 'matchedText'),
       locator = _requiredText(locator, 'locator');

  final String matchedText;
  final String locator;

  @override
  List<Object?> get props => [matchedText, locator];
}

String _requiredText(String value, String fieldName) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw ArgumentError.value(value, fieldName, 'Value cannot be empty.');
  }
  return normalized;
}

String? _optionalText(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
