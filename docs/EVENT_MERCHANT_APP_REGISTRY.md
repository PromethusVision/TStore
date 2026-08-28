# EsnaftaVar Merchant App Event Registry

**State:** `CANDIDATE MINIMUM REGISTRY — NOT FINAL`

| Domain | Candidate event | Authority | Notes |
|---|---|---|---|
| Catalog candidate | `catalog_candidate_submitted`, `catalog_candidate_reviewed` | Server authoritative/audit | Preserve candidate/reviewer identity under least privilege |
| Listing | `listing_created`, `listing_updated`, `listing_availability_changed`, `listing_retired` | Server authoritative | Revision and shop/listing identity required |
| Price | `listing_price_changed` | Server authoritative | Old/new values restricted; no revenue implication |
| QR | `qr_issued`, `qr_scanned`, `qr_validation_failed`, `verified_purchase_created`, `qr_replay_rejected` | Mixed; dedicated model rules | Raw token never logged |
| Reviews | `review_viewed`, `review_report_submitted` | Client reported/server authoritative | No new report/removal rights |
| Shop | `shop_profile_changed`, `shop_status_changed` | Server authoritative/audit | Versioned fields and operator/merchant capability |
| Staff | `merchant_staff_access_changed`, `merchant_staff_action_rejected` | Server authoritative/security | Never expose staff/customer secrets |
| Ads | `campaign_draft_changed`, `campaign_submitted` | Server authoritative if feature exists | Future only; ad measurement separate |

Routine form focus, keystrokes, dashboard refreshes and repeated widget renders are
not business events. Merchant dashboard views are UI telemetry only if a concrete
health/adoption question justifies them.

The registry must not expose customer identity, raw QR, precise customer location,
private chat/review text or small-cohort journeys. Verified physical purchases are
not payment settlement, order revenue or audited merchant revenue.

`MERCHANT_EVENT_REGISTRY_FINALIZED: NO`

