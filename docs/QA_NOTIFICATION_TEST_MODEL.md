# Notification Test Model

State: PROPOSED — OWNER REVIEW REQUIRED

## Matrix

- permission allowed/denied and token registration/rotation/revocation;
- foreground, background, terminated, tapped, dismissed, and duplicate delivery;
- correct account/device after login, logout, switch, reinstall, and merchant/customer role change;
- valid/expired/malformed deep-link destination;
- quiet hours/preferences and category opt-out where implemented;
- sensitive content redaction on lock screen.

Delivery provider acceptance is separate from client unit/widget tests. Notifications are hints: opening one revalidates authorization and current server state. Token/log evidence must not expose PII or secrets.

OWNER_DECISION_REQUIRED: approve V1 notification categories, consent defaults, and lock-screen copy.
