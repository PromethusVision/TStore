# CI Artifact Retention

State: PROPOSED — OWNER REVIEW REQUIRED

Artifacts are classified before upload.

| Class | Examples | Proposed handling |
|---|---|---|
| Test evidence | JUnit, coverage, safe logs | short retention |
| Build diagnostics | unsigned compile outputs, symbol reports | limited, access-controlled |
| Release candidate | signed APK/AAB/archive, hashes, provenance | protected immutable release record |
| Sensitive | secrets, raw PII, Production dumps | never upload |

Artifacts carry commit, build, environment, toolchain, and expiry. Access/download is audited where possible. Crash symbols and signing-related metadata receive restricted access. Expiry must respect incident, support, store, and policy needs without indefinite accumulation.

OWNER_DECISION_REQUIRED: set retention periods and custodian roles after legal/privacy review.
