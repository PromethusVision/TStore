# Security Test Model

State: PROPOSED — SECURITY/OWNER REVIEW REQUIRED

Testing is defensive, authorized, and non-destructive. No offensive testing targets Production.

## Minimum threat cases

- IDOR across customer, merchant, shop, listing, case, and transaction IDs;
- role escalation and forged client metadata;
- cross-shop staff actions and operator capability bypass;
- expired/revoked/token replay and account switching;
- malicious/malformed deep links and callback confusion;
- QR replay, wrong shop, collusion boundaries, and price tampering;
- storage object access and signed URL scope;
- logs/errors revealing tokens, PII, policy signals, or secrets.

Test client UI, repository, RLS/RPC, and privileged server paths independently. Negative tests require independent identities and explicit denial assertions. Findings enter a severity/ownership/remediation process.

OWNER_DECISION_REQUIRED: define authorized security test environments and external review trigger.
