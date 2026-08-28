# Operations Decision Quality Model

State: PROPOSED FOR OWNER REVIEW

## Purpose

Operational quality means that comparable cases receive explainable, evidence-based and policy-consistent decisions while personal data exposure and false-positive harm remain limited. It is not operator throughput or a quota.

## Quality dimensions

| Dimension | Review question | Minimum evidence |
|---|---|---|
| Authority | Was the action permitted for this operator, scope and case? | authorization decision and actor identity |
| Evidence | Does retained evidence support the finding? | evidence references, provenance and integrity state |
| Policy | Was the effective policy version applied? | policy/version reference and applicability |
| Proportionality | Was the least harmful adequate action selected? | reason, alternatives and impact scope |
| Explanation | Can the subject understand the outcome without abuse-signal leakage? | public reason code and safe explanation |
| Consistency | Is the outcome compatible with materially similar cases? | precedent/calibration reference where relevant |
| Reversibility | Can an error be corrected without erasing history? | reversal or superseding-event path |
| Appeal | Was eligible appeal access preserved? | appeal status, deadline policy and independent reviewer rule |
| Privacy | Was access limited to necessary fields? | access-purpose and redaction state |

## Quality review method

- Review a risk-weighted sample: all P0/high-risk actions, a larger sample of P1 actions, and a smaller random sample of routine work.
- Include approved, rejected, no-action, reversed and appealed cases; sampling only enforcement actions creates blind spots.
- Where practical, hide the original operator identity during first-pass calibration to reduce status bias.
- A reviewer records a structured result: `CONSISTENT`, `MINOR_CORRECTION`, `MATERIAL_ERROR`, `POLICY_GAP`, or `INSUFFICIENT_EVIDENCE`.
- Corrections append a review finding and follow the normal reversible-action contract; audit history is never rewritten.

## Metrics with safeguards

Track decision reversal rate, appeal uphold/overturn rate, reopened-case rate, evidence sufficiency, policy-version errors, false-positive indicators and unexplained decision variance. Segment by case type and risk, not by simplistic league tables. Queue age and response targets may reveal capacity problems but must not reward rushed enforcement.

## Calibration and learning

Use anonymized case packets for periodic calibration. Disagreement should first test evidence sufficiency, policy wording and reason-code clarity; it must not be resolved by silently forcing a preferred outcome. Repeated ambiguity becomes a policy or tooling improvement item.

## Boundaries

- No opaque operator score, productivity surveillance or automatic punishment from quality metrics.
- No quality reviewer may directly edit verified history or manufacture missing evidence.
- Two-person review is reserved for defined high-risk actions, not every routine support response.
- Exact sample rates, review independence rules and acceptable error thresholds remain owner/policy decisions.

