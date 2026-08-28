# Reward Hybrid Funding Options

**State:** OPTIONS — OWNER DECISION REQUIRED

Hybrid funding combines merchant and platform contributions but must not blur who owes the customer.

| Pattern | Ledger requirement | Risk |
|---|---|---|
| Co-funded single benefit | Split funding snapshot per entry | Settlement and reversal allocation. |
| Merchant base + platform bonus | Separate linked entries | Customer may confuse expiry/scope. |
| Platform match | Bounded match rule and budget | Abuse and budget exhaustion. |

Rules must name the program/funder, record separate liabilities, apply proportional reversal, prevent double redemption and explain which portion works at which merchant. One opaque balance without funder lineage is unsafe.

**Recommendation:** defer hybrid funding until merchant-specific and platform-funded models each reconcile independently.
