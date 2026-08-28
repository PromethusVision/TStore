# EsnaftaVar Advertising Event Boundary

**State:** `PROPOSED — ADS FOUNDATION OWNER DECISIONS REMAIN OPEN`

| Candidate event | Evidence class | Boundary |
|---|---|---|
| `ad_decision_recorded` | Server derived/audit | Candidate/rule outcome, not an impression |
| `ad_impression_observed` | Client observed | Render requested/seen under a defined rule; not billable by default |
| `ad_qualified_impression_observed` | Client observed + governed qualification | Visibility/time threshold remains owner decision |
| `ad_opened` | Client reported | User opened sponsored destination |
| `ad_shop_opened` | Client reported | Sponsored context led to shop surface |
| `ad_directions_requested` | Client reported | Intent, not arrival/sale |
| `ad_hidden` / `ad_report_submitted` | Mixed | Feedback/safety signals; separate operations path |
| `ad_verified_purchase_observed` | Server derived join | Attribution candidate only; no causality/billing by default |

Every record identifies campaign and immutable campaign revision, target, surface,
shop and exact listing/product where applicable, plus model/rule version. Organic
product/shop events remain valid independent facts and can reference an ad context
without becoming ad-domain authority.

No event is automatically billable. Qualified visibility, click validity,
attribution window/model, consent, retention and commercial billing evidence need
explicit decisions. Paid exposure cannot affect review rights, reward, reputation
or organic ranking.

`AD_MEASUREMENT_RUNTIME: NOT_IMPLEMENTED`
