# Customer Operations Report Taxonomy

**State:** PROPOSED — NOT PRODUCT TAXONOMY

This taxonomy classifies operational reports, not products or merchants.

## Proposed top-level types

| Type | Examples | Default route |
|---|---|---|
| INCORRECT_SHOP | wrong location/hours/contact, nonexistent/closed shop | merchant/shop review |
| INCORRECT_PRODUCT | wrong identity/details/category/media | catalog/listing review |
| PRICE_AVAILABILITY | misleading/stale price, unavailable item | listing moderation |
| UNSAFE_PROHIBITED | unsafe, regulated, recalled, prohibited product/content | policy moderation |
| REVIEW_ABUSE | spam, harassment, PII, retaliation, manipulation | review moderation |
| QR_PURCHASE | wrong shop/item/state, replay concern | QR/support/fraud |
| ACCOUNT_SECURITY | takeover, unknown activity, recovery abuse | security incident |
| PRIVACY | data exposure, access/correction/deletion request | privacy operations |
| CHAT_CONTACT_ABUSE | harassment/spam/phishing where feature supports reporting | moderation/security |
| TECHNICAL | crash/error/loading/navigation | support/engineering incident |
| OTHER_UNRESOLVED | structured explanation insufficient | triage, never auto-enforcement |

## Metadata

Exact subject ID, event/request/case correlation, structured reason, severity hints, optional bounded description/evidence, reporter follow-up preference, safety/immediacy, and locale. Avoid free-text-only classification.

## Rules

One report can have secondary tags; exactly one primary route. Report count does not prove violation. Protect reporter identity, deduplicate safely, acknowledge without outcome promise, and provide emergency guidance only under approved content.

`REPORT_TAXONOMY_FINAL: NO`

`PRODUCT_TAXONOMY_CHANGED: NO`
