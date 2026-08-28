# Backend RPC Minimization Review

**Result:** PASS — SMALL COMMAND SURFACE RECOMMENDED

## Keep current / harden

- saved-location default/delete invariants;
- exact customer account deletion lifecycle;
- QR issue, authorized preview and atomic confirmation;
- verified shop rating eligibility/submit;
- product review eligibility/submit/update/delete and aggregates;
- bounded enriched conversation/unread reads where current clients depend on them.

## New V1 commands justified

| Command concept | Why direct table access is insufficient |
|---|---|
| listing mutation | capability + field allowlist + revision + audit/idempotency |
| merchant membership grant/revoke | privileged cross-row lifecycle and immediate revocation |
| governed product-candidate submit/decide | canonical catalog authority and provenance |
| merchant operation projection | bounded semantics across protected rows when a direct view cannot safely expose them |

## Reject/defer

- RPC wrappers for every public read or simple owner-scoped one-row mutation;
- generic “update anything” JSON commands;
- one RPC per UI screen/widget;
- Ads, Reward, reputation and broad analytics commands before those systems are
  separately approved;
- versioned copies without a semantic incompatibility.

Every RPC still requires execute-grant tests, invoker identity, exact resource
scope, validation, safe errors and search-path review. The review does not propose
deleting currently used RPCs.
