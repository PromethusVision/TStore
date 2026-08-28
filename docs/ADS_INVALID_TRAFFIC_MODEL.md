# Sponsored Invalid Traffic Model

**State:** CONCEPTUAL SIGNAL/RESPONSE MODEL — NO FRAUD ML

## Invalid-traffic classes

- `KNOWN_INVALID`: deterministic duplicate, replay, impossible request or blocked
  actor; exclude from metrics/billing candidate.
- `LIKELY_INVALID`: strong multi-signal anomaly; hold/filter pending policy.
- `SUSPECTED`: weak anomaly; keep separate, do not make irreversible accusation.
- `VALID_CANDIDATE`: qualification gates pass; still not proof of human purchase.
- `UNKNOWN`: insufficient evidence; conservative billing/reporting posture.

## Candidate signals

| Signal group | Examples | Caution |
|---|---|---|
| Event integrity | duplicate event ID, replay, impossible sequence/time | Strong when server-verifiable |
| Rate/pattern | rapid repeated opens, refresh loops, campaign-target burst | Shared networks/accessibility can look unusual |
| Actor relation | advertiser/self-account interaction | Do not infer household/device identity casually |
| Geo consistency | impossible movement, target far outside context | Location can be denied/stale/spoofed |
| Listing truth | price/stock churn around impressions | Merchant operation can legitimately change |
| Conversion mismatch | large clicks with zero downstream signals | Low-demand products can be legitimate |
| Complaint/dispute | customer/merchant reports | Needs corroboration and anti-abuse handling |

No single probabilistic client signal should automatically cause permanent merchant
sanction or a legal conclusion.

## Response ladder

1. Deduplicate/idempotently ignore exact replay.
2. Exclude deterministic invalid events from qualified metrics.
3. Rate-limit and reduce exposure under live attack.
4. Hold potentially billable units while confidence is unresolved.
5. Credit/reverse confirmed invalid traffic under future policy.
6. Pause target/campaign/merchant only at proportionate thresholds.
7. Escalate P0 safety/fraud with audit evidence and appeal path where appropriate.

## Privacy and explainability

Retain minimal pseudonymous signals and reason classes, not raw location/query/device
history indefinitely. Merchant reporting may show invalid counts/reasons at a safe
level but must not disclose thresholds that enable evasion or identify customers.

`INVALID_TRAFFIC_BILLABLE_BY_DEFAULT: NO`

`SINGLE_WEAK_SIGNAL_PERMANENT_BAN: NO`

`INVALID_TRAFFIC_MODEL: READY_FOR_OWNER_REVIEW`
