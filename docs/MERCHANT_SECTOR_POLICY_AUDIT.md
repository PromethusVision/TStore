# EsnaftaVar Merchant Sector Policy Audit

**State:** POLICY RESEARCH — PROPOSED, FAIL-CLOSED, NOT LEGAL ADVICE

Taxonomy placement does not authorize a merchant, product, service, claim or
fulfilment method. The table identifies sectors where merchant-level verification
**may** be needed; the exact rule must be confirmed by the responsible owner using
current authoritative guidance before implementation.

## 1. Classification

- `NORMAL`: no sector-specific merchant gate identified beyond ordinary business,
  product and content obligations.
- `VERIFICATION_MAY_BE_REQUIRED`: the sector commonly intersects registration,
  hygiene, safety, authorization-claim or premises evidence; implementation needs an
  exact evidence matrix.
- `LEGAL_REVIEW_REQUIRED`: safe launch eligibility or scope cannot be inferred from
  the sector name. Fail closed until an explicit allow rule exists.

## 2. Official evidence

- [Ministry of Trade current profession/NACE list, 20 May 2026](https://ticaret.gov.tr/esnaf-sanatkarlar/esnaf-ve-sanatkar-meslek-kollari/sektor-meslek-nace-listeleri/guncel-liste)
- [Ministry of Agriculture food-business registration/approval](https://www.tarimorman.gov.tr/Konular/Gida-Ve-Yem-Hizmetleri/Gida-Hizmetleri/Kayit-Onay)
- [Ministry of Health Opticianry Law](https://shgmsmdb.saglik.gov.tr/TR-102383/optisyenlik-hakkinda-kanun.html)
- [Optical Establishments Regulation](https://www.saglik.gov.tr/TR%2C10467/optisyenlik-muesseseleri-hakkinda-yonetmelik.html)
- [Medical Device Sales, Advertising and Promotion Regulation amendment](https://resmigazete.gov.tr/eskiler/2023/05/20230526-9.htm)
- [Ministry of Trade jewellery-commerce framework](https://ticaret.gov.tr/ic-ticaret/kuyum-ticareti)
- [Ministry of Agriculture plant-protection products](https://www.tarimorman.gov.tr/Konular/Bitki-Sagligi-Hizmetleri/Bitki-Koruma-Urunleri-Ve-Makinalari/Bitki-Koruma-Urunleri)
- [Hygiene Training Regulation](https://uzunkoprusm.saglik.gov.tr/TR-38602/hijyen-egitimi-yonetmeligi.html)

## 3. Policy-signalled proposed sectors

| SECTOR | REGULATION SIGNAL | MERCHANT VERIFICATION MAY BE NEEDED | PRODUCT POLICY LINK | CLASS | NOTES |
|---|---|:---:|---|---|---|
| Market, Bakkal & Süpermarket | Food retail registration/official controls | YES | Food registration; alcohol/tobacco exclusions | VERIFICATION_MAY_BE_REQUIRED | General store status does not authorize every stocked product. |
| Kasap | Animal-origin food handling/cold chain | YES | Meat/product traceability | VERIFICATION_MAY_BE_REQUIRED | Exact registration/approval depends on activity. |
| Şarküteri | Food handling/cold chain | YES | Food label/storage controls | VERIFICATION_MAY_BE_REQUIRED | Production and retail activities may differ. |
| Manav | Fresh-produce traceability/food retail | YES | Harvested food vs live plant | VERIFICATION_MAY_BE_REQUIRED | Sector does not prove origin/traceability. |
| Fırın | Food production/retail and premises evidence | YES | Food registration/hygiene | VERIFICATION_MAY_BE_REQUIRED | Exact activity/premises must be verified. |
| Pastane & Tatlıcı | Food production/retail and hygiene | YES | Food/allergen/label controls | VERIFICATION_MAY_BE_REQUIRED | Catering remains separate. |
| Kuruyemişçi | Food processing/packaging possible | YES | Food registration/label controls | VERIFICATION_MAY_BE_REQUIRED | Roasting/packaging can change evidence needs. |
| İçecek & Su Bayii | Food/beverage retail | YES | Water/food registration; alcohol excluded | VERIFICATION_MAY_BE_REQUIRED | No automatic alcohol scope. |
| Aktar | Ingestibles, claims, cosmetics and plant-derived goods mix | YES | Supplement/medical/biosidal intended-use gate | LEGAL_REVIEW_REQUIRED | “Doğal” is not an eligibility class. |
| Elektronik Mağazası | Mains electrical goods/installation claims | POSSIBLY | Electrical conformity and recall evidence | VERIFICATION_MAY_BE_REQUIRED | Product evidence remains per SKU. |
| Beyaz Eşya & Ev Aletleri Mağazası | Electrical/gas/installation interaction | POSSIBLY | Electrical appliance and installer-only product gate | VERIFICATION_MAY_BE_REQUIRED | Delivery is not installation authorization. |
| Elektrik Malzemeleri Satıcısı | Building electrical installation products | POSSIBLY | Electrical conformity/fixed-installation boundary | VERIFICATION_MAY_BE_REQUIRED | Retail and licensed installation are different activities. |
| Yapı Malzemeleri Satıcısı | High-risk and installer-only products may appear | YES FOR CONTROLLED SCOPE | Installer-only/gas/structural product allowlist | LEGAL_REVIEW_REQUIRED | Do not approve all inventory from sector alone. |
| Tesisat Malzemeleri Satıcısı | Gas/water/heating installation products | YES FOR CONTROLLED SCOPE | Installer-only/high-risk systems | LEGAL_REVIEW_REQUIRED | Exact retail allowlist required. |
| Boya & Dekorasyon Malzemeleri Satıcısı | Chemical labeling/storage | POSSIBLY | Hazardous-goods/chemical policy | VERIFICATION_MAY_BE_REQUIRED | Paint mixing does not relax product rules. |
| Oto Yedek Parçacı | Safety-critical/fitment/used parts | POSSIBLY | Vehicle fitment, second-hand, recall | VERIFICATION_MAY_BE_REQUIRED | Merchant sector does not validate compatibility. |
| Oto Aksesuar Mağazası | Vehicle-fitment electronics/chemicals | POSSIBLY | Automotive/electrical/chemical policy | VERIFICATION_MAY_BE_REQUIRED | Generic electronics keep own product rules. |
| Lastikçi | Safety-critical goods and fitting | YES | Tyre conformity/fitment/service evidence | VERIFICATION_MAY_BE_REQUIRED | Default mixed model. |
| Motosiklet Mağazası | Vehicle and protective equipment | YES | Registration, PPE, fitment | VERIFICATION_MAY_BE_REQUIRED | Exact vehicle-commerce scope needs separate review if vehicles are transacted. |
| Motosiklet Yedek Parça & Aksesuar Mağazası | Fitment/safety-critical components | POSSIBLY | Vehicle fitment/PPE | VERIFICATION_MAY_BE_REQUIRED | Compatibility is not inferred from shop type. |
| Erkek Berberi | Body-contact service/hygiene | YES | Service hygiene | VERIFICATION_MAY_BE_REQUIRED | Owner-confirmed taxonomy leaf; booking remains TBD. |
| Kadın Kuaförü | Body-contact service/hygiene | YES | Service hygiene | VERIFICATION_MAY_BE_REQUIRED | Owner-confirmed taxonomy leaf; booking remains TBD. |
| Güzellik Salonu | Body-contact service and treatment boundary | YES | Hygiene; medical/treatment claim boundary | VERIFICATION_MAY_BE_REQUIRED | Owner-confirmed leaf; medical procedures are not inferred. |
| Anne & Bebek Mağazası | Infant food and safety-critical products | POSSIBLY | Formula, restraint, sleep and age-stage controls | VERIFICATION_MAY_BE_REQUIRED | Merchant verification does not replace product eligibility. |
| Balıkçılık & Av Malzemeleri Mağazası | Weapon-like/restricted inventory risk | YES BEFORE CONTROLLED SCOPE | Firearm/ammunition exclusion; exact allowlist | LEGAL_REVIEW_REQUIRED | Benign fishing goods do not authorize hunting inventory. |
| Pet Shop | Live-animal/veterinary product ambiguity | YES BEFORE CONTROLLED SCOPE | Live animals and veterinary medicine excluded from inference | LEGAL_REVIEW_REQUIRED | Ordinary pet supplies can remain in scope after sector scope is defined. |
| Akvaryumcu | Live-animal trade and electrical equipment may coexist | YES BEFORE CONTROLLED SCOPE | Live animals; electrical safety | LEGAL_REVIEW_REQUIRED | A product-only aquarium shop is lower risk but same label is ambiguous. |
| Pet Kuaförü | Animal grooming/welfare/hygiene | POSSIBLY | Veterinary service exclusion | VERIFICATION_MAY_BE_REQUIRED | No veterinary claim inferred. |
| Optik Mağazası | Statutory opticianry/establishment framework | YES | Prescription/custom optical and contact-lens policy | LEGAL_REVIEW_REQUIRED | Sector label alone cannot establish authorization. |
| Kuyumcu | Ministry authorization-certificate framework | YES | Precious/high-value goods; authenticity/fraud | LEGAL_REVIEW_REQUIRED | Exact business/evidence checks needed. |
| Medikal Ürün Mağazası | Medical-device sales-centre/product registration framework | YES | Device class, intended use, seller and advertising | LEGAL_REVIEW_REQUIRED | Medicine/pharmacy scope is excluded from inference. |
| Bahçe & Yetiştirme Ürünleri Mağazası | Plant-protection dealer authorization can apply | YES BEFORE CONTROLLED PRODUCTS | Pesticide/plant-protection exclusion or allowlist | LEGAL_REVIEW_REQUIRED | Ordinary plants/tools do not authorize regulated chemicals. |
| Telefon & Elektronik Teknik Servisi | Device data and authorized-service claims | POSSIBLY | Data handling; repair/warranty claims | VERIFICATION_MAY_BE_REQUIRED | “Yetkili servis” badge requires evidence. |
| Beyaz Eşya Teknik Servisi | Electrical/gas repair and authorized-service claims | YES | Technical service/installation safety | VERIFICATION_MAY_BE_REQUIRED | Scope depends on appliance/energy type. |
| Anahtarcı | Security-sensitive locksmith activity | POSSIBLY | Service identity/consumer safety | VERIFICATION_MAY_BE_REQUIRED | Mobile emergency service needs separate scope rules. |
| Kuru Temizleme & Çamaşırhane | Chemical use/workplace hygiene | POSSIBLY | Chemical handling and customer-property controls | VERIFICATION_MAY_BE_REQUIRED | Not a product-policy authorization. |

## 4. Count reconciliation

Across the **67 assignable proposal leaves**:

| Default merchant-policy class | Count |
|---|---:|
| NORMAL | 31 |
| VERIFICATION_MAY_BE_REQUIRED | 26 |
| LEGAL_REVIEW_REQUIRED | 10 |
| **Policy-signalled total** | **36** |
| **All assignable leaves** | **67** |

These counts classify merchant-sector launch posture, not the number of regulated
products. A `NORMAL` merchant can still sell a policy-gated product; a regulated
merchant can sell ordinary products.

## 5. Fail-closed rules

1. Missing evidence never becomes `NORMAL` automatically.
2. Merchant-sector selection never changes Auth role or grants a capability.
3. A licence/registration badge must be server-authoritative and independently
   verified in any future implementation.
4. Product eligibility is evaluated per product; sector is only one signal.
5. Legal/official requirements must be re-checked at implementation and launch time.
6. Pharmacy, veterinary clinic, live-animal commerce, pesticide dealer, weapons and
   restricted medicine are not silently inferred or added.

`MERCHANT_POLICY_AUDIT: PASS_FOR_OWNER_REVIEW`

`POLICY_SIGNALLED_ASSIGNABLE_SECTORS: 36`

`LEGAL_ADVICE_PROVIDED: NO`
