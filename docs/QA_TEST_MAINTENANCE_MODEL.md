# Test Maintenance Model

**State:** PROPOSED

Tests change with an approved behavior/contract, a confirmed defect, fixture/schema evolution or removal of genuinely retired code.

## Rules

- update product behavior and its tests atomically;
- treat failing tests as evidence until behavior change is authorized;
- delete only when the protected behavior is retired, duplicated by stronger evidence or the test asserts an invalid contract;
- consolidate duplicate setup/assertions without erasing distinct risks;
- review stale snapshots, skips, quarantine, synthetic IDs and remote fixtures;
- version contract fixtures alongside RPC/schema changes;
- regenerate mechanical fixtures from reproducible sources and review the diff.

Do not rewrite expectations merely to obtain green CI. Every deletion records what protection replaces it or why none is needed.

Engineering owns routine maintenance; product owner involvement is only needed when expected behavior materially changes.
