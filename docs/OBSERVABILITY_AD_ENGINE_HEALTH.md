# EsnaftaVar Ad Engine Health

**State:** `PROPOSED — ADS RUNTIME NOT PRESENT`

Candidate health signals: decision request success/latency, eligible-candidate
empty/error distinction, campaign/revision load failure, impression delivery lag,
client measurement rejection rate, duplicate event rate, invalid-traffic filter
rate, attribution job freshness and report reconciliation.

Business volume (impressions/clicks/spend) is not system health. Low delivery may
reflect no eligible campaigns; health alerts require eligible inventory plus
technical failures. Billing reconciliation, if ever introduced, is a separate
authoritative gate.

Dimensions use environment, release/model/rule version, surface and bounded error
class. Avoid customer IDs, raw targeting values, precise location and unrestricted
query/creative payloads.

`AD_HEALTH_RUNTIME: NOT_IMPLEMENTED`
