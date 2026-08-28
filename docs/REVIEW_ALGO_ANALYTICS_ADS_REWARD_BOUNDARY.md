# Analytics, Advertising and Reward Boundaries

**State:** HARD SEPARATION CONTRACT

## Allowed analytics

Server-authoritative events may measure form exposure/completion, skip/N/A, response quality, effective
sample state, badge lifecycle and appeal outcomes. Analytics IDs are pseudonymous where possible; product
review text and precise location do not enter general event payloads.

## Prohibited influence

- Ad spend, campaign eligibility, impressions, clicks and budget have zero reputation/badge weight.
- Reward participation, points, streaks and reward redemption have zero reputation/badge weight.
- A merchant cannot purchase better placement inside review feeds or suppress unfavorable content.
- Reputation may not be used to claim ad effectiveness or verified revenue.
- Analytics cannot promote a client-reported response to authoritative evidence.

## Future safe uses

Aggregate reputation status may be an owner-reviewed, bounded marketplace eligibility input only if it does
not create pay-to-win or cold-start exclusion. It remains separate from ad auction/ranking and reward logic.

`AD_SPEND_REPUTATION_WEIGHT: 0`
`REWARD_PARTICIPATION_REPUTATION_WEIGHT: 0`
