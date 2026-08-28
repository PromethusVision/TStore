# Backend Contrarian Review

**State:** RECOMMENDED — OWNER REVIEW REQUIRED

## Challenge, evidence and conclusion

| Challenge | Evidence-based conclusion | Change to earlier recommendation |
|---|---|---|
| Is organization abstraction premature? | A full enterprise organization hierarchy is premature, but a single-shop organization plus membership seam prevents `profiles.role` and direct owner columns becoming the Merchant security model. | Narrow the model to an additive bridge; defer hierarchy, invitations and broad roles. |
| Do we need explicit variants in V1? | Not globally. Variant identity is required only where option selection changes the sellable identity or verified-purchase snapshot. | Make variants domain-gated and nullable; do not backfill synthetic variants everywhere. |
| Can current tables evolve? | Yes. Current `products`, `shop_products`, QR, verified transaction and review contracts should remain active while additive concepts are introduced. | Reject wholesale replacement. |
| Are too many RPCs proposed? | Direct RLS reads and simple owner-scoped mutations remain appropriate. RPCs are justified only for atomic, privileged or multi-row invariants. | Keep a small V1 command surface. |
| Is Realtime needed everywhere? | No. Current chat/notification behavior and operation-critical merchant status are enough. | Defer dashboard, catalog and analytics Realtime. |
| Is an outbox required now? | Not before durable asynchronous consumers exist. Transactional domain rows and deterministic reconciliation can be sufficient. | Treat outbox as a trigger-based future gate, not a V1 prerequisite. |
| Are audit/provenance requirements excessive? | Full event sourcing is excessive; security-sensitive commands, catalog corrections, QR consumption and operator actions still need append-only evidence. | Use focused audit facts, not universal row histories. |
| Can moderation remain manual? | Yes for low pilot volume, with case IDs and separation of duties for irreversible action. | Defer automation; preserve evidence and queue semantics. |
| Is the future model too enterprise-heavy? | It would be if all future concepts launched together. | Stage organization, variants, events, rewards, ads and reputation independently behind evidence gates. |

## Contrarian recommendation

The pilot should evolve the existing backend rather than replace it. Ship the
minimum Merchant identity/capability bridge, authoritative listing mutations,
and QR confirmation security first. Defer generalized event infrastructure,
complex organization hierarchies, universal variants, automated moderation,
Reward, Ads billing and public reputation until actual usage proves the need.

`OWNER_SELECTIONS: 0`

