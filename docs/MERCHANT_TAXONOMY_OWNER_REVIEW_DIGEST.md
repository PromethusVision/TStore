# EsnaftaVar Merchant Taxonomy — Product Owner Review Digest

**State:** DECISION DIGEST — PROPOSAL, NOT OWNER FINALIZATION

## 1. Decision baseline

The V1 proposal contains 14 navigation families, 65 L2 nodes and three L3
specialist leaves. There are 82 hierarchy nodes and 67 assignable leaves. The
recommended default operating mix is 53 `RETAIL`, 12 `SERVICE` and two `MIXED`
leaves.

The following subtree is already confirmed and is not reopened here:

- `Berber, Kuaför & Güzellik Salonu`
  - `Erkek Berberi`
  - `Kadın Kuaförü`
  - `Güzellik Salonu`

Its placement under `Kozmetik, Bakım & Güzellik` remains proposed. No additional
beauty leaf is proposed. Booking, reservation and service-price models remain
separate `TBD` product decisions.

Decision priority:

- `P0`: changes the tree or assignability;
- `P1`: controls future app, assignment or verification behaviour;
- `P2`: controls aliases, external-code links, analytics or presentation metadata.

## 2. P0 — tree decisions

### P0-01 — Merchant-taxonomy breadth

- **QUESTION:** Is V1 a product-adjacent local-commerce taxonomy or a comprehensive
  directory of local businesses?
- **OPTIONS:** A — product-adjacent retail plus the proposed controlled services;
  B — expand now to restaurants, pharmacies, veterinary clinics, auto repair,
  studios, real estate, custom trades and rentals; C — retail only.
- **RECOMMENDED OPTION:** A.
- **WHY:** It matches current EsnaftaVar product/QR capabilities while preserving a
  deliberate path to services. The 180-case test exposed eight absent business
  types, showing that B would require a separate research wave rather than a few
  ad-hoc nodes.
- **CROSS-DOMAIN EFFECT:** Determines onboarding eligibility, customer discovery,
  policy workload and whether service transaction/review models are prerequisites.

### P0-02 — Fourteen navigation families

- **QUESTION:** Approve the 14 proposed family names and grouping boundaries?
- **OPTIONS:** A — approve as proposed; B — merge adjacent families; C — split
  policy-diverse or overloaded families before leaf approval.
- **RECOMMENDED OPTION:** A, subject to the specific family questions below.
- **WHY:** Seven families rated `STRONG`, four `ACCEPTABLE` and three require
  substantive review. The families are browse aids, not product owners.
- **CROSS-DOMAIN EFFECT:** Changes browse order, onboarding navigation and future
  analytics rollups, but must not change Product Taxonomy.

### P0-03 — Assignable leaf set

- **QUESTION:** Approve the 64 proposed leaves outside the three already-confirmed
  beauty leaves as the V1 owner-review set?
- **OPTIONS:** A — approve the set with targeted exceptions below; B — approve only
  high-confidence leaves and defer the rest; C — commission a broader redesign.
- **RECOMMENDED OPTION:** A.
- **WHY:** Every proposed assignable leaf appeared in the stress test; most match
  ordinary Turkish storefront language. Six granularity exceptions and regulated
  activation gates remain explicit rather than hidden.
- **CROSS-DOMAIN EFFECT:** Fixes the future stable-ID inventory and the set available
  in onboarding; it does not constrain which product categories a merchant may use.

### P0-04 — Market, Bakkal & Süpermarket

- **QUESTION:** Keep a combined scale-neutral leaf or split market formats?
- **OPTIONS:** A — keep one leaf; B — split `Bakkal`, `Market` and `Süpermarket`; C —
  keep one leaf and record store format/scale as metadata later.
- **RECOMMENDED OPTION:** C.
- **WHY:** Customers and merchants use all three terms, but shop size is not a
  durable business-sector identity. Splitting would create avoidable onboarding and
  analytics fragmentation.
- **CROSS-DOMAIN EFFECT:** Affects search aliases and scale reporting, not product
  classification or inventory eligibility.

### P0-05 — Three narrow specialist leaves

- **QUESTION:** Should `İç Giyim Mağazası`, `Parfümeri` and `Ofis Malzemeleri
  Mağazası` remain standalone assignable leaves?
- **OPTIONS:** A — retain all three; B — fold all into broader leaves and keep the
  terms as aliases; C — decide each independently.
- **RECOMMENDED OPTION:** C: retain `Parfümeri`; retain `İç Giyim Mağazası` only if
  merchant acquisition supports it; fold `Ofis Malzemeleri Mağazası` into
  `Kırtasiye` unless a distinct B2B cohort is in launch scope.
- **WHY:** Standalone businesses exist, but taxonomy value depends on meaningful
  acquisition/search distinction rather than inventory detail.
- **CROSS-DOMAIN EFFECT:** Alters stable IDs, onboarding choices and analytics;
  product leaves and search terms remain independent.

### P0-06 — Optik, Saat, Takı & Medikal family

