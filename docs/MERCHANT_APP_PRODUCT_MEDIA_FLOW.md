# Merchant App Product Media Flow

Status: **PROPOSED — OWNER REVIEW REQUIRED**  
Wave: 17 / WP24

## Media classes

| Class | Owner | Use |
|---|---|---|
| Canonical media | Governed catalog | Shared product identity |
| Listing media | Merchant/shop | Local packaging, presentation or actual stock context |
| Evidence media | Restricted moderation | Candidate/policy verification; not customer-visible by default |

## Flow

1. Prefer eligible canonical media.
2. Allow listing media only under rights, MIME/size and content policy.
3. Preview customer-visible crop/order and label local media correctly.
4. Upload idempotently, scan/moderate, then publish eligible asset reference.
5. Removing listing media does not delete canonical assets or immutable evidence.

## Safety

- No secrets, IDs/documents or unrelated customer faces.
- Storage authorization is organization/shop scoped; object path is not authorization.
- Draft upload is not customer publication.
- Merchant cannot promote listing media into canonical media directly; promotion workflow is deferred (`CAT-13 P1`).
- Orphan cleanup, retention and appeal policies need backend/operations design.

