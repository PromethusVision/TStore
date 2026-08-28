# Merchant Verification Expiry and Recheck Options

**State:** OPTIONS — OWNER/POLICY/LEGAL DECISION REQUIRED

## Recheck triggers

- evidence expiry or approaching expiry;
- issuing authority revocation/change;
- shop address/control/sector/activity change;
- policy/ruleset change;
- high-confidence fraud/security signal;
- repeated substantiated customer reports;
- material catalog/listing behavior change;
- periodic risk-based review;
- merchant-requested capability expansion.

## Options

| Option | Strength | Risk | Recommendation |
|---|---|---|---|
| Fixed annual recheck for all | Simple | Unnecessary burden; misses shorter expiry | Not universal |
| Document-expiry driven | Tracks authoritative validity | Some evidence has no date | Mandatory where available |
| Risk-tier interval | Proportionate | Requires owner-defined tiers | Preferred with documented rules |
| Event-triggered only | Low burden | Long stale periods | Insufficient alone |
| Continuous external registry check | Fresh | Cost, availability, false matches, data processing | Future after evidence |
| One-time verification | Cheapest | Unsafe for changing/regulated scope | Reject for sensitive use |

## Proposed hybrid

Document expiry plus event-triggered recheck for all; owner-approved risk-tier periodic review for sensitive activities. Ordinary low-risk assertions may have longer intervals. No exact duration is finalized here.

## Grace and fail-closed

A short grace period may apply only to non-safety-critical capability if owner/policy explicitly permits it. Expired regulated evidence blocks the dependent capability; it does not silently remain verified. Notification failures do not extend validity. Merchant receives advance notice and a clear remediation route.

## Audit and privacy

Record trigger, prior/current evidence, policy version, decision, effective/expiry, dependent capabilities, and communication. Reuse still-valid evidence rather than repeatedly collecting documents. Delete/redact data when no longer needed under approved retention rules.

`RECHECK_INTERVAL_FINALIZED: NO`

`ONE_TIME_REGULATED_VERIFICATION: NOT_RECOMMENDED`
