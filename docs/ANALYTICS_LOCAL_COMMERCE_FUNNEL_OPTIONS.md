# EsnaftaVar Local Commerce Funnel Options

**State:** `OPTIONS — NO CAUSAL MODEL FINALIZED`

Candidate stages are search/category discovery, product view, seller comparison,
shop open, directions request and server-authoritative verified purchase.

| Option | Model | Benefit | Risk |
|---|---|---|---|
| A — Counts only | Publish independent stage counts | Lowest identity/privacy complexity | No transition/conversion claims |
| B — Same-session directional funnel | Link approved soft events within a short pseudonymous session | Shows coarse journey drop-off | Consent/session bias; guest/account linkage risk |
| C — Correlation-based bounded journey | Link only explicit context/correlation transitions | Stronger provenance and less broad tracking | Sparse; UI must preserve context |
| D — Customer-level longitudinal funnel | Link across sessions/accounts | Retention/attribution analysis | Highest privacy/policy risk; not recommended for pilot by default |

Recommended pilot starting point is A, optionally C for explicit flows after
privacy review. Each rate must state numerator, eligible denominator, window,
identity unit, bot/test filtering and late-event policy.

A path from directions to verified purchase is temporal association, not proof of
store arrival or causality. Offline purchases not using QR are invisible; QR
adoption differences bias comparisons.

`FUNNEL_OPTION_SELECTED: NO`
