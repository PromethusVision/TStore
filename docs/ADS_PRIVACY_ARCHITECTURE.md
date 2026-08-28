# Sponsored Advertising Privacy Architecture

**State:** PROPOSED PRIVACY-BY-DESIGN — LEGAL REVIEW REQUIRED, NO RUNTIME

## Recommended V1 posture

Use current contextual intent plus bounded local location context. Avoid behavioral
profiles, third-party ad identifiers, audience brokers, contact/customer lists and
cross-app retargeting.

## Data-purpose map

| Purpose | Minimum candidate data | Prohibited shortcut |
|---|---|---|
| Eligibility | campaign/listing/shop/product/policy/budget state | Customer profile not needed |
| Local relevance | explicit current/saved/selected location context; shop coordinate | Long-term precise movement trail |
| Contextual relevance | current query/product/category/surface | Indefinite linked search history |
| Frequency safety | request/session counter; short pseudonymous bucket if approved | Device fingerprint/cross-app ID |
| Measurement | event/campaign/target IDs and minimal context | Unnecessary raw messages/contact data |
| Fraud | proportionate integrity/rate/anomaly signals | Unlimited surveillance because fraud is possible |
| Reporting | aggregate/minimum-sample metrics | Customer-level merchant export |

## Current evidence

- [KVKK Cookie Practices Guide](https://www.kvkk.gov.tr/Icerik/7353/Cerez-Uygulamalari-Hakkinda-Rehber)
  treats advertising/marketing tracking and online behavioral advertising as
  personal-data processing contexts requiring purpose/legal-basis analysis.
- [KVKK Mobile Application Privacy Recommendations](https://www.kvkk.gov.tr/Icerik/7751/Mobil-Uygulamalarda-Mahremiyetin-Korunmasina-Yonelik-Tavsiyeler)
  notes that app providers, ad networks and other actors can have distinct roles.
- [Ministry of Trade 2026 targeted-ad announcement](https://ticaret.gov.tr/haberler/ticaret-bakanligindan-cocuklarin-dijital-guvenligini-guclendirecek-onemli-duzenleme)
  describes criteria/control transparency and a prohibition on profiling-based
  targeted ads to children effective 1 August 2026.

These are research inputs, not case-specific legal advice.

## Gates before implementation

- controller/processor roles and purposes;
- lawful basis, notice and consent/control where required;
- children/sensitive-data detection without creating more risky profiling;
- exact location/query/event retention and deletion;
- access, security, processors and international transfer;
- customer access/objection/deletion consequences;
- aggregate/minimum-sample merchant reporting;
- privacy impact and launch-time legal review.

Declining optional ad personalization must not block organic discovery. Contextual
and location behavior must use only the data permitted for the current purpose.

`ADS_V1_BEHAVIORAL_PROFILING: NO`

`CHILD_PROFILED_TARGETING: PROHIBITED_CANDIDATE`

`PRIVACY_LEGAL_REVIEW_REQUIRED: YES`
