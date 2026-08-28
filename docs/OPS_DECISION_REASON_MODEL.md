# Customer-Facing Decision Reason Model

**State:** PROPOSED — COPY/POLICY NOT FINAL

## Layered reasons

1. **Public reason class:** safe, understandable category.
2. **Affected object/scope:** account, review, listing, QR action, etc.
3. **What happened:** concise fact under current policy.
4. **What can be done:** correction/evidence/recovery/appeal.
5. **Effective state/time:** temporary/permanent/pending where approved.
6. **Reference:** case/decision ID and support route.

## Candidate reason classes

`AUTH_OR_OWNERSHIP_REQUIRED`, `INFORMATION_INCOMPLETE`, `CONTENT_POLICY`, `PRODUCT_POLICY`, `SECURITY_HOLD`, `DUPLICATE_OR_CONFLICT`, `TRANSACTION_INVALID`, `CAPABILITY_RESTRICTED`, `TECHNICAL_UNAVAILABLE`, `REQUEST_NOT_SUPPORTED`.

## Protect

Do not reveal reporter identity, another user's data, fraud score/threshold/device fingerprint, internal note, exploit detail, operator identity beyond policy, merchant competitor evidence, or privileged system topology. Do not mislead: “security reasons” cannot hide an ordinary product error.

## Quality

Reason matches actual server decision/policy version, is localized/plain language, avoids accusation beyond evidence, provides a meaningful next step, and remains consistent across UI/email/support. Unknown/TBD policy produces pending/escalated status rather than invented final rejection.

## Appeal

Material adverse decisions include appeal/review path when approved. Case reference is not authorization and does not expose existence to unauthorized users.

`DECISION_COPY_FINAL: NO`

`ABUSE_DETECTION_LEAK: PROHIBITED`
