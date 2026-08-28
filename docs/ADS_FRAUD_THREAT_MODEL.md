# Sponsored Advertising Fraud and Abuse Threat Model

**State:** DESIGN THREAT MODEL — NO FRAUD ML OR ENFORCEMENT IMPLEMENTATION

## Risk scale

- `P0`: can cause wrongful charge, unsafe/misleading ad, account compromise or
  material trust damage; hard block/incident path required.
- `P1`: materially distorts ranking, delivery, metrics or merchant fairness.
- `P2`: low-volume manipulation/noise needing monitoring and rate controls.

## Threat registry

| Threat | Risk | Main control concept |
|---|:---:|---|
| Fake/nonexistent listing | P0 | Catalog/listing ownership and serve-time active check |
| Price bait or stock bait | P0 | Fresh source-of-truth, snapshots, complaints, suppression |
| Policy evasion/unsafe creative | P0 | Exact SKU/claim review; fail closed; emergency stop |
| Campaign/account takeover | P0 | Auth/session security, ownership, high-risk-change review |
| Budget double-spend/concurrency | P0 | Atomic reservation, idempotency, immutable ledger |
| QR purchase gaming for ad metrics | P0 | Purchase evidence independent; no default billing coupling |
| Merchant self-click/view | P1 | Merchant/device/session/link analysis; filter/credit |
| Competitor click depletion | P1 | Anomaly/rate/geo patterns; cap exposure; dispute/credit |
| Bot/refresher traffic | P1 | Request integrity, rendering qualification, rate patterns |
| Location spoofing | P1 | Context confidence; no precise merchant disclosure; anomalies |
| Campaign cycling to reset caps/review | P1 | Merchant/shop/target-level history and cap continuity |
| Many listings from same merchant dominate | P1 | Merchant/product/page density and auction-independent caps |
| Review/reputation laundering | P1 | Badge/review systems independent from spend |
| Misleading competitor/brand targeting | P1 | Governed context and impersonation review |
| Duplicate callbacks/events | P2 | Idempotency IDs and replay-safe ingestion |
| Low-volume accidental taps | P2 | Qualified interaction rules and merchant-facing caveats |

## Responses

- reject/suppress before serve where evidence is decisive;
- mark traffic invalid without deleting audit evidence;
- pause campaign/merchant scope under high-confidence active harm;
- credit disputed/invalid charge under owner-approved billing policy;
- request review/appeal without revealing detection thresholds;
- preserve organic experience during ad suspension/outage;
- separate detection signal from final enforcement decision.

## Safety constraints

No device fingerprinting, precise location history or cross-service profiling is
introduced merely because it could improve fraud detection. Data use must be
necessary, proportionate, retained narrowly and privacy/legal reviewed.

`AD_FRAUD_THREAT_MODEL: READY_FOR_OWNER_REVIEW`

`P0_THREATS_FAIL_CLOSED: YES`

`FRAUD_ML_IMPLEMENTED: NO`
