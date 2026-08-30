import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';
import 'package:t_store/main_development.dart' as development;

void main() {
  test(
    'Development canonical opt-in is off and performs no proof read by default',
    () async {
      var proofReads = 0;
      final configuration = await development
          .createDevelopmentTaxonomyConfiguration(
            canonicalOptIn: false,
            proofLoader: () async {
              proofReads++;
              return _previewOnProof();
            },
          );

      expect(configuration.runtimeRequest.name, 'legacy');
      expect(proofReads, 0);
    },
  );

  test(
    'explicit Development opt-in requires the supplied live proof',
    () async {
      var proofReads = 0;
      final proof = _previewOnProof();
      final configuration = await development
          .createDevelopmentTaxonomyConfiguration(
            canonicalOptIn: true,
            proofLoader: () async {
              proofReads++;
              return proof;
            },
          );

      expect(proofReads, 1);
      expect(configuration.contractProof, same(proof));
      expect(configuration.runtimeRequest.name, 'canonicalV1Acceptance');
    },
  );
}

TaxonomyBackendContractProof _previewOnProof() {
  return TaxonomyBackendContractProof(
    contractVersion:
        TaxonomyBackendContractProof.supportedClientContractVersion,
    taxonomyVersion: TaxonomyBackendContractProof.supportedTaxonomyVersion,
    rpcContractVersion:
        TaxonomyBackendContractProof.supportedRpcContractVersion,
    rpcGeneration: TaxonomyBackendContractProof.supportedRpcGeneration,
    supportedFeatures: TaxonomyBackendContractProof.requiredCanonicalV1Features,
    verifiedEvidence: TaxonomyBackendContractProof.requiredCanonicalV1Evidence,
    previewSupported: true,
    previewEnabled: true,
    lifecycleMetadata: true,
    policyMetadata: true,
    aliasStateMetadata: true,
    pathMetadata: true,
    publicActiveRootCount: 0,
    pilotActiveRootCount: 0,
    previewRootCount: 24,
    productScopeContract:
        TaxonomyBackendContractProof.supportedProductScopeContract,
    productScopeRequiresAssignable: true,
    productScopePolicyFailClosed: true,
  );
}
