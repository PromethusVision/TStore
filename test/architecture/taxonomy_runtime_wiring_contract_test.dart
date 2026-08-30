import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('both entrypoints explicitly preserve legacy taxonomy runtime', () {
    final development = File('lib/main_development.dart').readAsStringSync();
    final production = File('lib/main_production.dart').readAsStringSync();

    expect(development, contains('TaxonomyDependencyConfiguration.legacy'));
    expect(production, contains('TaxonomyDependencyConfiguration.legacy'));
    expect(development, isNot(contains('CANONICAL_TAXONOMY_ENABLED')));
    expect(production, isNot(contains('CANONICAL_TAXONOMY_ENABLED')));
  });

  test('service locator requires proof and explicit canonical bindings', () {
    final source = File(
      'lib/core/dependency_injection/service_locator.dart',
    ).readAsStringSync();

    expect(source, contains('TaxonomyDependencyPlanner().resolve'));
    expect(source, contains('taxonomyPlan.requiresCanonicalBindings'));
    expect(source, contains('verifiedCanonicalTaxonomyAdapter'));
    expect(source, contains('verifiedTaxonomyScopedProductRepository'));
  });
}
