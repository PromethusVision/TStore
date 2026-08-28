# Backend Audit and Analytics Separation

**State:** PROPOSED — SEPARATE PURPOSES AND ACCESS

| Dimension | Audit/security evidence | Product analytics |
|---|---|---|
| Purpose | Reconstruct privileged action, denial, correction and incident | Measure product use/outcomes |
| Authority | Trusted control/domain path | Mixed and explicitly labelled |
| Mutability | Append-only or superseding correction | Versioned projection/restatement |
| Identity | Necessary actor/subject/case under restricted access | Minimized/pseudonymous/aggregate where possible |
| Payload | Reason, policy, evidence reference, bounded before/after | Allowlisted metric dimensions; no unrestricted content |
| Access | Case/capability/purpose bound | Approved analytical roles and aggregation thresholds |
| Retention | Evidence/policy driven | Metric/privacy-purpose driven |

Audit events are not engagement metrics, operator productivity tracking or a
default dashboard source. Analytics cannot satisfy an audit requirement merely
because an event was logged. One domain transition may create linked but distinct
audit and analytics records with different IDs, schemas, access and retention.

Never copy passwords, tokens, raw QR, private chat/review content, full evidence
documents or precise unnecessary location into either system. Audit export and
analytics re-identification are privileged, recorded actions. Retention and legal
hold classes remain `OWNER_DECISION_REQUIRED`.
