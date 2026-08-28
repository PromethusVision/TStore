# Merchant App Hypothetical Recommended State

Status: **HYPOTHETICAL — NOT OWNER APPROVED**
Wave: 17 / WP104

This simulation assumes all 18 root recommendations are selected. It does not finalize them.

## Expected architecture effect

- Organization-backed identity with simple single-shop pilot UX and narrow optional staff presets.
- Allowlisted ordinary merchant activation; regulated/unknown remains pending.
- Governed canonical product/variant/listing model and private candidate drafts.
- Current short-lived, online-only QR with confirm-time atomic consume.
- Requested + actual governed variable-measure snapshot.
- Service/mixed shop presence but no booking/service catalog engine.
- Aggregate shop/product analytics under cohort/retention controls.
- Read/report reviews, availability-only bulk, moderated listing media, critical push+inbox.
- Separate Flutter app with narrow shared packages; no visible future-engine placeholders.

## Stress impact

All 3,500 designed stress rows have a deterministic expected safe outcome. This means the recommendation set is internally modelled, not that runtime has passed. Remaining high-risk work is backend schema/RLS/RPC, moderation operations, environment/release implementation and physical two-device acceptance.

## Residual trade-offs

More QR regeneration, candidate moderation workload, incomplete service merchant capability, support for invitations/revocation and privacy aggregation cost. These are explicit rather than hidden failure modes.