- **QUESTION:** Keep four strong specialist leaves under one policy-diverse family?
- **OPTIONS:** A — keep the family; B — split navigation families without changing
  leaves; C — defer regulated leaves from V1.
- **RECOMMENDED OPTION:** B if customer browse testing shows confusion; otherwise A
  with clearly separate verification rules. Do not merge the leaves.
- **WHY:** The leaf identities are locally strong, but they do not share one licence,
  regulator or evidence model.
- **CROSS-DOMAIN EFFECT:** Changes browse/analytics rollups and policy routing; it
  must not imply shared eligibility or product authorization.

### P0-07 — Repair/service breadth

- **QUESTION:** Keep `Tamir, Bakım & Yerel Hizmetler` at eight leaves or expand V1?
- **OPTIONS:** A — keep the controlled eight; B — add the eight missing stress-test
  types; C — split out a separate professional/local-services architecture.
- **RECOMMENDED OPTION:** A for V1, then C if broader services become a product goal.
- **WHY:** Piecemeal additions would mix bookings, regulated care, property and food
  service with product-led commerce without the required transaction model.
- **CROSS-DOMAIN EFFECT:** Controls Merchant App scope, reviews, verification and
  whether non-product transactions need a new canonical subject.

### P0-08 — Parent-node assignability

- **QUESTION:** May family/grouping nodes be selected as merchant sectors?
- **OPTIONS:** A — never assign parents; B — allow every parent; C — default parents
  to non-assignable and approve explicit exceptions only.
- **RECOMMENDED OPTION:** C, with no V1 exception identified.
- **WHY:** Exact leaves improve discovery and analytics. Broad parent assignment
  would hide ambiguity and weaken verification routing.
- **CROSS-DOMAIN EFFECT:** Affects onboarding validation, migration and reporting;
  browse families remain visible.

### P0-09 — Confirmed beauty subtree placement

- **QUESTION:** Place the confirmed beauty subtree under `Kozmetik, Bakım &
  Güzellik`?
- **OPTIONS:** A — approve the proposed placement; B — place it under the service
  family; C — create a distinct beauty-services family.
- **RECOMMENDED OPTION:** A.
- **WHY:** It is natural for customer discovery and keeps retail cosmetics adjacent
  while the operating model distinguishes service leaves. The already-confirmed
  names and children remain unchanged.
- **CROSS-DOMAIN EFFECT:** Changes navigation and family analytics only; it does not
  authorize cosmetics sales, booking or service pricing.

## 3. P1 — assignment and future app decisions

### P1-01 — Secondary-sector limit

- **QUESTION:** How many secondary sectors may one merchant hold?
- **OPTIONS:** A — none; B — up to three; C — unlimited.
- **RECOMMENDED OPTION:** B.
- **WHY:** It represents genuine combinations without allowing keyword stuffing or
  twenty unrelated claims.
- **CROSS-DOMAIN EFFECT:** Requires validation, customer-display limits and distinct
  primary-versus-secondary analytics.

### P1-02 — Secondary-sector evidence and adjacency

- **QUESTION:** What makes a secondary sector valid?
- **OPTIONS:** A — merchant self-selection only; B — declared activity plus evidence
  or catalogue/service signal where appropriate; C — strict same-family adjacency.
- **RECOMMENDED OPTION:** B; use adjacency as a risk signal, not an absolute rule.
- **WHY:** Legitimate combinations cross families, while unbounded self-selection is
  easy to abuse.
- **CROSS-DOMAIN EFFECT:** Affects moderation, onboarding explanations and search
  ranking; it must not infer product classification from sector.

### P1-03 — Retail/service/mixed operating model

- **QUESTION:** Keep `RETAIL`, `SERVICE` and `MIXED` orthogonal to sector?
- **OPTIONS:** A — yes; B — encode retail/service into duplicate sector leaves; C —
  infer it permanently from current catalogue.
- **RECOMMENDED OPTION:** A.
- **WHY:** A telefoncu, optician or bicycle business may operate differently without
  changing its recognizable sector identity.
- **CROSS-DOMAIN EFFECT:** Keeps future transaction and UI capability decisions out
  of the hierarchy and reduces duplicate sectors.

### P1-04 — Branch and multi-location identity

- **QUESTION:** Is sector assigned to a merchant organization, each branch, or both?
- **OPTIONS:** A — organization only; B — branch only; C — organization defaults
  with explicit branch overrides and effective history.
- **RECOMMENDED OPTION:** C for future design; do not implement until the owner/shop
  account model is decided.
- **WHY:** Chains can share identity while individual branches offer different
  services. Current one-owner/one-shop constraints are insufficient for this.
- **CROSS-DOMAIN EFFECT:** Affects Auth ownership, shop schema, analytics and sector
  change history.

### P1-05 — Sector-change publication

- **QUESTION:** How should a merchant change primary/secondary sectors?
- **OPTIONS:** A — instant overwrite; B — request, validate and publish an effective
  change while retaining history; C — support-only changes.
- **RECOMMENDED OPTION:** B, with fail-closed review for controlled targets.
- **WHY:** History is needed for analytics, aliases and regulated-state continuity;
  instant overwrite enables category gaming.
