# EsnaftaVar Esenler Pilot — Customer First Use and Trust

**State:** `PROPOSED JOURNEY — UI NOT DESIGNED`

## First-use journey

1. user sees the bounded Esenler pilot promise and coverage limits;
2. guest can inspect discovery value before unnecessary registration;
3. location request appears only at the moment it improves nearby results, with a
   manual area fallback;
4. search/category returns honest local results or a truthful empty state;
5. product shows seller, price/availability freshness and shop context;
6. user can compare/open shop and request directions/contact;
7. protected actions explain why login is needed;
8. QR, if enabled, explains physical-purchase evidence and no payment processing;
9. feedback/support is visible without becoming the main journey.

## Trust promises

- coverage is selected and local, not “all Esenler”; 
- availability may be `UNKNOWN`; no false in-stock language;
- distance/directions are intent aids, not proof of visit or sale;
- sponsored content is absent in the recommended first pilot; if introduced later,
  it must be explicitly labelled and independently governed;
- verified purchase is not payment or merchant revenue;
- reviews follow the existing eligibility contract;
- customer data and precise location are minimized.

## Recovery paths

| Failure | Customer-safe response |
|---|---|
| No results | Explain coverage and allow nearby/category adjustment without fake results |
| Location denied | Manual area/cell selection and clear limited behavior |
| Stale/unknown listing | Show status, enable shop confirmation if supported |
| Login/session failure | Preserve safe browse context where possible; no false action success |
| Directions handoff fails | Retry/copy address path without claiming visit |
| QR timeout | Reconcile authoritative state before retrying |
| Support unavailable | Publish hours and urgent safety route; do not claim 24/7 |

## Acceptance questions

Can a new user explain what EsnaftaVar does, what it does not do, which area is
covered, what freshness means and whether QR is payment? If not, acquisition pauses
until the promise is understood.

`CUSTOMER_TRUST_ACCEPTANCE_COMPLETE: NO`
