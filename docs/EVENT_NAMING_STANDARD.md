# EsnaftaVar Event Naming Standard

**State:** `PROPOSED — OWNER/ENGINEERING REVIEW REQUIRED`

## Recommended form

Use a stable machine key in `lower_snake_case`, normally
`<subject>_<past_tense_action>`: `product_viewed`, `shop_opened`,
`directions_requested`, `verified_purchase_created`. These are illustrative
candidate names, not an approved registry.

Rules:

- Name a completed fact in past tense, not an instruction (`review_created`, not
  `create_review`).
- Lead with the durable business subject; avoid screen/widget names.
- Describe one semantic fact. Do not use generic `clicked`, `success`, `changed`
  or `event` without a domain subject.
- Use positive outcome names and a bounded reason/result field rather than
  inventing a new event for every error string.
- Never encode customer, shop, campaign, category, platform or environment IDs in
  the event name; those belong in the envelope.
- UI telemetry uses a distinct namespace/class and cannot impersonate a domain
  event.

## Namespaces and versions

The envelope carries `event_class` and `event_version`; the key remains readable.
If a transport requires namespacing, use a separate namespace field such as
`qr.verified_purchase_created`, not inconsistent casing. Compatible additive
changes retain the version. A semantic or required-field breaking change creates
a new integer version and documented coexistence window.

Renaming a display label, taxonomy node or screen does not rename historical
events. Deprecated event types retain registry entries and successor guidance.

## Review checklist

- Is this a business fact, measurement, audit/security signal or UI telemetry?
- Is the subject stable across UI redesign?
- Does the name imply more authority than the producer has?
- Can bounded fields express the reason/source without cardinality explosion?
- Are duplicate, failure and correction semantics documented?
- Is the producer, privacy class and version owner recorded?

Forbidden patterns include `button_clicked`, `page_1`, dynamic event names,
customer identifiers in names, `sale_completed` for a QR verification, and
`revenue_recorded` without settlement/accounting authority.

`EVENT_NAMING_FINALIZED: NO`

