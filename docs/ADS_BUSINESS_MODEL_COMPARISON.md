# EsnaftaVar Monetization — Business Model Comparison

**State:** PROPOSED FOR PRODUCT OWNER REVIEW  
**Scope:** Qualitative business-model comparison. No price, forecast, revenue promise, payment implementation, or owner-final choice.

## 1. Context and Unknowns

EsnaftaVar connects customers with nearby physical merchants. Its initial economics are constrained by local density: customer demand, eligible listings, merchant onboarding, inventory freshness, and measurable offline outcomes must overlap in the same place and time.

The repository does not provide validated values for merchant willingness to pay, traffic, conversion uplift, acquisition cost, support cost, fraud loss, churn, or regulatory operations. Any exact price or revenue projection would therefore be invented. This comparison identifies what must be measured.

## 2. Models Compared

| Model | Customer ranking impact | Merchant price predictability | Platform operations | Thin-market fit | Key risk |
|---|---|---|---|---|---|
| Subscription only | None, if subscription never buys rank | High | Medium: entitlement, invoicing, churn/support | Potentially good if merchant tools have standalone value | Merchants pay before demand/value is proven |
| Ads only | Direct paid-placement impact | Medium/low depending pricing | Very high: policy, ranking, billing, fraud, reporting, disputes | Weak until local intent/inventory density exists | Trust and operating cost exceed revenue |
| Subscription + ads | Both feature entitlement and paid placement | Low/medium | Highest: two ledgers, packaging, fairness, support | Poor for first pilot | Small merchants face layered paywalls/pay-to-be-seen perception |
| Fixed sponsored placement | Direct but bounded paid placement | High | High: eligibility, allocation, delivery, credits, trust | Better than auction for a controlled cohort | Incumbency, under-delivery, pressure to serve irrelevant ads |
| Auction ads | Direct dynamic paid placement | Low | Very high: auction, quality, reserves, pacing, fraud, explanations | Poor in thin local markets | Unstable price/allocation and opaque merchant outcomes |

## 3. Subscription Only

### Potential strengths

- does not require payment to alter customer discovery order;
- predictable recurring merchant cost and platform revenue timing;
- simpler invoice/support story than click/impression billing;
- can fund real merchant value such as catalog management or analytics;
- no click-fraud or auction gaming.

### Risks

- merchant tools and customer reach may be too immature to justify payment;
- a single plan can be inequitable across merchant size and sector;
- feature gating may harm small/local merchant inclusion;
- churn can mask whether the root issue is low demand, poor catalog data, or pricing;
- subscription must not imply verification, reputation, reviews, or organic rank.

### Evidence needed

Merchant interviews and willingness-to-pay tests tied to concrete tools; cohort retention; support cost; perceived fairness; customer demand delivered independent of payment.

## 4. Ads Only

### Potential strengths

- merchants can pay for a specific distribution objective rather than a bundle;
- entry can be optional with no recurring commitment;
- contextual search demand can create understandable promotion value;
- delivery metrics may support iteration.

### Risks

- weak traffic and sparse eligible inventory cause under-delivery;
- policy, disclosure, ranking, billing, fraud, and dispute systems are mandatory before meaningful scale;
- offline conversion is difficult to attribute and should not be promised;
- paid placement can damage the core local-trust proposition;
- ad revenue can pressure the platform to broaden relevance or density.

### Evidence needed

Shadow demand/inventory density; customer disclosure and ranking comprehension; incremental merchant discovery; invalid-traffic rate; operational cost per campaign; under-delivery and dispute rates.

## 5. Subscription + Ads

### Potential strengths

- diversified monetization;
- subscription can cover foundational tools while ads price optional promotion;
- segments may choose different value propositions.

### Risks

- merchants may perceive “pay to join, then pay to be visible”;
- package/entitlement interactions create fairness and explanation complexity;
- two billing systems compound support, accounting, refund, and tax work;
- subscription tier must not secretly improve organic or paid quality scores;
- unsuitable before either model has independent evidence.

