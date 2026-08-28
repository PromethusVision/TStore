# Operations Admin Search Model

**State:** PROPOSED — NO SEARCH INDEX OR UI

## Supported keys

| Key | Default result |
|---|---|
| CASE_ID | exact case and authorized linked subjects |
| MERCHANT/SHOP | minimized identity, lifecycle, verification, open cases |
| PRODUCT/LISTING | identity/provenance/current policy/moderation state |
| CUSTOMER_ACCOUNT | only justified exact account lookup for assigned purpose |
| QR_TRANSACTION | exact state/evidence timeline without raw QR |
| REVIEW/CAMPAIGN/EVENT | exact object and linked case where feature exists |
| REQUEST/TRACE_ID | safe operational correlation |

## Rules

Prefer exact opaque IDs. Name/email/phone searches require higher purpose and return minimized candidates; avoid broad prefix enumeration. Every query checks operator capability, assigned case/queue, subject scope, sensitivity, and environment. Search access and exports are audited.

## Results

Show safe summary, why result matched, lifecycle/policy freshness, open restriction/appeal, and authorized actions. Do not display passwords, tokens, raw documents, precise location, private content, reporter identity, fraud thresholds, or cross-tenant data.

## Abuse controls

Rate limits, exact-search preference, minimum query quality, no wildcard bulk dump, sensitive-field reveal step with reason/re-auth, anti-enumeration errors, session assurance, anomaly review, and export caps.

Search is navigation—not authority. Opening a result does not grant mutation capability. Production and Development identities never mix.

`ADMIN_SEARCH_IMPLEMENTED: NO`

`BROAD_CUSTOMER_SEARCH_DEFAULT: NO`
