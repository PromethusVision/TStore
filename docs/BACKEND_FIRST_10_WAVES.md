# Backend First 10 Implementation Waves

**State:** RECOMMENDED SEQUENCE — NO IMPLEMENTATION AUTHORIZED

| Wave | Goal | Scope | Dependencies | Migration owner | Tests / integration gate | Complexity |
|---:|---|---|---|---|---|---:|
| 1 | Baseline lock | current schema/RPC/RLS/query snapshots and contract tests | owner root decisions relevant to V1 | Integration-designated single author | clean-room 0001–0009, RLS/RPC baseline, Customer N/N-1 | M |
| 2 | Merchant identity seam | additive organization/membership/capability model for one shop | ROOT-01 | one author; Auth/RLS reviewers separate | role escalation, cross-shop, revocation, Customer regression | L |
| 3 | Listing command surface | listing-owned price/availability/SKU mutation and revision | Wave 2, ROOT-03 | one author | validation, duplicate retry, lost update, seller comparison | L |
| 4 | Merchant QR verification | membership-bound inspect/consume with current one-winner contract | Waves 1–2, ROOT-05 | one author | expiry, wrong shop, replay, concurrency, physical two-device | L |
| 5 | Minimal merchant operations | recent confirmations, truthful counts, operation notifications | Waves 3–4, ROOT-10/12 | one author if schema needed | metric semantics, pagination, Realtime authorization | M |
| 6 | Candidate intake | governed candidate queue; no auto-promotion | Waves 2–3, ROOT-12 | one author | tampering, dedup, staff capability, operator decision audit | M |
| 7 | Selected variants | only approved correctness-critical domains | catalog owner choice ROOT-02 | one author | identity, cart, listing, QR snapshot, old-client compatibility | XL |
| 8 | Catalog correction | merge/split lineage and explicit ambiguity | Wave 7, ROOT-04 | one author | 300 correction cases, review/reward evidence preservation | XL |
| 9 | Privacy/lifecycle | approved retention, deletion and suspension effects | ROOT-06/07/09 | one author | deletion residuals, pseudonymization, audit access, legal gate | L |
| 10 | Optional future systems | independently gated Ads/Reward/reputation/event consumers | ROOT-08 and separate foundations | separate waves; one author each | decoupling, ledger authority, billing/legal acceptance | XL |

Each wave uses an isolated task branch. A migration file may be authored only by
the named wave owner; remote Development/Production apply is separate authority.

