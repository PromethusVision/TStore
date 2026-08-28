# Backend Reward RPC Boundary

**State:** PROPOSED FROM REWARD FOUNDATION — NO REWARD IMPLEMENTATION

Reward value changes only through governed ledger commands such as earn, adjust,
reverse, redeem and expire. A command identifies reward account, authoritative
source event, policy/rule version and idempotency identity.

Customers may read balances/history and request an allowed redemption; merchants
may manage only owner-approved future configuration. Neither may directly update
balance/progress or mark a purchase eligible. Analytics, ads, clicks and UI events
cannot manufacture reward entries.

Every mutation is atomic with the ledger entry and entitlement/reservation where
needed. Corrections append compensating entries. Purchase quantity/amount are not
trusted unless the reward policy explicitly accepts their authoritative snapshot.

Funding, unit, scope, redemption and expiry remain
`OWNER_DECISION_REQUIRED`; therefore no V1 RPC names are finalized.

