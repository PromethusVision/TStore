# Merchant Operations Report Taxonomy

**State:** PROPOSED — NO MERCHANT APP CHANGE

## Proposed types

| Type | Examples | Route |
|---|---|---|
| ACCOUNT_STAFF_SECURITY | unknown staff/device, role/ownership issue | merchant security |
| SHOP_VERIFICATION | evidence/status/address/control dispute | verification |
| CATALOG_CANDIDATE | cannot find product, correction, barcode conflict | catalog review |
| LISTING_PRICE_AVAILABILITY | own listing error/stale state/unauthorized change | merchant support/moderation |
| REVIEW_REPORT | spam/harassment/PII/conflict; not rating disagreement | review moderation |
| QR_TRANSACTION | wrong/replayed/unknown confirmation, staff abuse | QR fraud/support |
| POLICY_RESTRICTION | regulated/excluded/evidence decision | policy review |
| ADS_LATER | rejection/traffic/reporting dispute | ads operations when enabled |
| REWARD_LATER | progress/funding/abuse dispute | reward operations when rules exist |
| TECHNICAL | auth/RPC/realtime/storage/crash | support/incident |
| OTHER_UNRESOLVED | no safe match | triage |

## Submission

Authenticated organization membership and shop scope, exact object/correlation, structured reason, bounded evidence, desired correction, and urgency. Staff authority is rechecked; merchant cannot report on competitors through an internal privileged route without a general abuse report.

## Boundaries

Report does not grant canonical edit, verification, refund, review deletion, QR correction, ad credit, or role. Commercial pressure/spend does not change priority. Safe status/reason and appeal are returned without reporter/fraud/internal-note leakage.

`MERCHANT_REPORT_TYPES_FINAL: NO`

`REPORT_EQUALS_ACTION: NO`
