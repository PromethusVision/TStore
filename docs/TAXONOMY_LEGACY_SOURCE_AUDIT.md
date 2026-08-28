# Legacy Taxonomy Source Audit

**Wave:** 15 — Legacy Taxonomy Reconciliation Audit

**Audit base:** `origin/main@f092cf8fe7431f812a017d4cbc9b538775bb41e6`

**Audit state:** ANALYSIS ONLY — NO RUNTIME MUTATION

## 1. Conclusion

The authoritative legacy machine-source candidate is:

`docs/data/esnaftavar_category_taxonomy_v1_final.json`

Independent parsing confirms the historical figures exactly:

| Depth | Actual nodes |
|---|---:|
| L1 | 23 |
| L2 | 91 |
| L3 | 505 |
| L4 | 32 |
| **Total** | **651** |
| Leaf nodes | 525 |
| Active assignable leaf nodes | 524 |
| Inactive/non-assignable review nodes | 1 |

The tracked final JSON has SHA-256
`182B8719E74EA889F5FC3B257D119C258C8750F8D24883D08AA6AFB88CCD2B08`,
matching the value recorded by the final legacy documentation and current canonical
architecture document. The known `23/91/505/32` baseline therefore does not differ
from repository reality.

The JSON is a documentation/data artefact, not the current Flutter runtime source.
The current client reads the Supabase `categories` table. No tracked code, migration,
seed, test, or build configuration imports the 651-node JSON into that table.

## 2. Discovery method

The audit used only repository-static, read-only evidence:

- `git ls-files` to inventory tracked JSON, Markdown, SQL, seed, fixture, and code
  candidates;
- `rg` to find direct file references, `categories` reads, `category_id` references,
  inserts, seed fixtures, and runtime model fields;
- JSON parsing to recompute depth, total, status, leaf, parent, and field counts;
- Git history and object/hash inspection to distinguish draft, final, and generated
  views;
- `git show <remote-ref>:<path>` to read proposal documents without checking out or
  merging their branches.

No Production or Development query was made.

## 3. Source-of-truth candidates

| Path | Format | Role | Authority assessment | Runtime use evidence |
|---|---|---|---|---|
| `docs/data/esnaftavar_category_taxonomy_v1_final.json` | JSON | Complete legacy V1.0.0 machine artefact | **AUTHORITATIVE LEGACY MACHINE CANDIDATE**. Declares `status=final`, exact node contract, counts, governance, policies, moves, deprecations, filters, risks, and all 651 nodes. | No direct import/reference outside documentation was found. Not a runtime seed. |
| `docs/ESNAFTAVAR_CATEGORY_TAXONOMY_V1_FINAL.md` | Markdown | Complete human-readable rendering and decision record | **AUTHORITATIVE HUMAN COMPANION**, but explicitly names the final JSON as machine source. Its tree mirrors the JSON and should not be parsed as a second source. | Documentation only. |
| `docs/data/esnaftavar_category_taxonomy_v1_draft.json` | JSON | Pre-final review draft | Historical predecessor, not current authority. `20/91/505/32 = 648`; 642 slugs overlap final, six are draft-only, nine are final-only. | No runtime import found. |
| `docs/ESNAFTAVAR_CATEGORY_TAXONOMY_V1_DRAFT.md` | Markdown | Human rendering of draft JSON | Generated/human duplicate of the draft state; superseded by final. | Documentation only. |
| `docs/ESNAFTAVAR_CANONICAL_CATEGORY_TAXONOMY_RESEARCH.md` | Markdown | Research/architecture evidence for draft | Historical design evidence, not a node source. | Documentation only. |
| `docs/ESNAFTAVAR_CATEGORY_TAXONOMY_OWNER_REVIEW.md` | Markdown | Product-owner review pack for draft | Historical decision input; changes were applied to the final JSON. | Documentation only. |
| `docs/ESNAFTAVAR_CANONICAL_CATEGORY_TAXONOMY.md` | Markdown | New 24-L1 architecture and owner-final pilots | **CURRENT ARCHITECTURE AUTHORITY**, but intentionally does not replace or mutate the 651-node artefact. | Documentation/decision source; runtime reconciliation not started. |
| `supabase/migrations/20260812000100_0001_core_auth_catalog.sql` | SQL | Runtime table contract | Authoritative schema for current `public.categories`: UUID `id`, nullable UUID `parent_id`, name, image, sort, active state. It does not seed the legacy tree. | Runtime schema. |
| `lib/features/shop/data/repositories/category_repository_impl.dart` | Dart | Runtime category read path | Reads active rows from Supabase `categories`, ordered by `sort_order`, including parent/subcategory reads. | Active runtime code. |
| `lib/features/shop/data/models/category_model.dart` | Dart | Runtime category model adapter | Maps UUID `id`, `name`, `parent_id`, `sort_order`, `is_active`, timestamps, and media URL. It has no legacy slug/alias/version fields. | Active runtime code. |
| `supabase/seeds/esenler_demo_v1.sql` and `tool/demo_seed/esenler_demo_v1.json` | SQL/JSON | Four-category Esenler demo fixture | Deterministic demo dataset with independent UUID category IDs and demo slugs. It is not generated from the 651-node JSON. | Static seed artefact; Production application is historical and outside this audit. |
| `supabase_sample_data.sql` and `supabase_schema.sql` | SQL | Older sample/schema material | Historical sample/reference; not the canonical migration chain. | Not evidence of legacy tree deployment. |

## 4. Duplicate and generated copies

- The final Markdown document is a human presentation of the final JSON, not an
  independent taxonomy.
- The draft Markdown document is a human presentation of the draft JSON.
- The draft and final JSON files are not byte-identical duplicates and represent
  distinct historical states.
