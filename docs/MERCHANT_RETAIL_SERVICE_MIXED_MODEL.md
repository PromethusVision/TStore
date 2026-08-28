# EsnaftaVar Retail / Service / Mixed Merchant Model

**State:** PROPOSED FOR OWNER REVIEW — NO BOOKING OR RUNTIME DESIGN

## 1. Separation of concerns

The merchant sector says what kind of business a location is. The operating model
says how it primarily delivers value:

- `RETAIL`: sale of physical products is the public-facing proposition;
- `SERVICE`: labor/expertise is the public-facing proposition;
- `MIXED`: retail and service are both sustained, material propositions.

Professional/regulatory status is a separate policy dimension. Product and service
records must also remain separate. A replacement phone screen can be a product; the
labor to fit it is a service. Neither determines the other's canonical taxonomy.

## 2. Classification test

Use `MIXED` only when both sides are visible, durable and independently meaningful
to customers. Incidental advice, free setup, delivery, packaging or warranty support
does not turn ordinary retail into mixed commerce.

| Signal | Retail | Service | Mixed |
|---|:---:|:---:|:---:|
| Physical goods are the main proposition | Yes | Incidental | Yes |
| Labor/expertise is independently purchased | Incidental | Yes | Yes |
| Customer can visit only for service | Usually no | Yes | Yes |
| Persistent service menu/workshop/staff | Usually no | Yes | Usually yes |
| Product catalog required | Yes | Not necessarily | Yes |

The operating model is assigned to the merchant location, not hard-coded forever
into a sector node. The proposal records only sensible defaults.

## 3. Proposed defaults and edge interpretations

| Merchant sector | Default | Boundary rule |
|---|---|---|
| Telefoncu & GSM Mağazası | `RETAIL` | Becomes `MIXED` only with a material repair/service line. |
| Telefon & Elektronik Teknik Servisi | `SERVICE` | Parts remain separately classified products. |
| Bilgisayarcı | `RETAIL` | PC assembly/setup does not alone require `MIXED`; paid repair workshop can. |
| Bilgisayar Teknik Servisi | `SERVICE` | Parts sales can justify a secondary retail sector, not product ownership. |
| Beyaz Eşya & Ev Aletleri Mağazası | `RETAIL` | Delivery or outsourced installation is capability metadata. |
| Beyaz Eşya Teknik Servisi | `SERVICE` | Authorized-service claim requires evidence. |
| Lastikçi | `MIXED` | Tyre retail and fitting/balancing are ordinarily coupled. |
| Bisiklet Mağazası | `RETAIL` | A staffed repair workshop can add Bisiklet Servisi and become `MIXED`. |
| Bisiklet Servisi | `SERVICE` | Incidental replacement parts do not make it retail automatically. |
| Müzik & Enstrüman Mağazası | `RETAIL` | Repair/course are secondary business lines only if sustained. |
| Perdeci | `RETAIL` | Measurement/delivery is ordinary sales support; custom sewing/install can justify `MIXED`. |
| Optik Mağazası | `MIXED` | Product and lawful fitting/measurement interaction coexist; regulated flag separate. |
| Erkek Berberi | `SERVICE` | Incidental grooming-product sale does not make it mixed. |
| Kadın Kuaförü | `SERVICE` | Incidental hair-product sale does not make it mixed. |
| Güzellik Salonu | `SERVICE` | Cosmetic retail can be a secondary sector only when it is a real storefront line. |
| Pet Kuaförü | `SERVICE` | Veterinary service must not be inferred. |
| Kuru Temizleme & Çamaşırhane | `SERVICE` | Cleaning-product resale is incidental unless sustained. |
| Anahtarcı | `SERVICE` | Key/lock material is incidental; a real hırdavat retail line can be secondary. |
| Terzi & Giyim Tadilatı | `SERVICE` | Garment sales require a real Giyim Mağazası line. |
| Kuyumcu / Saatçi | `RETAIL` | Repair/personalization can justify `MIXED`; high-value policy remains separate. |

## 4. Service catalog boundary

A future service catalog should not reuse Product Taxonomy IDs as service identity.
Conceptually it may need:

- service family/type;
- merchant sector compatibility;
- description and eligibility;
- service area or in-store flag;
- duration/availability only if later owner-approved;
- evidence/qualification requirements;
- price representation only after an explicit product decision.

This document does **not** design those fields, a service taxonomy, booking,
reservation, staff calendar, slot capacity or service-price engine.

## 5. Customer discovery

- Merchant-sector filters can include retail, service and mixed locations.
- Product search must continue to find products through Product Taxonomy and
  listings, independent of the merchant's operating model.
- Future service search should query service records/capabilities, not pretend that
  a service is a product.
- A mixed merchant profile can present products and services in separate sections.
- Ratings/reviews may later need a typed subject (`merchant`, `product`, `service`)
  and must not be inferred from sector alone.

## 6. Compliance and safety

- `REGULATED` is not an operating model.
- Sector and operating-model selection cannot create `merchant` role or privileges.
- Repair, fitting, installation, medical/optical interaction and beauty-treatment
  claims can require evidence independent of taxonomy.
- If the legal/service boundary is unclear, publish neither an unsupported service
  claim nor a regulated badge; route to review.

## 7. Open owner decisions

1. Approve `RETAIL/SERVICE/MIXED` as the minimal operating-model vocabulary.
2. Decide whether merchants self-declare `MIXED` or the system derives it after
   product/service configuration.
3. Define when repair/installation becomes a real secondary service sector.
4. Decide future service catalog scope separately.
5. Booking, reservation and service-price model remain `TBD`.

`RETAIL_SERVICE_MIXED_MODEL: PROPOSED_FOR_OWNER_REVIEW`

`BOOKING_MODEL_FINALIZED: NO`
