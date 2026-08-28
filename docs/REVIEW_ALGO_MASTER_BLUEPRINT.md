# Unified Review and Merchant Badge Master Blueprint

**State:** READY FOR OWNER REVIEW — NOT CANONICAL/FINAL

## Architecture in one page

```text
Merchant-confirmed QR verified purchase
  ├─ Product lane: one lifetime active review per customer + canonical product
  │    └─ origin-shop merchant-feed projection (no second seller free text)
  └─ Shop lane: short structured response set per eligible purchase
       └─ customer+shop effective cap
            └─ dimension aggregates (product stars excluded)
                 └─ primary badge candidates
                      └─ versioned composite/meta DAG (future only)
```

## Leading research recommendations

- Single form with product and shop sections; three versus four questions, leading with three.
- Friendliness, helpfulness and accurate product information; test overall experience as fourth.
- Raw shop response per purchase, latest effective contribution per customer+shop+window; window unselected.
- Product free text stays on the immutable origin shop even after cross-shop repeat purchase.
- Shop-first reputation; organization roll-up and public merchant star deferred.
- Model B Bayesian ordinal estimate plus Model D gates as offline candidate; Model A audit baseline.
- `Insufficient history`, never a punitive new-shop score; no quantity/value/frequency/ad/reward weight.
- No pilot decay or badges. Progress collection → internal analysis → primary badges → composite/meta.
- Badge DAG requires active prerequisites, sample/confidence/freshness, integrity/policy and region gates.
- `Mahallenin Yıldızı` remains Phase 4 and unselected; small regional cohorts fail closed.

## Immutable trust boundaries

Server evidence grants rights. Product rating and merchant dimensions never share an aggregate. Moderation
cannot edit scores. Fraud signals require evidence/case/appeal. Ads and rewards are completely decoupled.
Verified purchase is not payment, receipt, revenue or platform guarantee.

## Owner/professional gates

Fifteen root decisions cover launch phase, questions, identity/cap, origin feed, scope/lifecycle,
aggregation/sample/recency, badge families/lifecycle/composites/locality, public surfaces and privacy.
Runtime, DB, Production and public badge thresholds require separate future authorization.

`ARCHITECTURE_RECOMMENDATION: PHASE_1_COLLECTION_THEN_EVIDENCE`
`FINAL_FORMULA: NONE`
