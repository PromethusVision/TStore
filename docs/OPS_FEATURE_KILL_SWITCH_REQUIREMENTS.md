# Feature Kill-Switch Requirements

**State:** CONCEPTUAL — NO CONFIGURATION OR RUNTIME IMPLEMENTATION

## Candidate switches

| Feature | Safe disabled behavior | Preserve |
|---|---|---|
| QR creation | Explain temporary unavailable; no token issued | Existing transaction/audit history |
| QR confirmation | Reject/hold new confirmation server-side | Prior verified purchases |
| Reviews create/update | Read-only or unavailable by scope | Existing governed reviews/eligibility |
| Chat send/realtime | Disable send/connection safely | Existing authorized message history |
| Ads serving | Exact organic-only results | Campaign/budget/report history; no charge |
| Rewards claim/progress | Hold new mutations | Verified purchase/reward ledger history |
| Merchant catalog writes | Read-only merchant catalog | Customer reads of known-safe active data |
| Media uploads | Disable upload/processing | Existing safe media |

## Requirements

- server-authoritative, environment/feature/scope explicit;
- global and narrowly scoped controls where justified;
- default state/version/owner documented;
- strong authorization, re-authentication, reason, case, expiry/review time;
- atomic/idempotent activation and safe rollback;
- observable effective state and acknowledgement;
- no client-only switch for security containment;
- independent from release build when rapid containment is required;
- all activation/deactivation audited and alerted.

## Failure behavior

Unknown switch state for a sensitive mutation fails closed. A switch must not delete data, fake success, silently queue unbounded work, or convert to an insecure fallback. Disabling one feature should not collapse unrelated organic/read-safe journeys.

## Governance

Routine operators cannot toggle global controls. Scoped moderation actions are not global kill switches. Break-glass activation receives retrospective review; Production activation needs explicit authorized operational context.

`KILL_SWITCHES_IMPLEMENTED: NO`

`CLIENT_ONLY_KILL_SWITCH_ACCEPTABLE: NO`
