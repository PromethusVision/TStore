# Reward Fraud Threat Model

Status: **PROPOSED — SECURITY REVIEW REQUIRED**
Wave: 18 / Workstream I

| ID | Priority | Threat | Required boundary |
|---|---|---|---|
| RF-01 | P0 | Fake QR verification | Existing server-authoritative QR and shop binding |
| RF-02 | P0 | Merchant/customer collusion | Hold/risk review and relationship/device/account signals |
| RF-03 | P0 | Replay/duplicate event | Source identity uniqueness and ledger idempotency |
| RF-04 | P0 | Split-purchase farming | Versioned earning window/rule; do not infer harmlessness |
| RF-05 | P0 | Quantity/amount inflation | Trust-state gating; no weighting by untrusted values |
| RF-06 | P0 | Multi-account abuse | Account/device/risk controls with privacy safeguards |
| RF-07 | P0 | Merchant/staff self-purchase | Membership/relationship exclusion or review hold |
| RF-08 | P1 | Merchant staff mass confirmation | Shop/staff rate anomaly and audit |
| RF-09 | P1 | Refund/correction avoidance | Append reverse/adjust after authoritative correction |
| RF-10 | P1 | Program cycling/reset | Durable merchant/program lineage |
| RF-11 | P1 | Reward dispute fabrication | Evidence-linked support and non-editable history |
| RF-12 | P2 | Notification/social engineering | Trusted deep links and no secret/balance authority in push |

Counts: P0 = 7, P1 = 4, P2 = 1.

## Principles

Fraud score is not customer social credit or public merchant badge. High-risk events can be held without deleting source purchase evidence. Reward reversal never silently removes legitimate review eligibility unless the independent verified-purchase correction contract requires it.
