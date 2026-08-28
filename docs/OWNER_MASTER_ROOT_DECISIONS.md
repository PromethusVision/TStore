# Owner Master Root Decisions

State: `24 PRODUCT OWNER FINAL ROOTS — 0 OPEN / 3 PROVISIONAL / 4 DEFERRED`

Recommendations remain working hypotheses for non-final roots. On 2026-08-29 the
Product Owner finalized the first eight roots and then a second, explicitly
bounded batch: `OM-R01=A`, `OM-R02=A`, `OM-R03=A`, `OM-R09=A`, `OM-R10=A`,
`OM-R11=B`, `OM-R12=A`, `OM-R13=A`, `OM-R14=A`, `OM-R15=A`, `OM-R16=A`,
`OM-R17=A`, `OM-R18=A` and `OM-R31=A`. A third bounded batch finalized
`OM-R06=B` and `OM-R07=B`; it approves strategy/identity direction only and no
runtime or schema authority. No other answer is implied.

## Product Owner final register

| Root | Final | Decision state | Remaining gate |
|---|---|---|---|
| OM-R01 | A | FINAL | exact KPI formulas and targets remain open |
| OM-R02 | A | FINAL | exact launch cells and density evidence remain open |
| OM-R03 | A | FINAL | staged release execution remains gated |
| OM-R04 | A | FINAL | exact signed artifact and physical acceptance not executed |
| OM-R05 | A | FINAL | KVKK review remains open |
| OM-R06 | B | FINAL | migration strategy only; no activation, ID generation or cleanup authorized |
| OM-R07 | B | FINAL | identity direction only; no catalog schema/runtime authorized |
| OM-R09 | A | FINAL | staff/multi-branch automation not approved |
| OM-R10 | A | FINAL | lawyer/regulatory review remains open; sensitive scope fails closed |
| OM-R11 | B | FINAL | minimum safe slice only; full Merchant App not approved |
| OM-R12 | A | FINAL | exact enum/schema not approved; claim review remains open |
| OM-R13 | A | FINAL | physical/two-device evidence not executed |
| OM-R14 | A | FINAL | user-facing process review remains open |
| OM-R15 | A | FINAL | KVKK data-map review and numeric thresholds remain open |
| OM-R16 | A | FINAL | no future price approved; accounting/tax review remains open |
| OM-R17 | A | FINAL | KVKK review for feedback/acquisition data remains open |
| OM-R18 | A | FINAL | lawyer/KVKK approval required before commercial launch |
| OM-R19 | A | FINAL | runtime token reconciliation not authorized here |
| OM-R20 | A | FINAL | light-only runtime cleanup not authorized here |
| OM-R21 | A | FINAL | bounded C1 implementation/evidence pending |
| OM-R22 | A | FINAL | Shop Details implementation pending |
| OM-R23 | A | FINAL | Cart V2 implementation pending |
| OM-R24 | A | FINAL | card implementation pending |
| OM-R31 | A | FINAL | exact numeric stop/expand thresholds not approved |

## Master root registry