- No second tracked byte-identical copy of the final 651-node JSON was found.
- Category icon assets and legacy static UI text are presentation material, not node
  registries.
- Proposal documents on the three overnight branches are future target evidence,
  not copies of the legacy tree.

## 5. Legacy node contract

Every one of the 651 JSON nodes contains:

- `slug`
- `display_name_tr`
- `merchant_label_tr`
- `parent_slug`
- `level`
- `level_label_tr`
- `path_slugs`
- `path_display_tr`
- `sort_order`
- `status`
- `is_leaf`
- `assignable`
- `search_aliases`
- `optional_keywords`
- `applicable_filter_family_ids`
- `risk_flags`

### IDs

No opaque UUID or numeric node ID exists in the legacy JSON. The only exact node
locator is `slug`; `parent_slug` and `path_slugs` also depend on it. The legacy
governance text calls slug an immutable semantic identity. For reconciliation CSV,
`LEGACY_NODE_ID` therefore records `slug` as the exact available locator and does
not invent a production ID.

### Slugs and parents

- Slugs are present on all 651 nodes.
- Every non-L1 node has a `parent_slug`; L1 nodes have `null` parent.
- Full slug and display paths are materialized on every node.
- Parent/level/path consistency, duplicate slug, sibling duplicate, cycle, and
  orphan checks are recorded as passing in the source and were independently
  rechecked during inventory generation.

### Aliases

`search_aliases` and `optional_keywords` exist, but they are search vocabulary.
They are not a versioned legacy redirect registry and do not model predecessor or
successor IDs. The root metadata separately carries `deprecated_nodes` and
`moved_nodes`, but not a general many-to-many successor graph.

### Active/inactive state

- 650 nodes are `active`.
- `hediyelik-obje` is the single `inactive_review`, non-assignable leaf.
- Leaf and assignability are explicit and separate fields.
- The source has no general lifecycle timestamps or immutable opaque lifecycle ID.

### Display names and Turkish normalization

- All nodes have Turkish `display_name_tr` and `merchant_label_tr`.
- Root locale is `tr-TR`.
- Slugs are ASCII-style kebab-case locators.
- The legacy validation records normalized sibling-name uniqueness and Turkish
  display naming as passing.
- Search aliases include Turkish and ASCII/market variants, but the file does not
  define a complete locale-normalization algorithm or distinguish redirects from
  synonyms.

## 6. Root-level metadata

The final JSON also contains:

- schema/taxonomy version and release status;
- source-draft hash/commit evidence;
- deterministic ordering and assignment policies;
- Product Owner decisions and approved split/move records;
- Home/sponsored/publishing/second-hand/shop-type policy records;
- governance, deprecated nodes, moved nodes, and inactive-review records;
- filter-family and risk-flag registries;
- explicitly excluded domains;
- validation summary and aggregate counts.

These records make the final JSON the strongest legacy audit input, but they do not
turn its slug into the future immutable opaque ID required by the new architecture.

## 7. Runtime-use evidence

The active Flutter path is database-driven:

1. `CategoryRepositoryImpl` queries `SupabaseTables.categories`.
2. `CategoryModel` expects a UUID-like string `id`, `name`, `parent_id`, ordering,
   active state, timestamps, and image URL.
3. Products reference `public.categories(id)` through nullable UUID `category_id`.
4. Browse, search, product, shop, and wishlist repositories join runtime category
   rows by database relationship.

The 651-node JSON is not referenced by those paths. The runtime schema also lacks
the JSON's slug, level, aliases, taxonomy version, assignability, filter profile,
and risk metadata. Consequently:

- the legacy JSON is **not proven deployed**;
- database UUIDs cannot be inferred from legacy slugs;
- repository-static demo UUIDs cannot be treated as legacy node IDs;
- runtime migration requires a separately approved stable-ID bridge and source-to-
  runtime registry.

## 8. Proposal target inputs

Read-only proposal sources were verified without merge:

| Batch | Remote ref | HEAD | Proposed non-final L1 |
|---|---|---|---:|
| 01 | `origin/agent3/w15-overnight-taxonomy-batch-01` | `4b500a629e3ca6f388617c49aae16fe32538a378` | 6 |
| 02 | `origin/agent1/w15-overnight-taxonomy-batch-02` | `bca5d57c359dc4f767972597551aa6616031b667` | 8 |
| 03 | `origin/agent2/w15-overnight-taxonomy-batch-03` | `f1e766eeacbcbc1f1ed69ee18d040321645a6796` | 8 |

The 22 proposal documents contain 224 proposed L2 nodes in total. They remain
`PROPOSED FOR OWNER REVIEW`; any row that depends on them must be labeled
`PROVISIONAL_PROPOSAL`.

Elektronik and Bilgisayar & Tablet L2 documents, plus the Telefon & Aksesuarları
and Bilgisayar Bileşenleri L3/L4 pilots on `origin/main`, are owner-final target
evidence.

## 9. Source audit decision

- **Authoritative legacy candidate:** final JSON.
- **Human companion:** final Markdown.
- **Historical predecessor:** draft JSON/Markdown and research/review pack.
- **Runtime source:** Supabase categories table, independently modeled and not
  populated from the legacy JSON by any tracked pipeline.
- **Stable immutable opaque IDs:** absent in legacy JSON.
- **Actual legacy node count:** 651, exactly matching the known baseline.
- **Source mutation performed:** none.

`LEGACY_TAXONOMY_SOURCE_AUDIT: PASS`

`LEGACY_SOURCE_RUNTIME_DEPLOYMENT: NOT_PROVEN`

`LEGACY_OPAQUE_STABLE_IDS: ABSENT`
