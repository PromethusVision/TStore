# Merchant Pilot V1 vs Defer

State: `PROPOSED — OWNER REVIEW REQUIRED`

## MUST before pilot

- Merchant auth/session/logout and exact-shop single-owner authority.
- Verification/policy state and shop profile read.
- Listing read, price, availability/unknown and freshness update.
- Existing-product association; no candidate auto-publish.
- QR scan/preview/explicit confirm/reconcile/history with all server invariants.
- Critical notifications, support/correlation and immutable audit evidence.
- Regulated-domain fail-closed.
- Automated RLS/RPC/concurrency tests and two-device exact-artifact acceptance.

## SHOULD in first pilot increment

- Basic candidate submission.
- Merchant-assisted initial listing batch with attestation.
- Read-only reviews/evaluations and simple report path.
- Action-first freshness/QR/support summary.
- Session revoke/lost-device support surfaced clearly.

## DEFER after evidence

- Advanced dashboard/charts/export.
- Staff invites, role editor, shifts and device fleet.
- Multi-branch/org management.
- Advanced catalog bulk/media/inventory automation.
- Review replies, reputation and badge dashboards.
- Ads/rewards/gamification controls.
- iOS Merchant App if owner chooses Android-only controlled pilot; requirements remain open.

## Trigger rules

Staff UI only when multiple real users per shop are admitted. Multi-branch only when cohort contains multi-branch organizations. Dashboard only after actionable data and merchant questions exist. Candidate automation only after review volume is measured. Reputation/badges only after minimum sample/fraud/policy decisions.

