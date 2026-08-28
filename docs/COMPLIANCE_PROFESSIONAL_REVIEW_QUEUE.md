# Compliance Professional Review Queue

**State:** ROUTED — NOT PROFESSIONALLY DECIDED
**Input:** 32 consolidated questions in `COMPLIANCE_LEGAL_QUESTION_DEDUP.md`.

Each question has one accountable primary route so none disappears. Secondary reviewers remain
consulted where the issue crosses disciplines.

| Primary route | Count | Consolidated questions | Expected output |
|---|---:|---|---|
| `LAWYER` | 12 | CQ-01, 08, 09, 12, 13, 14, 15, 18, 21, 22, 26, 28 | scoped legal position, wording/rule, residual uncertainty |
| `KVKK/PRIVACY_SPECIALIST` | 7 | CQ-02, 03, 04, 05, 07, 10, 16 | purpose/ground, notice, rights, transfer and minimization disposition |
| `ACCOUNTANT/TAX_ADVISER` | 1 | CQ-29 | funding, records, tax/accounting treatment; no product inference |
| `DOMAIN_REGULATORY_SPECIALIST` | 6 | CQ-17, 20, 23, 24, 25, 27 | item/capability evidence and permitted/excluded boundary |
| `PRODUCT_OWNER` | 2 | CQ-19, 30 | product scope after professional constraints are known |
| `TECHNICAL_ARCHITECT` | 4 | CQ-06, 11, 31, 32 | enforceable control and evidence design |
| **Total** | **32** | **CQ-01–CQ-32** | — |

## Priority queue

- **P0 before pilot:** CQ-01–04, CQ-08–16, CQ-18–23, CQ-26 and any released part of
  CQ-28–30.
- **P1 before affected feature:** CQ-05–07, CQ-17, CQ-24–25, CQ-27, CQ-31–32.
- **P2 optimization:** only implementation refinements that do not change the professional answer.

## Review packet standard

Every answer must record source/version/date, factual product assumptions, what was decided, what
was not decided, affected capabilities, implementation evidence and review trigger. “Legal review”
without a named owner or deliverable does not close an item.
