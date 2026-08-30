import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'legacy remains default and canonical opt-in exists only in Development',
    () {
      final development = File('lib/main_development.dart').readAsStringSync();
      final production = File('lib/main_production.dart').readAsStringSync();

      expect(development, contains('TaxonomyDependencyConfiguration.legacy'));
      expect(production, contains('TaxonomyDependencyConfiguration.legacy'));
      expect(
        development,
        contains('ESNAFTAVAR_DEVELOPMENT_CANONICAL_TAXONOMY'),
      );
      expect(development, contains('const bool.fromEnvironment'));
      expect(production, isNot(contains('DEVELOPMENT_CANONICAL_TAXONOMY')));
      expect(production, isNot(contains('taxonomy_capabilities_v2')));
      expect(development, isNot(contains('tnipyxnvhgelwdpykyez')));
    },
  );

  test(
    'service locator binds strict repositories only after verified plan',
    () {
      final source = File(
        'lib/core/dependency_injection/service_locator.dart',
      ).readAsStringSync();

      expect(source, contains('TaxonomyDependencyPlanner().resolve'));
      expect(source, contains('taxonomyPlan.requiresCanonicalBindings'));
      expect(source, contains('SupabaseCanonicalTaxonomyRpcAdapter'));
      expect(source, contains('CanonicalTaxonomyScopedProductRepositoryImpl'));
    },
  );
}
