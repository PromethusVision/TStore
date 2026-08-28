# Backend Evolution Bridge

**State:** RECOMMENDED EVOLUTION PLAN — NOT OWNER-FINAL
**Wave:** 21 / Workstream D

## Principle

Evolve the working Customer App backend through additive, reversible steps. A
future concept does not justify replacing an active table/RPC merely to improve
naming. Compatibility reads and explicit dual-read/dual-write windows require
their own migration plan; neither is implied by this document.

## Bridge matrix

| Future concept | Current support | Direction | Compatibility rule |
|---|---|---|---|
| Customer identity | Auth user + `profiles` | EXTEND EXISTING | Preserve profile ID and role guard |
| Merchant organization | None; direct shop owner only | NEW CONCEPT NEEDED | Backfill/bridge only after deterministic owner mapping |
| Merchant membership | None | NEW CONCEPT NEEDED | No rights until active server-side membership exists |
| Shop/branch | `shops` | EXTEND EXISTING | Preserve shop IDs and public Customer App reads |
| Capability | Profile role + owner check | NEW CONCEPT NEEDED | New checks may narrow; never broaden by metadata fallback |
| Canonical product | `products` | EXTEND EXISTING | Preserve IDs and current reads |
| Variant | None | NEW CONCEPT NEEDED | Nullable for products without identity-changing variation |
| Shop listing | `shop_products` | EXTEND EXISTING | Preserve listing identity; add revision/freshness additively |
| Price/availability | Listing plus compatibility product fields | EXTEND EXISTING | Listing becomes future authority only after explicit migration |
| Merchant SKU/barcode | No governed namespace model | NEW CONCEPT NEEDED | Merchant code never becomes global product identity |
| Product candidate | None | NEW CONCEPT NEEDED | Candidate cannot be customer-visible canonical automatically |
| Product merge/split | No lineage contract | NEW CONCEPT NEEDED | Append lineage; never rewrite evidence silently |
| Taxonomy assignment | Category FK | EXTEND EXISTING | Stable node/version before rename/move/split tooling |
| Cart V2 | `carts`, `cart_items_v2` | EXTEND EXISTING | Preserve single-shop behavior and listing references |
| QR issue/consume | QR tables + RPCs | EXTEND EXISTING | Preserve token TTL, shop binding, atomic single use |
| Verified purchase | Transaction + item snapshot | EXTEND EXISTING | Preserve IDs/product evidence and historical snapshots |
| Reviews | `reviews` + verified RPCs | EXTEND EXISTING | Preserve lifetime one-active-review rule |
| Notifications | `notifications` + Realtime | EXTEND EXISTING | Separate notification fact from channel delivery |
| Chat | Direct sender/receiver | EXTEND OR DEFER | Add merchant shop/staff context only when product flow requires it |
| Ads | None | NEW CONCEPT NEEDED | Target listing revisions; never alter organic/review/reputation truth |
| Reward ledger | None | NEW CONCEPT NEEDED | Source only from approved authoritative event/policy |
| Reputation signal | Rating exists; broader reputation absent | NEW CONCEPT NEEDED | Rating stays visible and independent |
| Operations case | None | NEW CONCEPT NEEDED | Restricted case/audit layer; no hidden superuser shortcut |
| Event platform/outbox | Domain triggers but no general outbox | DEFER/NEW | Add only for delivery-critical projections; analytics is not command bus |

## Safe migration shape

1. Inventory live callers and define old/new response compatibility.
2. Add new identities/columns/tables without changing active reads.
3. Backfill using deterministic, audited rules; unresolved rows remain explicit.
4. Introduce server contract/RPC with version and bounded error classes.
5. Run Development shadow comparison and concurrency/failure tests.
6. Move one caller class at a time behind a compatibility boundary.
7. Observe mismatches; never repair by silent data coercion.
8. Retire an old path only after all callers, rollback and historical reads are
   proven.

## Fail-closed bridges

- A missing membership does not fall back to `profiles.role = merchant` for a
  privileged write.
- A missing variant does not cause an arbitrary sibling to be selected.
- A product split does not assign historical purchases/reviews to the first child.
- Missing availability means unknown, not in stock.
- Missing event delivery does not roll back an already committed purchase, and an
  analytics retry cannot recreate it.
- Advertising attribution, reward qualification and reputation evidence each
  re-evaluate their own policy and authority.

## Owner decision gates

- organization introduction timing and pilot backfill rule;
- variant minimum scope;
- whether event outbox is required for pilot side effects;
- historical product split and review collision policy;
- reward, ads and reputation pilot scope.

All remain `OWNER_DECISION_REQUIRED`. No migration or runtime transition is
authorized here.
