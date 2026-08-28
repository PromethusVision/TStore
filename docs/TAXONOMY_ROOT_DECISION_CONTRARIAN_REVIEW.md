# Taxonomy Root Decision Contrarian Review

## Status

**ADVERSARIAL SELF-REVIEW — NOT OWNER APPROVED / NOT CANONICAL**

This review deliberately argues against every recommended Option A. It tests the strongest plausible alternative rather than defending the existing recommendation. No recommendation is changed silently.

## Outcome summary

| Metric | Result |
|---|---:|
| Roots challenged | 18/18 |
| P0/high-impact roots challenged | 15/15 |
| P1 roots challenged | 3/3 |
| Recommendations changed | 0 |
| Confidence lowered | 0 |
| Uncertainty hidden | 0 |

The review found real tradeoffs but no alternative that beats Option A across local physical-retail discoverability, one primary owner, merchant effort, duplication, policy safety and future depth together.

# ROOT-01 — Medical intended-use rule

- **Strongest argument against A:** Evidence-backed status is costly to collect and can delay ordinary wellness inventory.
- **Alternative performs better when:** Option C is operationally simpler in a marketplace with no medical assortment and no ability to validate external registrations.
- **Hidden downside of A:** Moderation becomes a de facto classification service and inconsistent evidence review can still produce unequal outcomes.
- **Merchant confusion:** Merchants may not know whether a claim changes intended use or merely triggers review.
- **Customer confusion:** Similar-looking products can appear in different L1s because one has regulated intended use.
- **Future scalability concern:** Every new regulated family needs a maintained evidence vocabulary.
- **Conclusion:** Keep A. The alternative reduces operational cost by sacrificing safety and regulated-product correctness; exact eligibility remains deferred.

# ROOT-02 — Baby/life-stage ownership rule

- **Strongest argument against A:** “Baby-specific function and schema” can be subjective and create inconsistent override decisions.
- **Alternative performs better when:** Option C is simpler for a form-first catalogue where Anne & Bebek is only a browse projection.
- **Hidden downside of A:** The exception surface may grow whenever merchants add baby wording.
- **Merchant confusion:** A diaper bag and an ordinary bag with changing compartments may be described identically.
- **Customer confusion:** Some baby-labelled apparel/shoes stay in form L1 while feeding/care moves to Anne & Bebek.
- **Future scalability concern:** Each baby-specific exception needs a deterministic lower-level schema.
- **Conclusion:** Keep A. Real feeding/care/safety products need stronger ownership than an optional projection, but the threshold must be explicit.

# ROOT-03 — Technical sport product ownership

- **Strongest argument against A:** Sport shoppers may expect all technical apparel and footwear under Sports regardless of physical form.
- **Alternative performs better when:** Option B performs better in a specialist sports retailer whose catalogue and merchant organization are activity-first.
- **Hidden downside of A:** Cross-domain search/projections become essential, not optional.
- **Merchant confusion:** “Integrated technical system” is less obvious than a simple sport-marketed/not-sport-marketed split.
- **Customer confusion:** A trekking boot is under Shoes while climbing equipment is under Sports.
- **Future scalability concern:** New sports can pressure the integrated-system allowlist.
- **Conclusion:** Keep A. EsnaftaVar is a broad local-retail marketplace, so form ownership is more stable than specialist-retailer organization.

# ROOT-04 — Generic versus domain-specific carrying product

- **Strongest argument against A:** The inseparable/schema-changing threshold can be hard to prove for protective cases, hydration packs and mounted bags.
- **Alternative performs better when:** Option C offers the lowest merchant onboarding cost if Bags has excellent compatibility facets.
- **Hidden downside of A:** Borderline products require manual review and can move as integrations evolve.
- **Merchant confusion:** “Purpose-built” may be mistaken for “integrated.”
- **Customer confusion:** Similar equipment bags can live in Bags or a specialist domain based on internal construction.
- **Future scalability concern:** Device-specific carriers can produce a large compatibility registry.
- **Conclusion:** Keep A. A strict integration test preserves both generic discovery and genuine specialist schemas.

# ROOT-05 — Fixed installation versus movable product

- **Strongest argument against A:** Customers often shop by room/use, not connection method.
- **Alternative performs better when:** Option B can be more intuitive in a home-improvement catalogue organized entirely by room projects.
- **Hidden downside of A:** Visually similar lighting, bathroom and garden products split across L1s.
- **Merchant confusion:** “Fixed” can be unclear for plug-in devices that are mounted to a wall.
- **Customer confusion:** A movable lamp and wired wall light have different owners.
- **Future scalability concern:** Hybrid DIY/pro-installed products need a connection/installation decision tree.
- **Conclusion:** Keep A. Installation and infrastructure are more durable schema boundaries; browse projections can restore room-based discovery.

# ROOT-06 — Manual versus powered household product

