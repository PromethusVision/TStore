# Operations Evidence Model

**State:** PROPOSED — DATA MINIMIZED, NO STORAGE IMPLEMENTATION

## Evidence types

| Type | Examples | Reliability considerations |
|---|---|---|
| SERVER_EVENT | Auth, RPC, lifecycle, authorization, state transition | Integrity/source/version; absence may reflect retention/outage |
| QR_VERIFICATION | Token creation/consume, shop binding, expiry, transaction snapshot | One-time state, immutable server time, actor/shop linkage |
| CATALOG_PROVENANCE | Barcode/source assertion, field conflict, predecessor/successor | Source authority, freshness, exact field scope |
| MERCHANT_DOCUMENT | Identity, shop existence, registration/authorization evidence | Authenticity, scope, expiry, revocation, sensitive fields |
| CUSTOMER_REPORT | Incorrect shop/product, unsafe content, abuse | Credibility is contextual; reporter identity protected |
| SYSTEM_LOG | Sanitized correlated error/security event | Logs are signals, not complete truth; no secrets/session tokens |
| MEDIA | Listing/review image or later operator screenshot | Rights, provenance, tampering, malware, metadata/PII |
| EXTERNAL_AUTHORITY | Current official registry/notice or formal response | Exact authority, retrieval time, jurisdiction, stable capture/reference |
| OPERATOR_OBSERVATION | Reproducible steps and observed state | Must not replace authoritative evidence when available |

## Evidence envelope

- opaque evidence ID and type;
- source system/actor and collected/recorded time;
- subject and case reference;
- integrity hash/reference where appropriate;
- original location, access class, and retention class;
- structured facts asserted and limits;
- policy/ruleset version;
- verification status: `UNVERIFIED`, `CORROBORATED`, `CONFLICTING`, `INVALID`, `EXPIRED`;
- redaction/derived-view metadata;
- superseding evidence reference.

## Data minimization

Store/reference only what the decision needs. Redact unrelated ID numbers, addresses, faces, EXIF, messages, tokens, and third-party data. Operators receive a purpose-built derived view, not unrestricted raw files. Evidence access and export are audited. Never ask for passwords, one-time codes, recovery links, complete payment credentials, or service-role secrets.

## Decision rule

No single customer report, screenshot, merchant declaration, or classifier score automatically proves a high-risk fact. Conflicts remain visible. Missing sensitive evidence fails closed for approval, while punitive action uses proportionate containment and human review.

## Research anchors

OWASP recommends excluding session identifiers and unnecessary sensitive data from logs while preserving safe correlation. KVKK guidance requires appropriate technical and administrative measures and purpose-based handling; final retention/legal basis needs responsible review.

`EVIDENCE_MODEL_FINAL: NO`

`RAW_PII_BY_DEFAULT: NO`
