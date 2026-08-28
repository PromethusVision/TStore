# EsnaftaVar Primary / Secondary Merchant Sector Model

**State:** PROPOSED FOR OWNER REVIEW — CONCEPTUAL ONLY

## 1. Recommendation

Every public-facing merchant location should have:

- exactly **one required primary sector**;
- **zero to three secondary sectors**;
- a separate `RETAIL`, `SERVICE` or `MIXED` operating model;
- separate policy/verification flags.

This follows the local-discovery principle that a category describes what the
business *is*, not every product or service it has. Google Business Profile likewise
uses one primary category and recommends only a few additional categories rather
than one for every offering ([official guidance](https://support.google.com/business/answer/7249669?hl=en), [representation rules](https://support.google.com/business/answer/3038177?hl=en)). The exact EsnaftaVar limit remains an owner decision; **three** is the proposed anti-abuse maximum.

## 2. Primary-sector test

Select the sector that best satisfies all of the following:

1. completes “Bu işletme bir …” naturally;
2. matches the storefront/signage and customer expectation;
3. describes the main durable commercial proposition, not a seasonal shelf;
4. normally represents the largest revenue/activity share;
5. remains true even when individual products change;
6. has the strongest required licence/verification relationship if the identity is
   regulated.

Revenue is evidence, not the sole rule. A newly opened specialist optician does not
become a generic accessories shop because early sales are low.

## 3. Secondary-sector eligibility

A secondary sector is permitted only when the merchant has a sustained,
customer-facing business line matching that sector. At least two of these evidence
signals should normally be present:

- dedicated signage, counter, workshop or staffed department;
- a material and persistent catalog/service range;
- separate advertised hours, service menu or merchant proposition;
- meaningful revenue/activity share;
- merchant documentation or regulated authorization where applicable;
- customers can intentionally visit for that business line.

A handful of products, one service, search keywords, a brand dealership, a delivery
method or a future plan is insufficient.

## 4. Conceptual validation

| Rule | Validation result |
|---|---|
| Primary required | Reject publish if no active assignable leaf is selected. |
| One primary | Reject more than one primary per location/effective period. |
| Secondary maximum | Reject a fourth active secondary; direct merchant to review primary identity and catalog. |
| Distinctness | Reject duplicate primary/secondary IDs. |
| Active leaf | Reject family, grouping, inactive or retired nodes. |
| Plausibility | Warn or review combinations with no approved adjacency/relationship. |
| Evidence | Ask for business-line evidence when a combination is unrelated or regulated. |
| Policy | Sector selection never bypasses merchant/product verification. |
| History | Version material changes; never rewrite past analytics silently. |

The future adjacency matrix should classify a pair as:

- `COMMON` — ordinary local combination;
- `PLAUSIBLE_WITH_EVIDENCE` — allowed after a short explanation/evidence;
- `REGULATED_REVIEW` — verification required;
- `UNRELATED_REVIEW` — do not self-publish without manual review;
- `PROHIBITED_COMBINATION` — only when a later explicit policy establishes it.

No matrix is implemented here.

## 5. Representative decisions

| Merchant reality | Primary | Secondary | Why |
|---|---|---|---|
| Kırtasiye with a meaningful book department | Kırtasiye | Kitapçı | Customers visit for both; individual books still use Product Taxonomy. |
| Bookstore carrying notebooks near checkout | Kitapçı | None | Shelf stock is not a second business identity. |
| Telefon sales plus full repair workshop | Telefoncu & GSM Mağazası | Telefon & Elektronik Teknik Servisi | Durable retail and service propositions coexist; operating model becomes `MIXED`. |
| Computer shop carrying phone chargers | Bilgisayarcı | None | Cross-L1 inventory is normal and does not imply Telefoncu. |
| Florist with a sustained gift section | Çiçekçi | Hediyelik Eşya Mağazası | Both are customer-facing lines. |
| Florist adding gift ribbon | Çiçekçi | None | Packaging is inventory/capability. |
| Jewellery store with a watch counter | Kuyumcu | Saatçi | Common adjacent retail lines; kuyum verification remains. |
| Market with staffed deli counter | Market, Bakkal & Süpermarket | Şarküteri | Department is durable and customer-facing. |
| Market selling packaged salami | Market, Bakkal & Süpermarket | None | Product assortment alone is insufficient. |
| Nalbur with electrical-installation specialist counter | Nalbur & Hırdavatçı | Elektrik Malzemeleri Satıcısı | Plausible adjacent business line. |
| Beauty salon selling cosmetics | Güzellik Salonu | None by default | Incidental product sales do not create a cosmetic-store identity. |
| Cosmetics shop operating a visible beauty salon | Kozmetik & Kişisel Bakım Mağazası | Güzellik Salonu | Secondary is owner-confirmed exact leaf; hygiene/policy gates remain. |

## 6. Branch and chain rule

Classification attaches to a branch/location. Same-format chain branches normally
share a primary sector; a different-format branch may differ. A separately owned
business inside the same address must be a separate merchant record, not an
additional sector of the host.

## 7. Suggested-sector behavior

Catalog composition, business name, NACE/profession evidence and customer search
signals may later produce **suggestions**. They must not:

- auto-change primary sector;
- infer a regulated authorization;
- create a secondary for every Product L1 sold;
- use merchant sector to reclassify products;
- publish an unreviewed `Other` label as a new canonical node.

## 8. Corrections and changes

- A simple wrong-selection correction may be self-service if the target is normal
  and adjacent.
- Material changes are effective-dated and retain prior history.
- Entry into a regulated sector requires the applicable review.
- Repeated unrelated changes or keyword-like selections route to manual review.
- A sector split/merge uses stable-ID successor rules rather than rewriting old
  assignments.

## 9. Open owner decisions

1. Approve the proposed secondary maximum of three.
2. Define the minimum evidence threshold for `PLAUSIBLE_WITH_EVIDENCE`.
3. Decide whether common combinations can publish immediately or need sampling.
4. Assign the operational owner for regulated-sector verification.
5. Decide whether customer-facing profiles show all secondaries or only the most
   relevant one/two.

`PRIMARY_SECONDARY_SECTOR_MODEL: PROPOSED_FOR_OWNER_REVIEW`

`MULTI_PRODUCT_L1_MERCHANT_SUPPORT: PASS`
