# Unified Review and Badge Root Owner Decisions

**State:** OWNER REVIEW PACK — RECOMMENDATIONS ARE NOT SELECTIONS

## ROD-01 — Launch phase (P0)

- **Question:** How far should the first Esenler pilot launch?
- **Options:** Phase 1 collection; Phase 2 private analytics; Phase 3 primary badges; Phase 4 composites.
- **Recommended:** Phase 1 only.
- **Why/tradeoff:** validates comprehension/data at lowest reputational risk; delays public differentiation.

## ROD-02 — Question and scale contract (P1)

- **Question:** Which structured form should be tested?
- **Options:** one overall; three dimensions; three plus overall; five+.
- **Recommended:** test three versus four with labeled 1–5, skip and N/A; lead with three.
- **Why/tradeoff:** dimension value without excessive survey burden; four adds a useful cross-check.

## ROD-03 — Repeat/cross-shop contribution identity (P0)

- **Question:** How does repeat purchase affect shop evaluation?
- **Options:** every purchase; lifetime one; latest per shop/window; bounded N/window.
- **Recommended:** raw per transaction, latest effective customer+shop/window; Shop B independent.
- **Why/tradeoff:** longitudinal evidence with one-customer cap; needs a window and clear replacement rule.

## ROD-04 — Merchant-feed origin (P0)

- **Question:** Which shop projects the one product free-text review?
- **Options:** first-review origin; latest purchase; all purchased shops; no merchant projection.
- **Recommended:** immutable first-review origin, separately labeled structured data.
- **Why/tradeoff:** deterministic and non-duplicative; a later shop does not receive that product text.

## ROD-05 — Reputation subject/lifecycle (P0)

- **Question:** Is evidence shop-first, and what survives ownership/branch changes?
- **Options:** shop only; organization only; shop plus later derived roll-up.
- **Recommended:** shop-first, roll-up deferred, transfer effective-date segmentation.
- **Why/tradeoff:** matches QR/local experience; organization comparison arrives later.

## ROD-06 — Aggregation method (P0)

- **Question:** Which Model A–D framework should lead future scoring?
- **Options:** A mean; B Bayesian; C binary lower bound; D hybrid gates; combinations.
- **Recommended:** B internal estimate + D gates, with A audit baseline; no exact prior yet.
- **Why/tradeoff:** protects small samples while retaining ordinal data; method explanation is harder.

## ROD-07 — Sample/confidence rule (P0)

- **Question:** When is evidence sufficient for a badge?
- **Options:** fixed N; diversity; precision; hybrid.
- **Recommended:** pilot-calibrated hybrid with `insufficient history`, count/window disclosure.
- **Why/tradeoff:** broad protection and fairness; exact numeric gate waits for data.

## ROD-08 — Freshness and grace (P1)

- **Question:** How should older evidence and badge aging behave?
- **Options:** lifetime; rolling; exponential; dual; event segmentation.
- **Recommended:** pilot timestamps/no decay; later disclosed recent window + lifetime context and AT_RISK.
- **Why/tradeoff:** explainable and reversible; less responsive initially.

## ROD-09 — Primary badge family/names (P1)

- **Question:** Which narrow badges may be tested?
- **Options:** none; three candidate dimensions; overall badge; larger family.
- **Recommended:** no public pilot badges; later test three candidate names/meanings.
- **Why/tradeoff:** avoids premature claims; postpones merchant-facing benefit.

## ROD-10 — Fraud, correction and appeal (P0)

- **Question:** How do suspicious/invalid contributions affect derived reputation?
- **Options:** immediate auto-remove; hold+review; count until final; manual score edit.
- **Recommended:** explainable hold/recompute and append-only appeal reversal; never manual score edit.
- **Why/tradeoff:** protects integrity and false positives; creates an operations queue.

## ROD-11 — Composite semantics (P1)

- **Question:** How may primary strengths form a composite?
- **Options:** all specified; any N; balanced; weighted score.
- **Recommended:** specified or balanced prerequisites, weakest-dimension confidence guard.
- **Why/tradeoff:** explainable; less flexible than opaque weights.

## ROD-12 — `Mahallenin Yıldızı` and region (P0)

- **Question:** Which model/region can support a future local meta badge?
- **Options:** A specified; B any N; C balanced; D percentile; E absolute+local.
- **Recommended:** defer; later compare E with A/C using stable shop geography and cohort minimum.
- **Why/tradeoff:** prevents weak/small-cohort winner; delays the proposed hero badge.

## ROD-13 — Public/search surfaces (P1)

- **Question:** Should a merchant star or badge affect search/comparison?
- **Options:** public star/rank; narrow badges; profile only; internal only.
- **Recommended:** no V1 merchant star or hard search prerequisite; later narrow profile badges.
- **Why/tradeoff:** avoids product-star confusion/cold start; lower immediate discoverability signal.

## ROD-14 — Privacy/policy contract (P0)

- **Question:** What notice, retention, deletion/correction and automated-decision safeguards apply?
- **Options:** require professional review before collection; before publication; defer feature.
- **Recommended:** professional review before collection and public methodology review before badges.
- **Why/tradeoff:** fail-closed on personal data/public claims; adds an explicit gate.

## ROD-15 — Implementation/publication gates (P0)

- **Question:** Which gates separate architecture, collection, analytics and publication?
- **Options:** single launch; phased gates; indefinite defer.
- **Recommended:** phased owner, privacy, backend, physical/pilot-data, ops and Production gates.
- **Why/tradeoff:** limits blast radius while preserving learning; more milestones, not more runtime scope now.

## Counts

- Root decisions: 15
- P0: 10
- P1: 5
- P2: 0
- Options selected: 0

`ROOT_DECISION_SET: 15`
