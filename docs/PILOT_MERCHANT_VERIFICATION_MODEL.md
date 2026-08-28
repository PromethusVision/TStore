# EsnaftaVar Esenler Pilot — Merchant Verification Model

**State:** `PROPOSED EVIDENCE MODEL — LEGAL/POLICY REVIEW MAY BE REQUIRED`

Merchant verification answers whether a person may operate a specific shop in the
pilot. It does not guarantee product quality, legal compliance, customer service,
inventory or reputation.

## States

`UNSTARTED → EVIDENCE_REQUESTED → UNDER_REVIEW → VERIFIED | NEEDS_MORE_EVIDENCE |
REJECTED → SUSPENDED | EXPIRED → REVERIFY`

## Minimum evidence classes

| Class | Purpose | Handling rule |
|---|---|---|
| Operator identity/account | Bind an authenticated person | Collect only approved minimum; never store credentials/tokens in cases |
| Shop relationship | Prove authority over exact physical shop | Evidence type and expiry need owner/legal approval |
| Location/existence | Prevent fictional/wrong-area shop | Field or reliable source check; record date/source |
| Sector/declaration | Route policy review | Does not authorize products by itself |
| Contact/control | Support and recovery | Verify without publishing private details by default |

## Controls

- verification and listing/QR capabilities are separate grants;
- exact shop scope is explicit;
- reviewer, reason, evidence references, policy version and timestamps are audited;
- rejected/expired status is not bypassed by a new client account;
- sensitive evidence has least-privilege access and retention review;
- unclear or expired evidence fails closed;
- suspension preserves history and provides an appeal/escalation route.

## Lean pilot option

The pilot may combine verification and onboarding work in one trained operator, but
high-risk or disputed cases require named second-line review. This is a staffing
compression, not an authority shortcut.

`MERCHANT_VERIFICATION_IS_REPUTATION: NO`

`VERIFICATION_EVIDENCE_FINALIZED: NO`
