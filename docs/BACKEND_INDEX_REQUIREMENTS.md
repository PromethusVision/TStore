# Backend Index Requirements

**State:** CONCEPTUAL ANALYSIS — NO INDEX SQL

Current migrations already index core owner, active catalog, shop/listing, Cart V2,
QR expiry/status, purchase time, review evidence, chat and notification access
paths. New indexes must be justified by measured query plans and production-like
cardinality, not by every foreign key or hypothetical filter.

## Future candidate shapes

| Query family | Candidate leading keys | Notes |
|---|---|---|
| Active listings by product | product/variant + active/availability + price + ID | support seller comparison order |
| Shop listing operations | shop + lifecycle + updated/revision + ID | merchant work queue |
| Membership authorization | user + organization/status; organization + shop scope | revocation lookup must be fast |
| Product candidate queue | status + priority/created + ID; normalized evidence | avoid unbounded fuzzy index initially |
| Purchase history | customer/shop + confirmed time + ID | stable cursor and participant RLS |
| Review list | product + visibility + created + ID | aggregate and list rule alignment |
| Ops cases | queue/status/severity/updated + ID | field-level access still required |
| Outbox | deliverable state + next attempt + ID | partial/lease semantics after design |

Index order follows equality filters, selective lifecycle predicates and final
cursor order. Partial/covering/geospatial/text indexes are candidates only after
query-plan evidence. Every index has write/storage cost, deployment lock/build
risk, rollback and duplicate-index audit. Exact additions are implementation
decisions, not Product Owner decisions.
