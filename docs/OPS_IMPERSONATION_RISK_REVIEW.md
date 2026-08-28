# Operator Impersonation Risk Review

**State:** PROPOSED — RECOMMEND AVOIDING IMPERSONATION

## Risks

Impersonation can expose private data, create actions attributed to the wrong person, bypass consent/authentication, alter carts/messages/reviews/QR/listings, enable social engineering, confuse audit/non-repudiation, and make screenshots/support handling unsafe.

## Recommendation

Do not allow operators to assume a customer or merchant session in V1. Use:

- role-scoped read-only derived support views;
- reproducible demo/test accounts outside Production;
- customer-provided safe request ID;
- server event/state summaries;
- feature/state simulators with synthetic data;
- customer-guided screen sharing only under a separately approved privacy process.

## If ever reconsidered

Require explicit owner/security/privacy approval, user consent where appropriate, high-assurance re-auth, reason/case, short read-only session, prominent banner, prohibited mutations, separate operator identity in every event, sensitive-field redaction, no credential/token disclosure, automatic expiry, and audit/alert.

“View as” must never issue the user's actual token or create events as the user. Account recovery and merchant ownership transfer stay canonical Auth workflows.

## Break-glass

Security investigation access is not ordinary impersonation and remains narrowly scoped, audited, and handled through incident capability.

`V1_OPERATOR_IMPERSONATION: NO`

`USER_TOKEN_SHARED_WITH_OPERATOR: NO`
