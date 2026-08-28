# Reputation Paid-Influence Boundary

Status: **NON-NEGOTIABLE PROPOSED GUARDRAIL**
Wave: 18 / Workstream Z

## Rule

Advertising spend, bid, campaign tenure, impressions, clicks, billing tier, reward funding or paid subscription cannot directly improve merchant reputation, customer rating, verification, review weight, organic ranking or trust badge.

## Permitted bounded interaction

- Severe independently verified abuse/reputation state may make advertising ineligible.
- Advertising outcome can be measured separately using defined events.
- An advertised journey can later produce an independently verified purchase; sponsorship does not increase its reputation/reward weight.
- Paid placement remains clearly `Sponsorlu` and cannot use reputation badge as disclosure substitute.

## Prohibited products

- Paid “verified/trusted/favorite” badge.
- Review suppression/boost or reputation repair package.
- Ad-spend threshold for organic trust.
- Merchant-funded reward automatically presented as reputation.

## Audit

Any future reputation computation must exclude ad spend/history as positive signal and prove this through contract tests and traceable signal registry.
