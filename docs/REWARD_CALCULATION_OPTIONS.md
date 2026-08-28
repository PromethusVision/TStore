# Reward Calculation Options

**State:** OPTIONS — NO FORMULA FINALIZED

| Model | Trusted input need | Complexity | Assessment |
|---|---|---|---|
| Fixed stamp per verified purchase | Unique verified event | Low | Strongest starting hypothesis. |
| Purchase count | Unique settled event and repeat rules | Low/medium | Explainable; split-purchase gaming risk. |
| Spend-weighted | Authoritative money/currency/tax/refund amounts | High | Unsafe with current evidence assumptions. |
| Merchant-configured | Versioned bounded templates/funding | High | Future only. |
| Category-based | Stable policy/category IDs | Medium/high | Taxonomy correction and incentive risk. |

Quantity does not multiply a review right and must not automatically multiply reward. Repeat purchases may be eligible only after owner rules; idempotency remains per authoritative event. No client total, listing price or displayed discount is authoritative purchase amount.

**Recommendation:** test fixed-stamp/purchase-count in non-economic shadow mode; no economic formula is selected.
