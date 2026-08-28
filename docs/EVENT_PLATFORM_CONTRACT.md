# EsnaftaVar Event Platform Contract

**State:** `PROPOSED — DESIGN ONLY`  
**Scope:** Customer, merchant, catalog, QR, review, search, ads, reward,
reputation, operations and platform health. No runtime, schema or SDK is selected.

## Contract

An event is an immutable statement that something was observed or decided at a
specific time. It is not automatically a database row, analytics fact, audit
proof or billing input. The producer owns factual correctness; consumers own
their projections without changing the source meaning.

| Class | Purpose | Typical authority | May drive authoritative state? |
|---|---|---|---|
| Domain event | Records a business state transition | Server authoritative/derived | Yes, only under the domain contract |
| Analytics event | Measures product use or outcomes | Mixed, explicitly labelled | No by itself |
| Audit event | Append-only evidence of privileged action | Trusted server/control plane | Evidence only |
| Security event | Detects abuse, denial or anomaly | Trusted server/derived | May trigger a separately governed control |
| Ad measurement event | Measures exposure/interaction | Client observed or server derived | No billing/causal claim by default |
| Reward ledger event | Records awarded/reversed value | Server authoritative | Yes, only in a future ledger contract |
| Reputation signal | Input to a governed reputation projection | Mixed with evidence grade | Never a direct score edit |
| UI telemetry | Diagnoses UI performance/failure | Client observed | No business state |

One occurrence may produce several class-specific records linked by correlation,
but those records retain different IDs, schemas, retention and access controls.
For example, a verified purchase can emit a domain fact, an aggregate analytics
fact and a privacy-minimized audit record; an ad click cannot become a purchase.

## Non-negotiable boundaries

- QR verified purchase is created only by the server-authoritative, replay-safe
  confirmation path. QR display, scan or client success UI is not proof.
- Analytics is append/derive, not a command bus. Replaying analytics cannot award
  rewards, create reviews, bill ads or alter reputation.
- Soft engagement signals such as views, wishlist, cart and directions are not
  sales, revenue, payment settlement or customer identity disclosure.
- Ads and spend never create trust, review eligibility, reward eligibility or
  organic relevance.
- Audit/security payloads never contain secrets, raw QR tokens, auth tokens,
  private chat content or unnecessary precise location.
- Development, demo, test and Production data remain separate dimensions and
  must not share business dashboards by default.

## Lifecycle

1. Producer validates permissions, business invariants and idempotency.
2. Producer records the authoritative state and an event/outbox-equivalent fact
   atomically where correctness requires both. The runtime mechanism is open.
3. Delivery may be at least once; consumers deduplicate by source event identity.
4. Consumers validate event type/version, privacy class and authority before use.
5. Invalid or unsupported events are quarantined, not silently coerced.
6. Corrections use explicit superseding/reversal facts; history is not rewritten.

## Governance gates

Before implementation, owners must approve the minimum registry, privacy/consent
classes, retention, access roles, metric definitions and pilot observability
scope. Legal/policy review is required where consent, advertising measurement,
precise location or personal data retention is involved. No decision is finalized
by this document.

`EVENT_PLATFORM_RUNTIME: NOT_IMPLEMENTED`
