# Sponsored Targeting Architecture

**State:** PRIVACY-MINIMIZING V1 PROPOSAL — NO TARGETING RUNTIME

## Three targeting classes

| Class | Examples | V1 recommendation | Review posture |
|---|---|---|---|
| `CONTEXTUAL_TARGETING` | Current query, opened canonical product, current category, current surface/time | MUST HAVE | Use stable IDs and current intent; no profile required |
| `LOCATION_TARGETING` | Verified shop, current/saved/selected location, bounded radius/district | MUST HAVE | Purpose limitation, honest fallback and geo privacy required |
| `BEHAVIORAL_PERSONAL_TARGETING` | Cross-session history, inferred interests, retargeting, lookalikes | DEFER | Privacy/legal/consent and child-safety review required |

## V1 inputs

- normalized current search intent and ambiguity state;
- canonical product/variant or current Product Taxonomy stable ID;
- active shop listing and shop location;
- customer-selected/current/saved location context;
- current time/window;
- coarse surface/device capability needed for rendering;
- merchant-sector signal only as weak business-context metadata.

## Explicitly excluded from V1

- third-party data brokers or external ad identifiers;
- special-category/sensitive personal data;
- inferred health, financial, political, religious or similar interests;
- profiling children or child-directed behavioral targeting;
- contact-list, message/chat or precise location-history targeting;
- merchant-uploaded customer lists;
- cross-app/device retargeting;
- reward/gamification behavior as an ad-targeting shortcut.

## Targeting resolution

1. Preserve raw intent for audit but use normalized/contextual representation.
2. Resolve category/product/search targets through versioned stable identities.
3. Apply policy exclusions before relevance scoring.
4. Intersect merchant campaign scope with platform local maximum.
5. Prefer explicit current context over historical inference.
6. If ambiguity cannot be resolved, show grouped organic results or no ad.

The Ministry of Trade's 2026 targeted-ad transparency direction and KVKK guidance
make implementation-time legal/privacy review mandatory. This document does not
declare a legal basis or consent design.

`ADS_V1_TARGETING: CONTEXTUAL_PLUS_LOCATION`

`BEHAVIORAL_PROFILING_V1: NO`

`PERSONAL_DATA_LEGAL_BASIS_FINALIZED: NO`
