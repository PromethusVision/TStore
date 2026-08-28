# Auth Release Acceptance

State: PROPOSED — OWNER REVIEW REQUIRED

## Required paths

- customer signup, confirmation-required state, confirmation, and confirmed login;
- invalid/expired/duplicate link and resend;
- recovery, password change, old credential rejection, and session refresh;
- logout, relaunch, user switch, network loss, enumeration-safe errors;
- default customer profile and prohibition of client role escalation.

Unit/widget/callback tests precede a production-like Development SMTP acceptance. Real delivery evidence requires configured provider credentials through secure runtime mechanisms and exact environment verification. Production testing is minimal, authorized, and non-destructive.

Legacy LoginCubit/RegisterCubit paths must not return. OAuth controls remain hidden until providers are actually configured and accepted.

OWNER_DECISION_REQUIRED: identify release SMTP/provider owner and approved synthetic recipient domains.
