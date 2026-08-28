# EsnaftaVar Taxonomy Runtime Reconciliation Risk Model

**State:** ANALYSIS ONLY — NO MIGRATION EXECUTED

## 1. Risk scale

| Level | Taxonomy operation | Default interpretation |
|---|---|---|
| LOW | Stable-ID-preserving rename | Presentation/slug change with unchanged product population and policy meaning. |
| MEDIUM | Semantic-identity-preserving move | Parent/path changes; products remain the same concept. |
| HIGH | Merge, split, cross-domain reclassification, or policy exclusion | Identity graph, product assignment, search, and analytics may change. |
| VERY HIGH | Ambiguous split affecting active products, reviews, analytics, or URLs | No deterministic successor; manual evidence and rollback are required. |

Risk is raised when the target is provisional, data is live, policy eligibility is
unclear, aliases collide, or product attributes are insufficient. A category
placement does not imply regulatory/listing approval.

## 2. Operation-specific controls

### LOW — rename

Keep the stable ID, update mutable name/slug, preserve the old slug as a typed
redirect, and verify search/display/deep links. Escalate if inclusion/exclusion or
policy meaning changed.

### MEDIUM — move

Keep the stable ID only when the product set is semantically unchanged. Update the
parent relation, recompute paths, preserve the old path, and test parent/descendant
navigation. Escalate cross-domain moves or any move that changes eligibility.

### HIGH — merge

Create an explicit many-to-one predecessor graph. Validate duplicate product
assignments, analytics rollups, saved filters, alias collisions, and policy/facet
compatibility. The current audit identifies zero exact merges; future L3/L4
finalization may change that result.

### HIGH/VERY HIGH — split

Create one-to-many successor edges. Apply a deterministic classification rule only
when reliable attributes exist; otherwise use manual review. Never redirect the
predecessor to one arbitrary child or duplicate a product into several primary
leaves. Assignable split leaves with active products are VERY HIGH until data
profiling proves deterministic reassignment.

### HIGH — retire/policy exclusion

Keep historical identity addressable, disable new assignment, preserve audit
history, and separate search visibility from listing eligibility. Policy review is
not legal advice and must be completed by the responsible owner/process.

## 3. Repository-specific runtime risks

The current schema/client contract creates several future migration concerns:

- `public.categories` already has UUID identity, but there is no proven mapping
  from those UUIDs to the 651 legacy slugs;
- the schema has no visible slug, alias, taxonomy-version, lifecycle history, or
  predecessor/successor model;
- `products.category_id` is nullable in SQL, while the Flutter product model reads
  it as a required string;
- category product queries filter by one exact category UUID and do not visibly
  include descendants;
- category deletion uses `ON DELETE SET NULL`, so destructive replacement could
  create products the client cannot decode;
- current static seeds use independent broad category UUIDs and labels.

These are design observations only. This audit does not change schema or client
code.

## 4. Consumer impact matrix

| Consumer | Rename | Move | Merge | Split / policy exclusion |
|---|---|---|---|---|
| `products` | Low if ID preserved | Medium | High reassignment/deduplication | Very high if successor ambiguous |
| `shop_products` | Indirect display impact | Indirect discovery impact | Inherits product change | Inherits reassignment; listing must not duplicate |
| Search | Alias/index refresh | Path/facet refresh | Synonym collision/recall risk | Multi-target query and policy suppression |
| Analytics | Label dimension update | Hierarchy rollup change | Many-to-one historical rollup | Versioned one-to-many attribution required |
| Saved filters | Redirect old slug/ID | Re-resolve path | Scope may broaden | Must expose changed meaning/disambiguation |
| Deep links | Old slug redirect | Old path redirect | Redirect to successor | Split landing; never arbitrary child |
| URLs/slugs | Preserve old locator | Preserve old path | Collision review | One-to-many redirect contract |
| Demo seed | Rename mapping | Category UUID/path mapping | Regenerate carefully | Reclassify product fixtures |
| Merchant assignment | Display-only when safe | New navigation context | Selection may collapse | Manual/product-attribute classification |
| Future ads | Label/link refresh | Audience hierarchy change | Campaign rollup change | Target scope/policy revalidation |
| Reviews | Product ID should remain | Usually unaffected | Analytics grouping changes | Never clone review/product identity |
| Recommendations | Feature label refresh | Hierarchy feature drift | Training distribution combines | Training labels split; historical version needed |
| Future imports/exports | Alias support | Parent/path version | Many old IDs to one | One old ID requires disambiguation |

## 5. Highest-risk known cases

1. `telefon-tutucu` mixes vehicle- and phone/desk-primary products across two L1
   domains; intended installation may be absent from product data.
2. `bilgisayar-sogutma` is one assignable leaf but has four final successors;
   subtype evidence is mandatory.
3. `Oyuncak, Hobi & Müzik` becomes two owner-final L1s; old links/analytics need a
   split-aware bridge.
4. Coarse Electronics and Computer L2 umbrellas split across several final L2s,
   changing parent filters and URLs.
5. 67 proposal-dependent splits can change again after owner review.
6. 461 rows lack an exact owner-final successor.
7. 130 legacy nodes carry risk flags whose listing policy must remain independent
   of taxonomy placement.
8. `hediyelik-obje` is inactive and must not be accidentally reactivated.
9. The current client expects non-null product category IDs even though the
   database foreign key permits null after category deletion.
10. Static demo UUIDs are not proven canonical stable IDs.

## 6. Required future dry-run evidence

Before any authorized runtime change, a Development dry-run should produce:

- pre/post counts for categories, products, listings, reviews, and related data;
- a stable-ID mapping for every deployed category, not merely every documentation
  slug;
- zero orphaned product category references;
- zero products assigned to non-leaf, retired, or policy-blocked nodes;
- a queue and reason for every unresolved/split product;
- alias/redirect collision results;
- search, parent/descendant filter, deep-link, and saved-filter comparisons;
- analytics reconciliation by old and new taxonomy version;
- idempotency and rollback evidence;
- explicit confirmation that Production was not affected by the dry-run.

## 7. Runtime decision

The static audit is sufficient to design future controls but not to authorize a
runtime migration. Owner-final L2/L3/L4 architecture, canonical stable IDs, a live
read-only data profile, split rules, and Development dry-run evidence are required
first.

`RUNTIME_RECONCILIATION_RISK_MODEL: PASS`

`PRODUCTION_MIGRATION_AUTHORIZED: NO`
