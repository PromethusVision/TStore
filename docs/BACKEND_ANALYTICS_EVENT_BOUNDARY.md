# Backend Analytics Event Boundary

**State:** PROPOSED — DESIGN ONLY, NO EVENT RUNTIME

## Backend responsibility

The backend emits or derives analytics facts only after the owning domain contract
has classified the occurrence and its authority. A server relaying a client claim
does not upgrade it to authoritative.

| Event class | Producer posture | Permitted use |
|---|---|---|
| Authoritative domain outcome | Emitted after guarded database commit | Governed metric and separately authorized consumer input |
| Server-derived projection | Rebuildable from authoritative rows/events | Aggregate analytics with source/rule version |
| Client-reported intent | Validated, bounded, explicitly non-authoritative | Product usage analytics only |
| Client-observed telemetry | Render/latency/failure observation | UX/health analysis under consent/purpose |
| Soft signal | View, search, wishlist, cart, directions | Directional analytics; never a sale |

## Hard boundaries

- Only the replay-safe QR confirmation transaction creates verified purchase.
- Generic analytics cannot create review eligibility, reward ledger entries,
  reputation evidence, ad billing or domain mutations.
- An analytics consumer cannot write back an authoritative domain state.
- Event ID, idempotency key and correlation ID remain distinct.
- Producer/environment/authority/privacy/event version are explicit.
- Delivery may be at least once; consumers deduplicate and quarantine unsupported
  versions.
- Raw QR, credentials, private content and unnecessary precise location are
  excluded before serialization.

Use a selective transactional outbox only where losing a committed domain fact
would break a required downstream contract. Best-effort telemetry must never be
placed inside a critical purchase transaction. Exact pilot registry and retention
remain `OWNER_DECISION_REQUIRED`.

