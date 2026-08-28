# Nightly Test Options

**State:** OPTIONS — OWNER_DECISION_REQUIRED

| Option | Contents | Cost/risk | Recommendation |
|---|---|---|---|
| A — None | PR/main deterministic gates only | cheapest; slower drift discovery | acceptable until CI baseline exists |
| B — Local extended | full tests, clean-room DB, generated artifacts, compile matrix | moderate runner time; no secrets | recommended first nightly candidate |
| C — Development synthetic | B plus opt-in remote Auth/RLS/Realtime/QR | account/quota/cleanup and secret risk | add only after isolated fixtures are reliable |
| D — Device farm | selected integration/device matrix | cost and maintenance | defer until measured device-risk need |

## Scheduling rules

Nightly failure opens a triage signal; it does not automatically block unrelated work without reproducibility and ownership. Jobs deduplicate identical commits, cancel superseded runs and avoid building unchanged platforms. Remote suites use exact environment allowlists and bounded accounts.

## Cost principle

Measure duration, queue delay, cache hit, flaky retry and defect yield for several weeks before expanding. A nightly suite that repeats PR work without finding distinct defects should be reduced.

`RECOMMENDED_OPTION: B_AFTER_CI_FOUNDATION`

`OWNER_DECISION_REQUIRED: NIGHTLY_ENABLEMENT_AND_BUDGET`
