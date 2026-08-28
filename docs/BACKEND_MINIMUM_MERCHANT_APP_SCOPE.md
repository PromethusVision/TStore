# Minimum Merchant App Backend Scope

**State:** RECOMMENDED — OWNER REVIEW REQUIRED

## Required V1 capabilities

1. **Authenticated merchant principal:** normal Auth user linked through an
   active membership; no client-settable role escalation.
2. **One-shop access:** exact shop scope and owner/verifier capabilities evaluated
   server-side on every command.
3. **Listing management:** read assigned shop catalog; change listing-owned price,
   availability status and optional merchant SKU with validation and revision.
4. **QR verification:** inspect an opaque active token, prove exact-shop access,
   and consume through the existing atomic verified-purchase path.
5. **Operational feedback:** stable client-safe errors, idempotent retry results,
   recent confirmations and minimal counts whose semantics are explicit.
6. **Revocation/suspension:** access stops at the next server request and active
   subscriptions are reauthorized.
7. **Audit:** actor, shop scope, command, request key, result and correction link
   for sensitive actions.

## Not required for minimum V1

- organization hierarchies, invitations and arbitrary custom roles;
- cross-shop/cross-branch QR confirmation;
- global catalog editing or candidate auto-promotion;
- perfect stock, payment, revenue or “sales” inference;
- Ads billing, Reward, reputation, gamification or broad analytics;
- generalized outbox, workflow engine or all-table Realtime.

## Compatibility guard

Merchant additions must be additive. Existing Customer reads and canonical QR,
verified-purchase and review behavior remain valid while Merchant App versions
roll out independently.
