# EsnaftaVar Event Envelope Model

**State:** `PROPOSED LOGICAL MODEL — NO SCHEMA`

## Core envelope

| Field | Requirement | Meaning |
|---|---|---|
| `event_id` | Required | Globally unique immutable occurrence identity |
| `event_type` | Required | Registry key following the naming standard |
| `event_version` | Required | Positive integer semantic contract version |
| `event_class` | Required | Domain, analytics, audit, security, ad, reward, reputation or UI telemetry |
| `occurred_at` | Required | Trusted occurrence time or explicitly client-reported time |
| `recorded_at` | Required | Platform receipt/persistence time |
| `authority_level` | Required | Authority classification, never inferred from type name |
| `producer` | Required | Stable service/app producer identity and version |
| `environment` | Required | Development/test/demo/Production boundary |
| `privacy_class` | Required | Collection/use/access/retention gate |
| `payload` | Required | Versioned, allowlisted event-specific fields |

Optional, purpose-limited references include `actor_type`, pseudonymous or
permitted `actor_id`, `merchant_id`, `shop_id`, `canonical_product_id`,
`variant_id`, `listing_id`, taxonomy/sector versioned identity and campaign/revision
identity. Unknown fields are not populated with empty identifiers.

## Correlation and delivery metadata

`correlation_id` links one bounded journey or business transaction.
`causation_event_id` points to the immediate preceding event where defensible.
`idempotency_key` is a command/outcome safety key and is not replaced by
correlation. Optional session identity follows the privacy-minimizing session
contract. Delivery attempt, partition and transport metadata stay outside the
business payload where possible.

## Safety rules

- Entity identifiers are opaque stable IDs, not display names, email, phone or
  mutable slugs.
- `occurred_at` from a client is labelled untrusted; server recording time remains
  available for ordering and windows.
- Do not place passwords, tokens, raw QR, signed URLs, private message/review text,
  exact address or precise coordinates in any general envelope.
- Free-form metadata bags are forbidden for authoritative and analytics events.
- Required fields and enums are bounded; high-cardinality debug detail belongs in
  privacy-safe logs, not metric dimensions.
- Producers cannot self-upgrade authority by setting a field; runtime trust comes
  from authenticated producer/control-path policy.

## Validation outcome

Consumers either accept the exact supported type/version, quarantine it with a
bounded reason, or ignore an optional class by policy. They never guess missing
identity, coerce malformed timestamps, or treat an unsupported version as the
latest.

`EVENT_ENVELOPE_SCHEMA_IMPLEMENTED: NO`

