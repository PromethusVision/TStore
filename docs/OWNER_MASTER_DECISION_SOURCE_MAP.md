# Owner Master Decision Source Map

State: `READ-ONLY SOURCE RECONCILIATION — NO OPTION SELECTED`

## Purpose

Bu belge Wave 31 karar envanterinin kaynak kapsamını ve öncelik kurallarını
sabitler. Kaynak branch'ler okunmuş, birleştirilmemiştir. Her kaynak soru
`OWNER_MASTER_RAW_DECISION_INVENTORY.csv` içinde kaynak HEAD'iyle korunur.

## Pinned primary sources

| Wave | Branch | HEAD | Owner-decision source | Ingested |
|---|---|---|---|---:|
| 23 | `origin/agent1/w23-ecosystem-master-reconciliation` | `b3b5c928f36ff91e97e06a6d3ffad3858074489e` | `ECOSYSTEM_OWNER_DECISION_INVENTORY.md` | 48 |
| 25 | `origin/agent1/w25-global-owner-fast-review-pack` | `b5a62284c8ce6ddc03d66b3e2d78b8d3efd0ed55` | `ECOSYSTEM_MOBILE_OWNER_REVIEW.md` | 18 |
| 24 | `origin/agent2/w24-turkiye-platform-compliance-foundation` | `57bb5734d8e1770d56b3437046b43ea10e6774b2` | `COMPLIANCE_OWNER_DECISION_INVENTORY.md` | 24 |
| 26 | `origin/agent3/w26-esenler-commercial-pilot-foundation` | `aaccff79561c7f10eed9038add590d9ea5d993f9` | `PILOT_OWNER_DECISION_INVENTORY.md` | 45 |
| 28 | `origin/agent2/w28-unified-review-reputation-algorithm-foundation` | `4404ac338d145662b7751704c2d6df9c679d31f4` | `REVIEW_ALGO_OWNER_DECISION_INVENTORY.md` | 30 |
| 29 | `origin/agent3/w29-customer-ui-owner-fast-review` | `9a708f6e8cfcbad2876a967802525fbedda53dcc` | `UI_MOBILE_OWNER_REVIEW.md` | 15 |
| 30 | `origin/agent2/w30-minimum-merchant-pilot-surface` | `a7532adbdab068fc262054c90dc7c1bf4d8b1d32` | `MERCHANT_PILOT_OWNER_DECISIONS.md` | 24 |

`RAW_SOURCE_DECISIONS: 204`

## Authority and precedence

1. Product Owner tarafından açıkça final ilan edilmiş mevcut ürün kontratları
   seçenek değildir; yeni karar bunları sessizce geri açamaz.
2. Wave 25'in 18 ekosistem kökü başlangıç omurgasıdır, değişmez bir sayı
   değildir.
3. Wave 24 hukuki hüküm üretmez; profesyonel girdiyi ve fail-closed sınırı
   belirler.
4. Wave 26 ticari pilot kapsamını, Wave 30 ise merchant-side minimum uygulama
   yüzeyini tanımlar. Bu iki karar ailesi aynı değildir.
5. Wave 28'deki tek görünür değerlendirme yönü korunur; form ayrıntıları,
   contribution policy ve badge algoritmaları seçilmiş sayılmaz.
6. Wave 29'un sekiz implementation gate'i görünür kalır; global kökle çakışan
   AuthGuard ve exact-artifact kabulü ikinci kez sorulmaz.

## Established constraints, not fresh owner questions

- Verified product review eligibility yalnız merchant-confirmed QR purchase
  evidence'ından gelir.
- İkinci merchant free-text review sistemi yaratılmaz.
- Product rating ve structured shop evaluation aggregate'leri karıştırılmaz.
- Ads harcaması ve Reward katılımı reputation kanıtı değildir.
- Exact-shop authorization, QR idempotency, secret handling, immutable catalog
  lineage ve exact-artifact identity mühendislik/güvenlik invariant'larıdır.
- Regulated kapsam profesyonel onay olmadan açılmaz.

## Professional-review sources

Wave 24'ün 32 soruluk profesyonel kuyruğu ayrıca okundu: 12 lawyer, 7 KVKK,
1 accountant/tax, 6 domain regulatory, 2 Product Owner ve 4 technical architect.
Bu sorular owner kararıymış gibi çoğaltılmadı; ilgili master köklerin
`PROFESSIONAL REVIEW` alanına bağlandı.

## Scope safety

- Source branches merged: `NO`
- Existing source documents modified: `NO`
- Runtime/DB/Figma/environment touched: `NO`
- Owner or professional decision selected: `NO`
