# Backend Seed Data Contract

**State:** PROPOSED — NO SEED CREATED OR APPLIED

Canonical seeds are deterministic, reviewable fixtures for a declared environment
and product purpose. They are not migrations or shortcuts around Auth/RLS/trust.

## Requirements

- fixed namespace/manifest and stable IDs; no random/time-dependent business data;
- exact expected counts, controlled fields and referential order;
- explicit demo/test marker and human-visible synthetic naming;
- transaction with schema/collision/natural-key/dependency preflight;
- idempotent second apply only for exact-compatible rows; no blind `DO UPDATE`;
- postflight customer/merchant read contract and zero forbidden trust data;
- exact cleanup manifest/order with fail-closed dependency checks;
- no real people/businesses, credentials, copyrighted media or exact private
  location;
- no verified purchase, review, reward, reputation or ad evidence fabrication;
- apply and cleanup each require separate environment-specific authorization.

Generated artifact, generator and validator must agree byte-for-byte. Real customer
activity makes destructive cleanup a new risk decision, not an automatic seed step.
