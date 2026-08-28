# Reward and Advertising Decoupling

Status: **PROPOSED GUARDRAIL — NO RUNTIME**
Wave: 18 / Workstream M
Ads source: read-only `origin/agent2/w16-sponsored-advertising-engine-foundation@43135b99d6187de205bd431fd780d9871ad61e02`

## Independence

Advertising buys eligible, disclosed distribution. Reward evaluates explicitly approved customer evidence. Neither system creates the other's source truth.

## Prohibited by default

- Reward for ad impression, view, click or mandatory watch.
- Higher reward solely because the journey was sponsored.
- Ad spend creating loyalty evidence, verified purchase, review right, rating or reputation badge.
- Campaign changing reward balance or hiding expiry.
- Reward loss for declining personalization/ad controls.

## Permitted future interaction

An advertised journey may later produce an independently verified purchase. Reward evaluates that purchase exactly like an equivalent organic purchase. Ads may report an attributed aggregate under privacy rules; it does not own or bill the reward event.

## Required event separation

Campaign/impression/click, verified purchase, reward ledger and reputation identities remain separate with provenance. `billable`, `verified_purchase`, `reward_eligible` and `reputation_eligible` cannot collapse into one boolean.

Any future ad-engagement reward requires a separate P0 owner, policy, privacy, child-safety, fraud, economics and disclosure decision. Until then it is prohibited, not merely deferred.
