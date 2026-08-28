# EsnaftaVar Merchant / Sector Taxonomy Design Method

**State:** DESIGN CONTRACT — PROPOSED FOR OWNER REVIEW

**Scope:** Merchant/Sector Taxonomy only. No Product Taxonomy, runtime, database,
remote environment, Merchant App, booking or pricing implementation.

## 1. The question this taxonomy answers

Merchant Taxonomy answers **“Bu işletme ne tür bir işletme?”** Product Taxonomy
answers **“Bu ürün nedir?”** Facets answer **“Bu ürünün veya işletmenin hangi
özellikleri var?”** These are independent systems.

Consequences:

- a `Market, Bakkal & Süpermarket` may sell food, cosmetics, stationery, household
  goods and pet products without becoming five product categories;
- a product keeps exactly one canonical Product Taxonomy leaf regardless of which
  merchant sells it;
- a merchant sector may suggest likely product areas, but never owns, rewrites or
  authorizes product placement;
- a service, licence, delivery mode, brand, neighbourhood or price band is not a
  merchant sector merely because customers search for it.

## 2. Evidence standard

The design uses four kinds of evidence:

1. **Current official activity language.** TÜİK's NACE Rev.2.1 classification and
   the Ministry of Trade's 20 May 2026 profession/NACE list reveal formal activity
   boundaries. NACE is evidence, not a customer-facing navigation tree.
2. **Local professional language.** TESK profession branches validate terms that
   Turkish merchants recognize; for example, its list distinguishes male barber,
   women's hairdresser and beauty salon activities.
3. **Local-discovery practice.** Google Business Profile recommends a primary
   category that describes what the business *is*, plus only a few additional
   categories—not a category for every item or service it has.
4. **EsnaftaVar product evidence.** The 24 owner-final Product L1s, two final L2
   pilots, 224 proposed L2s and prior mixed-merchant tests are boundary inputs, not
   a template for merchant sectors.

Primary sources, accessed 2026-08-28:

