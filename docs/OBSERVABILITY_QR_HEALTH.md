# EsnaftaVar QR Health

**State:** `PROPOSED`

Minimum indicators:

- issue request success/rate and latency;
- scan→server validation attempt count and latency;
- verified-purchase success rate over eligible server validations;
- expected rejection mix: expiry, cancel, wrong shop, malformed, unauthorized;
- replay rejection count/rate and concurrent-confirm consistency;
- server/transaction error rate;
- duplicate purchase invariant violations (must remain zero);
- outcome reconciliation lag between authoritative fact and client notification.

Rates use server outcomes, not client scans. Low success can reflect expired user
behavior, adoption or an outage; reason mix and baseline are required. Exact alert
thresholds wait for pilot data, except any duplicate authoritative purchase or
cross-shop authorization breach is critical immediately.

No raw token, customer contact, exact item/price, signed link or private content is
logged. Abuse detections open restricted investigation and do not prove guilt.

`QR_DUPLICATE_OUTCOME_TOLERANCE: ZERO`
