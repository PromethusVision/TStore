# Media Test Model

State: PROPOSED — OWNER REVIEW REQUIRED

Media testing applies to product/shop, chat, review, report, or evidence uploads only when those paths exist.

## Checks

- file type/signature, size, dimensions, count, and malformed payload;
- orientation, compression, thumbnail, metadata stripping, and accessibility text;
- upload cancel/retry/duplicate, poor network, expired signed URL, and lifecycle;
- owner/path isolation, unauthorized read/write/delete, and object cleanup;
- moderation/policy state and removal without breaking audit/history;
- no local path, token, GPS metadata, or private evidence leaked publicly.

Client extension checks are not security controls; server/storage policy is authoritative. Production adversarial uploads are prohibited.

OWNER_DECISION_REQUIRED: set per-surface media limits, retention, and moderation rules.
