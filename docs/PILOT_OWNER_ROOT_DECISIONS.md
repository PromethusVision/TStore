# EsnaftaVar Esenler Pilot — Minimum Root Decisions

**State:** `OWNER REVIEW SET — NO OPTION SELECTED`

## Root register

| Root | Question and options | Recommended option | Why / tradeoff | Effects | Priority |
|---|---|---|---|---|---|
| `PR-01` Mission | Choose core proof: A discovery usefulness; B merchant digitization; C monetization; D multi-goal. | A, with merchant truth as guardrail | Cleanest customer-value test; delays monetization proof. | Cost: focus. Merchant: truth/value. Customer: useful discovery. Tech: core flows. Pilot: coherent. | P0 |
| `PR-02` Geography/density | A one cell; B 2–3 cells; C district-wide. Define usable cell-domain evidence. | A then gated B | Concentrates supply/support; narrower reach. | Cost: lower. Merchant: fewer first. Customer: honest local choice. Tech: bounded. Pilot: safer. | P0 |
| `PR-03` Rollout mode | A invite/closed; B bounded public; C broad public. | A then B | Better containment/learning; selection bias. | Cost: lower. Merchant: controlled traffic. Customer: restricted access. Tech: track/cohort. Pilot: reversible. | P0 |
| `PR-04` Domain/allowlist | A ordinary narrow domains; B broad retail; C include regulated/services. | A | Minimizes policy/catalog burden; less breadth. | Cost: lower. Merchant: some excluded. Customer: limited promise. Tech: allowlist. Pilot: safer. | P0 |
| `PR-05` Merchant offer | A time-free; B milestone-free; C free basic; D paid validation; E research then new offer. | E or B for comparison | Avoids accidental long free entitlement; requires explicit later offer. | Cost/revenue: open. Merchant: clarity needed. Customer: supply continuity. Tech: minimal now. Pilot: better willingness-to-pay learning. | P0 |
| `PR-06` Merchant operating path | A wait full app; B controlled minimum tool; C operator-only bootstrap. | B with capped C bootstrap | Speeds learning without weakening authority; creates managed temporary debt. | Cost: manual M. Merchant: workable. Customer: truthful supply. Tech: bounded path. Pilot: faster. | P0 |
| `PR-07` Verification | A minimal identity/shop relation; B stronger business-document set; C sector-tiered evidence. | C with ordinary-domain minimum | Proportionate; needs professional review and operations. | Cost: variable. Merchant: friction by risk. Customer: trust. Tech: states/access. Pilot: fail-closed. | P0 |
| `PR-08` Listing freshness | A one global window; B domain-tiered; C no promise/contact only. | B with visible unknown state | More honest; more governance. | Cost: reminders/review. Merchant: maintenance. Customer: confidence. Tech: timestamps/state. Pilot: core trust. | P0 |
| `PR-09` QR timing | A all day one; B staged; C limited cohort; D post-pilot. | C or B | Learns QR safely without masking discovery; mixed-expectation copy needed. | Cost: bounded training. Merchant: selected cohort. Customer: partial availability. Tech: flag/reconciliation. Pilot: isolatable. | P0 |
| `PR-10` Guest/login/location | A account+location first; B guest + contextual permission + manual fallback; C invite account only. | B, with C earliest cohort if needed | Shows value and minimizes data; adds state complexity. | Cost: UX QA. Merchant: broader demand. Customer: lower friction. Tech: guest/auth/fallback. Pilot: valid acquisition. | P0 |
| `PR-11` Platform | A Android-only; B Android-first+iOS lane; C dual launch. | B | Maintains speed while acknowledging exclusion; two readiness lanes. | Cost: bounded now. Merchant: Android device check. Customer: iOS deferred. Tech: separate artifacts. Pilot: faster. | P0 |
| `PR-12` Customer acquisition | A merchant/organic/referral only; B add bounded Meta test; C broad paid launch. | A then optional B after gates | Preserves core-value signal; slower reach. | Cost: low first. Merchant: participates in invites. Customer: trusted local sources. Tech: source tags. Pilot: cleaner. | P0 |
| `PR-13` Support/staffing | A owner only; B one operator+owner+specialists; C hybrid team; D outsource. | B for tiny cell | Lean but avoids owner handling every case; single-point risk needs backup. | Cost: M. Merchant/customer: declared support. Tech: roles/audit. Pilot: feasible if capped. | P0 |
| `PR-14` KPI/monitoring | A minimal governed scorecard/free-first health; B broad SaaS analytics; C manual anecdotes. | A | Actionable and privacy-minimized; fewer exploratory metrics. | Cost: M. Merchant/customer: honest evidence. Tech: env/release/event needs. Pilot: defensible. | P0 |
| `PR-15` Ads/reward/reputation timing | A day one; B stabilization; C post-pilot; D never. Decide each separately. | C for all three; rating/count remains | Protects focus; delays monetization/incentive experiments. | Cost: avoids XL. Merchant: fewer tools. Customer: less distortion. Tech: no new engines. Pilot: clearer. | P0 |
| `PR-16` Feedback | A observed tasks/interviews; B in-app survey only; C support data only; D combined minimal methods. | D | Triangulates evidence; consent/ops burden. | Cost: M. Merchant/customer: voice. Tech: minimal capture. Pilot: learning. | P1 |
| `PR-17` Terms/privacy | A minimum approved data/purpose/vendors; B broad analytics; C defer review. | A before participants | Required trust/governance; may constrain tooling. | Cost: professional review. Merchant/customer: clarity. Tech: retention/access. Pilot: launch gate. | P0 |
| `PR-18` Pause/expansion | A calendar/count thresholds; B evidence-based gates one dimension at a time; C opportunistic growth. | B | Preserves causality and safety; slower growth. | Cost: controlled. Merchant/customer: fewer shocks. Tech: flags/metrics. Pilot: reversible. | P0 |

## Dependencies

- `PR-01` precedes every KPI/scope choice.
- `PR-02/04/05/06/07/08/13/17` precede merchant launch.
- `PR-09` precedes QR acceptance and education.
- `PR-10/11/12/17` precede customer acquisition.
- `PR-14/18` precede any exposure expansion.
- `PR-15` is not a prerequisite for the first pilot.

`ROOT_OWNER_DECISIONS: 18`

`ROOT_OPTIONS_SELECTED: 0`
