# Customer App Auth Closeout Audit

Status: PASS — static/local contract; remote configuration remains manual

## Flow results

| Flow | Result | Evidence/risk |
| --- | --- | --- |
| Signup + legal metadata | PASS | Canonical privacy/terms versions are submitted; widget and repository tests cover validation and consent. |
| Login | PASS | Duplicate submit blocked; unconfirmed and invalid credentials map to safe Turkish messages. |
| Logout | PASS | User-initiated window prevents false expiry feedback; customer-scoped local data clears. |
| Session restore/refresh | PASS | Existing session starts customer data; same-user token refresh does not clear it. |
| Automatic expiry | PASS | Clears Cart/Wishlist/navigation and removes protected back stack. |
| Account switch | PASS | Previous customer data is cleared before the new customer's data loads. |
| Email confirmation | PASS | Initial/live callback deduplication, profile refresh, Home/Login result, invalid callback safety; signed Android physical acceptance exists. |
| Password recovery/PKCE | PASS | Recovery identity binding, update, fresh-credential proof, safe cleanup and typed failures; signed Android B6 completed. |
| Expired/invalid token | PASS | Safe error UI and clean return to Login. |
| Duplicate signup/enumeration | PASS WITH PROVIDER DEPENDENCY | Client messages do not expose raw exceptions; authoritative anti-enumeration/provider behavior is Production configuration. |
| Session refresh | PASS | Supabase Auth state listener handles user identity and expiry transitions. |

## Security observations

- Auth keys are public-client only; no admin method or service-role secret is available to Flutter.
- Passwords/tokens are not persisted by application code or logged by error mapping.
- Recovery success is not inferred from an HTTP result alone: the implementation proves the new credential with a fresh login and identity match.
- Account deletion uses the protected canonical customer deletion operation.
- Callback schemes are exact platform contracts; the removed legacy callback must not be reintroduced.

## Residual manual gates

- Production Email/SMTP/Site URL/redirect allowlist are external configuration and must be checked without exposing secrets.
- iOS physical callback acceptance remains platform/release work.
- Wave 16 performs no signup, email send, recovery, or remote Auth read/write.

`AUTH_CLOSEOUT_AUDIT: PASS`  
`REMOTE_AUTH_RECONFIGURED: NO`  
`NEW_AUTH_FIXTURE: NO`
