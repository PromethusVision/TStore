# Catalog Analytics Identity Model

Status: **OWNER REVIEW DRAFT — NO ANALYTICS IMPLEMENTATION**
Wave: 16, Work Package 44

Analytics records the identity observed at event time and a separate current-lineage
projection. Reprocessing may change the projection, never the original event.

## Event keys

- event ID/time and anonymized/pseudonymous actor/session as actually needed;
- canonical product ID and product revision observed;
- variant ID when selected/known;
- shop listing and shop ID for offer/seller/cart/QR events;
- stable taxonomy leaf and taxonomy/ruleset version;
- predecessor ID when event used an alias;
- event type, surface and minimal experiment/attribution context;
- policy-safe price/availability snapshot only where the event needs it.

## Continuity rules

| Change | Analytics treatment |
| --- | --- |
| Rename/taxonomy move | Same product ID; keep observed title/leaf version and current projection. |
| Duplicate merge | Historical events retain predecessor; lineage aggregate may roll up to survivor with mapping version. |
| Product split | Do not allocate predecessor events to a child without deterministic evidence; report unresolved bucket. |
| Variant correction | Preserve observed variant and mapped successor/confidence separately. |
| Listing price/state change | Event remains tied to listing snapshot/time; canonical identity unchanged. |
| Shop listing retirement | Historical attribution remains; current availability projection changes. |

Metrics must expose raw/predecessor versus lineage-adjusted definitions to prevent
silent dashboard drift. Review/verified-purchase metrics use server-authoritative
evidence, not clicks/cart as purchase proxies. Data minimization forbids copying full
catalog records or unnecessary customer identity into each event.
