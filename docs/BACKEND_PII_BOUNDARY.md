# Backend PII Boundary

**State:** PROPOSED PRIVACY MINIMIZATION — NOT LEGAL ADVICE

Collect personal data only for a declared customer/merchant/security purpose.
Prefer opaque internal identifiers and aggregate/coarse dimensions over email,
phone, name, address, exact location, IP/device linkage or free-form content.

## Never in general logs/events/analytics

Passwords, OTPs, access/refresh tokens, recovery links, service credentials, raw
QR, authorization headers, cookies, signed media URLs, private chat/review/support
content, full request bodies, identity documents, payment material and unnecessary
precise location.

## Controls

- field allowlists and redaction before serialization;
- purpose/authority/privacy class and retention version;
- least-privilege column projections and restricted evidence references;
- encrypted transport/storage under platform controls;
- audited access/export and non-production masking/synthetic fixtures;
- subject deletion/access correction workflows with legal/audit exceptions;
- no assumption that hashing makes a linkable identifier anonymous.

Search text, IP/network, device/session and coarse geography can still be personal
or sensitive. Exact consent/legal basis and retention require policy/legal review;
this document does not finalize them.
