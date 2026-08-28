# EsnaftaVar Analytics Event PII Boundary

**State:** `PROPOSED HARDENING STANDARD`

Never log or place in analytics/event payloads:

- password, OTP, auth/access/refresh token, service-role key, recovery/secret link;
- raw QR value, signed URL, cookie, authorization header or full request headers;
- private chat/review/support content or unrestricted form/request/response bodies;
- full unnecessary address, precise customer location or movement history;
- payment/card/bank data, identity documents or sensitive-category inferences;
- customer email/phone/name when an opaque permitted subject ID or aggregate works.

Potentially personal fields (pseudonymous customer ID, IP/network data, device ID,
search text, coarse location) require explicit purpose, classification, access,
retention and deletion controls. Hashing direct identifiers does not make them
anonymous when linkage remains possible.

Client and server libraries must apply an allowlist/redaction boundary before
serialization. Crash/error tooling scrubs breadcrumbs, URLs, headers and local
state. Field audits fail closed on newly introduced keys.

`SECRETS_IN_EVENTS: FORBIDDEN`

