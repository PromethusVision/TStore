# Backend V1 Versus Future Scope

**State:** RECOMMENDED — NOT OWNER APPROVED

## MUST_HAVE

- Preserve current Customer anonymous discovery, profile, cart, QR, verified
  purchase and review contracts.
- Add server-authoritative merchant membership/capability checks without trusting
  UI roles.
- Provide owner-scoped listing price/availability mutations with validation,
  revision checks, idempotency and audit evidence.
- Preserve one-winner QR consumption, exact-shop binding and durable product
  snapshots.
- Enforce RLS for customer, merchant staff and operator boundaries.
- Use additive migrations, N/N-1 client compatibility, rollback gates and
  authoritative postflight checks.
- Keep service-role credentials exclusively in trusted server contexts.

## SHOULD_HAVE

- Single-shop organization/membership bridge with owner and verifier capability.
- Governed product-candidate intake without automatic canonical promotion.
- Listing freshness/unknown semantics and a small truthful merchant dashboard.
- Cursor pagination for unbounded feeds and operation-critical notification/chat
  subscriptions.
- Focused audit trail for privileged/security-sensitive commands.
- Selected-domain variant support only when identity correctness requires it.

## DEFER

- Multi-organization hierarchy, complex staffing and automated transfer.
- Universal variants, variable-measure commerce and authoritative stock claims.
- Event outbox until durable asynchronous consumers require it.
- Reward ledger, gamification, merchant reputation and paid attribution/billing.
- Broad operator automation, generalized workflow engine and universal Realtime.
- Public review media/avatar media, cross-shop QR and destructive catalog cleanup.

The boundaries are recommendations. Economic, legal, policy and pilot-scope
choices remain in the owner decision pack.
