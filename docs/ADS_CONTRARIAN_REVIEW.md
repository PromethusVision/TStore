# Sponsored Advertising — Contrarian Review

**State:** CHALLENGE FOR PRODUCT OWNER REVIEW
**Scope:** Deliberately argues against premature advertising implementation. No owner decision, financial promise, or runtime change.

## 1. Executive Challenge

EsnaftaVar may not need an advertising engine for its first commercial phase. A small Esenler pilot has thin merchant supply, limited customer traffic, incomplete merchant/catalog foundations, and a trust promise centered on nearby real shops. Advertising could add more policy, billing, fraud, ranking, support, and privacy cost than revenue or customer value.

The foundation documents make a safer ad system conceivable; they do not prove that building it now is the correct business decision.

## 2. Do We Need an Auction at All?

Probably not for V1, and possibly not for a long time.

- Thin local auctions may have few eligible merchants, making “market price” unstable or meaningless.
- A bid can dominate attention even when relevance evidence is weak unless many guardrails exist.
- Merchants need understandable spend, but auctions introduce reserve prices, rank thresholds, quality weighting, pacing interactions, disputes, and strategic behavior.
- Auction optimization benefits from volume and conversion evidence EsnaftaVar does not yet have.
- A non-auction rotation or fixed campaign makes cost, fairness, and explanation easier to audit.

The counterpoint is that fixed prices can underprice scarce high-intent inventory and require manual price setting. That is still a preferable early uncertainty to financial/ranking complexity masquerading as precision.

## 3. Could Sponsored Ranking Damage Trust?

Yes, even with a visible `Sponsorlu` label.

Customers may reasonably interpret local discovery as “the closest,” “the best match,” or “the best available price.” A paid listing placed above a nearer or cheaper organic result can feel like product betrayal, particularly when the user does not understand the distinction between relevance and payment.

Disclosure is necessary but not sufficient. Trust also depends on:

- the sponsored result being truly relevant and available;
- real distance, merchant, price, and stock facts remaining visible;
- organic results not being removed or secretly reordered;
- low density and frequency;
- no “recommended,” “verified,” “best,” or “special price” implication without independent evidence;
- fast, exact organic fallback when ads fail.

The 150-case customer trust stress test intentionally surfaced explanation, nearest, endorsement, price, verification, and disclosure-persistence risks. Automated rows are design evidence, not customer comprehension evidence. Real moderated usability testing remains necessary.

## 4. Is Seller-Comparison Sponsorship Too Aggressive?

For V1, yes.

A seller-comparison surface carries an unusually strong expectation of neutral comparison across price, distance, availability, and seller quality. Even one clearly labeled paid row above the list may anchor customers and disadvantage nearer/cheaper sellers. The placement could also look like platform endorsement of that seller for the exact product.

Recommendation: exclude seller-comparison sponsorship from V1. If reconsidered later, test only one exact canonical product/variant/listing row, preserve the full organic order, show real comparison facts, and run a separate owner/trust gate.

## 5. Is the Operational Burden Worth V1 Revenue?

Unknown, with evidence currently leaning against broad implementation.

Advertising requires more than a campaign form and a ranking score:

- product and merchant policy review;
- regulated-domain evidence and renewals;
- creative/claim moderation;
- budget reservation, reconciliation, credits, and disputes;
- invalid-traffic detection and appeals;
- privacy controls and data retention;
- customer report/hide handling;
- merchant reporting freshness and support;
- ranking/disclosure monitoring;
- incident response and kill switch;
- finance/accounting/tax ownership;
- Development and Production operational acceptance.

A low-volume pilot may be too small to automate economically but too financially sensitive to operate casually. Manual operations are safer only if the cohort remains deliberately tiny.

## 6. Could Fixed Sponsored Slots Be Safer?

They can be safer than an auction but are not automatically safe.

Benefits:

- predictable merchant cost;
- easier hard-cap and under-delivery handling;
- simpler explanation and reconciliation;
- less strategic bidding;
- easier new-merchant rotation.

Risks:

- fixed slots can become permanent incumbency;
- a prepaid slot may pressure the platform to serve an irrelevant ad;
- scarcity allocation remains an owner decision;
- fixed placement can still damage organic trust;
- “guaranteed” delivery is unsafe when eligible local inventory/traffic is unknown.

Safer candidate: a non-guaranteed, non-auction flat promotion with hard total cap, paced fair rotation, strict eligibility, and no charge/credit for under-delivery. Do not promise a position or impression count before evidence exists.

## 7. Is Advertising Premature for the Esenler Pilot?

Likely yes unless the pilot's purpose is explicitly to validate the advertising hypothesis.

The core product still benefits first from:

- trustworthy canonical catalog/listing identity;
- accurate price/stock/shop availability;
- merchant product management and analytics;
- strong organic discovery and local relevance;
- merchant sector/policy verification;
- enough merchants and customers to produce useful matching density;
- evidence that merchants will pay for incremental discovery.

Ads introduced before those foundations may hide organic quality problems, produce weak delivery, and confuse merchants about whether poor outcomes came from the product, inventory, audience size, or campaign.

## 8. Could Merchant Subscription Be Better Initially?

Possibly.

A simple subscription can fund access to clearly defined merchant tools without inserting payment into customer ranking. It may be easier to explain, forecast, support, and reconcile. It also avoids click-fraud and auction mechanics.

However, subscription creates its own risks:

- merchants may not see value before customer demand exists;
- one price may be unfair across shop sizes/sectors;
- feature gating can disadvantage small merchants;
- subscription must not buy organic rank, trust, reviews, or verification;
- churn may be high if catalog/analytics foundations are incomplete.

Subscription is not automatically the answer, but it is a credible lower-complexity alternative worth testing before ads.

## 9. Falsification Tests

Before an ads build is approved, seek evidence that could disprove it:

1. Do merchants prefer a predictable subscription or fixed promotion over performance pricing?
2. Do customers correctly identify `Sponsorlu` units and still understand nearest/price/organic order?
3. Is there enough eligible query × location × listing density for campaigns to deliver without broadening relevance?
4. Can a manual policy/support team handle expected review and dispute volume?
5. Does a shadow ranker improve merchant discovery without materially reducing organic satisfaction?
6. Are expected revenues meaningfully above billing, fraud, moderation, support, and engineering costs?
7. Can new merchants receive fair exposure without sacrificing relevance?
8. Does the core organic product already retain customers and merchants?

Failure to answer these is evidence for postponement, not a reason to implement more machinery.

## 10. Contrarian Recommendation

Prefer subscription/organic discovery or no monetized promotion at initial release. Complete catalog, merchant, organic search, policy, and analytics foundations first. If the owner still wants ad learning, run a Development-only shadow experiment followed by a tiny, non-auction, Search-only, low-risk, manually reviewed pilot. Keep seller comparison, behavioral targeting, auctions, CPA, and multi-surface expansion out.

The appropriate outcome of owner review may be **DO NOT BUILD ADS YET**. This foundation remains useful as a future risk map even if that is the decision.
