# CI Environment Isolation

State: PROPOSED — OWNER REVIEW REQUIRED

CI jobs are disposable and environment-specific.

## Boundaries

- PR: no remote mutation, no secrets, mocked/local contracts;
- main: deterministic tests and isolated synthetic services;
- authorized live: exact Development project, unique fixtures, cleanup, no parallel collision;
- release: protected signing/store environment and exact approved commit;
- Production: deployment/smoke only through explicit approval, never adversarial tests.

Use separate accounts/projects/credentials, immutable tool versions, clean checkout, bounded network destinations, read-only defaults, and no cross-job mutable cache. Artifacts carry environment identity; a Development artifact cannot be promoted as Production.

OWNER_DECISION_REQUIRED: decide whether to create a dedicated TEST Supabase project; until then TEST means local/disposable, not a remote assumption.
