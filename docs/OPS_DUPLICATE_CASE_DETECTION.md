# Duplicate Case Detection

**State:** PROPOSED — NO ML OR AUTO-CLOSE IMPLEMENTATION

## Purpose

Reduce repeated review without losing reporters, evidence, scope, or urgency.

## Candidate signals

Exact subject/event/transaction/listing/review/campaign ID; same reporter + reason + short window; shared error/correlation signature; same merchant/shop/product and policy issue; incident/time cluster; normalized safe text fingerprint; evidence hash. Free-text similarity alone is weak.

## Outcomes

- `EXACT_DUPLICATE`: link intake to primary case; preserve reporter/evidence/acknowledgement.
- `RELATED`: link cases but keep separate decisions/scopes.
- `INCIDENT_CLUSTER`: link under incident while preserving cases.
- `POSSIBLE_DUPLICATE`: operator suggestion.
- `DISTINCT`: no merge.

## Safeguards

Do not merge different affected people, shops, products, transactions, policy versions, appeal rights, or severities merely because text matches. New evidence or higher severity can reopen/escalate primary. Duplicate status never suppresses urgent safety/security report.

## Explainability

Show matched IDs/time/reason and differences. No opaque classifier final decision. Reporter identities remain separate and protected. Every link/unlink is audited and reversible.

## Metrics

Dedup rate, incorrect-merge/unlink, repeated underlying incident, reporter follow-up, and handling time—without using dedup to hide case volume.

`DUPLICATE_ML_IMPLEMENTED: NO`

`DUPLICATE_REPORT_DISCARDED: NO`
