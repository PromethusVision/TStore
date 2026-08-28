# Operations Review Queue Model

**State:** PROPOSED — NO QUEUE IMPLEMENTATION

## Initial queues

- merchant verification;
- regulated/policy review;
- catalog candidate/dedup;
- catalog merge/split/reclassification;
- listing/media moderation;
- review reports;
- QR fraud/verified correction;
- ads review/invalid traffic when enabled;
- account security/privacy incidents;
- appeals.

## Queue item

Case ID, type, priority/severity, primary subject, safe reason summary, required capability, policy version/freshness, evidence completeness, assignment, age/target, dependency/blocker, and conflict/appeal status. No unnecessary PII in list view.

## Routing

Deterministic rules may route by case type, subject, policy class, severity, language, and required capability. They must not make final high-impact decisions. Unrecognized or conflicting cases go to triage, not a random queue.

## Assignment

Pull or explicit assignment; ownership lease/expiry; handoff reason; no two operators unknowingly acting on the same version; stale-version conflict on decision. P0/P1 has named owner and escalation.

## Fairness

Queue order combines severity, urgency, age, vulnerable-user/safety risk, and external deadline. Merchant size, ad spend, social pressure, or operator preference does not buy priority. Related duplicates link to a primary case.

## Health

Track unassigned count, oldest age, target status, waiting-external time separately, reopen/appeal/false-positive, and blocked dependencies. “Closed count” alone is not quality.

`QUEUE_MODEL_FINAL: NO`

`AUTO_ENFORCEMENT_FROM_QUEUE: NO`
