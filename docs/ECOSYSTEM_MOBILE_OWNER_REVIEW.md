# Ecosystem Mobile Owner Review

**State:** 18 ROOT DECISIONS — NO ANSWER SELECTED
**Source:** `b3b5c928f36ff91e97e06a6d3ffad3858074489e`

Bu belge telefonda hızlı karar içindir. Öneri Product Owner kararı değildir.

## R01 — Pilot platformu ve release kanıtı

**SORU:** İlk ticari pilot hangi platformlarda ve hangi fiziksel/release kanıtlarıyla kabul edilecek?

**ÖNERİLEN:** A

**NEDEN:**

- Hazır olmayan platform sözü verilmez.
- Exact signed artifact ve fiziksel gate netleşir.
- CI sonucu tek başına release sayılmaz.

**A:** Android-only pilot; iOS ayrı hazır olduğunda açılır.

**B:** Android ve iOS aynı anda, ikisi de exact kanıtla açılır.

**C:** Ticari pilot yerine süresiz araştırma build’leri sürer.

**ETKİLEDİĞİ:** Customer App, QA/Release, CI

**BU KARARLA ÇÖZÜLEN:** 4 alt karar + 2 conflict.

**RİSK:** HIGH

**CEVAP FORMATI:** R01=A

---

## R02 — Nearby ve yerel geçmiş

**SORU:** Nearby herkese açık mı olacak ve cihazda ne kadar yerel geçmiş tutulacak?

**ÖNERİLEN:** B

**NEDEN:**

- Konum izni faydadan önce istenir.
- Yerel geçmiş minimum ve silinebilir kalır.
- Geniş konum profili oluşmaz.

**A:** Nearby login ister; yerel geçmiş tutulmaz.

**B:** Nearby izin güvenli biçimde açıktır; minimum silinebilir cihaz geçmişi tutulur.

**C:** Geniş hesap ve konum geçmişi tutulur.

**ETKİLEDİĞİ:** Customer App, Privacy, Analytics

**BU KARARLA ÇÖZÜLEN:** 2 alt karar + 0 conflict.

**RİSK:** MEDIUM

**CEVAP FORMATI:** R02=A

---

## R03 — Taxonomy ve demo aktivasyonu

**SORU:** Final taxonomy, facet, legacy mapping ve demo veri runtime’a nasıl taşınacak?

**ÖNERİLEN:** B

**NEDEN:**

- Final ve proposed durumları karışmaz.
- Stable ID ve rollback korunur.
- Demo veri körlemesine silinmez.

**A:** Tüm taxonomy/facet/legacy/demo yapısı birlikte değiştirilir.

**B:** Stable ID ile aşamalı migration ve bağımlılık-aware demo retirement yapılır.

**C:** Mevcut yapı süresiz dondurulur.

**ETKİLEDİĞİ:** Product Taxonomy, Search/Facet, Catalog, Demo

**BU KARARLA ÇÖZÜLEN:** 4 alt karar + 1 conflict.

**RİSK:** MEDIUM

**CEVAP FORMATI:** R03=A

---

## R04 — Product, Variant ve Listing kimliği

**SORU:** V1’de Product, Variant, Listing ve barcode kimlikleri nasıl ayrılacak?

**ÖNERİLEN:** B

**NEDEN:**

- Fiyat ve stok listing’de kalır.
- Variant yalnız gerekli domainlerde açılır.
- Barcode çakışması blind merge üretmez.

**A:** Product ve Listing kullanılır; explicit Variant yoktur.

**B:** Product + domain-gated Variant + ayrı Listing ve evidence-based identifier kullanılır.

**C:** Her domain için universal Variant ve blind barcode eşleşmesi kullanılır.

**ETKİLEDİĞİ:** Catalog, Backend, Search, QR, Reviews, Ads

**BU KARARLA ÇÖZÜLEN:** 3 alt karar + 1 conflict.

**RİSK:** HIGH

**CEVAP FORMATI:** R04=A

