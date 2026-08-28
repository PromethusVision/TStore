# EsnaftaVar Merchant App Health

**State:** `PROPOSED SIGNAL INVENTORY`

Priority journeys are startup/auth/role bootstrap, shop context, listing writes,
catalog candidate workflow, review/report operations and QR issue/scan/confirm.

For each measure request success/error/timeout, latency distribution, conflict or
policy rejection, retry count and release/environment. Merchant input validation
is separate from server failure. Listing availability freshness is operational
health, not customer demand.

QR deserves explicit classification:

- expected terminal: expired, cancelled, wrong shop, already consumed;
- client/capability: camera/permission/parse/network;
- authorization/security: role/policy/replay/anomaly;
- platform failure: RPC unavailable, transaction error, inconsistent terminal
  outcome.

Only platform-failure rates page operators. Raw QR, customer identity/contact,
items/prices and private evidence are excluded. Verified purchase success is
reconciled from authoritative facts, not client UI.

`MERCHANT_HEALTH_RUNTIME: NOT_IMPLEMENTED`