| ID | P | Root question | Recommended option | Original review lane |
|---|---:|---|---|---|
| OM-R01 | P0 | İlk Esenler pilotunun tek başarı amacı nedir? | A — useful local discovery plus trustworthy merchant/QR operating evidence | NOW |
| OM-R02 | P0 | Hangi Esenler hücreleri ve hangi minimum density ile açılır? | A — bounded cells, evidence-based usable density | NOW |
| OM-R03 | P0 | İlk cohort ve distribution sırası nedir? | A — controlled closed rollout, then measured expansion | NOW |
| OM-R04 | P0 | Hangi platform ve exact-artifact kanıtı pilotu açar? | A — Android-only if exact signed/physical gates pass | NOW |
| OM-R05 | P0 | Guest discovery, registration, location and AuthGuard boundary nedir? | A — guest discovery, contextual auth, transient location, minimal local history | PROVISIONAL |
| OM-R06 | P1 | Taxonomy/facet/legacy/demo runtime geçişi nasıl yapılır? | B — stable-ID staged migration after dedicated acceptance | NOW |
| OM-R07 | P0 | Product, Variant, Listing ve identifier kimliği nasıl ayrılır? | B — Product + domain-gated Variant + separate Listing | NOW |
| OM-R08 | P0 | Candidate, variable-measure ve media ne zaman customer-visible olur? | B — governed candidate and reviewed/gated publication | PROVISIONAL |
| OM-R09 | P0 | Pilot merchant organization, authority ve cohort shape nedir? | A — ordinary single-owner shops with organization seam | NOW |
| OM-R10 | P0 | Merchant sector, verification ve policy allowlist sınırı nedir? | A — ordinary allowlist; regulated/unknown fail closed | PROVISIONAL |
| OM-R11 | P0 | Pilot için hangi merchant-side operating surface gerekir? | B — minimum safe Merchant App; assisted bootstrap time-boxed | NOW |
| OM-R12 | P0 | Price, availability ve freshness truth nasıl korunur? | A — merchant self-service core plus explicit states/risk-tier freshness | NOW |
| OM-R13 | P0 | QR ne zaman, hangi shop evidence ve history ile açılır? | A — gated subset, exact-shop authority, limited minimized history | NOW |
| OM-R14 | P0 | Support, staffing, operator authority ve pause controls nedir? | A — named lean coverage, evidence/audit and explicit pause authority | NOW |
| OM-R15 | P0 | Hangi KPI, baseline, monitoring ve privacy sınırı pilotu yönetir? | A — question-led minimum metrics, baseline before targets | PROVISIONAL |
| OM-R16 | P0 | Merchant'a hangi bounded pilot offer sunulur? | A — explicit no-charge pilot term, end state and no silent conversion | NOW |
| OM-R17 | P1 | İlk acquisition mix ve feedback yöntemi nedir? | A — merchant/community-led acquisition and opt-in research | NOW |
| OM-R18 | P0 | Terms, privacy, deletion and factual platform disclosures ne olmalıdır? | A — professional-reviewed minimum surfaces before launch | PROFESSIONAL FIRST |
| OM-R19 | P0 | Customer UI semantic palette rolleri nedir? | A — teal/green primary, terracotta accent | NOW |
| OM-R20 | P0 | Pilot light-only çıkabilir mi? | A — consistent light-only pilot; dark later | NOW |
| OM-R21 | P0 | Kritik Customer ekran yönü nasıl kabul edilir? | A — current direction with bounded C1 corrections | NOW |
| OM-R22 | P0 | Shop Details ana CTA nedir? | A — directions/physical visit primary, chat secondary | NOW |
| OM-R23 | P0 | Cart V2 müşteriye ne anlatır? | A — single-shop physical-shopping preparation, not checkout | NOW |
| OM-R24 | P0 | Product/category card density nedir? | A — balanced two-line local-context cards | NOW |
| OM-R25 | P1 | Tek değerlendirme akışının fazı ve soru seti nedir? | A — collection-only, three labeled dimensions with skip/N/A | PROVISIONAL |
| OM-R26 | P1 | Shop contribution and merchant-feed projection identity nedir? | A — per-purchase evidence, capped customer-shop contribution, immutable origin | PROVISIONAL |
| OM-R27 | P1 | Public reputation/badge ne zaman ve hangi subject için görünür? | A — no public pilot score/badge; private learning first | POST-PILOT |
| OM-R28 | P2 | Hangi score/confidence/composite/meta model kullanılır? | A — defer formula; calibrate with data before any meta badge | POST-PILOT |
| OM-R29 | P1 | Ads ne zaman ve hangi privacy/economic contract ile açılır? | A — organic-only pilot; Ads stays shadow/deferred | POST-PILOT |
| OM-R30 | P1 | Reward ne zaman ve hangi funding/value-transfer contract ile açılır? | A — no economic reward in pilot | POST-PILOT |
| OM-R31 | P0 | Ne zaman pause edilir ve hangi kanıtla expand edilir? | A — predefined stops; expand one dimension after evidence | NOW |

`Original review lane` is provenance from the pre-selection queue, not the
current decision state. The Product Owner final register above is authoritative;
recommendations for provisional/deferred roots are not selections.

