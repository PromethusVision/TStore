# EsnaftaVar Merchant Taxonomy — Contrarian Review

**State:** ADVERSARIAL REVIEW OF A PROPOSAL — NO OWNER FINALIZATION OR REWRITE

## 1. Review posture

This review assumes the V1 proposal may be wrong. It challenges usefulness,
recognition, breadth, granularity, onboarding cost, policy feasibility and Product
Taxonomy independence. A criticism does not automatically become a tree change;
each proposed response is an input to Product Owner review.

The exact confirmed `Berber, Kuaför & Güzellik Salonu` subtree and its three exact
children are preserved. Only its proposed wider placement is open.

## 2. Executive challenge

The proposal is credible as a **product-adjacent neighbourhood-commerce V1**, but
not as a complete directory of Turkish local businesses. Its strongest feature is
recognizable storefront language. Its biggest risk is promising a broader “local
merchant” universe than the 67 assignable leaves actually cover.

The architecture does not need wholesale rework before owner review. It does need
an explicit scope decision, targeted review of six granularity nodes, a launch
allowlist for policy-signalled sectors and a decision on whether three overloaded
families are acceptable browse containers.

## 3. Is it too detailed?

### Challenge

- 67 assignable leaves can create onboarding choice overload.
- `İç Giyim Mağazası`, `Parfümeri` and `Ofis Malzemeleri Mağazası` may encode a
  specialization that could be an alias or secondary descriptor.
- Closely related repair/retail pairs can tempt merchants to select multiple sectors
  to describe capabilities rather than durable identity.

### Counter-evidence

- Turkish merchants commonly self-identify with many proposed specialist nouns.
- Every assignable leaf appeared in the 180-case stress set.
- Search and controlled aliases allow direct leaf discovery without exposing all 67
  choices at once.

### Recommendation

Keep the tree intact for owner review. Decide the three narrow leaves individually,
make family nodes non-assignable and prototype search-first onboarding before
runtime finalization.

## 4. Is it too marketplace-like?

### Challenge

`Teknoloji & Elektronik`, `Ev, Mutfak & Mobilya`, `Anne, Bebek, Oyuncak & Hobi`
and similar names resemble product-department navigation. Merchants could interpret
them as permission to list only matching products, or the app could accidentally
derive one from the other.

### Counter-evidence

The model gives merchant sectors independent IDs, explicit many-to-many Product L1
mapping and no product ownership semantics. Stress and decoupling audits repeatedly
classify cross-domain stock without changing merchant identity.

### Recommendation

Retain familiar browse language, but every implementation contract must say
“işletme türü” and prohibit product IDs/paths as merchant-sector identity. Optional
catalogue defaults must remain suggestions.

## 5. Is it too service-heavy?

### Challenge

It is not too service-heavy by count: only 12 default `SERVICE` and two `MIXED`
leaves exist. The opposite problem is stronger. Eight service/business archetypes
in the stress test have no current target, including automotive repair,
photography studio, real-estate office, custom carpenter and equipment rental.

Beauty and repair leaves also expose missing transaction semantics: service subject,
price, staff, availability and verified completion do not yet exist.

### Recommendation

Do not add isolated service nodes. Owner should either freeze V1 as product-adjacent
plus controlled services or authorize a separate service-taxonomy research wave.
Booking/reservation/service price remains `TBD` and outside this taxonomy decision.

## 6. Does Product Taxonomy leak into merchant identity?

### Challenge

- Many merchant names share nouns with Product L1/L2 labels.
- Mapping suggestions could become mandatory filters in a future app.
- Product-tree renames could be treated as merchant-sector rename triggers.

### Counter-evidence

The 100-scenario decoupling audit requires zero merchant-ID changes. Forty-six
scenarios require suggestion refresh only; 54 require no action. Sector changes do
not bulk-move SKUs, and product changes do not rewrite merchants.

### Recommendation

Make independent immutable ID namespaces, APIs and lifecycle histories a runtime
gate. A merchant-sector foreign key must never reference a Product Taxonomy node.

## 7. Does onboarding overload the merchant?

### Challenge

- Fourteen families plus 67 leaves are too much for a single flat control.
- Primary/secondary/operating-model/policy questions could look like one complex
  classification task.
- Regulated notices on 36 leaves could create excessive friction or false alarms.

### Recommendation

Use search-first leaf selection, progressive disclosure and examples. Ask for
exactly one primary first; secondaries are optional and operating model is a
separate plain-language question. Trigger policy review only for the specific leaf
and activity, never for an entire family solely because one sibling is controlled.

## 8. Are there sectors nobody identifies with?

### Findings

- Family labels are mostly navigation language rather than storefront identity;
  they should not be assignable.
- `Yapı Malzemeleri Satıcısı` is broad and formal compared with ordinary shop
  speech.
- `Boya & Dekorasyon Malzemeleri Satıcısı` and `İçecek & Su Bayii` combine terms
  that merchants may use unevenly.
- `Optik, Saat, Takı & Medikal` is understandable as a directory grouping but not a
  shared merchant profession.
- `Anne, Bebek, Oyuncak & Hobi` combines distinct purchase missions for browse
  economy, not merchant self-identity.

### Recommendation

Do not assign family labels. Test the five questioned labels in merchant interviews
and search logs; maintain familiar aliases such as `yapı market`, `boyacı`, `su
bayii`, `optikçi` and `medikalci` without turning every phrase into a node.

## 9. Which Turkish local businesses are missing?

The stress test deliberately found eight absent/out-of-scope archetypes:

1. Eczane
2. Veteriner kliniği
3. Kafe/restoran
4. Oto servis/tamir
5. Fotoğraf stüdyosu
6. Emlak ofisi
7. Özel ölçü marangoz/atölye
8. Ekipman kiralama

