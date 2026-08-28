# Backend Client Capability Model

**State:** PROPOSED — OPTIONAL NEGOTIATION, SERVER REMAINS AUTHORITY

Capabilities describe what a deployed backend/app contract can safely render or
request, such as listing revision support, merchant membership, variant selection,
cursor version or push delivery. They do not represent user permission.

## Model

- server publishes a bounded signed/trusted contract manifest or returns capability
  fields through bootstrap;
- app declares release/contract support without choosing security policy;
- unknown capability defaults to unavailable, not a legacy unsafe path;
- required security/integrity feature returns `UNSUPPORTED_CLIENT` when no safe
  degradation exists;
- optional UX hides/degrades while current customer core remains usable;
- capability rollout/retirement is environment/release observable.

Do not negotiate every field or create combinatorial flags. Prefer additive API
compatibility; use capability checks for genuinely optional/incompatible behavior.
User membership/capability is evaluated separately on every mutation.
