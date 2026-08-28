# Customer App Client-side Security Audit

Status: PASS WITH PRIVACY POLICY FOLLOW-UP

## Controls

- Supabase SDK owns token/session persistence; application code does not copy tokens/passwords into SharedPreferences or logs.
- Build configuration accepts only client-safe anon/publishable keys and rejects server-only keys.
- Auth callback validation is exact by environment/scheme/host/path/code/action; malformed links cannot trigger exchange/navigation.
- Browser callback URL cleanup avoids retaining one-time code parameters where supported.
- URL launches validate/construct phone/map URIs and fail with customer-safe feedback.
- Critical RPC payloads normalize/validate IDs and values; backend RLS/RPC is authoritative against IDOR/client tampering.
- Public media resolver rejects malformed/non-HTTPS legacy URLs and prevents credential-bearing sources.
- Release logging is disabled and diagnostics are sanitized by an architecture contract.
- Customer data operations check current session and user scope.

## Local storage

- Onboarding flag and five recent searches are device-local.
- Recently viewed product IDs are keyed per customer.
- Pending pre-login chat intent stores bounded receiver metadata/draft for at most 24 hours and is cleared on consumption/cancel/error. It contains no token but may be privacy-sensitive on a shared device.

Owner should finalize the device-local search/draft retention policy. No encryption dependency or behavioral change was introduced without that decision.

`CLIENT_SECURITY_AUDIT: PASS`  
`CLIENT_ADMIN_SECRET: NO`  
`OWNER_DECISION_REQUIRED: DEVICE_LOCAL_HISTORY_POLICY`
