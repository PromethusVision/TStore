# EsnaftaVar Metric Failure Registry

**State:** `PROPOSED`

| ID | Metric failure | Severity | Root control |
|---|---|---|---|
| MTF-001 | Verified purchase count inflated by duplicate delivery | P0 | Distinct authoritative purchase ID + reconciliation |
| MTF-002 | Demo/test/Development included in Production business KPI | P0 | Source marking + environment purity gate |
| MTF-003 | Secret/PII appears in metric dimension/export | P0 | Allowlisted bounded dimensions + export audit |
| MTF-004 | Soft intent labelled sales/revenue | P1 | Semantic registry and UI copy gate |
| MTF-005 | Ad attribution candidate labelled causal conversion | P1 | Attribution status/model disclosure |
| MTF-006 | Paid ads/rewards alter reputation metric | P1 | Source-evidence allowlist |
| MTF-007 | Review update/delete not reflected | P1 | Latest-revision projection/reconciliation |
| MTF-008 | Catalog merge double-counts predecessor facts | P1 | Event identity before lineage rollup |
| MTF-009 | Catalog/taxonomy split allocates facts arbitrarily | P1 | Predecessor/unresolved bucket |
| MTF-010 | Metric definition changes silently | P1 | Immutable metric ID/version governance |
| MTF-011 | Ratio denominator differs in scope/window/filter | P1 | Formula contract fixture tests |
| MTF-012 | Zero denominator rendered as zero conversion | P1 | Not-applicable state |
| MTF-013 | Customer-level/small cohort exposed to merchant | P1 | Suppression/access controls |
| MTF-014 | Late/corrected events do not restate prior window | P2 | Bounded recomputation and freshness |
| MTF-015 | Shop-local and UTC days mixed | P2 | Timezone/window dimension |
| MTF-016 | Partial day compared with complete period | P2 | Partial-window label/exclusion |
| MTF-017 | Bot/invalid filter version missing | P2 | Versioned filter and raw reconciliation |
| MTF-018 | Unique count approximated but labelled exact | P2 | Algorithm/precision disclosure |
| MTF-019 | Dashboard stale data appears current | P2 | Freshness/stale state |
| MTF-020 | Vanity metric presented without outcome/health context | P3 | KPI review and definition caveat |

Metric failures are corrected by versioned projection/backfill and disclosure, not
manual dashboard number editing. P0/P1 requires impact analysis across every
consumer and window.

`METRIC_FAILURE_REGISTRY_FINALIZED: NO`

