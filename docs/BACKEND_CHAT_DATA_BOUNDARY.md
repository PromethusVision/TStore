# Backend Chat Data Boundary

**State:** PROPOSED — PRESERVES CURRENT PRIVATE PARTICIPANT MODEL

Chat message text and attachments are customer/merchant private content. Only
participants/assigned shop staff and narrowly case-authorized operators may access
the minimum needed fields.

## Rules

- sender and conversation/shop context are server-derived and authorized;
- bounded message size/type; no executable content or unrestricted metadata;
- private text is excluded from analytics, general logs, traces and notification
  previews beyond an approved minimal snippet;
- moderation/search access requires case, purpose, capability and audit;
- organization membership alone does not expose all branch conversations;
- staff revocation stops new access/sends and preserves authorized history;
- export/deletion/report/appeal follows explicit lifecycle and retention;
- future attachments require separate Storage ownership, scanning and retention.

Metrics use counts/latency/outcomes, not message meaning by default. Automated
content analysis, encryption model, retention and customer deletion behavior are
`OWNER_DECISION_REQUIRED` with privacy/policy review.
