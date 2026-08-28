# Backend Additive-First Migration Strategy

**State:** RECOMMENDED

## Phases

1. Add new nullable/versioned structure and narrow server contracts without
   changing current Customer App behavior.
2. Backfill deterministic rows in bounded batches; quarantine ambiguity.
3. Shadow-read new and old interpretations, record aggregate mismatch only.
4. Cut one server/read caller at a time behind a compatibility facade.
5. Move writes only when the authoritative owner and reconciliation are clear.
6. Enforce new constraints after data/caller acceptance.
7. Observe a full supported-client overlap window.
8. Retire old fields/functions in a separate destructive-authorized wave.

Additive does not mean permanently duplicated truth. Every temporary field/path
has owner, reconciliation metric and removal criteria. Avoid defaults that label
unknown rows “active”, “merchant”, “in stock” or a guessed variant. New security
predicates may narrow immediately only after old legitimate users have a safe
membership bridge.

Use expand/migrate/contract, not one large migration. Production execution always
requires its own owner-authorized gate.