---

## R05 — Catalog intake, ölçü ve medya

**SORU:** Merchant’ın ürettiği candidate, variable-measure ve medya ne zaman customer-visible olabilir?

**ÖNERİLEN:** B

**NEDEN:**

- Catalog kirliliği ve hak ihlali azalır.
- Ölçü yalnız QR snapshot kontratıyla açılır.
- Merchant verisi otomatik canonical olmaz.

**A:** Merchant verisi doğrudan public canonical olur.

**B:** Governed candidate, gated measure ve reviewed media promotion kullanılır.

**C:** Merchant catalog katkısı tamamen kapatılır.

**ETKİLEDİĞİ:** Catalog, Merchant App, QR, Storage, Policy

**BU KARARLA ÇÖZÜLEN:** 3 alt karar + 2 conflict.

**RİSK:** HIGH

**CEVAP FORMATI:** R05=A

---

## R06 — Catalog düzeltmeleri ve review geçmişi

**SORU:** Product merge/split olduğunda purchase ve review geçmişi nasıl korunacak?

**ÖNERİLEN:** B

**NEDEN:**

- Verified evidence silinmez.
- Review hakkı uydurulmaz.
- Belirsiz collision görünür kalır.

**A:** Eski referanslar yeniden yazılır veya silinir.

**B:** Immutable lineage korunur; collision ve ambiguity açık yönetilir.

**C:** Catalog correction tamamen yasaklanır.

**ETKİLEDİĞİ:** Catalog, Verified Purchase, Reviews, Backend

**BU KARARLA ÇÖZÜLEN:** 2 alt karar + 1 conflict.

**RİSK:** HIGH

**CEVAP FORMATI:** R06=A

---

## R07 — Merchant organizasyonu ve staff

**SORU:** Pilotta organization, shop, branch ve staff kapsamı ne kadar olacak?

**ÖNERİLEN:** B

**NEDEN:**

- Shop yetkisi profile label’a bağlanmaz.
- Owner/verifier rolleri yeterli olur.
- Enterprise çoklu-şube ertelenir.

**A:** Tek direct owner modeli kullanılır.

**B:** One-shop organization seam ve owner/verifier presetleri kullanılır.

**C:** Enterprise roller ve full multi-branch ilk günden açılır.

**ETKİLEDİĞİ:** Merchant App, Backend, RLS, QR

**BU KARARLA ÇÖZÜLEN:** 3 alt karar + 3 conflict.

**RİSK:** HIGH

**CEVAP FORMATI:** R07=A

---

## R08 — Merchant Sector finalizasyonu

**SORU:** Proposed 67 sector leaf nasıl owner-final olacak ve organization/branch’e nasıl atanacak?

**ÖNERİLEN:** B

**NEDEN:**

- Proposal sessizce canonical olmaz.
- Confirmed subtree sınırı korunur.
- Branch override geleceğe açık kalır.

**A:** 67-leaf proposal doğrudan final sayılır.

**B:** Owner review yapılır; org default, future branch override ve sınırlı secondary kullanılır.

**C:** Merchant Sector sınıflandırması kullanılmaz.

**ETKİLEDİĞİ:** Merchant Taxonomy, Onboarding, Policy, Merchant App

**BU KARARLA ÇÖZÜLEN:** 3 alt karar + 2 conflict.

**RİSK:** MEDIUM

**CEVAP FORMATI:** R08=A

---

## R09 — Policy allowlist ve services

**SORU:** Pilotta hangi ürün/merchant policy grupları ve service yetenekleri açılacak?

**ÖNERİLEN:** B

**NEDEN:**

- Unknown ve regulated ürünler fail closed kalır.
- Ordinary retail pilotu gecikmez.
- Booking/service engine vaat edilmez.

**A:** Tüm gruplar self-service açılır.

**B:** Ordinary allowlist açılır; unknown/regulated kapanır; service presence var, booking yoktur.

**C:** Her ürün ve merchant manuel review ister.