Other plausible future gaps include floristry services/events, plumbers/electricians
as service providers, home cleaning, wellness, tutoring, logistics and professional
offices. Adding them now would materially change the product surface and policy
model.

### Recommendation

Treat absence as a scope decision, not a data-quality bug. The unresolved “other”
flow may collect demand but must not publish free-text sectors.

## 10. Are mixed merchants modeled badly?

### Challenge

- Primary plus up to three secondaries can become keyword stuffing.
- A merchant may choose sectors to describe every stocked product department.
- `MIXED` can be confused with “multiple sectors.”

### Recommendation

- Primary means the durable customer promise, not highest current SKU count.
- Secondary requires a recognizable independent activity, not a shelf.
- `MIXED` means material retail **and** service operation; it does not mean multiple
  retail sectors.
- Cross-family secondary choices are permitted but higher-risk for review.
- Customer UI should emphasize primary and display only an approved subset of
  secondaries.

## 11. Policy and regulation pressure test

### Challenge

The policy audit flags 36 of 67 assignable leaves: 26
`VERIFICATION_MAY_BE_REQUIRED` and ten `LEGAL_REVIEW_REQUIRED`. This is more than
half the assignable tree. A naive implementation would either over-block ordinary
merchants or under-control sensitive activity.

Especially sensitive boundaries include food handling, live-animal/veterinary
interpretation, optician activity, medical devices, jewellery commerce,
plant-protection products and hunting-related goods.

### Recommendation

- Sector and policy state stay independent.
- Review attaches to the declared activity/evidence, not merely a broad family.
- No badge, role or product-listing capability follows automatically from sector.
- Launch only owner-approved, legally reviewed policy cases; keep unresolved cases
  fail-closed.
- Treat the audit as a risk signal, not legal advice.

## 12. Family-by-family contrarian flags

| Family | Strongest objection | Severity | Owner action |
|---|---|---|---|
| Gıda & Günlük Tüketim | Broad market leaf and varied food obligations | MEDIUM | Confirm combined market identity and activity-level review. |
| Giyim, Ayakkabı & Aksesuar | İç-giyim leaf may be too narrow | MEDIUM | Retain or demote based on acquisition value. |
| Teknoloji & Elektronik | Highest risk of Product Taxonomy confusion | MEDIUM | Enforce independent IDs and copy. |
| Ev, Mutfak & Mobilya | Custom manufacture/service not represented | LOW | Keep retail V1; defer workshop model. |
| Yapı, Hırdavat & Tesisat | Broad inventory/policy and installer leakage | MEDIUM | Clarify seller versus service provider. |
| Otomotiv, Motosiklet & Mobilite | Vehicle sale/repair scope ambiguity | HIGH | Define retail-only V1 and decide auto service separately. |
| Kozmetik, Bakım & Güzellik | Retail/service/policy collision | MEDIUM | Approve parent placement; preserve confirmed subtree. |
| Anne, Bebek, Oyuncak & Hobi | Overloaded browse grouping | MEDIUM | Rely on search-to-leaf; validate family label. |
| Kitap, Kırtasiye & Ofis | Office specialist may be B2B/narrow | MEDIUM | Confirm launch cohort or fold into Kırtasiye. |
| Spor & Outdoor | Hunting wording creates product-policy risk | HIGH | Separate sector identity from restricted-goods authorization. |
| Evcil Hayvan | Live-animal and veterinary boundary unresolved | HIGH | Define launch scope before activation. |
| Optik, Saat, Takı & Medikal | Four unrelated verification regimes | HIGH | Review family grouping and leaf-specific gates. |
| Çiçek, Bahçe, Hediyelik & Parti | Gift leakage and plant-protection boundary | MEDIUM | Keep definitions strict; activity-level policy. |
| Tamir, Bakım & Yerel Hizmetler | Incomplete service universe | HIGH | Decide controlled V1 versus separate expansion. |

## 13. High-risk assumptions to invalidate before implementation

1. Merchants can reliably choose one durable primary sector.
2. Search-first onboarding prevents 67-leaf overload.
3. The proposed 14 family labels are understandable in Turkish customer browse.
4. A maximum of three secondaries covers real combinations without abuse.
5. Policy review can be scoped below broad family labels.
6. Product-led QR/review flows can coexist with service-only profiles without false
   “verified purchase” implications.
7. One-owner/one-shop current state will not be mistaken for a final branch model.

These should be tested with owner decisions, merchant interviews and future
Development prototypes—not assumed from desk research.

## 14. Final adversarial verdict

| Question | Verdict |
|---|---|
| Too detailed? | Manageable with search-first onboarding; three narrow leaves need decisions. |
| Too marketplace-like? | Naming risk exists; architecture remains decoupled if runtime gates hold. |
| Too service-heavy? | No; service breadth is intentionally incomplete. |
| Product leakage? | Controlled in design, high-impact implementation risk. |
| Onboarding overload? | Plausible risk; progressive disclosure required. |
| Unnatural sectors? | No fatal leaf set; five labels merit field validation. |
| Missing local businesses? | Yes, by deliberate scope; owner must define breadth. |
| Mixed merchants? | Model is workable if evidence/anti-stuffing rules are enforced. |

**Recommendation:** advance to Product Owner review without declaring the tree
final. Resolve scope, family grouping, granularity exceptions and regulated launch
ownership before runtime design.

`MERCHANT_TAXONOMY_CONTRARIAN_REVIEW: PASS`

`WHOLESALE_REDESIGN_REQUIRED: NO`

`READY_FOR_OWNER_REVIEW: YES`
