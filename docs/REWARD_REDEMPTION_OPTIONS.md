# Reward Redemption Options

Status: **PROPOSED — NO COUPON ENGINE**
Wave: 18 / Workstream G

| Option | Example meaning | Main dependency | Risk |
|---|---|---|---|
| Discount | Fixed/percentage reduction | Price/payment or checkout proof | Bait, margin, tax/receipt handling |
| Voucher | Defined merchant benefit entitlement | Issuance, claim, consume and expiry | Transfer/replay/dispute |
| In-kind benefit | Merchant-provided item/service | Inventory/policy and clear terms | Substitution/availability |
| Badge-only unlock | Recognition, no economic value | Badge semantics | Mislabeling as reward value |
| Merchant-defined benefit | Configurable within platform templates | Governance/approval/versioning | Arbitrary unfair changes |

## Redemption contract

- Earned entitlement and redemption attempt have separate immutable identities.
- Redemption is server-authoritative, shop/program authorized, idempotent and one-time where applicable.
- Failed redemption cannot consume entitlement; unknown outcome reconciles.
- Customer sees benefit, eligible merchant/shop/products, expiry and exclusions before earning/redeeming.
- Merchant cannot edit earned customer history or silently reduce value.

## Recommendation

Do not implement until funding and purchase amount trust are resolved. If launched, prefer a simple template-based merchant benefit with platform governance rather than arbitrary coupons.
