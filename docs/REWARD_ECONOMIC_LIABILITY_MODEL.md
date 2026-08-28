# Reward Economic Liability Model

**State:** OPTIONS — ACCOUNTING/LEGAL REVIEW REQUIRED

This is an architecture review, not accounting, tax or legal advice. Any point, voucher, discount promise or transferable credit can create operational obligations even when called “non-cash.”

## Liability questions

| Question | Why it matters | Gate |
|---|---|---|
| Who owes the benefit? | Determines merchant/platform obligation and customer remedy. | P0 owner + contract review |
| When is value earned? | Purchase confirmation, settlement and correction timing change exposure. | P0 |
| Is value fixed or variable? | Retroactive changes can breach trust. | P0 |
| Can value transfer across merchants? | Creates clearing/reconciliation complexity. | P0 |
| What happens on expiry/refund/deletion? | Requires auditable release/reversal rules. | P0/P1 |
| Is outstanding value measurable? | Needed for reconciliation and risk monitoring. | P0 |

## Required controls

- Versioned terms and funding source snapshot on every economic entry.
- Immutable `EARN/ADJUST/REVERSE/REDEEM/EXPIRE` chain; no balance overwrite.
- Reconciliation by funder/program and dispute-ready evidence.
- Caps and kill switch that stop new issuance without erasing earned rights.
- Separate marketing analytics from accounting records.

**Recommendation:** no economic promise in the first pilot; obtain professional accounting/tax/legal review before issuance.
