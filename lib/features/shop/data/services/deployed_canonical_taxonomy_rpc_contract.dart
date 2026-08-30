import 'package:t_store/features/shop/domain/taxonomy/taxonomy_backend_contract_inventory.dart';

/// Read-only inventory captured from the deployed Development pg_catalog.
///
/// This is evidence for compatibility assessment, not a runtime capability
/// response. It deliberately cannot enable canonical mode by itself.
final deployedCanonicalTaxonomyV1Inventory = TaxonomyBackendContractInventory(
  taxonomyVersion: 'canonical-v1.0.0',
  declaredClientContractVersion: null,
  hasAuthoritativeCapabilityResponse: false,
  endpoints: {
    'taxonomy_roots_v1': _endpoint(
      name: 'taxonomy_roots_v1',
      arguments: const ['p_taxonomy_version'],
      returns: const {
        'id',
        'parent_id',
        'name',
        'slug',
        'level',
        'is_assignable',
        'sort_order',
        'taxonomy_version',
      },
    ),
    'taxonomy_children_v1': _endpoint(
      name: 'taxonomy_children_v1',
      arguments: const ['p_parent_id', 'p_taxonomy_version'],
      returns: const {
        'id',
        'parent_id',
        'name',
        'slug',
        'level',
        'is_assignable',
        'sort_order',
        'taxonomy_version',
      },
    ),
    'taxonomy_descendants_v1': _endpoint(
      name: 'taxonomy_descendants_v1',
      arguments: const ['p_category_id', 'p_taxonomy_version'],
      returns: const {'id', 'level', 'is_assignable'},
    ),
    'taxonomy_exact_leaf_v1': _endpoint(
      name: 'taxonomy_exact_leaf_v1',
      arguments: const ['p_category_id', 'p_taxonomy_version'],
      returns: const {'id', 'name', 'slug', 'taxonomy_version'},
    ),
    'taxonomy_breadcrumb_v1': _endpoint(
      name: 'taxonomy_breadcrumb_v1',
      arguments: const ['p_category_id', 'p_taxonomy_version'],
      returns: const {'id', 'parent_id', 'name', 'slug', 'level'},
    ),
    'taxonomy_resolve_alias_v1': _endpoint(
      name: 'taxonomy_resolve_alias_v1',
      arguments: const ['p_alias_slug', 'p_taxonomy_version'],
      returns: const {'category_id', 'canonical_slug', 'resolution_state'},
      securityMode: TaxonomyRpcSecurityMode.definer,
    ),
    'taxonomy_search_context_v1': _endpoint(
      name: 'taxonomy_search_context_v1',
      arguments: const ['p_term', 'p_taxonomy_version'],
      returns: const {'category_id', 'name', 'slug', 'match_kind'},
      securityMode: TaxonomyRpcSecurityMode.definer,
    ),
  },
);

TaxonomyRpcEndpointInventory _endpoint({
  required String name,
  required List<String> arguments,
  required Set<String> returns,
  TaxonomyRpcSecurityMode securityMode = TaxonomyRpcSecurityMode.invoker,
}) {
  return TaxonomyRpcEndpointInventory(
    functionName: name,
    argumentNames: arguments,
    returnFields: returns,
    securityMode: securityMode,
    isStable: true,
    searchPathPinnedToPublic: true,
    anonExecute: true,
    authenticatedExecute: true,
  );
}