- **Strongest argument against A:** Customers may view a manual and electric version as substitutes and expect them together.
- **Alternative performs better when:** Option B works in use-task catalogues where “coffee making” or “cleaning” dominates device lifecycle.
- **Hidden downside of A:** Seller comparison across manual/electric substitutes becomes cross-L1.
- **Merchant confusion:** Battery-assisted accessories and passive replacement parts are borderline.
- **Customer confusion:** Manual and electric grooming/kitchen tools separate despite identical intended outcome.
- **Future scalability concern:** Smart/passive accessories require principal-device rules.
- **Conclusion:** Keep A. Powered lifecycle, safety and compatibility justify the split; search can compare substitutes.

# ROOT-07 — Generic versus fitment/device-specific electronics

- **Strongest argument against A:** Fitment verification adds the highest onboarding burden in the root set.
- **Alternative performs better when:** Option B is simpler for a small electronics-only assortment with no vehicle/tool-specific compatibility engine.
- **Hidden downside of A:** Bad fitment data can misroute products with high confidence.
- **Merchant confusion:** Generic, model-family compatible and installation-specific are not always cleanly separated.
- **Customer confusion:** Electrically similar chargers can live in Electronics, Automotive or Hardware.
- **Future scalability concern:** Vehicle/device/tool registries and versioning become core infrastructure.
- **Conclusion:** Keep A. It has the highest measured ambiguity leverage and preserves owner-final Electronics/Computer boundaries.

# ROOT-08 — PPE and certified protection ownership

- **Strongest argument against A:** Certification may apply at SKU/variant level while taxonomy often groups broader product families.
- **Alternative performs better when:** Option B is easier if the system cannot store verified conformity and intended-use data.
- **Hidden downside of A:** One visual form can fragment across occupational, medical and sports owners.
- **Merchant confusion:** Marketing claims may be mistaken for certified purpose.
- **Customer confusion:** Masks, glasses, gloves or footwear can separate based on evidence invisible on a category card.
- **Future scalability concern:** Standards and evidence vocabularies change and need lifecycle management.
- **Conclusion:** Keep A. The inability to store evidence should block high-risk listing, not force unsafe form-only classification.

# ROOT-09 — Gift purpose and personalization no-duplication

- **Strongest argument against A:** Customers often browse “gifts” as a primary mission, not as an attribute.
- **Alternative performs better when:** Option B can improve seasonal discovery in a campaign-first gift marketplace.
- **Hidden downside of A:** Hediyelik & Parti may look sparse without strong cross-domain projections.
- **Merchant confusion:** Intrinsic keepsake versus ordinary personalized product needs examples.
- **Customer confusion:** A personalized mug is under Kitchen while a keepsake object is under Gift.
- **Future scalability concern:** Multi-line bundles need representation outside a single product leaf.
- **Conclusion:** Keep A. Search, collections and merchant capabilities can support gift missions without duplicating the catalogue.

# ROOT-10 — Product versus service boundary

- **Strongest argument against A:** Local esnaf often sells a product and labor as one inseparable commercial offer.
- **Alternative performs better when:** Option B works in a future unified product-service marketplace with typed offer components.
- **Hidden downside of A:** Current product discovery cannot represent the merchant’s real installed/prepared value proposition.
- **Merchant confusion:** “Separately sellable” may not match how the merchant prices the offer.
- **Customer confusion:** Product appears, but installation/preparation may be discoverable elsewhere or not at all.
- **Future scalability concern:** A future Service taxonomy must link offers without rewriting product ownership.
- **Conclusion:** Keep A for V1. Typed linked offers are a future model; mixing labor into product nodes now creates more leakage.

# ROOT-11 — Weapon-like and hazardous recreation posture

- **Strongest argument against A:** Maintaining an exact allowlist may be more expensive than a categorical V1 ban.
- **Alternative performs better when:** A stricter implementation of A with no exceptions performs best until legal, age, delivery and merchant controls exist; permissive Options B/C require infrastructure not present.
- **Hidden downside of A:** “Future allowlist” can be misread as current eligibility.
- **Merchant confusion:** Legal product possession does not necessarily mean marketplace/channel sale is allowed.
- **Customer confusion:** Familiar sport/toy/party products may be absent despite being sold elsewhere.
- **Future scalability concern:** Laws, product definitions and channel restrictions require continuous item-level maintenance.
- **Conclusion:** Keep A and state that the current allowlist may be empty. Do not promote B or C.

# ROOT-12 — Live and biological product scope

- **Strongest argument against A:** Even allowed plants/seeds create perishability, invasive-species, seasonal and fulfilment risks.
- **Alternative performs better when:** Option C is safer if EsnaftaVar lacks live-goods logistics, provenance and complaint handling.
- **Hidden downside of A:** “Allowed” can be mistaken for operational readiness.
- **Merchant confusion:** Plant, seed, bulb, fertilizer and plant-protection status can overlap in everyday language.
- **Customer confusion:** Some live plants may be visible while animals or certain biological goods are absent.
- **Future scalability concern:** Regional restrictions and species lists need current data.
- **Conclusion:** Keep A as taxonomy posture, but launch eligibility remains fail closed. Option C remains a valid operational launch choice.

# ROOT-13 — Facet or controlled-category exception

