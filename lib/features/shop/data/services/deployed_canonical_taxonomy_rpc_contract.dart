import 'package:t_store/features/shop/domain/taxonomy/taxonomy_backend_contract_inventory.dart';

/// Read-only V2 shape inventory captured from Development pg_catalog.
///
/// Activation never trusts this static inventory. The runtime requires a fresh
/// `taxonomy_capabilities_v2` proof from the configured Development backend.
final deployedCanonicalTaxonomyV2Inventory = TaxonomyBackendContractInventory(
  taxonomyVersion: 'canonical-v1.0.0',
  declaredClientContractVersion: 'taxonomy-client-v1',
  hasAuthoritativeCapabilityResponse: true,
  endpoints: {
    for (final entry
        in TaxonomyBackendCapabilityVerifier.requiredEndpointArguments.entries)
      entry.key: _endpoint(
        name: entry.key,
        arguments: entry.value,
        returns: TaxonomyBackendCapabilityVerifier
            .requiredResponseFields[entry.key]!,
      ),
  },
);

TaxonomyRpcEndpointInventory _endpoint({
  required String name,
  required List<String> arguments,
  required Set<String> returns,
}) {
  return TaxonomyRpcEndpointInventory(
    functionName: name,
    argumentNames: arguments,
    returnFields: returns,
    securityMode: TaxonomyRpcSecurityMode.definer,
    isStable: true,
    searchPathPinnedToPublic: true,
    anonExecute: true,
    authenticatedExecute: true,
  );
}
