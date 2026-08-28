# CI Cache Model

State: PROPOSED — OWNER REVIEW REQUIRED

Caches improve speed but are untrusted performance hints, never release evidence or secret storage.

## Rules

- key by OS, architecture, toolchain, and dependency lock hashes;
- separate trusted/main/release write scopes from untrusted PR restore scopes;
- untrusted jobs cannot poison a cache later used by privileged jobs;
- never cache credentials, signing material, environment files, user data, or mutable build outputs;
- verify downloaded dependencies and rebuild artifacts from source;
- provide cache-off fallback and periodic invalidation;
- measure hit rate and time saved before expanding scope.

Release binaries are artifacts, not caches. A cache hit must not bypass tests or provenance generation.

OWNER_DECISION_REQUIRED: approve cache scopes and retention after initial CI timing.
