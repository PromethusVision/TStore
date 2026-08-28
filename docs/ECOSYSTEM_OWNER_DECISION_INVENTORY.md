# Ecosystem Product Owner Decision Inventory

**State:** RAW GLOBAL DECISIONS — NONE SELECTED

| ID | System | Question | Recommendation | Priority | Policy/legal |
|---|---|---|---|---:|---|
| ECO-D001 | Release/Pilot | Android-only pilot mi, Android+iOS eşzamanlı mı? | Kanıt/hazırlığa göre açık platform scope; desteklenmeyen platformu vaat etme | P0 | YES |
| ECO-D002 | Customer/Nearby | Nearby guest mı login-gated mı? | Mahremiyet açıklamasıyla public discovery; kişiselleştirme ayrı | P1 | YES |
| ECO-D003 | Customer | Recent search/chat draft ne kadar device-local tutulur? | Minimum, açık ve silinebilir local retention | P1 | YES |
| ECO-D004 | Customer/Release | Final UI/accessibility fiziksel kabulü pilot gate mi? | Fonksiyonel/erişilebilir blockerlar gate; kozmetik final kit ayrı | P1 | NO |
| ECO-D005 | Product Taxonomy | Owner-final Product Taxonomy V1 runtime’a ne zaman alınır? | Ayrı migration/client acceptance wave sonrası | P0 | NO |
| ECO-D006 | Search/Facet | Global facets/synonyms pilotta ne kadar açılır? | Current search korunur; yalnız kanıtlanmış minimum facet | P1 | NO |
| ECO-D007 | Legacy Taxonomy | 651 legacy node reconciliation ne zaman uygulanır? | Stable IDs ve rollback ile post-pilot/ayrı wave | P1 | NO |
| ECO-D008 | Catalog | Canonical identity product family/variant/listing nasıl ayrılır? | Product + domain-gated variant + separate listing | P0 | NO |
| ECO-D009 | Catalog | Hangi domainlerde explicit variant V1 zorunlu? | Yalnız choice-bearing correctness-critical domains | P0 | POLICY |
| ECO-D010 | Catalog | GTIN/no-barcode auto-link sınırı nedir? | Compatible strong evidence; conflictte review, blind merge yok | P1 | POLICY |
| ECO-D011 | Catalog | Merchant candidate ne zaman public canonical olur? | Governed queue; policy/duplicate gates | P0 | POLICY |
| ECO-D012 | Catalog/Merchant | Variable measure pilotta aktif mi? | Unit/precision/QR snapshot kararı olmadan defer | P0 | POLICY |
| ECO-D013 | Catalog/Reviews | Merge sonrası aynı customer review collision nasıl sunulur? | Tarihi koru; görünür active policy owner-gated | P0 | POLICY |
| ECO-D014 | Catalog/Reviews | Split predecessor review hakkı child’a taşınır mı? | Yalnız deterministic snapshot; ambiguity fail closed | P0 | POLICY |
| ECO-D015 | Catalog/Media | Listing media canonical media olabilir mi? | Rights/evidence ile reviewed promotion; otomatik değil | P1 | YES |
| ECO-D016 | Merchant | Organization/shop/branch topology pilotta nedir? | One-shop organization seam; enterprise hierarchy defer | P0 | NO |
| ECO-D017 | Merchant | Owner/verifier/catalog staff V1’de hangi scope ile var? | Minimum presets; custom roles yok | P0 | NO |
| ECO-D018 | Merchant | Transfer/multi-branch automation pilotta var mı? | Manual case correction; automation defer | P1 | YES |
| ECO-D019 | Merchant Taxonomy | 67-leaf proposal bütünü owner-final olacak mı? | Ayrı owner review; confirmed subtree dışını final sayma | P0 | POLICY |
| ECO-D020 | Merchant Taxonomy | Secondary sector sayısı/evidence nedir? | En fazla üç, evidence/risk review | P1 | POLICY |
| ECO-D021 | Merchant Taxonomy | Sector organization mı branch mi atanır? | Org default + future branch override | P1 | POLICY |
| ECO-D022 | Policy | Hangi merchant/product policy sınıfları pilotta açılır? | Ordinary allowlist; unknown/regulated fail closed | P0 | YES |
| ECO-D023 | Merchant | Service/mixed merchants ve booking V1 kapsamı nedir? | Shop presence olabilir; service catalog/booking defer | P0 | POLICY |
| ECO-D024 | Listing | Availability freshness ve unknown customer dili nedir? | Threshold sonrası unknown; false stock/out-of-stock claim yok | P0 | POLICY |
| ECO-D025 | QR | Sibling branch confirmation/reissue nasıl çalışır? | Exact issued shop + explicit cancel/reissue | P0 | NO |
| ECO-D026 | QR | Variable-measure requested/actual snapshot nasıl doğrulanır? | Governed unit ile requested + merchant-confirmed actual | P0 | POLICY |
| ECO-D027 | Reviews/Merchant | Merchant review reply/moderation pilotta var mı? | Read/report only; replies defer | P1 | POLICY |
| ECO-D028 | Merchant App | Separate Flutter app mi controlled pilot tool mu? | Pilot operating path first; full separate app post-pilot | P1 | NO |
| ECO-D029 | Merchant | Push/email/in-app notification scope nedir? | Critical in-app; push only approved operational need | P2 | YES |
| ECO-D030 | Ads | Esenler pilotunda Ads var mı? | Organic-only pilot; Ads post-pilot shadow | P0 | YES |
| ECO-D031 | Ads | Ads olursa object/surface nedir? | Exact listing + Search-only controlled pilot | P0 | POLICY |
| ECO-D032 | Ads | Pricing/billing/auction modeli nedir? | Shadow first; then fixed/non-auction only if approved | P0 | YES |
| ECO-D033 | Ads | Location/behavior/policy eligibility nedir? | Contextual + coarse request location + narrow allowlist | P0 | YES |
| ECO-D034 | Ads | Attribution, under-delivery ve dispute nasıl ele alınır? | Reporting-only conservative attribution; manual pilot reconciliation | P1 | YES |
| ECO-D035 | Reward | Reward Engine pilotta var mı? | DEFER until purchase/funding/liability evidence | P0 | YES |
| ECO-D036 | Reward | Earning unit/scope/funding nedir? | Verified event; no formula until merchant/platform funding choice | P0 | YES |
| ECO-D037 | Reward | Redemption/expiry/cross-merchant transfer nedir? | No promise until trust/economics/legal review | P1 | YES |
| ECO-D038 | Reward | Purchase amount/quantity authoritative mi? | Assume NO until confirmation contract proves it | P0 | YES |
| ECO-D039 | Gamification | Badges/levels/challenges/streaks hangileri gerekir? | Badges-only future candidate; levels/challenges/streaks defer | P1 | YES |
| ECO-D040 | Reputation | Shop mı organization mı; public badge ne zaman? | Factual shop-level later; ratings independent; cold-start guard | P0 | POLICY |
| ECO-D041 | Ops | Pilot Ops role/case tooling minimumu nedir? | Named lean roles + manual case/evidence/runbook | P0 | YES |
| ECO-D042 | Ops | Hangi P0 actions second review/appeal ister? | Permanent/high-risk actions; reversible containment first | P1 | YES |
| ECO-D043 | Ops/Privacy | Case/audit/support retention nedir? | Purpose/class-specific; legal review | P1 | YES |
| ECO-D044 | Analytics | Pilot KPI/event registry neyi içerir? | Question-led minimum health/QR/discovery/quality metrics | P0 | YES |
| ECO-D045 | Analytics/Privacy | Consent/location/identity/retention sınırı nedir? | Minimized/coarse/thresholded; no customer-level profiling | P0 | YES |
| ECO-D046 | QA/Release | Hangi physical/manual/release gates zorunlu? | Exact artifact + platform/backend/QR gates; honest blocks | P0 | NO |
| ECO-D047 | QA/CI | CI matrix/skip/quarantine breadth nedir? | Risk-based minimum; skipped state explicit | P2 | NO |
| ECO-D048 | Demo/Roadmap | Demo retire ve post-pilot sequencing nasıl olur? | Dependency-aware soft retire; no blind cleanup/claim | P1 | NO |

Counts: raw=48; P0=28; P1=18; P2=2. Implementation details such as lock,
index, exact RPC name, CI vendor or queue transport are excluded.

