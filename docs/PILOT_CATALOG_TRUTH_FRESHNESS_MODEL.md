# EsnaftaVar Esenler Pilot — Catalog Truth and Freshness

**State:** `PROPOSED OPERATING CONTRACT — THRESHOLDS TBD`

## Customer-visible truth classes

| State | Meaning | Customer behavior |
|---|---|---|
| `CURRENT` | Merchant-confirmed within approved window | Display normally with timestamp where useful |
| `AGING` | Approaching freshness limit | Display with caution/reminder; prioritize recheck |
| `UNKNOWN` | Availability cannot be confirmed | Do not imply stock; allow contact/directions only if product policy permits |
| `STALE` | Approved window exceeded | Suppress stock-like claim or listing per chosen policy |
| `DISPUTED` | Customer/operator evidence conflicts | Hold risky claim and open case |
| `PAUSED` | Shop/listing intentionally unavailable | Exclude from active discovery |

Exact durations vary by product/domain and remain owner/operations decisions. A
single global “updated recently” promise is unsafe.

## Truth controls

- merchant attestation binds exact shop/listing and timestamp;
- price and availability update independently;
- unknown is a valid state, never coerced to in-stock;
- customer reports are signals, not automatic canonical edits;
- correction preserves before/after, actor, reason and source;
- repeated truth failures affect listing/shop operational state, not a hidden
  composite reputation score;
- dashboard freshness is separate from customer-visible stock language.

## Sampling plan

Sample at onboarding, first week, after customer disputes, after long inactivity,
and before expanding a cell/domain. Track material-error rate, time-to-correct and
merchant update effort without exposing customer PII.

`EXACT_FRESHNESS_WINDOWS_FINALIZED: NO`

`PERFECT_REAL_TIME_STOCK_PROMISED: NO`
