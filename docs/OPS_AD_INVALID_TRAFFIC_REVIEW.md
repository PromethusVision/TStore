# Advertising Invalid-Traffic Review

**State:** PROPOSED — NO DETECTOR, BILLING, OR ADS RUNTIME

## Signals

Duplicate/idempotency conflict, impossible sequence, merchant/staff self-click, bot/burst, device/account farm, collusion, repeated low-dwell interaction, geo/session mismatch, replayed measurement, reporting/ledger inconsistency, or compromised client. Signals are probabilistic and data-minimized.

## Workflow

Detect → hold affected billable status → cluster by campaign/merchant/request safely → inspect event provenance and system health → distinguish technical duplicate from abuse → decide → reconcile report/ledger → communicate/appeal → tune control with QA.

## Decisions

- `VALID`;
- `DUPLICATE_NON_BILLABLE`;
- `INVALID_NON_BILLABLE`;
- `HOLD_PENDING_REVIEW`;
- `CAMPAIGN_PAUSE`;
- `MERCHANT_AD_CAPABILITY_RESTRICTION`;
- `SECURITY/ACCOUNT_INCIDENT`.

No score automatically causes permanent merchant suspension. A detector outage fails closed for high-risk billing and may disable paid serving while organic results continue.

## Evidence/privacy

Use opaque IDs, coarse risk features, timestamps, event lineage, campaign/listing/shop relationships, and policy version. Restrict IP/device/location access and retention. Never expose thresholds/fingerprints to merchants or copy raw tokens into cases.

## Independence

Invalid traffic changes advertising measurement/billing status only. It does not alter organic rank, merchant reputation, verified purchase, review, or rewards without their own evidence and case.

`INVALID_TRAFFIC_THRESHOLD_FINAL: NO`

`AUTOMATED_PERMANENT_ENFORCEMENT: NO`
