# EsnaftaVar Esenler Pilot — KPI Registry

**State:** `MINIMUM REGISTRY PROPOSAL — TARGETS NOT FINAL`

Metrics are environment-, release-, cohort-, cell- and time-window qualified. Test,
demo and staff traffic is excluded or separately labelled. No target is set before
a trustworthy baseline.

## Minimum scorecard

| KPI ID | Definition | Primary source | Why it matters | Caveat |
|---|---|---|---|---|
| `PKPI-01` | Launch-ready active shops | Verification + readiness roster | Supply capable of serving promise | Registration count is not readiness |
| `PKPI-02` | Current useful visible listings | Active listings passing freshness/policy | Catalog depth | Row count can contain duplicates or thin goods |
| `PKPI-03` | Usable cell-domain pairs | Cell/domain status=`USABLE` or better | Merchant density | Threshold remains owner-approved after field audit |
| `PKPI-04` | Qualified first-use customers | Distinct valid users/devices completing defined discovery task | Acquisition quality | Identity/linkage must be privacy-minimized |
| `PKPI-05` | Search/discovery task success | Valid tasks reaching a useful result | Core product value | Must pair with no-result and abandonment context |
| `PKPI-06` | Product/shop/directions intents | Quality-filtered distinct actions | Downstream local intent | Never call sales, visits or revenue |
| `PKPI-07` | Distinct verified physical purchases | Unique server-authoritative verified-purchase IDs | QR outcome evidence | Not payment, revenue or all physical purchases |
| `PKPI-08` | QR coverage and failure mix | Confirmed/eligible or attempts, with reason classes | Adoption/operability | Denominator must be explicitly observable |
| `PKPI-09` | Listing truth/freshness quality | Sample pass, disputes, corrections and time-to-correct | Customer trust | Samples and domain mix affect interpretation |
| `PKPI-10` | Eligible review integrity | Active eligible reviews and duplicate/right violations | Trust loop | Review volume alone is not quality |
| `PKPI-11` | Critical product health | Crash/startup/auth/RPC/search/QR error and recovery | Safe operation | Health dashboard is not business success |
| `PKPI-12` | Support/incident health | P0/P1 open/age, unowned, reopen and pause state | Operational capacity | SLA/thresholds need staffing decision |
| `PKPI-13` | Merchant continuation | Ready merchants continuing truth maintenance after milestone | Supply retention | Login activity alone is insufficient |
| `PKPI-14` | Customer useful return | Cohort returning for another qualified task | Demand retention | No incentive-distorted interpretation |
| `PKPI-15` | Catalog candidate burden | New candidates, age, match/create/reject/request-more and queue time | Scaling cost | High volume can reflect poor canonical reuse |

## Reporting rules

- Show numerator, denominator, window, coverage and exclusion rules.
- Keep event-time facts and current catalog/taxonomy rollups distinguishable.
- Deduplicate authoritative metrics by source identity, not delivery attempts.
- Mark missing telemetry and partial coverage; do not backfill by guess.
- Small cohorts require suppression/aggregation appropriate to privacy.
- Definition changes create a new version and restatement note.

## Vanity-metric exclusions

Downloads, impressions, raw page views, merchant signups, notification opens and
cart adds are supporting diagnostics only. They do not independently answer whether
local discovery, merchant truth or physical-purchase verification works.

`PILOT_KPI_TARGETS_FINALIZED: NO`
