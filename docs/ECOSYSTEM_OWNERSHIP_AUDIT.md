# Ecosystem Ownership Audit

## Ownership classes

- **Customer-owned:** mutable customer content/preferences, always constrained by
  account scope and server validation.
- **Merchant-owned:** exact-shop offer/profile truth the merchant is entitled to
  maintain; never canonical identity or customer evidence.
- **Platform-owned:** taxonomy, canonical catalog governance, policy definitions,
  release identity and case governance.
- **Server-authoritative:** facts whose trust cannot be delegated to a client:
  membership, QR consumption, verified purchase, review eligibility, aggregates,
  future reward ledger and governed reputation signals.
- **Derived:** recomputable projections from authoritative facts; not a write-back
  authority.
- **Analytics-only:** minimized question-led measurement; cannot mutate domain state.
- **Audit:** restricted immutable operational/security evidence.

## High-risk field ownership

| Field/fact | Owner | Forbidden writer/source |
|---|---|---|
| canonical product identity/taxonomy | Platform catalog governance | merchant listing form, Ads, analytics |
| listing price/availability/SKU | exact-shop merchant capability | canonical product, customer, campaign |
| shop ownership/staff capability | membership server workflow | profile role/client metadata/sector |
| QR verified purchase | atomic exact-shop server command | customer, analytics event, legacy boolean |
| review eligibility | verified evidence evaluator | merchant, Ads, Reward, quantity/repeat purchase |
| organic order/relevance | organic search/discovery contract | ad spend, badge, reputation payment |
| Reward ledger | future trusted evaluator | click/view analytics, review right |
| reputation evidence | future governed evaluator | campaign spend or hidden rating rewrite |
| Ops decision | case/capability/policy | admin UI visibility alone |
| release certification | immutable artifact + evidence gates | source tests alone |

The matrix contains 38 scoped facts/actions. No ownership conflict remains hidden;
policy-sensitive activation choices are routed to owner roots.
