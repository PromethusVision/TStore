# Merchant Reputation Time-Decay Options

Status: **PROPOSED — OWNER_DECISION_REQUIRED**
Wave: 18 / Workstream X

| Evidence | Option | Recommendation |
|---|---|---|
| Identity/policy verification | Expire/revalidate by source terms | Current factual status only |
| Listing/availability accuracy | Rolling recent window | Yes; old operations should not dominate |
| Verified purchase volume | Time-windowed, scale-normalized | Never direct quality score |
| Customer reviews/ratings | Keep dated visible history; aggregate policy separate | Do not silently erase/decay real rating |
| Upheld abuse/security | Severity-based retention and remediation | Policy/legal review |
| Profile completeness | Current snapshot | Recompute, not historical score |

## Options

- No decay: simple but stale evidence dominates.
- Fixed rolling window: comparable but boundary effects.
- Exponential weighting: smooth but opaque.
- Evidence-specific lifecycle: most explainable, more governance.

## Recommendation

Evidence-specific lifecycle. Use current state for verification/completeness, bounded recent windows for operations, and retain customer review history visibly under its independent contract. No opaque universal decay formula.
