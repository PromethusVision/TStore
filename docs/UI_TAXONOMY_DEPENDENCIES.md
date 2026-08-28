# UI Taxonomy Dependencies

## Boundary

Taxonomy runtime is separate from UI rollout. Proposed category nodes are neither
hardcoded nor treated as production data by this plan.

## UI requirements independent of final taxonomy content

- Category cards/rows accept ID, display name, optional image and availability.
- Listing accepts zero-to-many children and variable hierarchy depth.
- Breadcrumb renders dynamic ancestry and handles narrow screens.
- Search/category resolution can show the matched category path.
- Unknown/deferred image uses a safe fallback without changing identity.
- Renamed/moved categories update display data without requiring a new widget.
- Analytics/test keys use stable IDs rather than display names when available.

## Dependent surfaces

| Surface | Dependency | Rollout treatment |
|---|---|---|
| Home category rail | L1 display order/name/image | Use current runtime feed; visual component stays data-driven |
| Category listing | child nodes and ancestry | Stress zero/many/long/deep data |
| Product listing/search | selected category/filter context | Keep current query and routing behavior |
| Product details | category context/breadcrumb | Treat as optional dynamic metadata |
| Empty/no-result | category display name | Copy must tolerate renamed/unknown category |
| Accessibility | spoken category label/path | Use display text, stable semantic order |

## Forbidden coupling

- enum/switch per proposed category;
- per-L1 color/component/screen without a separate owner-approved need;
- layout based on exactly 24 L1 or a fixed L2 count;
- asset paths derived directly from Turkish display names;
- analytics identity derived from mutable slugs/display labels;
- copying pilot Figma labels into runtime constants.

## Test fixtures

Use synthetic nodes with empty, one, many and four-level ancestry; 40+ character
Turkish labels; missing image; renamed display label with stable identity; retired
or unavailable state; and unknown future child depth. These fixtures validate the
UI contract without implementing taxonomy.

## Gate

Taxonomy-dependent data hookup may follow the separate canonical taxonomy runtime
task. Component, spacing, overflow and accessibility work can proceed earlier as
long as current repository contracts are preserved.
