# CI Main Gate Model

State: PROPOSED — OWNER REVIEW REQUIRED

Main should always identify a potentially releasable source state, though manual/signing gates may remain open.

## Candidate jobs

- repeat PR gates from clean checkout;
- full Flutter regression;
- Android debug/production compile contracts and fail-closed signing check;
- iOS static/project validation on Windows or native build on macOS when available;
- migration artifact/static/local validation;
- package artifact metadata and non-release unsigned outputs where safe;
- aggregate evidence with commit identity.

No automatic Production database apply, store upload, or signed release follows a main push. A main failure is triaged immediately; rerun is not a fix.

OWNER_DECISION_REQUIRED: choose macOS availability and whether main builds retain non-signed artifacts.
