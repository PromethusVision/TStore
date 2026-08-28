# Sponsored Disclosure Standard

**State:** PROPOSED PRODUCT/LEGAL STANDARD — NOT FINAL UI DESIGN OR LEGAL ADVICE

## Evidence baseline

Türkiye's commercial-advertising framework requires advertising to be identifiable,
truthful and non-deceptive. The Ministry of Trade's July 2026 announcements describe
new digital-ad transparency and targeted-ad requirements effective 1 August 2026.
KVKK guidance separately treats advertising/marketing tracking and mobile ad-network
data flows as personal-data concerns. Exact implementation requires launch-time
legal/privacy review.

Primary sources:

- [Ministry of Trade — transparent digital advertising, 28 July 2026](https://ticaret.gov.tr/haberler/ticaret-bakanligindan-sosyal-medyada-seffaf-reklam-donemi)
- [Ministry of Trade — targeted-ad transparency and children, 28 July 2026](https://ticaret.gov.tr/haberler/ticaret-bakanligindan-cocuklarin-dijital-guvenligini-guclendirecek-onemli-duzenleme)
- [Ministry of Trade — commercial advertising principles](https://dabm.ticaret.gov.tr/tuketici/ticari-reklamlar)
- [KVKK — Cookie Practices Guide](https://www.kvkk.gov.tr/Icerik/7353/Cerez-Uygulamalari-Hakkinda-Rehber)
- [KVKK — Mobile Application Privacy Recommendations](https://www.kvkk.gov.tr/Icerik/7751/Mobil-Uygulamalarda-Mahremiyetin-Korunmasina-Yonelik-Tavsiyeler)
- [EU DSA Article 26, comparative transparency evidence](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=uriserv%3AOJ.L_.2022.277.01.0001.01.ENG)

## Mandatory conceptual rules

1. Every paid placement displays the exact Turkish text `Sponsorlu`.
2. The label is present at first render and remains visible in list/grid/compact,
   loading-complete, scroll/recycle and accessibility variants.
3. Text—not color, icon, position or styling alone—carries disclosure.
4. Label contrast, size and proximity make the paid relationship immediately
   understandable; it cannot be hidden in overflow or a details screen.
5. Sponsored cards cannot impersonate organic ranking, editorial recommendation,
   verification, cheapest or nearest status.
6. Advertiser/shop identity remains visible.
7. A directly reachable “Neden Sponsorlu?” explanation identifies the main
   contextual/location reasons and available controls without exposing security
   logic or personal profiles.
8. Customer reports preserve the served campaign/revision/disclosure evidence.

## Variant contract

Every creative/surface variant has a disclosure slot in its schema. A variant that
cannot render the label is ineligible to serve. Image failure, truncation or stale
cache must not remove disclosure. Screenshot/assistive-technology acceptance is a
future release gate.

## Prohibited copy

- `Önerilen`, `En iyi`, `En yakın`, `Doğrulandı` or `Fırsat` solely because payment
  occurred;
- a decorative `S` icon without text;
- disclosure only after click;
- low-contrast/zero-size label;
- merchant-provided label removal or replacement.

`SPONSORED_LABEL_TEXT: Sponsorlu`

`DISCLOSURE_CAN_DISAPPEAR: NO`

`LEGAL_REVIEW_REQUIRED: YES`
