# EsnaftaVar Ad Attribution Event Model

**State:** `REPORTING OPTIONS ONLY — NO CAUSAL/BILLING AUTHORITY`

An attribution candidate links a qualified ad interaction and a later outcome by
an explicitly versioned rule. It never changes either source event.

Conceptual record: attribution-candidate ID, ad interaction event ID, outcome
event ID, campaign/revision, shop/listing/product, interaction/outcome timestamps,
model and window version, match basis, confidence/status, privacy class and
invalid/reversal lineage.

| Option | Match | Tradeoff |
|---|---|---|
| Same explicit correlation | Outcome carries the ad context | Strong provenance, sparse |
| Same approved pseudonymous session | Last/first eligible interaction in session | More coverage, consent/session bias |
| Same authenticated subject/window | Longitudinal join | Highest privacy and causal-overclaim risk |
| Aggregate lift experiment | Cohort comparison | Needs experiment design/volume; not individual proof |

Recommended default is reporting-only explicit correlation, labelled “ad sonrası
doğrulanmış alışveriş adayı.” Attribution windows and multi-touch rules are owner
decisions. No candidate is merchant revenue, billing proof or reputation evidence.

Late, duplicate or invalidated source events cause deterministic recomputation or
an explicit superseding candidate; they do not rewrite raw evidence.

`AD_ATTRIBUTION_MODEL_SELECTED: NO`

