# Sponsored Frequency-Cap Model

**State:** PROPOSED PRIVACY-MINIMIZING CONTRACT — EXACT CAPS TBD

## Objectives

- prevent one sponsor from dominating a customer experience;
- preserve useful local repetition without harassment;
- avoid building a detailed behavioral profile merely to count exposure;
- cap independently from budget and ranking quality.

## Cap dimensions

| Dimension | Candidate rule | Identity need |
|---|---|---|
| Per result page/request | One instance of same target; surface density cap | Request/session token |
| Per search | Do not repeat same campaign in paginated duplicate window | Normalized intent hash + short window |
| Per session | Limit same merchant and same listing | Ephemeral session counter |
| Per day | Coarse merchant/campaign/listing cap | Pseudonymous daily bucket if legally approved |
| Per merchant | Prevent many products from one shop filling sponsored slots | Merchant/shop ID |
| Per product | Prevent many campaigns for same product overwhelming comparison | Canonical product ID |

Exact numeric values require Product Owner, UX and privacy review. Proposed surface
density begins at one sponsor in the first five Search/Category results and no more
than 20%, but this is not final.

## Privacy posture

- prefer request/session counters before persistent customer-level tracking;
- if daily dedup is necessary, use rotating/pseudonymous identifiers with short
  retention and no cross-purpose enrichment;
- do not store raw query plus precise location plus stable user solely for capping;
- guest users receive session/device-safe caps without fingerprinting;
- opting out of behavioral personalization cannot remove safety/density caps that
  can operate without profiling.

## Failure behavior

Counter store timeout must choose a conservative no-ad or stricter request cap, not
unlimited serving. Organic results continue. Duplicate measurement events do not
increment caps twice.

`FREQUENCY_CAP_V1: REQUIRED`

`CROSS_APP_TRACKING_FOR_CAPS: NO`

`EXACT_CAP_VALUES_FINALIZED: NO`
