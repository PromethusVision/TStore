# Merchant Evaluation Aggregation Options

**State:** ALGORITHM COMPARISON — NO FORMULA FINALIZED

## Common input contract

Inputs are eligible 1–5 structured responses after evidence, integrity, customer-cap, window and
question-version rules. Quantity, basket value, purchase frequency, ads and rewards have weight zero.
Product rating is never an input.

| Model | Method | Interpretability | Small-sample behavior | Fraud resistance | Complexity |
|---|---|---|---|---|---|
| A | arithmetic mean + minimum sample | Highest | hidden until threshold, then can jump | threshold only | Low |
| B | Bayesian-adjusted ordinal score + minimum sample | Medium if disclosed plainly | shrinks uncertain shops toward a declared prior | better against a few extremes; not fraud-proof | Medium |
| C | lower confidence bound after binary positive/not-positive transform | Medium | conservative | useful for success proportions | Medium; loses 1–5 detail |
| D | hybrid dimension eligibility: score + sample + freshness + integrity gates | High at rule level | explicit `insufficient history` | strongest gating; still needs detection | Medium |

## Formula sketches, not thresholds

### Model A

`mean_d = sum(rating_d) / eligible_count_d`, published only after `n >= N_min`.

### Model B

`adjusted_d = (n * observed_mean + k * prior_mean) / (n + k)`. Prior scope, strength `k`, minimum
sample and display rounding require validation. A global prior can be unfair across heterogeneous
shop contexts; do not learn it from tiny pilot data.

### Model C

Map a declared subset, for example 4–5, to positive and compute a lower confidence bound. This is
appropriate only if the product question is truly binary; it must not masquerade as an adjusted
five-star mean.

### Model D

Badge eligibility requires each needed dimension to satisfy a method score plus independent sample,
freshness, customer-diversity, fraud/policy and status gates. It is a decision framework and can use
A, B or C internally.

## Research recommendation

Use **B for internal dimension estimation with D safeguards** as the leading research candidate.
Keep raw count/distribution visible and retain A as an audit baseline. Do not publish an opaque
single merchant star. Model C is secondary for future yes/no reliability questions, not the default
ordinal rating model.

`RECOMMENDED_RESEARCH_CANDIDATE: MODEL_B_PLUS_MODEL_D`
`FINAL_PRIOR_OR_THRESHOLD: NONE`
