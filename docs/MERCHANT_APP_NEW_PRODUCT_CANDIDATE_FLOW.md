# Merchant App New Product Candidate Flow

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP16

## Entry criteria

Candidate flow is offered only after canonical search, synonyms, barcode (when present) and likely-duplicate suggestions do not produce a confident match.

## Flow

1. Capture minimum identity facts and intended taxonomy leaf.
2. Capture brand/model only when applicable; unbranded/custom is explicit.
3. Record merchant/shop actor and provenance privately.
4. Run normalized-name, barcode and attribute duplicate checks.
5. Show likely matches for merchant confirmation.
6. Submit idempotently with client request key.
7. Return `PENDING_REVIEW`, `POSSIBLE_DUPLICATE`, `NEEDS_CORRECTION`, `POLICY_BLOCKED` or approved link result.

## Publication boundary

- Candidate is not a canonical product until governed activation completes.
- Whether limited private draft listing may exist before approval is `OWNER_DECISION_REQUIRED` (`CAT-07 P0`).
- Policy-signalled categories fail closed.
- Bulk import uses the same gates; it is not a moderation bypass.

## Merchant UX

- Preserve draft across safe retries.
- Explain missing/correction fields without internal moderation notes.
- If linked to an existing product, guide merchant to listing creation without losing merchant-entered listing fields.
- No promise of review SLA until operations ownership exists.
