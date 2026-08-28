# EsnaftaVar Merchant Sector Stable Identity and Alias Strategy

**State:** DESIGN ONLY — NO IDS GENERATED, NO SCHEMA OR RUNTIME CHANGE

## 1. Identity objective

A merchant-sector assignment, profile, review, analytics event and saved discovery
filter must survive Turkish display-name changes, slug changes and most hierarchy
moves. Therefore, immutable identity must not be derived from a mutable label or
path.

## 2. Recommended conceptual record

Every future sector node should have:

| Concept | Rule |
|---|---|
| Immutable opaque sector ID | Primary identity; generated only by approved future tooling. |
| Turkish display name | Mutable customer/merchant-facing label. |
| Slug | Mutable route/discovery locator with collision rules. |
| Parent sector ID | Mutable hierarchy relation; null at root families. |
| Level | Derived/validated, proposed maximum 3. |
| Assignability | Explicit; families/groupings normally false. |
| Lifecycle | Proposed minimum `active`, `inactive`, `retired`. |
| Owner state | Proposed vs owner-confirmed, separately versioned. |
| Default operating model | Suggested `RETAIL/SERVICE/MIXED`; merchant-specific value may differ. |
| Policy class | Separate from identity and operating model. |
| Typed aliases | Search/display/legacy forms, never alternate primary IDs. |
| Predecessor/successor edges | Explicit rename/move/merge/split/retire history. |
| Effective version/evidence | Decision provenance and activation interval. |

No UUID or production identifier is created in this wave.

## 3. Forbidden identity inputs

Do not derive immutable identity from:

- Turkish display name;
- slug;
- parent path or level;
- sort order;
- NACE/activity code;
- primary Product L1/L2 mapping;
- merchant operating model or policy class;
- translation or search synonym.

All can change without the merchant-sector concept disappearing.

## 4. Rename rule

Preserve the stable ID when inclusion/exclusion meaning remains the same. Change the
display name/slug and retain the old label as a typed alias or redirect.

Example: if owner chooses a clearer wording for `Ofis Malzemeleri Mağazası` without
changing its merchant population, identity remains. A broader/narrower redefinition
is not a simple rename.

## 5. Move rule

Preserve the stable ID when only parent placement changes. Historical assignment
continuity remains; the old path becomes a legacy redirect where applicable.

This is especially important for the confirmed `Berber, Kuaför & Güzellik Salonu`
subtree: its future parent placement may change, but the exact owner-confirmed child
identities must not be recreated merely because their path changes.

## 6. Merge rule

Represent multiple predecessors to one explicit successor.

- normally create/choose the successor only after owner approval;
- retain predecessor IDs for history;
- stop new assignments to predecessors;
- preserve old slugs as typed redirects when unambiguous;
- distinguish historical and harmonized analytics;
- do not merge merely because sectors commonly coexist.

`Kitapçı + Kırtasiye` as one merchant is not evidence that the two sector nodes
should merge.

## 7. Split rule

Represent one predecessor to multiple successors. Never silently redirect an old
sector assignment to an arbitrary child.

- successors receive independent IDs;
- predecessor becomes unassignable/retired;
- existing merchants require deterministic evidence or explicit re-selection;
- historical events keep predecessor identity unless a versioned, defensible
  reclassification is available;
- ambiguous merchants enter review, not guesswork.

If `Market, Bakkal & Süpermarket` is later split by owner decision, scale/name alone
must not arbitrarily rewrite every legacy merchant.

## 8. Retire rule

A retired sector:

- retains its ID and historical assignments;
- cannot receive new assignments;
- records reason, effective version and successor guidance;
- remains resolvable for analytics and support;
- never causes its merchants or events to disappear.

## 9. Alias taxonomy

| Alias type | Purpose | Identity behavior |
|---|---|---|
| `SEARCH_SYNONYM` | Query expansion such as `nalbur` → `Nalbur & Hırdavatçı`. | Does not prove identity equality outside search target. |
| `DISPLAY_ALIAS` | Prior/alternate official customer label. | Renders alternative wording; stable ID unchanged. |
| `LEGACY_REDIRECT` | Old slug/path after rename/move. | Resolves to exact ID or split-disambiguation state. |
| `COLLOQUIAL_TERM` | Merchant language such as `telefoncu`. | Controlled search aid. |
| `FORMAL_ACTIVITY_TERM` | NACE/chamber description linkage. | Verification/evidence lookup, not UI identity. |
| `TYPO_OR_ASCII_VARIANT` | Controlled spelling normalization. | Search only. |

Brand/company names must not be aliases. `Unisex Kuaför` must not be introduced as
a hidden canonical node or alternate assignable identity; the confirmed beauty
leaves remain exact.

## 10. Collision controls

Future tooling should fail closed when:

- an active slug resolves to multiple IDs;
- an alias collides with another canonical name without disambiguation;
- a grouping/family is assigned despite `assignable=false`;
- a split predecessor redirects to one arbitrary child;
- a retired node receives a new assignment;
- a proposed node is treated as owner-final;
- merchant sector ID is derived from Product Taxonomy path;
- a policy flag is interpreted as permission or a sector implies Auth role;
- parent links cycle or depth exceeds the approved maximum.

## 11. Branch/location assignments

Sector identity and merchant assignment identity are different:

- sector stable ID identifies the concept `Kitapçı`;
- assignment identifies that branch X was primary `Kitapçı` during an effective
  interval;
- the same sector ID is reused across merchants/branches;
- different chain formats may use different assignments;
- changes create new assignment history, not new sector IDs.

## 12. Recommended future sequence

1. Owner-finalize proposal structure and parent assignability.
2. Freeze sector stable-ID, lifecycle, alias and successor contracts.
3. Assign opaque IDs through reviewed migration input—not names/paths.
4. Validate alias collisions and primary/secondary relationships.
5. Design policy evidence links separately.
6. Dry-run against Development under a separately authorized runtime task.
7. Migrate Production only with explicit authorization and reconciliation.

None of these execution steps is performed here.

`MERCHANT_SECTOR_IDENTITY_STRATEGY: PASS`

`PRODUCTION_IDS_GENERATED: NO`
