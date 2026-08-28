# CI Secret Handling

State: PROPOSED — SECURITY/OWNER REVIEW REQUIRED

## Rules

- untrusted pull-request code receives no secrets;
- environment-scoped secrets use least privilege and approval for release;
- prefer short-lived federation over long-lived credentials when supported;
- secret values never enter repository, cache keys, artifacts, command echo, screenshots, or test reports;
- mask is defense-in-depth, not permission to print;
- rotate/revoke on exposure and audit downstream logs/artifacts;
- separate Development, signing, store, and Production identities.

Fork/PR triggers and workflow modifications require special review. Third-party actions are pinned to immutable commits and minimized. Signing keys remain external and fail closed when absent.

This document neither creates nor requests any credential.

OWNER_DECISION_REQUIRED: choose secret store/federation and release-environment approvers.
