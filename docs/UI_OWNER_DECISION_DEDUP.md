# UI Owner Decision Deduplication

Every raw decision from `UI_OWNER_DECISION_INVENTORY.md` is represented exactly
once below. Similar questions are clustered without collapsing materially distinct
brand, accessibility or product-semantic choices.

| CLUSTER_ID | SOURCE_DECISION_IDS | ROOT_QUESTION | SAFE_TO_COLLAPSE | DISTINCT_SUBQUESTIONS | WHY |
|---|---|---|---|---|---|
| UDC-01 | UOD-001,UOD-002 | What exact semantic brand palette is approved? | YES | Role ordering; exact values | Same token decision, both needed in one palette approval |
| UDC-02 | UOD-003 | What is the launch dark-mode policy? | NO | Standalone | Affects whole artifact and cannot hide inside palette choice |
| UDC-03 | UOD-004,UOD-005,UOD-006 | Which critical discovery/product direction is approved? | YES | Home; listing; product/seller acceptance remains separately checkable | One owner board review with per-screen verdicts |
| UDC-04 | UOD-007 | What is Shop Details action hierarchy? | NO | Standalone | Local physical intent is product-critical |
| UDC-05 | UOD-008 | What is approved Cart V2 visual contract? | NO | Standalone | Must prevent checkout interpretation and prove arithmetic |
| UDC-06 | UOD-009 | What is the guest AuthGuard presentation? | NO | Standalone | Affects trust/conversion and protected-action continuation |
| UDC-07 | UOD-010,UOD-011,UOD-012 | What discovery/card density and information priority is approved? | YES | Global density; product metadata; category presentation | Interdependent 390 px hierarchy choices |
| UDC-08 | UOD-013,UOD-014 | What media fallback and icon art direction is approved? | YES | Image fallback; icon family | Shared visual-language decision; can still have separate deliverables |
| UDC-09 | UOD-015 | What motion level is approved? | NO | Standalone | Accessibility/performance trade-off |
| UDC-10 | UOD-016 | What is the final Turkish customer voice? | NO | Standalone | Product tone, not engineering copy mechanics |
| UDC-11 | UOD-017,UOD-018 | How are trust and dormant future signals presented? | YES | Verified prominence; future slots hidden/visible | Both govern signal prominence and false implication risk |
| UDC-12 | UOD-019,UOD-024 | What visual scope may be deferred after critical acceptance? | YES | Low-traffic surfaces; V2/V3 imperfections | Same commercialization-versus-polish decision |
| UDC-13 | UOD-020 | Is tablet-specific pilot polish required? | NO | Standalone | Platform scope decision |
| UDC-14 | UOD-021,UOD-022 | How much reusable reference/cross-app consistency is desired? | YES | Customer/Merchant relation; K'pasa ceiling | Both bound customization without forcing identical apps |
| UDC-15 | UOD-023 | What evidence constitutes visual approval/freeze? | NO | Standalone | Governance decision with release impact |

## Coverage proof

- Raw decisions: 24.
- Source IDs represented: 24/24.
- Duplicate source assignment: 0.
- Root clusters: 15.
- Standalone/deferred decisions lost: 0.
- Owner selections made: 0.
