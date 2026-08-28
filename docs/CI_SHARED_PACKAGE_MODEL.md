# Shared Package CI Model

State: FUTURE PROPOSAL — OWNER REVIEW REQUIRED

If shared Dart/packages emerge, reuse must not couple release cadence silently.

## Required gates

- package unit/analyzer/API compatibility;
- all consuming apps compile and run affected tests;
- explicit semantic version/change record for published packages;
- source dependency pinned through lockfiles;
- no app secrets, environment endpoints, UI-specific assumptions, or privileged roles in generic packages;
- deprecation window and rollback for breaking contracts.

Prefer keeping code app-local until duplication and semantic stability justify extraction. A shared package change fans out to every supported consumer even when path filters would otherwise skip them.

OWNER_DECISION_REQUIRED: approve extraction criteria, ownership, and internal publication method if the need arises.
