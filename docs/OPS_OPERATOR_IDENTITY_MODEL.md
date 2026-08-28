# Operator Identity Model

**State:** PROPOSED — NO AUTH OR SCHEMA IMPLEMENTATION

## Separation

| Concept | Meaning | Must not become |
|---|---|---|
| AUTH USER | Login/session identity | Operator authority by metadata alone |
| OPERATOR PROFILE | Employment/engagement status and display identity | Customer/merchant profile reuse |
| ROLE | Reviewable bundle of common capabilities | Unbounded superuser shortcut |
| CAPABILITY | Server-checked action on a scoped resource | UI button visibility |
| CASE ASSIGNMENT | Temporary purpose/scope to handle one case or queue | Permanent privilege escalation |

An Auth user becomes an operator only through a separate active operator profile. A role supplies candidate capabilities; every request still checks active operator status, capability, resource scope, case/purpose, policy constraints, and re-authentication where required.

## Conceptual identifiers

- immutable opaque operator profile ID;
- Auth user reference, never email as identity;
- role assignment ID with effective/expiry timestamps;
- capability and scope version;
- case assignment ID;
- session assurance level and last re-auth time;
- suspension/offboarding status;
- audit correlation ID.

## Rules

1. Customer or merchant roles cannot self-create an operator profile.
2. Auth metadata/client claims are not authoritative.
3. Shared operator accounts are prohibited.
4. Operator identity is displayed in internal audit but minimized in customer-facing reasons.
5. Case assignment narrows access; it does not broaden the role.
6. Temporary elevation expires automatically and requires reason/case.
7. Operator suspension immediately blocks privileged actions and revokes active sessions through the future server contract.
8. Historical audit keeps the immutable operator reference after offboarding.
9. Break-glass access is separate, short-lived, strongly authenticated, and retrospectively reviewed.
10. Operator search/view access is auditable even when no mutation follows.

## Decision function

```text
authenticated auth user
AND active operator profile
AND current role assignment
AND explicit capability
AND resource/tenant/case scope
AND required assurance/re-auth
AND policy and lifecycle allow
```

Any missing predicate denies by default with a safe reason and correlation ID.

`ADMIN_UI_IS_SECURITY: NO`

`SERVER_AUTHORITY_REQUIRED: YES`
