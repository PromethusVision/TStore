# Secret Scan Model

State: PROPOSED — OWNER REVIEW REQUIRED

Secret scanning is a required local/PR/release gate, supplemented by review of binaries and build logs.

## Scope

- tracked and staged source/history appropriate to the change;
- environment files, Android keystore properties, iOS signing/export material;
- Supabase service-role keys, SMTP/provider tokens, OAuth credentials;
- private keys, certificates/profiles, webhooks, CI tokens, test fixtures, docs, logs, and artifacts.

Allowlisted public identifiers such as project refs or anon/publishable keys must be documented; pattern suppression requires owner, reason, exact scope, and review. A discovered secret is not printed: stop use, revoke/rotate through the owner, remove exposure safely, and assess history/log/artifact impact.

No scanner replaces least privilege or external secret storage.

OWNER_DECISION_REQUIRED: select future scanner/tooling and rotation incident owner.
