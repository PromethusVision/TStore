# Customer App Home Functional Audit

Status: PASS

## Functional surfaces

- Public Home opens after onboarding and does not require a customer fixture.
- Categories, featured products, banners, Nearby shops, location control, search, notifications/profile entries, and customer navigation are wired to real state/data contracts.
- Loading states do not invent demo records.
- Empty states distinguish no data from loading/error.
- Error states provide a real retry action.
- Product/category/shop taps reject missing identities and suppress rapid duplicate navigation.
- Product cards request seller prices in a bounded batch and remain usable if price lookup fails.
- A minimum purchasable listing price is shown where available; “featured” is discovery metadata, not sponsorship.
- Existing Production read-only smoke proved the demo baseline of 4 categories, 20 active/featured products, 57 shops, and 285 listings. Wave 16 does not contact Production.

## State/race review

Global Home Cubits are long-lived by design. View-local async price requests carry current IDs and ignore stale responses. Refresh/retry paths call the original query instead of synthesizing state. No deterministic stale-data or navigation defect was reproduced in existing unit/widget coverage.

## Deferred

Card spacing, typography, media proportions, icon treatment, and token migration are `UI_KIT_DEFER`. They are not functional blockers.

`HOME_FUNCTIONAL_AUDIT: PASS`
`FUNCTIONAL_HOME_BLOCKER: NO`
`COSMETIC_REVIEW: DEFERRED`
