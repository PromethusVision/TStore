# EsnaftaVar Shop Metric Model

**State:** `PROPOSED`

Shop metrics use stable shop and optional branch identity. A merchant-wide rollup
is a separately labelled aggregation, not a shop row duplicated across branches.

| Family | Candidate metrics | Evidence/constraint |
|---|---|---|
| Discovery | shop views, search/category opens leading to shop | Quality-filtered soft events |
| Local intent | directions requests, optional phone action if approved | Intent only; no arrival/sale claim |
| Catalog | active/unavailable/stale listings, catalog completeness | Authoritative listing state |
| Commerce | verified physical purchases and items | Distinct server-authoritative outcomes |
| Reputation | active eligible review count/rating distribution | Review lifecycle projection, not ad spend |
| Operations | QR success/failure classes, update freshness | Restricted operational aggregate |

Reporting defaults to shop-local day and complete-day rolling windows, with
freshness and late-event correction disclosed. Soft metrics apply bot/test/demo
filters. Small customer cohorts and customer-level journeys are suppressed.

Comparison with other merchants, revenue/profit and conversion rates are out until
owner, privacy and denominator/evidence decisions exist.

`SHOP_METRIC_MODEL_FINALIZED: NO`

