import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/shop/data/services/deployed_canonical_taxonomy_rpc_contract.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_backend_contract_inventory.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';

void main() {
  const verifier = TaxonomyBackendCapabilityVerifier();

  test(
    'deployed Development V2 inventory matches shape but is not runtime proof',
    () {
      final result = verifier.assess(deployedCanonicalTaxonomyV2Inventory);

      expect(
        result.compatibility,
        TaxonomyContractCompatibility.match,
      );
      expect(result.supportsCanonicalV1, isFalse);
      expect(result.proof, isNull);
      expect(result.blockers, isEmpty);
    },
  );

  test(
    'deployed inventory records exact seven strict V2 signatures and grants',
    () {
      expect(deployedCanonicalTaxonomyV2Inventory.endpoints, hasLength(7));
      expect(
        deployedCanonicalTaxonomyV2Inventory
            .endpoints['taxonomy_children_v2']!
            .argumentNames,
        [
          'p_parent_id',
          'p_client_contract_version',
          'p_taxonomy_version',
          'p_preview',
        ],
      );
      expect(
        deployedCanonicalTaxonomyV2Inventory.endpoints.values.every(
          (endpoint) =>
              endpoint.isStable &&
              endpoint.searchPathPinnedToPublic &&
              endpoint.anonExecute &&
              endpoint.authenticatedExecute,
        ),
        isTrue,
      );
    },
  );

  test('static inventory cannot produce a runtime capability proof', () {
    final result = verifier.assess(_compatibleInventory());

    expect(result.blockers, isEmpty);
    expect(result.proof, isNull);
    expect(result.supportsCanonicalV1, isFalse);
  });

  test('one signature mismatch invalidates the whole proof', () {
    final compatible = _compatibleInventory();
    final endpoints = Map<String, TaxonomyRpcEndpointInventory>.of(
      compatible.endpoints,
    );
    endpoints['taxonomy_roots_v2'] = _endpoint(
      'taxonomy_roots_v2',
      const ['wrong_argument'],
      TaxonomyBackendCapabilityVerifier
          .requiredResponseFields['taxonomy_roots_v2']!,
    );

    final result = verifier.assess(
      TaxonomyBackendContractInventory(
        taxonomyVersion: compatible.taxonomyVersion,
        declaredClientContractVersion:
            TaxonomyBackendContractProof.supportedClientContractVersion,
        hasAuthoritativeCapabilityResponse: true,
        endpoints: endpoints,
      ),
    );

    expect(result.supportsCanonicalV1, isFalse);
    expect(result.blockers.join(' '), contains('argument signature'));
  });
}

TaxonomyBackendContractInventory _compatibleInventory() {
  return TaxonomyBackendContractInventory(
    taxonomyVersion: 'canonical-v1.0.0',
    declaredClientContractVersion:
        TaxonomyBackendContractProof.supportedClientContractVersion,
    hasAuthoritativeCapabilityResponse: true,
    endpoints: {
      for (final entry
          in TaxonomyBackendCapabilityVerifier
              .requiredEndpointArguments
              .entries)
        entry.key: _endpoint(
          entry.key,
          entry.value,
          TaxonomyBackendCapabilityVerifier.requiredResponseFields[entry.key]!,
        ),
    },
  );
}

TaxonomyRpcEndpointInventory _endpoint(
  String name,
  List<String> arguments,
  Set<String> returns,
) {
  return TaxonomyRpcEndpointInventory(
    functionName: name,
    argumentNames: arguments,
    returnFields: returns,
    securityMode: TaxonomyRpcSecurityMode.invoker,
    isStable: true,
    searchPathPinnedToPublic: true,
    anonExecute: true,
    authenticatedExecute: true,
  );
}
