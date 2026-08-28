# Sponsored Advertising — Root Owner Decisions

**State:** OPEN — PRODUCT OWNER DECISIONS REQUIRED
**Scope:** Decision digest only. Recommendations are research/design proposals, not owner choices or implementation authority.

## 1. Priority Meaning

- **P0:** changes whether/what the advertising product is and its core trust/policy boundary.
- **P1:** changes the operating, financial, ranking, evidence, or merchant contract.
- **P2:** changes implementation detail, explanation, controls, retention, or service levels after the root shape is chosen.

No item below is marked approved. A recommendation records the design team's preferred option for owner review.

## P0 — Canonical/product launch decisions

### P0-01

- **QUESTION:** What is the launch business model?
- **OPTIONS:** A subscription/organic only; B non-auction sponsored-listing pilot; C full ads product.
- **RECOMMENDATION:** A first; B only after gates. Do not choose C for V1.
- **WHY:** A small local pilot may not justify ad operations; subscription provides simpler economics.
- **TRADEOFF:** Delays ad revenue/learning but protects trust and reduces policy/billing burden.
- **AFFECTED SYSTEMS:** Product, Finance, Merchant, Customer, Operations

### P0-02

- **QUESTION:** What is the V1 sponsored object?
- **OPTIONS:** A SHOP_LISTING; B merchant/shop; C canonical product/variant; D banner/creative.
- **RECOMMENDATION:** A — exact active SHOP_LISTING.
- **WHY:** It is the object that owns shop-specific price, stock, availability, seller, and destination.
- **TRADEOFF:** Requires catalog/listing identity readiness and reduces broad awareness flexibility.
- **AFFECTED SYSTEMS:** Catalog, Campaign, Eligibility, Ranking, Client, Reporting

### P0-03

- **QUESTION:** Which customer surfaces launch?
- **OPTIONS:** A Search only; B Search + Category; C Search + Category + Nearby + Home; D no ads.
- **RECOMMENDATION:** D until ready, then A for a controlled pilot.
- **WHY:** Search has the clearest explicit intent; every additional surface adds trust and ranking ambiguity.
- **TRADEOFF:** Lower reach and slower economics learning.
- **AFFECTED SYSTEMS:** Search, Customer UI, Ranking, Measurement

### P0-04

- **QUESTION:** May seller-comparison rows be sponsored?
- **OPTIONS:** A no; B one exact-product sponsored seller row with strict disclosure; C multiple paid sellers.
- **RECOMMENDATION:** A for V1; reconsider B only after separate trust acceptance.
- **WHY:** Seller comparison is expected to be price/distance/availability-led and is the most aggressive trust boundary.
- **TRADEOFF:** Foregoes a commercially valuable high-intent placement.
- **AFFECTED SYSTEMS:** Product details, Seller comparison, Ranking, Disclosure

### P0-05

- **QUESTION:** How may paid rank interact with proximity and organic order?
- **OPTIONS:** A spend can dominate; B relevant eligible sponsor may enter a bounded slot while real distance remains visible; C nearest-only ads.
- **RECOMMENDATION:** B, with hard relevance/locality floors and untouched organic order.
- **WHY:** Money must not manufacture relevance or conceal distance; exact-nearest is not always the only relevant choice.
- **TRADEOFF:** Limits inventory and may under-deliver campaigns.
- **AFFECTED SYSTEMS:** Ranking, Geo, Search, Customer trust

### P0-06

- **QUESTION:** What location scope is allowed?
- **OPTIONS:** A precise continuous tracking; B coarse request-time location/radius; C shop district only; D none.
- **RECOMMENDATION:** B with permission/minimization and C fallback where truthful.
- **WHY:** Local discovery benefits from proximity without building a location history.
- **TRADEOFF:** Coarser targeting reduces precision and delivery volume.
- **AFFECTED SYSTEMS:** Privacy, Geo, Client permissions, Ranking

### P0-07

