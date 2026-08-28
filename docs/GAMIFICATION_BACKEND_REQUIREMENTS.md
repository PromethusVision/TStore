# Gamification Backend Requirements

**State:** CONCEPTUAL ARCHITECTURE — NO SQL, MIGRATION OR RPC

## Logical capabilities

- Immutable authoritative event intake with stable event, customer, merchant, shop, product, listing and policy identities.
- Separate reward ledger (`EARN/ADJUST/REVERSE/REDEEM/EXPIRE`) and derived balance/progress projections.
- Badge definition/version, evidence links, lifecycle and derived customer badge state.
- Merchant signal registry, evidence window, shop scope, badge lifecycle and independent rating projection.
- Idempotency registry, correction lineage, policy snapshot, dispute/appeal and audit log.
- Outbox/worker processing, replay/backfill controls, monitoring and kill switches.

## Hard separations

Reward ledger, review eligibility, advertising attribution and reputation derivation are distinct. Verified purchase failure semantics remain unchanged; a downstream reward failure retries asynchronously and never rolls back purchase confirmation.

## Unknowns

Exact tables, keys, enums, RLS, RPC signatures, retention and operational hosting are future implementation decisions after owner approval. This document authorizes none.
