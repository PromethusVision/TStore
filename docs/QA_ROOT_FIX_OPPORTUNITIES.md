# QA Root Fix Opportunities

**State:** PROPOSED — DESIGN ONLY

| ROOT_FIX | Failure classes addressed | Recommended class |
|---|---|---|
| RF01 Exact environment/artifact authority envelope | F001, F002, F018, F021, F024 | identity + protected approval |
| RF02 Server authorization matrix | F003, F007, F013, F016, F023, F038 | RLS/RPC/capability tests |
| RF03 Transactional idempotency and concurrency | F004, F014, F026, F029 | DB uniqueness/serialization |
| RF04 Migration evidence pipeline | F005, F008, F015, F017, F039 | pre/dry/post/recovery |
| RF05 Secret and PII isolation | F006, F007, F023, F028, F036 | least privilege/redaction |
| RF06 Critical physical acceptance pack | F009–F012, F019, F020, F024, F027, F031, F032, F040 | exact signed device matrix |
| RF07 Backward-compatible release contract | F010, F015, F019, F021 | expand/migrate/track |
| RF08 Release health and containment | F022, F035–F037 | observability/kill switch/support |
| RF09 Deterministic async/lifecycle state | F011, F025–F029 | cancellation/generation/duplicate guard |
| RF10 Lean test governance | F033, F034, F042, F043, F046 | cache/flake/warning/minimization |
| RF11 Turkish/accessibility/UI acceptance | F030–F032, F041, F044 | locale/semantics/visual |
| RF12 Future-scope isolation | F038, F045, F047, F048 | explicit FUTURE/DEFER gates |

Priority recommendation: RF01–RF06 before first commercial pilot; RF07–RF11 as release hardening; RF12 prevents proposal work from becoming false readiness.

No root fix is implemented by this documentation task.
