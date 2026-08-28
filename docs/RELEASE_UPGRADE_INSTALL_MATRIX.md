# Upgrade Install Matrix

State: PROPOSED — OWNER REVIEW REQUIRED

| From | To | Required checks |
|---|---|---|
| Previous Production | Candidate | install, preserved session/data, migrations, deep links, permissions |
| Previous-supported | Candidate | contract compatibility and deprecated state |
| Candidate beta | Candidate release | version/signature path and data continuity |
| Logged-out old app | Candidate | onboarding/auth/recovery |
| Logged-in customer | Candidate | token refresh, profile, cart/wishlist |

Test Android and iOS separately. Include interrupted update/relaunch where the platform permits it, low storage, network transition, and stale cached state. Never copy real customer data into fixtures.

Failures classify as data loss, account lockout, security/integrity, functional regression, or cosmetic. Any data loss or auth lockout is release-blocking until resolved.

OWNER_DECISION_REQUIRED: define which historical versions remain supported and supply signed predecessor artifacts safely.
