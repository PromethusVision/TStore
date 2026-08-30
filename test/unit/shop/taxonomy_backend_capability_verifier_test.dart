import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/shop/data/services/deployed_canonical_taxonomy_rpc_contract.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_backend_contract_inventory.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';

void main() {
  const verifier = TaxonomyBackendCapabilityVerifier();

  test(
    'deployed Development inventory fails closed on response contract gaps',
    () {
      final result = verifier.assess(deployedCanonicalTaxonomyV1Inventory);

      expect(
        result.compatibility,
        TaxonomyContractCompatibility.blockingContractMismatch,
      );
      expect(result.supportsCanonicalV1, isFalse);
      expect(result.proof, isNull);
      expect(result.blockers, isNotEmpty);
      expect(
        result.blockers.join(' '),
        contains('authoritative taxonomy-client-v1 capability'),
      );
      expect(result.blockers.join(' '), contains('lifecycle_state'));
    },
  );

  test(
    'deployed inventory records exact seven endpoint signatures and grants',
    () {
      expect(deployedCanonicalTaxonomyV1Inventory.endpoints, hasLength(7));
      expect(
        deployedCanonicalTaxonomyV1Inventory
            .endpoints['taxonomy_children_v1']!
            .argumentNames,
        ['p_parent_id', 'p_taxonomy_version'],
      );
      expect(
        deployedCanonicalTaxonomyV1Inventory.endpoints.values.every(
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

  test('complete authoritative contract can produce canonical proof', () {
    final result = verifier.assess(_compatibleInventory());

    expect(result.supportsCanonicalV1, isTrue);
    expect(result.proof, isNotNull);
    expect(result.proof!.supportsCanonicalV1, isTrue);
    expect(
      result.proof!.verifiedEvidence,
      TaxonomyBackendContractProof.requiredCanonicalV1Evidence,
    );
  });

  test('one signature mismatch invalidates the whole proof', () {
    final compatible = _compatibleInventory();
    final endpoints = Map<String, TaxonomyRpcEndpointInventory>.of(
      compatible.endpoints,
    );
    endpoints['taxonomy_roots_v1'] = _endpoint(
      'taxonomy_roots_v1',
      const ['wrong_argument'],
      TaxonomyBackendCapabilityVerifier
          .requiredResponseFields['taxonomy_roots_v1']!,
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
