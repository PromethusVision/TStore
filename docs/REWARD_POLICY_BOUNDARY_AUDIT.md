# Reward Policy Boundary Audit

**State:** PROPOSED — LEGAL/POLICY REVIEW REQUIRED

**Scope:** Workstream BB

**Research checked:** 2026-08-28

**Advice status:** Product architecture risk review, not legal advice

## Fail-closed rule

Policy-sensitive products and services receive no economic reward, progress, voucher, challenge credit, urgency message or merchant-funded incentive until Product Owner approval follows current legal/policy review. Ordinary catalog visibility does not imply reward eligibility.

## Current official-source findings

| Domain | Official evidence | Architecture posture |
|---|---|---|
| Alcohol | The Ministry of Agriculture and Forestry's 26 June 2026 notice states that consumer advertising/promotion and campaigns or promotions encouraging use/sale are prohibited under the amended Article 6 of Law 4250. The Ministry's published Law 4250 text also prohibits incentive, gift, promotional or free alcohol distribution. | `EXCLUDED_PENDING_LEGAL_REVIEW`; no earn, redeem, threshold, campaign or near-threshold messaging tied to alcohol. |
| Tobacco/nicotine | The Ministry's sales/presentation regulation prohibits promotion, campaigns and purchase-conditioned gifts/promotions for tobacco products. | `EXCLUDED`; do not create reward events, badges or challenges from purchase. |
| Human medicinal products | The Ministry of Health maintains the Regulation on Promotional Activities of Medicinal Products for Human Use; consumer-oriented reward mechanics could be promotional conduct and need specialist review. | `EXCLUDED_PENDING_LEGAL_REVIEW`; medicine purchase is not a gamification event. |
| Health services | The 2025 Ministry of Health regulation says overt or covert advertising in health service provision is prohibited and defines narrow informational boundaries. | `EXCLUDED_PENDING_LEGAL_REVIEW`; no reward/challenge for obtaining treatment or procedure. |
| Supplements and health claims | Ministry/TİTCK sources state supplement approval and health-claim controls are regulated; the Food Safety portal warns against non-compliant health claims. | `EXCLUDED_PENDING_POLICY_REVIEW`; no health-outcome language or incentive until product approval/status is trusted. |
| Infant/young-child nutrition | Ministry sources distinguish tightly controlled supplement/food categories and state that supplement approval is not issued for children under two. Broader infant-formula incentive rules require dedicated review. | `EXCLUDED_PENDING_LEGAL_REVIEW`; fail closed rather than infer eligibility from `Gıda & İçecek`. |
| Medical devices / optical products | Medical/optical classification and promotion can differ by product and prescription status. | `EXCLUDED_PENDING_LEGAL_REVIEW`; ordinary non-medical accessories require explicit classification before inclusion. |
| Hunting, weapons, pyrotechnics | Sale, age, licensing and promotion constraints may differ by item; taxonomy alone is insufficient. | `EXCLUDED_PENDING_LEGAL_REVIEW`; no challenges or spend incentives. |
| Chemicals, pesticides and regulated garden inputs | Authorization and safe-use constraints vary by product. | `EXCLUDED_PENDING_POLICY_REVIEW`; item-level allowlist only after review. |
| Customer profiling | KVKK materials highlight transparency, discrimination and automated-decision risks; Article 11 includes an objection right regarding adverse results produced solely by automated analysis. | Reward/reputation must be explainable, minimize purchase detail, permit correction/dispute and never create punitive social-credit scoring. |

## Sources

- [Ministry of Agriculture and Forestry — 2026 alcohol advertising amendment notice](https://www.tarimorman.gov.tr/TADAB/Duyuru/280/Alkollu-Icki-Reklamlarina-Iliskin-Mevzuatta-Yapilan-Degisiklik-Hakkinda-Duyuru)
- [Ministry of Agriculture and Forestry — Law No. 4250 consolidated publication](https://www.tarimorman.gov.tr/TADAB/Belgeler/Kanunlar/kanun_4250.pdf)
- [Ministry of Agriculture and Forestry — tobacco/alcohol sales and presentation regulation](https://www.tarimorman.gov.tr/TADAB/Belgeler/Y%C3%B6netmelikler/yonetmelik_27808_07.01.2011.pdf)
- [Ministry of Health — Medicinal Products Promotional Activities Regulation](https://erisilebilir.saglik.gov.tr/TR-10458/beseri-tibbi-urunlerin-tanitim-faaliyetleri-hakkinda-yonetmelik.html)
- [Ministry of Health — Health Services Promotion and Information Regulation](https://antalyaism.saglik.gov.tr/TR-366500/saglik-hizmetlerinde-tanitim-ve-bilgilendirme--faaliyetleri-hakkinda-yonetmelik.html)
- [TİTCK — Health-claim controls](https://saglikbeyani.titck.gov.tr/)
- [Ministry of Agriculture and Forestry — supplement approval process](https://istanbul.tarimorman.gov.tr/Sayfalar/Detay.aspx?SayfaId=233)
- [Ministry of Agriculture and Forestry — food and supplement health-claim warning](https://guvenilirgida.tarimorman.gov.tr/Haber/Detay/17281)
- [KVKK — profiling and automated-decision seminar summary](https://www.kvkk.gov.tr/Icerik/5509/Carsamba-Seminerleri-Profilleme-Uygulamalari-Kapsaminda-Kisisel-Verilerin-Korunmasi)

## Product-policy fields required before implementation

Conceptually, a versioned policy decision needs stable product/variant identity, jurisdiction, age restriction, regulated class, reward eligibility, redemption eligibility, reason code, effective interval and reviewing authority. This document does not define schema or SQL.

Unknown/missing/expired policy means ineligible. A later category rename or product merge cannot silently reclassify historical events. Historical events retain the policy snapshot and decision reason used at evaluation time.

## Interaction boundaries

- A merchant cannot override a platform exclusion or label a regulated item as ordinary.
- Ads eligibility and reward eligibility are separate; sponsored placement never bypasses a policy block.
- Excluded purchases retain lawful purchase/review evidence where applicable, but generate no reward or badge progress.
- A mixed purchase can settle eligible items without rewarding excluded items only if item-level authoritative evidence exists; otherwise the whole reward evaluation fails closed.
- No public badge may reveal a customer's health, alcohol, tobacco, infant-care or other sensitive purchase behavior.

## Required reviews before any pilot

1. Turkish legal review of reward, voucher, campaign and promotion treatment by regulated domain.
2. Accounting/tax review for economic value, funding, expiry and reversals.
3. Privacy review of profiling, notices, retention, correction and public display.
4. Product-policy registry ownership and an operational escalation path.
5. Test evidence proving policy unknown/error states issue zero economic value.

## Recommendation

Do not include policy-sensitive domains in a commercial reward pilot. Start, if approved at all, with a narrow explicit allowlist of ordinary goods after legal, accounting and privacy review. This recommendation is not owner-approved or canonical.
