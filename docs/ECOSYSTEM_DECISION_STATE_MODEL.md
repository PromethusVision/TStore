# Ecosystem Decision State Model

| State | Meaning | Reconciliation behavior |
|---|---|---|
| CONFIRMED — PRODUCT OWNER FINAL | Explicit owner-approved product decision at documented scope | Preserve exactly; supersede only by later explicit owner decision |
| FINAL runtime/release evidence | Implemented and verified behavior/artifact, not automatically a future product decision | Preserve working contract and exact evidence boundary |
| PROPOSED | Design candidate awaiting owner review | Compare and recommend; never present as selected |
| RECOMMENDED | Agent/research preference | Include rationale and alternatives; checkbox remains empty |
| HYPOTHETICAL | Simulation under assumed choices | Never use as canonical input or readiness proof |
| TBD / OWNER_DECISION_REQUIRED | Material unresolved product/policy choice | Route to global root decision |
| AUDIT COMPLETE | Investigation coverage finished | Does not imply implementation or owner approval |

When sources conflict, confirmed decisions and actual working contracts take
precedence within their scope. Proposed systems may add compatibility seams but may
not reinterpret canonical IDs, purchase evidence, reviews or release facts.
