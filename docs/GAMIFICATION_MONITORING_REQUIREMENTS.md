# Gamification Monitoring Requirements

**State:** PROPOSED — NO MONITORING IMPLEMENTATION

## Health signals

- Verified-event intake vs reward/badge/reputation projection lag.
- Duplicate suppression, retry/dead-letter and replay/reconciliation counts.
- Reward issuance/redemption/reversal/expiry by program/funder and policy.
- Fraud holds, QR replay/concurrency anomalies, multi-account/collusion clusters.
- Unexpected badge earn/revoke spikes and reputation distribution/fairness drift.
- New-merchant insufficient-history duration and cross-sector disparities.
- Dispute volume, resolution time, repeat reasons and notification delivery pressure.
- Ads/reputation invariant violations and policy-unknown evaluations.

## Response

Independent kill switches pause new economic issuance, public badge derivation or reputation projection without disabling verified purchases/reviews. Alerts route by severity; investigation retains immutable evidence and never performs broad automatic punishment. Dashboards avoid customer-level sensitive data.
