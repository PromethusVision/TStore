# Catalog Field Conflict Resolution

Status: **OWNER REVIEW DRAFT**
Wave: 16, Work Package 16

Conflicting values create parallel assertions until an authority rule resolves the
displayed projection. “Last write wins” and “merchant A wins” are forbidden for
canonical identity.

## Resolution order

1. Validate format and source authenticity; invalid evidence cannot win.
2. Apply field ownership: listing facts remain with the shop; policy facts require
   policy authority; manufacturer facts prefer responsible-party evidence.
3. Prefer exact, current manufacturer/trusted-source evidence within its scope.
4. Use compatible global-identifier assignment and package evidence as strong
   corroboration, never as an override of a hard identity conflict.
5. Consider multiple independent merchant observations as supporting evidence.
6. Resolve deterministic spelling/unit normalization automatically only when
   semantic value is unchanged.
7. Quarantine material unresolved conflicts for manual review.

## Field examples

| Conflict | Resolution |
| --- | --- |
| `500 g` vs `1 kg` | Treat as potential variant/different product; package/GTIN evidence required, no majority vote. |
| Model spelling | Normalize punctuation/case; preserve significant suffixes/zeros and raw values. |
| Compatibility claim | Require structured target/model evidence; merchant consensus alone cannot assert safety-critical fit. |
| Different image | Classify canonical, variant or shop media; packaging mismatch can reveal wrong product. |
| Brand/manufacturer | Prefer responsible-party evidence; handle private label/licensing explicitly. |
| Taxonomy leaf | Apply owner-approved placement rules; merchant selection is a proposal. |
| Price/stock | No conflict across shops: each listing owns its current fact. |

## Outcomes

`ACCEPT_ASSERTION`, `NORMALIZE_EQUIVALENT`, `KEEP_EXISTING`, `CREATE_VARIANT`,
`SPLIT_PRODUCT`, `IDENTIFIER_QUARANTINE`, `POLICY_REVIEW`, or `MANUAL_REVIEW`.
Every outcome records evidence, actor, ruleset and reversibility. A high-authority
source can still be wrong; correction creates a new assertion and audit event rather
than erasing the former value.
