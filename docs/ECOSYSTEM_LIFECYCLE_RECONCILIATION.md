# Ecosystem Lifecycle Reconciliation

**State:** RECOMMENDED CONTRACT — OWNER POLICY GATES REMAIN OPEN

| Entity | Minimum lifecycle | Cross-system effect |
|---|---|---|
| Auth/customer account | active → restricted → deletion_requested → deleted/pseudonymized | stop sessions/private access; preserve only purpose-approved historical evidence |
| Merchant organization | pending → active → restricted/suspended → closed | blocks new privileged writes; does not rewrite historic shops/purchases/reviews |
| Membership/staff | invited → active → revoked/expired | next request/subscription loses capability; audit remains |
| Shop/branch | draft → review → active → temporarily_closed/restricted → retired | inactive shop hidden from new discovery/QR; historical evidence remains |
| Canonical product | candidate → review → active → restricted/retired → merged/split lineage | listings/campaigns suppressed as required; history never silently reassigned |
| Variant | draft → active → retired/superseded | old purchase/review snapshots remain resolvable |
| Shop listing | draft → active → stale/unknown → paused/retired | current customer claims reflect freshness; old purchases unchanged |
| QR session | issued → active → consumed/expired/cancelled | exactly one terminal result; no resurrection |
| Verified purchase | created → corrected/reversed-by-evidence | append/link correction; no silent delete/rewrite |
| Review | active → edited → deleted/hidden/restored where policy permits | one active customer+canonical product; evidence survives content deletion |
| Ad campaign | draft → review → scheduled → active → paused/ended/rejected | never changes organic eligibility or trust evidence |
| Reward ledger item | earned → adjusted/reversed → redeemed/expired | immutable event chain; analytics delivery cannot mint value |
| Reputation signal | observed → active → challenged/revoked/retired | rating remains independent and visible |
| Ops case | opened → triaged → investigating → actioned/appealed → closed/reopened | actions reference case/evidence/policy version |
| Domain/analytics event | accepted/quarantined → processed/reconciled → retained/expired | domain truth survives telemetry failure |
| Release candidate | built → tested → accepted/rejected → distributed/retired | certification applies only to exact artifact/environment |

## Cross-lifecycle rules

- Parent suspension prevents new child operations but never fabricates deletion.
- Product/shop/listing retirement suppresses future discovery/Ads/QR while durable
  purchase and review evidence remains.
- Campaign pause never pauses an organic listing; listing ineligibility suppresses
  the campaign.
- Merchant closure does not delete customer reviews or rewrite verified purchases.
- Account deletion and policy retention are purpose-specific, not one global cascade.
- State transitions are server-validated and invalid transitions fail closed.