**ETKİLEDİĞİ:** Policy, Merchant Taxonomy, Catalog, Ops, Ads, Reward

**BU KARARLA ÇÖZÜLEN:** 2 alt karar + 1 conflict.

**RİSK:** HIGH

**CEVAP FORMATI:** R09=A

---

## R10 — Listing doğruluğu ve iletişim

**SORU:** Availability freshness, review etkileşimi ve notification kapsamı ne olacak?

**ÖNERİLEN:** B

**NEDEN:**

- Stale veri yanlış stok iddiasına dönüşmez.
- Review replies pilot dışında kalır.
- Kritik iletişim spam üretmez.

**A:** Best-effort stok, full replies ve tüm kanallar açılır.

**B:** Stale sonrası unknown, read/report review ve kritik in-app kanal kullanılır.

**C:** Merchant operasyon ve iletişim özelliği açılmaz.

**ETKİLEDİĞİ:** Listing, Merchant App, Reviews, Notifications, Analytics

**BU KARARLA ÇÖZÜLEN:** 3 alt karar + 2 conflict.

**RİSK:** MEDIUM

**CEVAP FORMATI:** R10=A

---

## R11 — QR shop ve miktar kanıtı

**SORU:** Sibling branch QR doğrulayabilir mi ve actual quantity nasıl kanıtlanacak?

**ÖNERİLEN:** B

**NEDEN:**

- Wrong-shop confirmation kapanır.
- Reissue açık ve izlenebilir olur.
- Actual quantity merchant-confirmed kalır.

**A:** Organization içindeki her branch doğrular; customer quantity kabul edilir.

**B:** Exact shop + explicit reissue; enabled ise requested ve merchant-confirmed actual tutulur.

**C:** Exact shop doğrular; yalnız fixed-unit ürünler desteklenir.

**ETKİLEDİĞİ:** QR, Merchant App, Catalog, Reviews, Reward

**BU KARARLA ÇÖZÜLEN:** 2 alt karar + 3 conflict.

**RİSK:** HIGH

**CEVAP FORMATI:** R11=A

---

## R12 — Merchant App teslim şekli

**SORU:** Pilot öncesi full ayrı Merchant App mi, kontrollü operating path mi?

**ÖNERİLEN:** B

**NEDEN:**

- Pilot full app nedeniyle gecikmez.
- Security sınırı backend capability’de kalır.
- Ayrı app için doğru seam korunur.

**A:** Full ayrı Merchant App pilot öncesi tamamlanır.

**B:** Önce secure verifier/listing path, sonra ayrı Merchant App geliştirilir.

**C:** Merchant işlemleri Customer App role tab’larında yapılır.

**ETKİLEDİĞİ:** Merchant App, Customer App, Backend

**BU KARARLA ÇÖZÜLEN:** 1 alt karar + 1 conflict.

**RİSK:** MEDIUM

**CEVAP FORMATI:** R12=A

---

## R13 — Ads pilot kapsamı

**SORU:** Esenler pilotunda Ads olacak mı; olacaksa hangi object ve surface kullanılacak?

**ÖNERİLEN:** A

**NEDEN:**

- Organic değer önce kanıtlanır.
- Billing ve trust yükü pilotu geciktirmez.
- Sonraki test exact Listing/Search ile sınırlanır.

**A:** Pilot organic-only olur.

**B:** Pilot sonrası exact-listing Search shadow denenir.

**C:** Multi-surface canlı Ads pilotta açılır.

**ETKİLEDİĞİ:** Ads, Catalog, Search, Merchant App, Ops

**BU KARARLA ÇÖZÜLEN:** 2 alt karar + 3 conflict.

**RİSK:** MEDIUM

**CEVAP FORMATI:** R13=A

---

## R14 — Ads ekonomi, privacy ve attribution

**SORU:** Ads açılırsa ücretlendirme, targeting ve attribution modeli ne olacak?

**ÖNERİLEN:** C

**NEDEN:**