- **QUESTION:** Which product and merchant cohorts are eligible?
- **OPTIONS:** A all non-illegal inventory; B narrow explicit allowlist; C broad L1/sector rules; D no ads.
- **RECOMMENDATION:** B, starting with low-risk exact product types and verified merchants.
- **WHY:** Broad taxonomy membership cannot prove product or merchant eligibility, especially in regulated/high-risk domains.
- **TRADEOFF:** Manual policy work and smaller pilot supply.
- **AFFECTED SYSTEMS:** Policy, Catalog, Merchant identity, Admin, Legal review

### P0-08

- **QUESTION:** What is the V1 pricing/billing basis?
- **OPTIONS:** A flat daily/fixed promotion; B CPC; C qualified impression; D CPA; E no real billing/shadow pilot.
- **RECOMMENDATION:** E first, then A if owner approves real pilot.
- **WHY:** Offline attribution and invalid traffic make performance billing fragile before evidence exists.
- **TRADEOFF:** Less familiar optimization and limited revenue upside.
- **AFFECTED SYSTEMS:** Billing, Budget, Merchant UX, Finance, Measurement

### P0-09

- **QUESTION:** Does V1 use an auction?
- **OPTIONS:** A no auction/rotation; B fixed-price score ordering; C first-price; D second-price/GSP.
- **RECOMMENDATION:** A; keep auction research only.
- **WHY:** Local thin markets, fairness, explainability, and operations do not justify auction complexity.
- **TRADEOFF:** Price discovery is manual and supply may be under-monetized.
- **AFFECTED SYSTEMS:** Pricing, Ranking, Budget, Merchant UX

### P0-10

- **QUESTION:** Is behavioral/personal profiling allowed?
- **OPTIONS:** A contextual + coarse location only; B first-party behavioral profile; C retargeting/lookalikes; D third-party data.
- **RECOMMENDATION:** A only for V1.
- **WHY:** It minimizes privacy risk and keeps ranking explainable; sensitive/child targeting concerns remain fail-closed.
- **TRADEOFF:** Lower targeting precision and possible revenue impact.
- **AFFECTED SYSTEMS:** Privacy, Identity, Targeting, Legal, Customer controls


## P1 — Operating model decisions

### P1-01

- **QUESTION:** What budget and pacing contract applies?
- **OPTIONS:** A hard total only; B total + daily cap with paced rotation; C auto-expanding budget.
- **RECOMMENDATION:** B; never C without explicit future authority.
- **WHY:** Hard limits and even pacing reduce overspend and early-day exhaustion.
- **TRADEOFF:** May under-deliver when eligible inventory is scarce.
- **AFFECTED SYSTEMS:** Budget ledger, Pacing, Billing, Reporting

### P1-02

- **QUESTION:** What frequency cap applies?
- **OPTIONS:** A none; B per listing/merchant/surface cap; C personalized optimization.
- **RECOMMENDATION:** B using privacy-minimized identifiers and owner-set limits.
- **WHY:** Repetition harms trust and allows large merchants to crowd out others.
- **TRADEOFF:** Lower reach; cap-store outages require fail-closed behavior.
- **AFFECTED SYSTEMS:** Serving, Privacy, Fairness, Analytics

### P1-03

- **QUESTION:** Which merchant eligibility evidence is mandatory?
- **OPTIONS:** A active account only; B active shop + identity + sector-specific verification; C manual whitelist only.
- **RECOMMENDATION:** B, with manual review for launch-sensitive cohorts.
- **WHY:** Self-selected sector or campaign spend cannot establish authorization.
- **TRADEOFF:** Higher onboarding friction and review workload.
- **AFFECTED SYSTEMS:** Merchant, Policy, Admin, Identity

### P1-04

