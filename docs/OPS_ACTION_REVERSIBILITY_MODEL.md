# Operations Action Reversibility Model

**State:** PROPOSED — NO ACTION IMPLEMENTATION

| Class | Examples | Reversal model |
|---|---|---|
| REVERSIBLE | assignment, temporary pause, queue route | explicit restore/new event after current-state check |
| CONDITIONALLY_REVERSIBLE | verification expiry, listing/review removal, suspension, ad/reward hold | re-review dependencies; restore does not erase interval/history |
| SUPERSEDE_ONLY | catalog field resolution, taxonomy move, verified-purchase status correction | append new authoritative event/projection |
| STRUCTURALLY_HIGH_RISK | product merge/split, bulk mapping | predecessor/successor graph; dedicated rollback/reconciliation |
| EFFECTIVELY_IRREVERSIBLE | external notification, data disclosure/export, physical deletion after retention | prevention/two-person/cooldown; cannot “undo” recipient knowledge |
| EMERGENCY | kill switch/session revoke | restore only after cause/health validated |

## Reversal envelope

Original action/event, case/reason/evidence, current resource revision, impact since action, dependencies, reversal reason/approver, before/after, communication, reconciliation counts, and superseding audit ID.

## Rules

An “undo” button never blindly sets old fields. It reruns current authorization/policy/invariants and may require manual resolution. Reversal of wrongful enforcement restores future access and corrects projections where valid; it cannot rewrite timelines or conceal operator error.

Hard deletion, external export, customer notification, and leaked data require prevention and impact management rather than false reversibility claims.

`SILENT_UNDO: PROHIBITED`

`REVERSIBILITY_RULES_FINAL: NO`
