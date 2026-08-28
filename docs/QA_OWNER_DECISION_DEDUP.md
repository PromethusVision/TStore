# QA Owner Decision Deduplication

**State:** PROPOSED — ALL RAW DECISIONS ACCOUNTED FOR

| Root / state | Raw decisions | Result |
|---|---|---|
| R01 PILOT_PLATFORM | D001, D002 | ROOT_DECISION |
| R02 DEVICE_PHYSICAL_SCOPE | D003, D004, D005 | ROOT_DECISION |
| R03 CI_AND_MACOS_INVESTMENT | D006, D007, D008 | ROOT_DECISION |
| R04 TEST_ENVIRONMENT | D009, D010 | ROOT_DECISION |
| R05 PRODUCTION_AUTHORITY | D011, D012, D013 | ROOT_DECISION |
| R06 PILOT_OPERATING_SCOPE | D014, D015, D016 | ROOT_DECISION |
| R07 ADVANCED_QA | D018, D019, D020 | ROOT_DECISION |
| R08 OBSERVABILITY_PRIVACY | D021, D022 | ROOT_DECISION |
| R09 ROLLOUT_UPDATE_POLICY | D017, D023, D024 | ROOT_DECISION |
| R10 LEGAL_SUPPORT_DEPENDENCIES | D025, D026 | ROOT_DECISION |
| R11 MERCHANT_APP_FUTURE | D027, D028 | DEFERRED_ROOT_DECISION |
| R12 RELEASE_RISK_GOVERNANCE | D029, D030 | ROOT_DECISION |

Raw decisions: 30. Root mappings: 28. Deferred but preserved: 2. Standalone: 0. Missing: 0.

Engineering-only questions removed from owner workload include test file placement, command flags, shard construction, deterministic ID format, cache key syntax, fixture cleanup implementation and parser library choice.
