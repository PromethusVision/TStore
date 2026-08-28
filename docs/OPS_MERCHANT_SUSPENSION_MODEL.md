# Merchant Suspension Model

**State:** PROPOSED — OWNER/POLICY DECISION REQUIRED

Suspension is a reversible containment state, not deletion or proof of permanent wrongdoing.

## Scope levels

| Scope | Typical use |
|---|---|
| CAPABILITY | Block QR, catalog write, ad creation, or staff management only |
| LISTING/PRODUCT | Restrict affected offers/content |
| SHOP | Stop one physical location while preserving organization review |
| MERCHANT/ORGANIZATION | Block all controlled shops/capabilities |
| ACCOUNT SECURITY HOLD | Protect takeover-affected actions pending recovery |

Use the narrowest safe scope.

## Cross-system effects

| System | Proposed effect |
|---|---|
| Shops | New discovery/actions hidden or restricted per scope; historical identity retained |
| Listings | Stop new availability/serving; preserve snapshots/history |
| QR | Stop creation/confirmation as applicable; preserve prior verified transactions |
| Ads | Pause campaigns/delivery/budget use; do not delete reports/audit |
| Reviews | Preserve legitimate reviews; block retaliation/reply/report abuse as scoped |
| Reputation | Freeze dependent updates if integrity uncertain; never arbitrarily set score |
| Staff/roles | Revoke risky sessions/capabilities; preserve audit |
| Catalog | Merchant assertions may be held; canonical truth not automatically deleted |

## Decision controls

Case, evidence, current policy, reason, scope, duration/review time, impact preview, communication, appeal, reviewer, and audit. Permanent restriction is a separate owner/policy decision and high-risk action.

## Restoration

Recheck authoritative state and affected dependencies; restore through a new event. Do not retroactively erase suspension or silently revive stale listings/campaigns. Security recovery may require session revocation, credential reset through canonical auth, and role review.

`SUSPENSION_EQUALS_DELETION: NO`

`BLAST_RADIUS_MINIMIZED: YES`
