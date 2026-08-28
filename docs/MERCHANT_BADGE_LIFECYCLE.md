# Merchant Badge Lifecycle

**State:** PROPOSED STATE MACHINE

```text
INELIGIBLE -> EARNED -> ACTIVE -> AT_RISK -> ACTIVE
                           |         |
                           v         v
                       SUSPENDED -> REVOKED -> RE_EARNED/ACTIVE
                           |
                           v
                        RETIRED
```

## States

| State | Meaning | Public behavior |
|---|---|---|
| EARNED | requirements first met; evaluation recorded | optionally pending publication/cooling period |
| ACTIVE | current rule and evidence satisfied | display with meaning/window |
| AT_RISK | freshness/confidence near loss or review pending without strong integrity finding | optionally show until grace rule ends |
| SUSPENDED | integrity/policy hold or shop temporarily ineligible | hidden or clearly unavailable; no guilt claim |
| REVOKED | requirements no longer met or substantiated invalidity | not displayed; reason/appeal path |
| RETIRED | badge definition/shop lifecycle ended | historical audit only |

## Transitions

- Recalculation is idempotent and versioned; no manual score editing.
- Re-earning uses current rules and fresh eligible evidence; it is not an operator gift.
- A definition retirement cannot be presented as merchant misconduct.
- Permanent shop closure retires public badges; temporary closure does not degrade scores.
- Ownership transfer triggers an owner-selected continuity policy and at minimum a visible effective-date
  boundary; personal reputation claims do not automatically transfer.

`BADGE_LIFECYCLE_AUDITABLE: REQUIRED`
`MANUAL_BADGE_GRANT: NO`