- **QUESTION:** How fresh must listing price/stock/availability be?
- **OPTIONS:** A best effort; B owner-set TTL/version gate; C merchant declaration only.
- **RECOMMENDATION:** B; unknown/stale critical state suppresses the ad.
- **WHY:** A paid placement amplifies harm from nonexistent stock or stale price.
- **TRADEOFF:** Reduced fill rate and stronger catalog dependency.
- **AFFECTED SYSTEMS:** Catalog, Eligibility, Creative, Reporting

### P1-05

- **QUESTION:** What campaign review/lifecycle model launches?
- **OPTIONS:** A publish immediately; B explicit draft/review/scheduled/active/paused/ended states; C admin-operated only.
- **RECOMMENDATION:** B, potentially admin-assisted during pilot.
- **WHY:** Versioned states make policy, edits, schedule, and audit reconstructable.
- **TRADEOFF:** More merchant UX and operations work.
- **AFFECTED SYSTEMS:** Campaign, Admin, Merchant app, Audit

### P1-06

- **QUESTION:** What attribution model is acceptable?
- **OPTIONS:** A last click; B last eligible ad interaction within a short window; C multi-touch; D no outcome attribution.
- **RECOMMENDATION:** D in shadow, then B for reporting only; no automatic CPA.
- **WHY:** Offline actions are not reliably attributable and verified purchase remains independent.
- **TRADEOFF:** Outcome reporting is conservative and less marketable.
- **AFFECTED SYSTEMS:** Measurement, Verified purchase, Privacy, Reporting

### P1-07

- **QUESTION:** How are under-delivery, credits, refunds, and disputes handled?
- **OPTIONS:** A no refunds; B automatic proportional credit; C manual evidence-based reconciliation; D guaranteed impressions.
- **RECOMMENDATION:** C for pilot, evolving to deterministic B where evidence supports it; no guarantees.
- **WHY:** Merchants need financial fairness without promising unavailable inventory.
- **TRADEOFF:** Manual operations do not scale.
- **AFFECTED SYSTEMS:** Billing, Finance, Support, Audit

### P1-08

- **QUESTION:** How is invalid traffic treated?
- **OPTIONS:** A charge unless proven fraud; B hold/exclude suspicious events with appeal; C block merchant automatically.
- **RECOMMENDATION:** B with conservative thresholds and human review for material actions.
- **WHY:** Self-clicks, bots, duplicates, and collusion must not become revenue or opaque punishment.
- **TRADEOFF:** Held reporting/revenue and false-positive review cost.
- **AFFECTED SYSTEMS:** Fraud, Billing, Merchant support, Security

### P1-09

- **QUESTION:** How are quality and new-merchant fairness balanced?
- **OPTIONS:** A historic performance dominates; B bounded exploration after hard eligibility; C equal random rotation.
- **RECOMMENDATION:** B with no spend-based trust/reputation advantage.
- **WHY:** New merchants need exposure, but safety/relevance gates cannot be relaxed.
- **TRADEOFF:** Some delivery is intentionally exploratory and less optimized.
- **AFFECTED SYSTEMS:** Ranking, Fairness, Merchant ecosystem, Measurement

### P1-10

- **QUESTION:** What measurement/reporting standard launches?
- **OPTIONS:** A clicks only; B idempotent funnel + explicit freshness/invalid status; C opaque aggregate score.
- **RECOMMENDATION:** B, with minimal data and billing-independent counters.
- **WHY:** A dispute-ready system must separate eligible, render, impression, interaction, billing, and attribution states.
- **TRADEOFF:** Larger event/analytics foundation than a simple click counter.
- **AFFECTED SYSTEMS:** Events, Analytics, Merchant reporting, Billing


## P2 — Implementation-detail decisions

### P2-01

- **QUESTION:** What exact disclosure and explanation copy is used?
- **OPTIONS:** A Sponsorlu only; B Sponsorlu + short reason; C icon/color only.
- **RECOMMENDATION:** B where space allows, with textual Sponsorlu always present.
- **WHY:** Text survives color, accessibility, and learned-interface ambiguity; a reason improves comprehension.
- **TRADEOFF:** Consumes limited UI space and needs localization testing.
- **AFFECTED SYSTEMS:** Customer UI, Accessibility, Legal review, Content

