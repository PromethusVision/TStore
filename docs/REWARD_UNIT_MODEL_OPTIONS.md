# Reward Unit Model Options

Status: **PROPOSED — OWNER_DECISION_REQUIRED**
Wave: 18 / Workstream D

| Unit | Customer meaning | Economic burden | Fraud/complexity | Recommendation |
|---|---|---|---|---|
| Stamp | One governed eligible event | Low-to-medium | Split/collusion controls needed | Strong starting candidate |
| Progress percentage | Distance to threshold | Depends on underlying unit | Threshold change can mislead | Presentation only |
| Points | Abstract balance | Medium/high | Formula/devaluation/expiry disputes | Defer |
| Credits | Monetary-like claim | High | Accounting, funding, redemption liability | Do not launch without specialist review |
| Non-monetary unlock | Access/status/content | Low economic, variable trust | Can blur badge vs reward | Separate explicit benefit |

## Invariants

- Unit name and displayed value match actual ledger semantics.
- Points/credits are not called cash and no monetary equivalence is implied without approved legal/economic contract.
- Badge is recognition/status; it is not silently redeemable reward value.
- A percentage is derived from versioned earned units and threshold, not independently stored authority.
- Rule revisions preserve earned history and explain transition.

## Recommendation

If an economic reward is approved after pilot, start with discrete stamps backed by one eligible verified-purchase event and a merchant-specific program. Do not owner-finalize threshold or benefit here.
