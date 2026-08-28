# EsnaftaVar Analytics Entity Identity Model

**State:** `PROPOSED — NO ID FORMAT/SCHEMA SELECTED`

| Entity | Analytics identity rule |
|---|---|
| Customer | Use only where justified; opaque subject ID with deletion/privacy controls |
| Merchant | Stable merchant organization ID, separate from people/staff |
| Shop | Stable physical/business location identity; branch is explicit |
| Canonical product | Immutable opaque product ID surviving rename/move |
| Variant | Stable identity for an identity-defining sellable variation |
| Listing | Shop-specific offer identity, separate from product/variant |
| Taxonomy node | Stable opaque node ID plus taxonomy version and lineage |
| Merchant sector | Stable opaque sector ID plus sector version/history |
| Campaign | Stable campaign ID plus immutable revision/creative/target references |

Display name, slug, hierarchy path, title, merchant email, external campaign label
and sort order never define identity. Events retain event-time entity references
and relevant revisions; current-state reports use explicit lineage projections.

Aliases and redirects resolve discovery/routing but do not replace IDs. Merge,
split, retirement and branch transfer are effective-dated edges. No guest/client
fingerprint is created to fill a missing customer ID.

`ANALYTICS_ID_FORMAT_FINALIZED: NO`

