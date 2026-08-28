# Future Merchant App Coverage Model

**State:** PROPOSED — MERCHANT APP RUNTIME NOT PRESENT

| Domain | Lowest authoritative tests | Client tests | Required acceptance |
|---|---|---|---|
| Merchant identity | membership, role, lifecycle and tenant RLS | login, organization/shop switch, stale session | revoked membership fails immediately |
| Shop | scoped create/update/location/lifecycle | forms, conflicts, revision refresh | multi-shop and inactive shop |
| Catalog | candidate/listing authorization and provenance | search-existing-first, exception states | canonical identity remains server-owned |
| Listing | ownership, price/availability/SKU invariants | edit, retry, conflict, offline boundary | Customer projection freshness |
| Price | numeric/unit/variable-measure rules, revision conflict | locale input and confirmation | concurrent edit and stale display |
| Availability | idempotent scoped transition | fast toggle, failure restore | customer visibility convergence |
| QR | atomic confirm, wrong shop, expiry, replay, concurrency | scanner permission, context and reconcile | two physical apps/devices |
| Reviews | read/report authorization; response only if approved | filters, report, safe explanation | no rating manipulation |
| Analytics | privacy-safe shop scope and freshness | empty/unknown/stale states | test traffic exclusion |
| Staff | invite/grant/revoke and capability scope | role presentation and shop selection | immediate revocation/user switch |
| Permissions | server capability matrix and denial audit | hidden/disabled UX only as convenience | client cannot grant authority |

## Sequence

Backend contracts and synthetic merchant identities precede Flutter screens. Customer–Merchant consistency tests bind price, availability, shop, QR and review projections across versions. Regulated merchant flows remain fail-closed until owner/policy rules exist.

## Non-claims

The Wave 17 source is design-only. This model does not assert that Merchant App, organization schema, staff roles or release pipeline exists.

`MERCHANT_APP_QA_READY_FOR_IMPLEMENTATION: NO`

`OWNER_DECISION_REQUIRED: MERCHANT_V1_SCOPE_AND_ROLE_MODEL`
