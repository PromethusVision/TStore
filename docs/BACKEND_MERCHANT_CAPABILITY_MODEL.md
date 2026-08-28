# Backend Merchant Capability Model

**State:** PROPOSED — MINIMAL CAPABILITIES, NO AUTH IMPLEMENTATION

## Model

Use a small navigational role vocabulary backed by explicit server capabilities.
Do not create one role per screen and do not treat a JWT/client metadata role as
permanent authority.

| Capability | Typical scope | Example actions |
|---|---|---|
| `SHOP_VIEW` | shop | Read private operational shop data |
| `SHOP_MANAGE` | shop | Edit allowed shop profile/hours |
| `LISTING_VIEW` | shop | Read merchant listing operations |
| `LISTING_MANAGE` | shop | Create/revise/retire listing fields |
| `QR_VERIFY` | shop | Validate/confirm customer QR |
| `STAFF_MANAGE` | organization/shop | Invite/revoke narrower memberships |
| `ANALYTICS_VIEW` | organization/shop | Read scoped merchant aggregates |
| `CAMPAIGN_MANAGE` | organization/shop | Future ads campaign operations |

Financial, policy, catalog approval, reward ledger adjustment and operator powers
are not ordinary merchant capabilities.

## Authorization predicate

Every privileged call checks authenticated user, active membership, organization,
explicit shop scope, capability, resource lifecycle, policy state and expected
resource revision. UI hiding is merely presentation.

## Delegation rules

- A delegator may grant only a capability/scope they are allowed to delegate.
- No self-promotion or acceptance-time expansion.
- Sensitive grants require fresh authentication and audit.
- Revoked/suspended memberships fail retries even when the idempotency key exists;
  an already committed outcome may be returned without re-executing it.

**Recommendation:** start with owner/manager/staff display roles mapped to the
small capability registry above. Exact role names remain
`OWNER_DECISION_REQUIRED`.

