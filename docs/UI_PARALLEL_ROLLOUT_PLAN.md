# UI Parallel Rollout Plan

## Three-agent model

Parallel work begins only after owner gates and the semantic/primitives API are
recorded. The plan avoids three agents editing the same global/theme files.

| Agent lane | Primary ownership | Starts after | Must not edit |
|---|---|---|---|
| Lane A — Foundation/integration | Theme tokens, primitives, navigation/AuthGuard, component API and integration | Owner decisions | Feature business logic; broad feature screens after handoff |
| Lane B — Discovery/commerce | Home, listing, taxonomy-neutral UI, product/seller/shop | Foundation API frozen | Global theme/navigation; Cart/review/chat files |
| Lane C — Trust/account | Cart/QR presentation, reviews/purchases, then chat/notifications/account by sub-wave | Required primitives stable | Global theme; discovery/product files |

Lane C is sequential internally: Cart/QR and review authority surfaces should not
be modified concurrently by the same integration window.

## File locks

The following have one active owner at a time:

- all theme/token/widget-theme files;
- `navigation_menu.dart` and `customer_bottom_navigation.dart`;
- each view over 900 lines;
- canonical component public API files;
- shared golden harness and baseline manifest.

## Integration sequence

1. Lane A lands foundation into the rollout integration branch.
2. Lane B and Lane C rebase/refresh from that immutable interface checkpoint.
3. Each lane submits one coherent screen family with tests and screenshot evidence.
4. Integration owner resolves only semantic conflicts; feature logic is not
   rewritten during integration.
5. Acceptance suite runs on combined exact artifact after each tranche.

## Suggested parallel tranches

| Tranche | Lane A | Lane B | Lane C |
|---|---|---|---|
| T0 | Tokens + test harness | Read-only fixture preparation | Read-only fixture preparation |
| T1 | Button/Field/State/Shell | Home data/state fixture baselines | Review/Cart fixture baselines |
| T2 | BottomNav/AuthGuard | Home | Review/verified primitives |
| T3 | Integration support | Listing + taxonomy-neutral rows | Cart V2 presentational extraction |
| T4 | API freeze | Product + seller | Purchases/reviews |
| T5 | Defect triage | Shop | QR sheet + account/communication groups |

## Required handoff packet

Each lane provides changed matrix rows, screenshots, tests, known deviations,
token/component API changes, unresolved owner decisions and confirmation that no
runtime semantics were intentionally changed.

## Conflict policy

If a component API change is required after freeze, Lane A records a compatible
addition and all consumers update in a coordinated tranche. Agents do not fork
near-identical local components to avoid waiting; that recreates the current debt.