## Root option summaries

### Pilot, release and customer access

- `OM-R01`: A local-discovery/operability evidence; B growth/MAU; C early revenue.
- `OM-R02`: A bounded ready cells; B all Esenler; C scattered merchant availability.
- `OM-R03`: A closed staged cohort; B broad public first; C indefinite invitation-only.
- `OM-R04`: A Android exact-artifact first; B simultaneous Android+iOS exact
  acceptance; C research builds without commercial gate.
- `OM-R05`: A guest discovery/contextual auth/minimized location; B login-first;
  C broad account/location history.

### Taxonomy, catalog and merchant truth

- `OM-R06`: A one-shot activation; B staged stable-ID migration; C indefinite freeze.
- `OM-R07`: A Product+Listing only; B domain-gated Variant; C universal Variant.
- `OM-R08`: A direct merchant publication; B governed publication; C no merchant intake.
- `OM-R09`: A single-owner ordinary cohort; B multi-staff from day one; C full
  enterprise/multi-branch.
- `OM-R10`: A ordinary allowlist/fail closed; B specialist-approved bounded
  regulated cohort; C broad open catalog.
- `OM-R11`: A full Merchant App; B minimum safe slice; C tiny operator-assisted
  verifier surface.
- `OM-R12`: A merchant self-service truth; B operator-only truth; C weak best-effort.
- `OM-R13`: A staged QR subset; B all merchants day one; C QR deferred.

### Operating and commercial pilot

- `OM-R14`: A lean named roles/audit/pause; B best-effort owner operations; C
  enterprise separation before pilot.
- `OM-R15`: A minimum question-led KPI; B broad dashboard; C anecdotal-only.
- `OM-R16`: A bounded no-charge pilot; B fixed “three months free”; C paid entry.
- `OM-R17`: A merchant/community-led; B paid local media first; C broad untargeted.
- `OM-R18`: A professionally reviewed minimum surfaces; B incomplete interim
  notices; C launch without them.

### Customer UI implementation gate

- `OM-R19`: A teal primary; B terracotta primary; C redesign palette.
- `OM-R20`: A light-only pilot; B light+dark together; C inconsistent legacy mode.
- `OM-R21`: A accept current direction with C1 fixes; B bounded revision; C redesign.
- `OM-R22`: A physical visit; B products; C chat as primary CTA.
- `OM-R23`: A physical-shopping preparation; B generic basket; C checkout-like flow.
- `OM-R24`: A balanced local context; B compact price-first; C editorial/low-density.

### Evaluation, reputation, Ads and Reward

- `OM-R25`: A three dimensions; B four including overall; C overall-only.
- `OM-R26`: A per-purchase raw plus capped effective contribution; B lifetime
  customer-shop evaluation; C uncapped purchase-weighted contribution.
- `OM-R27`: A private learning first; B primary badges in pilot; C public stars and
  composite badges immediately.
- `OM-R28`: A calibrate later; B Bayesian/hybrid now; C simple average now.
- `OM-R29`: A organic-only; B narrow disclosed experiment; C broad Ads launch.
- `OM-R30`: A disabled; B merchant-local non-transferable pilot; C cross-merchant value.
- `OM-R31`: A predefined stops/one-dimension expansion; B discretionary expansion;
  C fixed calendar expansion.

## Non-negotiable separations

- Commercial pilot scope (`OM-R01`–`OM-R03`, `OM-R16`, `OM-R17`, `OM-R31`) is
  not the same question as minimum Merchant App implementation (`OM-R11`).
- Product review text remains one system. Structured shop evaluation is separate
  evidence, and the merchant feed is a projection, not a second free-text review.
- Taxonomy eligibility does not imply legal sale permission; merchant sector does
  not imply regulatory authorization.
- Ads and Reward cannot influence verified review or merchant reputation evidence.

`ROOT_COUNT: 31`

`OWNER_FINAL_CHOICES: 24`

`OWNER_OPEN_ROOTS: 0`

`OWNER_PROVISIONAL_ROOTS: 3`

`OWNER_DEFERRED_ROOTS: 4`
