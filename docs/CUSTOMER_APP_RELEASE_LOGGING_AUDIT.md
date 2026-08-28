# Customer App Release Logging Audit

Status: PASS AFTER SAFE REMEDIATION

Issue `CUST-REL-001` (`P1`, `FIX_WITH_LOCAL_TESTS`): shared Logger helpers used `Level.debug` in all build modes. Dormant Dio/location helpers could log response bodies/headers, URLs, exact coordinates, or rendered addresses if reconnected; Auth listener diagnostics interpolated raw exceptions.

## Remediation

- Shared Logger instances now use `Level.off` in release mode.
- Dio diagnostics now contain only method, status, and error type; URL, headers, body, raw error, and error message were removed.
- Exact coordinates/address values were removed from legacy location diagnostics.
- Auth listener errors are generic and emitted only in debug mode.
- The dormant Bloc observer logs only event/state runtime types, never full state/event/error values.
- An architecture contract prevents regression of these properties.

`debugShowCheckedModeBanner` is false. Remaining debug diagnostics are generic and release-disabled. Supabase configuration exceptions deliberately omit values. No token, email, password, credential URL, Auth secret, or precise location is intentionally logged by the audited active paths.

`RELEASE_LOGGING_AUDIT: PASS`
`SENSITIVE_RELEASE_LOGGING: BLOCKED_BY_CONTRACT`
`FIX_ID: CUST-REL-001`
