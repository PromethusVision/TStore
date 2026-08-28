# Merchant App Architecture Readiness

Status: **PROPOSED — OWNER REVIEW ENTRY**
Wave: 17 / WP99

| Area | Status | Main gap |
|---|---|---|
| Identity | MINOR_GAP | RD-01/RD-02/RD-03 owner choices |
| Shop | MINOR_GAP | Branch/lifecycle/location approval policy |
| Catalog | MAJOR_GAP | Catalog source P0 identity/activation decisions |
| QR | READY_FOR_OWNER_REVIEW | TTL/reservation/lifecycle decisions; backend implementation later |
| Analytics | MINOR_GAP | Metric/privacy threshold choices |
| Reviews | MINOR_GAP | Reply/report policy |
| Notifications | MINOR_GAP | Channel/mandatory event matrix |
| Security | READY_FOR_OWNER_REVIEW | Controls defined; implementation/evidence pending |
| Backend | MAJOR_GAP | Schema/RLS/RPC/migration not designed or implemented |
| Testing | READY_FOR_OWNER_REVIEW | Matrices ready; runtime harness absent by design |
| V1 | READY_FOR_OWNER_REVIEW | 16/7/5/3 scope awaits approval |
| Future engines | MINOR_GAP | Source contracts mapped; no owner launch decisions |

Counts: `READY_FOR_OWNER_REVIEW = 4`, `MINOR_GAP = 6`, `MAJOR_GAP = 2`.

Architecture research is ready for owner review; runtime implementation is not ready until P0 roots and backend contract are resolved.
