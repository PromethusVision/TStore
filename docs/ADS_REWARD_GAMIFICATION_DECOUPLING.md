# Sponsored Advertising — Reward and Gamification Decoupling

**State:** PROPOSED FOR PRODUCT OWNER REVIEW
**Scope:** Design only; no reward, loyalty, advertising, billing, or verified-purchase runtime change.

## 1. Purpose

This document prevents sponsored advertising from becoming an implicit source of rewards, merchant reputation, product quality signals, or verified-purchase status. Ads buy eligible distribution only; they do not buy trust.

## 2. Independence Rule

Advertising, rewards/gamification, verified purchase, reviews, and merchant reputation are independent systems with separately owned identities and rules.

| System | What it may establish | What it must not establish |
|---|---|---|
| Advertising | Eligible paid placement and its delivery evidence | Quality, verification, popularity, purchase, or reward entitlement |
| Rewards/gamification | Benefits from explicitly approved customer actions | Paid-placement eligibility or ranking priority |
| Verified purchase | Evidence that the canonical purchase verification contract succeeded | Ad billing, endorsement, or guaranteed satisfaction |
| Reviews/reputation | Customer feedback and independently defined trust signals | A benefit purchasable through ad spend |
| Organic discovery | Relevance/locality/order under organic rules | Hidden sponsored preference |

## 3. V1 Prohibited Couplings

The following are outside the proposed V1 and should fail closed:

- rewarding a customer merely for viewing or clicking an ad;
- “watch an ad to earn” mechanics;
- granting merchant badges, stars, ranking reputation, or verification through spend;
- selling review visibility or review suppression;
- treating ad impressions/clicks as verified purchase evidence;
- charging automatically for an offline action inferred only from proximity;
- increasing organic rank because a merchant advertised;
- allowing a campaign to modify loyalty balances or voucher eligibility;
- presenting a sponsored listing as “recommended”, “verified”, “best”, or “popular” without an independent factual basis.

## 4. Permitted Independent Interactions

Advertising may report aggregate, privacy-minimized outcomes that happened under another system's authoritative rules. Examples:

- an ad click is followed by a separately verified purchase;
- a verified purchase independently qualifies for an owner-approved loyalty rule;
- a campaign report shows attributed verified purchases as a non-billable outcome signal;
- fraud systems compare ad traffic with valid purchase evidence.

These interactions require distinct event IDs and provenance. The reward or verified-purchase engine makes its own decision; the ad system never creates the qualifying fact.

## 5. Event Boundary

A cross-system event should conceptually include:

- source event ID and source system;
- independent subject identity under that system's rules;
- campaign/impression/click references only when legitimately attributable;
- event timestamp and integrity state;
- consent/privacy basis where applicable;
- `billable` status determined solely by the advertising billing contract;
- `reward_eligible` status determined solely by the reward contract;
- `verified_purchase` status determined solely by the purchase contract.

No single boolean should stand for all three outcomes.

## 6. Verified Purchase Rule

If a customer reaches a shop through a sponsored listing and later completes a verified purchase:

1. purchase verification follows the unchanged purchase/QR rules;
2. attribution may reference the earlier ad event within an approved window;
3. the campaign may report the attributed result;
4. V1 billing must not convert it into CPA without a separate owner decision and fraud/dispute contract;
5. any reward is evaluated independently and must be the same as for an equivalent organic journey.

An advertised purchase must not yield more review weight, merchant reputation, or reward value solely because it was sponsored.

## 7. Abuse Risks and Controls

| Risk | Required control |
|---|---|
| Click/reward farming | No V1 reward for impression/click; deduplicate events; invalid-traffic review. |
| Merchant self-interaction | Exclude merchant/staff-linked traffic from billable and reward paths where detectable. |
| Collusive verified purchases | Purchase system fraud review remains authoritative; ads cannot override it. |
| Paid trust laundering | Separate labels, metrics, badges, reputation, and moderation decisions. |
| Dark-pattern engagement | No forced ad interaction or reward penalty for declining ads. |
| Reward-driven child targeting | Behavioral targeting and ad-for-reward mechanics remain deferred and policy-reviewed. |
| Double benefit | Idempotent reward and attribution event handling; separate ledgers. |

## 8. Customer Experience

- `Sponsorlu` disclosure remains visible regardless of reward or loyalty context.
- A reward badge must describe the reward rule, not imply that the advertisement is endorsed.
- Declining personalization or reporting controls must not remove earned non-ad rewards.
- Organic access to the same discovery surface must remain available.
- Ad-block/report controls must not reduce customer loyalty standing.

## 9. Merchant Experience

Campaign reporting may show attributed outcomes but must clearly distinguish:

- delivered impressions;
- valid interactions;
- attributed, independently verified purchases;
- billable events;
- invalid or disputed activity;
- non-ad reward events.

Merchants must not be promised that spending buys reputation, verified status, reviews, or organic placement.

## 10. Future Decision Gate

Any future proposal to reward ad viewing/clicking requires a separate owner-final decision covering:

- customer value and informed choice;
- child and vulnerable-user protection;
- consent and privacy basis;
- fraud economics and device/account farms;
- advertiser billing fairness;
- tax/accounting treatment;
- reward expiry and dispute handling;
- disclosure that the engagement is incentivized;
- impact on organic discovery and trust.

Until that gate is complete, such mechanics remain prohibited rather than merely unimplemented.

## 11. Open Owner Decisions

1. May attributed verified purchases appear in merchant reports before any CPA billing exists?
2. Which aggregate thresholds are required before reward/attribution metrics are displayed?
3. Should merchants be able to exclude reward-associated traffic from campaign reporting?
4. Is any future loyalty benefit allowed for an advertised journey if it is exactly equal to the organic journey benefit?

## 12. Recommendation

Launch advertising and rewards as fully decoupled V1 systems. Allow only privacy-minimized reporting of independently verified outcomes. Do not reward impressions/clicks, sell reputation, or change reward value based on sponsorship.
