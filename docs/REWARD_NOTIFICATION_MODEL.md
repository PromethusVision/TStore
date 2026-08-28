# Reward Notification Model

Status: **PROPOSED — OWNER/POLICY REVIEW REQUIRED**
Wave: 18 / Workstream AY

## Event classes

- Earned/pending/held/reversed/adjusted.
- Near threshold, only if non-manipulative and customer enabled.
- Redemption success/failure/unknown outcome.
- Expiry reminder under disclosed terms.
- Program/merchant closure or material future-effective terms change.
- Dispute resolution.

## Frequency/trust controls

- Earn events may be batched; no duplicate per source.
- Near-threshold notice never uses artificial urgency or implies purchase necessity.
- Expiry reminder cadence is capped and cannot replace initial disclosure.
- Sensitive amount/merchant/product omitted from lock screen by default.
- Notification delivery failure does not change ledger/expiry.
- Deep link shows authoritative program/ledger state after auth.

Channel matrix, mandatory notices and timing remain owner/privacy/legal decisions.