- Önce para almadan delivery kanıtlanır.
- Behavioral profiling zorunlu olmaz.
- CPA/sales iddiası yapılmaz.

**A:** Fixed non-auction, contextual/coarse-location ve conservative reporting kullanılır.

**B:** CPC/CPA/auction ve behavioral targeting açılır.

**C:** Shadow-only çalışır; para alınmaz.

**ETKİLEDİĞİ:** Ads, Billing, Privacy, Analytics, Ops

**BU KARARLA ÇÖZÜLEN:** 3 alt karar + 2 conflict.

**RİSK:** HIGH

**CEVAP FORMATI:** R14=A

---

## R15 — Reward ekonomik kontratı

**SORU:** Reward pilotta açılacak mı; değer kim tarafından hangi kanıtla finanse edilip kullanılacak?

**ÖNERİLEN:** A

**NEDEN:**

- Authoritative tutar henüz varsayılamaz.
- Fonlama ve liability kararı yoktur.
- Review hakkı reward’dan bağımsız kalır.

**A:** Pilotta Reward olmaz.

**B:** Pilot sonrası verified-event shadow ledger kurulur.

**C:** Canlı cross-merchant points şimdi açılır.

**ETKİLEDİĞİ:** Reward, QR, Reviews, Merchant, Ops, Finance

**BU KARARLA ÇÖZÜLEN:** 4 alt karar + 2 conflict.

**RİSK:** HIGH

**CEVAP FORMATI:** R15=A

---

## R16 — Gamification ve reputation

**SORU:** Pilotta hangi badge, level ve merchant reputation sinyalleri public olacak?

**ÖNERİLEN:** A

**NEDEN:**

- Sparse veri haksız skor üretmez.
- Rating görünür ve bağımsız kalır.
- Dark-pattern spending baskısı oluşmaz.

**A:** Pilotta public gamification/reputation olmaz.

**B:** Yeterli veri sonrası explainable badge ve factual shop signals açılır.

**C:** Levels, challenges ve composite public score açılır.

**ETKİLEDİĞİ:** Gamification, Reputation, Reviews, Merchant, Analytics

**BU KARARLA ÇÖZÜLEN:** 2 alt karar + 2 conflict.

**RİSK:** MEDIUM

**CEVAP FORMATI:** R16=A

---

## R17 — Lean Operations governance

**SORU:** Pilot için hangi Ops rolleri, case/audit, second review ve retention gerekir?

**ÖNERİLEN:** B

**NEDEN:**

- P0 işlemler izlenebilir olur.
- Reversible containment önce gelir.
- Enterprise control plane gerekmez.

**A:** Formal Ops süreci kurulmaz.

**B:** Scoped roller, manual case/audit ve permanent P0 için second review kullanılır.

**C:** Enterprise otomatik control plane kurulur.

**ETKİLEDİĞİ:** Operations, Trust & Safety, Backend, Privacy, QA

**BU KARARLA ÇÖZÜLEN:** 3 alt karar + 2 conflict.

**RİSK:** HIGH

**CEVAP FORMATI:** R17=A

---

## R18 — Analytics amacı ve privacy

**SORU:** Pilotta hangi event/KPI tutulacak ve retention/privacy sınırı ne olacak?

**ÖNERİLEN:** A

**NEDEN:**

- Yalnız karar sorusuna bağlı veri toplanır.
- Konum ve kimlik minimize edilir.
- Telemetry domain authority olmaz.

**A:** Minimum health, QR ve discovery ölçümleri coarse/minimized inputs ile tutulur.

**B:** Geniş customer funnels ve profiles tutulur.

**C:** Yalnız operasyon logları tutulur; product learning ölçülmez.

**ETKİLEDİĞİ:** Analytics, Observability, Privacy, Ops, QA

**BU KARARLA ÇÖZÜLEN:** 2 alt karar + 5 conflict.

**RİSK:** HIGH

**CEVAP FORMATI:** R18=A

---

`OWNER_SELECTIONS: 0`