- **Strongest argument against A:** The exception test itself can become a subjective governance layer.
- **Alternative performs better when:** Option C is simpler and guarantees no cross-cutting duplicate L2s.
- **Hidden downside of A:** Registries can ossify cultural or audience labels into permanent structures.
- **Merchant confusion:** Popular browse language may feel like a category even when stored as a facet.
- **Customer confusion:** Some familiar labels appear as filters/collections while rare approved exceptions remain categories.
- **Future scalability concern:** Exception governance needs versioned criteria and periodic review.
- **Conclusion:** Keep A. A total ban would erase legitimate schema-bearing structures; the deterministic registry threshold must stay strict.

# ROOT-14 — Published content, supply and kit principal product

- **Strongest argument against A:** Principal user activity can vary by buyer; the same workbook/kit may be read, written in and played with.
- **Alternative performs better when:** Option C is easier for merchants because physical format and ISBN are observable.
- **Hidden downside of A:** Mixed products require additional content/kit-completeness metadata.
- **Merchant confusion:** A guided activity book and a complete experiment kit can include similar components.
- **Customer confusion:** Visually similar products may split between Books, Stationery and Toys.
- **Future scalability concern:** Digital companions and refill components complicate principal-product identity.
- **Conclusion:** Keep A. Format-only rules create systematic misplacement; three borderline products remain manual rather than forced.

# ROOT-15 — Pet nutrition and veterinary-health

- **Strongest argument against A:** Species-first browsing can create broad nodes that hide product intent and repeat shared products.
- **Alternative performs better when:** Option C is simple for a physical pet shop whose merchant inventory is already curated and legally controlled.
- **Hidden downside of A:** Separate species and regulatory axes can be difficult to express in a shallow L2.
- **Merchant confusion:** Food, supplement, hygiene, biosidal and medicine claims may look similar.
- **Customer confusion:** Shared products may be under a shared branch while formulated goods are species-specific.
- **Future scalability concern:** Species, life-stage and medical status create a multidimensional L3/L4 design.
- **Conclusion:** Keep A. Merchant context cannot replace exact product status; the L2 structure remains policy-dependent.

# ROOT-16 — Precious/high-value and protected-material provenance

- **Strongest argument against A:** High-value shopping and seller trust may deserve a visibly separate customer destination.
- **Alternative performs better when:** Option B can work in a specialist luxury/investment marketplace with dedicated custody and authenticity flows.
- **Hidden downside of A:** Important risk differences are hidden behind facets and eligibility state.
- **Merchant confusion:** Finished jewelry, investment products, loose stones and protected materials need different evidence despite shared materials.
- **Customer confusion:** High-value/protected material may not be visible in navigation until filters are used.
- **Future scalability concern:** Provenance, certification, secure delivery and returns are operational systems, not just attributes.
- **Conclusion:** Keep A for a broad local marketplace. Specialist investment/loose-product scope remains explicitly unresolved.

# ROOT-17 — Same-L1 primary intent for future L3/L4

- **Strongest argument against A:** Deterministic single ownership can suppress legitimate multi-intent products.
- **Alternative performs better when:** Option B improves discoverability if the runtime can distinguish one canonical owner from multiple indexed browse parents.
- **Hidden downside of A:** Domain-specific precedence ladders are expensive to author and test.
- **Merchant confusion:** Packaging, form and intended activity can point to different leaves.
- **Customer confusion:** A product appears in one leaf even if another use is equally important.
- **Future scalability concern:** New product forms can invalidate a rigid precedence ladder.
- **Conclusion:** Keep A for canonical ownership, while allowing aliases/projections—not multi-primary storage—to support discovery.

# ROOT-18 — Exact L2 structure and naming acceptance

- **Strongest argument against A:** Guided review still asks the owner to evaluate 22 spines and 40 names; it may remain the main bottleneck.
- **Alternative performs better when:** Option B is faster if launch speed outweighs known structural/naming risk; Option C is defensible only after a product strategy reset.
- **Hidden downside of A:** “High impact” triage can miss a seemingly editorial term that encodes scope.
- **Merchant confusion:** Proposal names may change after merchants begin mapping inventory if review is delayed.
- **Customer confusion:** Mixed naming styles persist until the final ballot is completed.
- **Future scalability concern:** Late edits increase stable-ID and migration cost once runtime begins.
- **Conclusion:** Keep A. Bulk candidates and priority rounds reduce the burden without pretending that 224 nodes can be auto-finalized.

## Recommendation-change audit

| Root set | Before contrarian review | After contrarian review | Change |
|---|---|---|---|
| ROOT-01–ROOT-18 | Option A recommended | Option A recommended | NONE |

No recommendation changed because every alternative won on one dimension by losing a higher-priority constraint. The closest alternatives were:

- ROOT-12 Option C for an operations-limited V1 launch;
- ROOT-10 Option B for a future typed product-service offer model;
- ROOT-17 browse projections resembling multi-parent discovery, while retaining one canonical owner.

These are recorded as implementation/launch considerations, not recommendation changes.

`CONTRARIAN_REVIEW: PASS`

`ROOTS_CHALLENGED: 18/18`

`RECOMMENDATIONS_CHANGED: 0`

`OWNER_FINALIZATION: NOT_PERFORMED`
