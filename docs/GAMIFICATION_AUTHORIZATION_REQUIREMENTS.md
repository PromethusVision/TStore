# Gamification Authorization Requirements

**State:** CONCEPTUAL — NO RLS/AUTH IMPLEMENTATION

| Actor | May read | May request | Must never do |
|---|---|---|---|
| Customer | Own reward/progress/private badges; public merchant facts | Own dispute/privacy/display choice | Award/redeem without server validation; read another customer's history. |
| Merchant staff | Authorized shop program/reputation aggregate | Approved program action/evidence dispute | Read customer history, edit reputation or forge purchase evidence. |
| Merchant owner/admin | Authorized merchant/shop aggregates/config templates | Prospective bounded configuration | Retroactively reduce earned rights or buy badges. |
| Platform support | Least-privilege case evidence | Audited adjustment request | Direct balance overwrite or review deletion. |
| System worker | Scoped authoritative events/policy | Idempotent derivation/ledger action | Use client claims as authority. |
| Anonymous | Public explainable merchant facts | None | Access customer reward/badge data. |

Future authorization must enforce server-side ownership, role guard, shop assignment, immutable audit and privileged-action separation. Service-role/server secrets never belong in Flutter clients.

