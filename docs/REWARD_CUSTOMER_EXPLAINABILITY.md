# Reward Customer Explainability

Status: **PROPOSED — OWNER/POLICY REVIEW REQUIRED**
Wave: 18 / Workstream AI

## Customer must understand

- Current program/merchant scope and earned unit.
- Which authoritative events count and which do not.
- Progress/threshold calculation and terms version.
- Funding/benefit owner and redemption location/conditions.
- Expiry date/rule before earning and redeeming.
- Pending, held, reversed, redeemed and expired entries.
- How to dispute missing/incorrect reward.

## Required language

Use exact unit (“3/5 damga”), not ambiguous cash-like value. Distinguish verified purchase from payment, reward from badge and expiry from deletion.

## Failure states

- QR failed: no claim that reward was earned.
- Purchase verified but evaluator delayed: `pending`, not zero/missing.
- Duplicate event: show single entitlement.
- Fraud/policy hold: safe neutral status and support path.
- Merchant/program closure: apply terms/portability decision, never silently erase.

No formula, threshold, redemption value or expiry is finalized by this document.
