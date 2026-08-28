# EsnaftaVar Customer and Merchant Retention Options

**State:** `OPTIONS — NONE SELECTED`

Customer activity anchors could be usable discovery, directions intent or
authoritative verified purchase. Merchant anchors could be catalog-ready shop,
listing maintenance, QR availability or verified-purchase participation.

| Option | Identity/window | Caveat |
|---|---|---|
| Event-return counts | Same approved entity active in later fixed window | Requires identity and eligibility denominator |
| Rolling active | Activity within trailing window | Hides cohort age and seasonality |
| Cohort retention | Return by acquisition/activation cohort | More interpretable; needs sufficient volume |
| Aggregate shop retention | Shop remains verified/catalog-ready | Operational, not customer engagement |

No session-based “return” without session definition. Customer longitudinal
retention needs privacy/legal basis and deletion handling. Merchant suspension,
seasonality and branch closure are separate from churn. Exact anchors/windows are
Product Owner decisions.

`RETENTION_MODEL_SELECTED: NO`

