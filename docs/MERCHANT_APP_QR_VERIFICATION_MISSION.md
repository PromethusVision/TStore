# Merchant App QR Verification Mission

Status: **PROPOSED — FROZEN SECURITY CONTRACT PRESERVED**
Wave: 17 / WP27

Merchant QR flow confirms that a physical purchase represented by a short-lived opaque customer token was accepted at the authorized shop. It is server-authoritative evidence for verified transaction/review eligibility.

## It is

- A physical purchase verification operation.
- Bound to authorized merchant/shop and immutable outcome evidence.
- Protected against expiry, replay, wrong shop and concurrency.

## It is not

- Payment collection or payment success.
- Online order completion, invoice or refund system.
- A customer identity lookup mechanism.
- Permission to edit review evidence or grant extra review rights.

## Frozen downstream contract

- Only merchant-confirmed QR physical purchase unlocks review.
- One active review per customer + canonical product for life.
- Repeat purchase or quantity does not grant another active review.
- Delete/recreate depends on immutable verified evidence.
- Legacy boolean verification alone is not evidence.
