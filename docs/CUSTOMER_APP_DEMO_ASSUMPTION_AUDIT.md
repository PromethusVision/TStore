# Customer App Demo Assumption Audit

Status: PASS

Runtime source scan found no hardcoded demo counts (`57` shops, `285` listings, or `19` neighborhoods) and no Esenler-only filter/sort boundary in reusable discovery logic. Esenler strings in active runtime are legal company address or customer input examples; dataset counts and neighborhood names are confined to demo/live tests and seed tooling.

- UI list lengths derive from repository responses.
- Shop owner ID is nullable in the model.
- Customer discovery/shop details/seller comparison work when owner is null.
- Merchant chat self-check applies only when an actual owner exists.
- Demo shops are never assumed able to confirm QR.
- Featured demo products are discovery content, not hardcoded sponsorship.
- Coordinates are parsed generically and distance math has no district polygon assumption.

The deterministic demo dataset and Production were not changed or contacted.

`DEMO_ASSUMPTION_AUDIT: PASS`
`RUNTIME_DEMO_COUNT_HARDCODE: NO`
`DEMO_DATASET_CHANGED: NO`