### Evidence needed

Validated value and unit economics for each model separately; merchant comprehension; no coercive bundling; clear separation of subscription entitlements, organic rank, and ad delivery.

## 6. Fixed Sponsored Placement

This means a non-auction fixed/flat promotion opportunity, not a guaranteed position or inventory promise.

### Potential strengths

- most understandable ad price for a low-volume pilot;
- hard budget limits and reconciliation are simpler;
- rotation can deliberately include new merchants;
- easier to explain than dynamic bidding.

### Risks

- platform must set scarcity price without market evidence;
- “fixed slot” can become incumbent reservation or geographic exclusivity;
- guaranteed delivery is unsafe when relevant demand is unknown;
- merchant may assume payment overrides proximity/relevance;
- still requires all core ad policy, disclosure, fraud, and support controls.

### Evidence needed

Eligible opportunity volume, fill and under-delivery, merchant value perception, fair allocation, customer trust, support workload, and a clear credit/no-charge contract.

## 7. Auction Ads

### Potential strengths

- can allocate scarce inventory among multiple eligible merchants;
- may discover willingness to pay at sufficient scale;
- supports flexible budgets when backed by mature quality/ranking systems.

### Risks

- local cohorts may not have enough bidders for meaningful competition;
- price/rank becomes difficult for small merchants to predict;
- auctions need bid validation, reserves, quality scores, pacing, invalid traffic, settlement, explanation, and anti-collusion controls;
- a high bid must never overcome relevance, policy, locality, disclosure, or fairness gates;
- complexity can create false confidence without incremental value.

### Evidence needed

Sustained multi-bidder density per eligible opportunity, proven non-auction demand, stable quality signals, merchant bidding literacy, fraud/settlement operations, and controlled experiments demonstrating benefit over rotation.

## 8. EsnaftaVar-Specific Evaluation Criteria

Before choosing a model, measure:

1. active customers and high-intent discovery requests by local area;
2. active shops and fresh eligible listings per request;
3. merchant catalog completeness and price/stock accuracy;
4. incremental visits or verified outcomes without claiming causation prematurely;
5. merchant willingness to pay and preferred price certainty;
6. customer trust/disclosure comprehension and organic satisfaction;
7. review, support, fraud, billing, privacy, and engineering cost;
8. under-delivery, disputes, refunds/credits, churn, and concentration;
9. small/new merchant fairness;
10. sensitivity of results to product/merchant policy exclusions.

Revenue alone is insufficient; margin after operating/risk costs and impact on the core marketplace must be considered.

## 9. Comparative Recommendation

| Stage | Recommended candidate | Rationale |
|---|---|---|
| Initial release | Organic discovery plus optional subscription research; possibly no monetization until value is proven | Lowest customer-ranking risk and simpler evidence collection |
| Pre-ad learning | Development-only shadow sponsored rank/measurement | Tests relevance, supply, density, fairness, and operations without customer billing |
| Small paid pilot, if approved | Non-auction flat/fixed sponsored listing with hard cap and under-delivery protection | Most understandable bounded ad model |
| Later | Subscription + optional ads only after each is independently validated | Avoids premature layered monetization |
| Not V1 | Auction or CPA | Insufficient density, outcome integrity, and operational maturity |

## 10. Owner Decisions and Experiment Gates

1. Is monetization required at initial launch?
2. Which merchant tool has enough standalone value for subscription testing?
3. Is customer-facing paid ranking acceptable at all?
4. What shadow/pilot evidence threshold justifies real billing?
5. What merchant cohort, duration, budget cap, and support capacity define a safe experiment?
6. What customer-trust or merchant-fairness result automatically stops the pilot?

## 11. Conclusion

There is no evidence-backed basis here for selecting ads, subscription, a price, or a revenue forecast as final. The lowest-complexity path is to validate organic marketplace value and subscription willingness first. If advertising learning is still desired, use shadow measurement and then a tightly bounded non-auction flat pilot. Auction and combined subscription-plus-ads models should wait for density and operating evidence.

