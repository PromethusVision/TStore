# Merchant App Abuse Case Registry

Status: **PROPOSED — SECURITY/OPERATIONS REVIEW REQUIRED**
Wave: 17 / WP111

| ID | Abuse | Control family | Priority |
|---|---|---|---|
| AB-01 | Fake merchant/shop registration | Verification, allowlist, evidence review | P0 |
| AB-02 | Stolen account/device | Strong session controls, revoke, alerts | P0 |
| AB-03 | Staff grants self owner rights | Server capability boundary | P0 |
| AB-04 | Cross-shop ID enumeration | Scoped reads and non-leaking errors | P0 |
| AB-05 | QR forwarding/replay | Short TTL, shop binding, one-time consume | P0 |
| AB-06 | Staff colludes for fake confirmations | Audit, anomaly/rate controls, evidence review | P0 |
| AB-07 | Price bait then unavailable | Freshness/history, customer reporting, policy | P1 |
| AB-08 | Listing spam/duplicate products | Search-first, fingerprint, moderation/rate limit | P1 |
| AB-09 | Barcode hijack | Conflict review; no blind auto-link | P0 |
| AB-10 | Regulated category evasion | Product/merchant policy independent fail-closed | P0 |
| AB-11 | Review retaliation/coercion | No edit/delete, governed reporting, monitoring | P1 |
| AB-12 | Mass false review reports | Dedup/rate limits/moderation audit | P1 |
| AB-13 | Malicious/rights-violating media | MIME/content/rights moderation | P1 |
| AB-14 | Analytics probing customers | Aggregation, cohort thresholds, no drilldown | P0 |
| AB-15 | Buying badge/organic rank | Ads disclosure and reputation separation | P1 |
| AB-16 | Notification/deep-link phishing | Trusted routing, re-auth/scope recheck | P1 |

Anti-abuse thresholds and security signals are platform-restricted; merchants receive safe reason/remediation without bypass detail.