### P2-02

- **QUESTION:** Which customer controls ship?
- **OPTIONS:** A report only; B report + hide ad/merchant + location/privacy controls; C topic preferences.
- **RECOMMENDATION:** B; defer advanced topic controls.
- **WHY:** Customers need meaningful recourse without building behavioral profiles.
- **TRADEOFF:** Control-state and abuse-handling complexity.
- **AFFECTED SYSTEMS:** Customer UI, Privacy, Moderation, Serving

### P2-03

- **QUESTION:** How are taxonomy aliases and target revisions governed?
- **OPTIONS:** A mutable names/paths; B stable IDs + revision + alias history; C free-text only.
- **RECOMMENDATION:** B.
- **WHY:** Renames/moves should not break identity; splits must not silently broaden targets.
- **TRADEOFF:** Depends on stable taxonomy/catalog identity work.
- **AFFECTED SYSTEMS:** Taxonomy, Targeting, Campaign, Audit

### P2-04

- **QUESTION:** What audit retention and role access applies?
- **OPTIONS:** A indefinite broad logs; B purpose-based retention/access classes; C no detailed audit.
- **RECOMMENDATION:** B with owner-approved schedules.
- **WHY:** Billing/policy disputes need evidence, while privacy requires minimization.
- **TRADEOFF:** Retention design and access administration are operational work.
- **AFFECTED SYSTEMS:** Audit, Security, Privacy, Finance, Policy

### P2-05

- **QUESTION:** What advertising data retention applies?
- **OPTIONS:** A retain all raw events; B short raw windows + aggregate retention; C aggregate only.
- **RECOMMENDATION:** B, with precise periods decided through privacy/legal review.
- **WHY:** Short raw evidence aids fraud/disputes without building permanent customer histories.
- **TRADEOFF:** Some long-horizon analysis becomes less precise.
- **AFFECTED SYSTEMS:** Analytics, Privacy, Fraud, Storage planning

### P2-06

- **QUESTION:** Which creative variants are permitted?
- **OPTIONS:** A arbitrary merchant creative; B native listing card from authoritative data; C banner templates.
- **RECOMMENDATION:** B for V1.
- **WHY:** Native creatives reduce false claims, disclosure drift, and moderation surface.
- **TRADEOFF:** Less merchant expression and brand awareness capability.
- **AFFECTED SYSTEMS:** Creative, Catalog, Customer UI, Moderation

### P2-07

- **QUESTION:** Which serving/reporting SLOs and failover thresholds apply?
- **OPTIONS:** A best effort; B explicit latency/error/freshness budgets and organic fallback; C ads block the surface.
- **RECOMMENDATION:** B.
- **WHY:** Ads are optional to discovery and should not degrade the core customer experience.
- **TRADEOFF:** Engineering/operations investment and conservative fallback reduce delivery.
- **AFFECTED SYSTEMS:** Performance, Search, Client, Analytics, Operations


## 2. Decision Count

| Priority | Open decisions |
|---|---:|
| P0 | 10 |
| P1 | 10 |
| P2 | 7 |
| **Total** | **27** |

## 3. Recommended Decision Order

1. Decide whether ads are needed at initial commercial launch.
2. If yes, close P0-02 through P0-10 as one coherent product boundary.
3. Close policy/merchant/listing/billing P1 decisions before schema or UI work.
4. Close P2 wording, control, retention, creative, and SLO contracts before Production acceptance.
5. Record every accepted option in canonical product decisions; recommendations in this document do not become final by implementation.

## 4. Go/No-Go Rule

If a P0 choice remains unresolved, any dependent design remains proposal-only. If merchant/product policy, listing freshness, disclosure, organic fallback, budget integrity, privacy, invalid traffic, billing dispute, or operational kill-switch contracts remain unresolved, customer-facing paid serving should not launch.