- **CROSS-DOMAIN EFFECT:** Requires server-authoritative workflow and event-time
  reporting but no automatic product recategorization.

### P1-06 — Regulated activation and review owner

- **QUESTION:** Which policy-signalled sectors launch, what evidence is required,
  and who owns review?
- **OPTIONS:** A — activate labels without verification; B — define a launch
  allowlist/evidence matrix and accountable review owner; C — defer all signalled
  sectors.
- **RECOMMENDED OPTION:** B, with C for any sector whose requirements are unresolved.
- **WHY:** 36 of 67 leaves carry a verification or legal-review signal. Sector
  selection alone cannot prove authorization.
- **CROSS-DOMAIN EFFECT:** Blocks app launch design, badges and moderation for those
  sectors; product-level policy remains separately enforceable.

### P1-07 — Catalogue suggestions and customer display

- **QUESTION:** How may sector influence catalogue setup and public profile?
- **OPTIONS:** A — mandatory product filtering; B — optional product-domain
  suggestions plus primary-sector display and limited approved secondaries; C — no
  use outside internal analytics.
- **RECOMMENDED OPTION:** B.
- **WHY:** Suggestions reduce onboarding effort while preserving many-to-many
  merchant/product independence.
- **CROSS-DOMAIN EFFECT:** Requires clear UI labels and ranking safeguards; it must
  not make a merchant sector the canonical owner of any SKU.

## 4. P2 — metadata and governance decisions

### P2-01 — Search-alias governance

- **QUESTION:** How are the 113 proposed search aliases approved and maintained?
- **OPTIONS:** A — unmanaged free text; B — versioned controlled aliases with
  ambiguity review; C — canonical names only.
- **RECOMMENDED OPTION:** B.
- **WHY:** Local terms improve findability, but aliases must not create hidden nodes,
  brand terms or first-result misclassification.
- **CROSS-DOMAIN EFFECT:** Affects merchant search/onboarding only; product search
  synonyms remain a separate system.

### P2-02 — NACE/TESK/professional-code linkage

- **QUESTION:** Should external activity codes be linked behind merchant sectors?
- **OPTIONS:** A — no link; B — many-to-many, versioned research/verification links;
  C — use legal codes as customer-facing sector IDs.
- **RECOMMENDED OPTION:** B.
- **WHY:** Official codes support evidence and review but are too detailed and
  unstable for customer-facing identity. C would collapse legal and UX models.
- **CROSS-DOMAIN EFFECT:** Supports compliance and migration without changing labels
  or immutable merchant-sector IDs.

### P2-03 — Analytics time semantics

- **QUESTION:** Report merchants by current sector, historical effective sector, or
  both?
- **OPTIONS:** A — current only; B — event-time only; C — both with explicit metric
  semantics.
- **RECOMMENDED OPTION:** C.
- **WHY:** Current discovery and historical performance answer different questions;
  rename/move must not break trends.
- **CROSS-DOMAIN EFFECT:** Requires effective history and stable IDs while Product
  Taxonomy analytics stays separate.

### P2-04 — Verification badge and privacy presentation

- **QUESTION:** What controlled status may customers see?
- **OPTIONS:** A — show sector as proof; B — server-authoritative approved badge with
  minimal public facts; C — show raw documents/licence data.
- **RECOMMENDED OPTION:** B.
- **WHY:** Sector labels are not credentials; sensitive evidence must not become
  public profile data.
- **CROSS-DOMAIN EFFECT:** Affects profile UI, moderation, privacy and revocation;
  product authorization remains independent.

### P2-05 — Booking, reservation and service price

- **QUESTION:** Should this taxonomy wave define booking/reservation/service-price
  behavior?
- **OPTIONS:** A — define now; B — keep as a separate product decision; C — infer
  product pricing rules for services.
- **RECOMMENDED OPTION:** B.
- **WHY:** These are transaction/capability models, not merchant-sector hierarchy.
- **CROSS-DOMAIN EFFECT:** Keeps the confirmed beauty subtree usable without
  prematurely defining calendars, staff, availability or a service catalogue.

## 5. Decision totals and recommended review order

| Priority | Count | Recommended order |
|---|---:|---|
| P0 | 9 | Decide scope, families, leaves, exceptions and assignability first. |
| P1 | 7 | Then decide assignment, verification and future app behavior. |
| P2 | 5 | Finally approve metadata and governance semantics. |
| **Total** | **21** | — |

Fastest safe path:

1. Resolve P0-01, P0-02 and P0-03 as the architecture gate.
2. Resolve the six targeted P0 exceptions without reopening the confirmed beauty
   children.
3. Approve P1-01 through P1-06 before any runtime schema/app design.
4. Approve the five P2 policies before stable IDs, aliases and analytics are wired.

`MERCHANT_OWNER_DECISION_COUNT: 21`

`MERCHANT_OWNER_REVIEW_DIGEST: READY`

`OWNER_FINALIZATION_PERFORMED: NO`
