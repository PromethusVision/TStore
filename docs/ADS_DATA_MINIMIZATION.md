# Sponsored Advertising Data Minimization

**State:** PROPOSED PURPOSE/NECESSITY CLASSIFICATION — NO DATA COLLECTION

## MUST HAVE for contextual/local V1

- campaign/target/revision IDs;
- merchant, active shop, listing, canonical product/variant stable IDs;
- current campaign schedule, geo scope, eligibility/policy and budget state;
- current request surface and normalized contextual target;
- customer-selected/current/saved location context only as needed for local
  eligibility, preferably coarse in persisted decision data;
- disclosure variant and qualified delivery/interaction event IDs;
- audit reason, timestamps, idempotency and retention class.

## OPTIONAL after explicit owner/privacy review

- pseudonymous short-lived frequency-cap bucket;
- bounded direct-interaction attribution link;
- coarse device/surface capability for creative rendering;
- aggregated merchant-quality/fairness metrics;
- verified purchase reporting join under independent evidence and minimization;
- limited experiment assignment.

## DEFER / DO NOT COLLECT FOR V1

- cross-app/site advertising identifiers and third-party broker audiences;
- contact list, chat/message content or address book;
- long-term precise location trail;
- inferred sensitive health/financial/political/religious interests;
- child profiling;
- merchant-uploaded customer lists;
- raw device fingerprint solely for advertising;
- full raw query history linked indefinitely to an identified customer;
- data collected only because it may be useful later.

## Controls

Purpose, legal basis, notice/consent where applicable, access, retention/deletion,
processor/transfer and security must be approved before collection. Data unavailable
or consent declined must degrade to contextual/organic behavior, not block the core
app.

[KVKK Cookie Practices Guide](https://www.kvkk.gov.tr/Icerik/7353/Cerez-Uygulamalari-Hakkinda-Rehber)
and [Mobile Application Privacy Recommendations](https://www.kvkk.gov.tr/Icerik/7751/Mobil-Uygulamalarda-Mahremiyetin-Korunmasina-Yonelik-Tavsiyeler)
are evidence inputs; they do not replace case-specific legal review.

`ADS_V1_PERSONAL_PROFILE: NO`

`DATA_MINIMIZATION_MODEL: READY_FOR_OWNER_REVIEW`

`LEGAL_BASIS_FINALIZED: NO`