- [TÜİK NACE Rev.2.1 classification server](https://siniflama.tuik.gov.tr/Classifications/ClassificationsSatir?ad=Avrupa+Toplulu%C4%9Funda+Ekonomik+Faaliyetlerin+%C4%B0statistiki+S%C4%B1n%C4%B1flamas%C4%B1+%2C+NACE+Rev.2.1&surumId=1438)
- [Ministry of Trade current profession/NACE list](https://ticaret.gov.tr/esnaf-sanatkarlar/esnaf-ve-sanatkar-meslek-kollari/sektor-meslek-nace-listeleri/guncel-liste)
- [TESK professions list](https://www.tesk.org.tr/resimler/915ced612016049.pdf)
- [Eurostat NACE overview](https://ec.europa.eu/eurostat/web/nace)
- [Google Business Profile category guidance](https://support.google.com/business/answer/7249669?hl=en)
- [Google business representation guidelines](https://support.google.com/business/answer/3038177?hl=en)

## 3. Merchant operating model

Use a small operational dimension separate from the hierarchy:

| Value | Meaning | Example |
|---|---|---|
| `RETAIL` | The public-facing proposition is primarily sale of physical products. | Kitapçı |
| `SERVICE` | The public-facing proposition is primarily labor/expertise delivered to the customer or an item. | Erkek Berberi |
| `MIXED` | Product sale and service are both ordinary, material parts of the same proposition. | Lastikçi selling and fitting tyres |

`PROFESSIONAL` or `REGULATED` must **not** be a fourth operating kind. It is an
orthogonal policy class because an optician can be `MIXED` and regulated, while a
medical-goods shop can be `RETAIL` and regulated.

Recommended policy dimension:

- `NORMAL`
- `VERIFICATION_MAY_BE_REQUIRED`
- `LEGAL_REVIEW_REQUIRED`
- `OUT_OF_SCOPE`

Taxonomy presence never grants the merchant or its products permission to trade.

## 4. Proposed hierarchy contract

- Proposed maximum depth: **3** (`sector family → merchant sector → optional
  specialist merchant type`).
- A family exists for browsing and governance; normally it is not assignable.
- Assignment should prefer the most specific active leaf that naturally completes
  the sentence **“Bu işletme bir …”**.
- L3 is justified only for a durable, customer-recognized distinction. It must not
  encode inventory, audience, brand or amenity.
- Variable depth is allowed. Most merchant sectors should remain assignable L2s.
- Parent placement may be proposed while an internally owner-confirmed subtree
  remains confirmed.

The owner-confirmed subtree is immutable in this design:

```text
Berber, Kuaför & Güzellik Salonu
├── Erkek Berberi
├── Kadın Kuaförü
└── Güzellik Salonu
```

`Unisex Kuaför` must not be added. Booking, reservation and service-price models
remain `TBD`.

## 5. Primary and secondary sectors

- Every merchant location has exactly one active **primary sector**.
- A location may have zero to three **secondary sectors** when each describes a
  real, customer-facing business line—not isolated shelf stock.
- Primary sector is the identity customers would use first, supported by storefront
  signage, main revenue/proposition and sustained activity.
- Secondary sectors cannot be selected as keywords or to improve reach.
- Product catalog evidence may later suggest a sector but must not silently change
  one.
- Unrelated combinations, regulated sectors and high-impact changes require review.
- A group or legal entity with materially different branches classifies each branch
  separately; corporate identity does not force one shared sector.

## 6. Naming and aliases

- Canonical display names use natural Turkish shop language.
- Legal/NACE descriptions remain linked evidence, not display labels.
- Search aliases may include colloquial or formal equivalents (`nalbur` /
  `hırdavatçı`) but never company names.
- A search synonym expands discovery. A legacy redirect preserves identity. These
  are different record types.
- Gender, size, price tier, brand, opening pattern, delivery, second-hand status,
  service area and product assortment are metadata/facets unless owner evidence
  proves a distinct merchant identity.

## 7. Chain, branch and department handling

- Sector assignment belongs to the public-facing **location/branch**, not only the
  legal merchant account.
- Same-format chain branches should normally share primary sector.
- A truly different public-facing branch can differ.
- A department is not automatically a sector. It may become a secondary sector only
  when customers can reasonably treat it as a sustained business line.
- Separately operated businesses inside one address keep separate merchant records.

## 8. Sector lifecycle

Each future sector identity needs an immutable opaque ID, mutable Turkish display
name and slug, parent ID, lifecycle state, aliases and versioned predecessor/
successor relations.

- **Rename:** preserve ID when meaning is unchanged; old label/slug becomes typed
  alias.
- **Move:** preserve ID when only hierarchy placement changes.
- **Split:** retire the predecessor for new assignment; require explicit selection
  among successors.
- **Merge:** preserve historical predecessor links; do not erase history.
- **Retire:** remain resolvable for history and analytics, but not selectable.

No production IDs are generated in this phase.

## 9. Sector change rules

- A merchant may request correction at any time.
- A material primary-sector change is versioned with effective time and reason.
- Historical reports resolve the sector valid at event time; current discovery uses
  the active sector.
- Changes into/out of regulated sectors may require renewed verification.
- Automated catalog inference can recommend, never finalize, a change.

## 10. Quality gates

A proposed sector passes only if:

1. customers and merchants recognize the name;
2. it represents a common standalone or durable mixed business;
3. it is not merely a Product L1/L2, facet, brand or single service;
4. it does not make the merchant the canonical owner of its inventory;
5. mixed merchants can be expressed with primary plus few secondary sectors;
6. regulated status remains a separate fail-closed policy gate;
7. onboarding remains searchable and understandable;
8. the owner-confirmed beauty subtree is preserved exactly;
9. the tree has no duplicate active names or path-dependent immutable IDs;
10. no proposal is marked final without explicit Product Owner approval.

`MERCHANT_TAXONOMY_DESIGN_CONTRACT: PROPOSED_FOR_OWNER_REVIEW`

`PRODUCT_MERCHANT_FACET_SEPARATION: PASS`

`RUNTIME_IMPLEMENTATION: NO`
