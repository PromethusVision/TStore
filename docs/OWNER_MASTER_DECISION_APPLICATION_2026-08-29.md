# Owner Master Decision Application — 2026-08-29

State: `8 PRODUCT OWNER FINAL ROOTS — 23 ROOTS OPEN — NO RUNTIME`

## Authority and scope

Product Owner explicitly selected the following eight options as FINAL for the
current canonical product direction:

| Root | Final option | Canonical direction | Professional review |
|---|---|---|---|
| OM-R04 | A | Android-only pilot when exact signed artifact and physical gates pass; iOS later | NONE |
| OM-R05 | A | Guest discovery, contextual auth, transient/coarse location and minimal deletable local history | KVKK remains open |
| OM-R19 | A | Teal/green primary, terracotta accent | NONE |
| OM-R20 | A | Consistent light-only pilot; dark mode later | NONE |
| OM-R21 | A | Current critical-screen direction with bounded C1 corrections | NONE |
| OM-R22 | A | Directions/physical visit primary; products core; chat secondary | NONE |
| OM-R23 | A | Cart V2 is single-shop physical-shopping preparation, not checkout | NONE |
| OM-R24 | A | Balanced two-line cards with merchant count and availability context | NONE |

No other `OM-Rxx` option is selected or implied. Professional/legal requirements
attached to selected options remain open and are not waived.

## Apply-map result

- Master roots finalized: **8**
- Source/apply rows transitioned to `PRODUCT_OWNER_FINAL`: **30**
- Downstream child/dependent records inheriting a parent answer: **22**
- Rows unchanged and still unselected: **174**
- Unexpected option values: **0**

The raw source inventory remains immutable. Only the apply map records the owner
decision state.

## Downstream auto-resolutions

### OM-R04=A — 9 downstream records

- First pilot platform is Android-only, subject to exact signed artifact and
  physical acceptance.
- Android reach bias is accepted for the first cohort; it must be documented in
  pilot interpretation.
- iOS is deferred, not cancelled and not represented as ready.
- UI-R15 requires immutable reference evidence plus exact-artifact physical
  checks; screenshots or CI alone cannot certify release.
- Production release authority remains an explicit human gate.
- Physical/manual/release gates remain mandatory and cannot be auto-passed.
- CI vendor and exact matrix breadth remain engineering decisions under the
  risk-based gate contract.

### OM-R05=A — 7 downstream records

- Nearby/local discovery is guest-visible.
- Registration is required only for protected/persistent actions defined by
  existing authorization contracts.
- UI-R06 resolves to a short contextual explanation followed by the existing
  login flow, preserving cancel/resume behavior.
- Location permission is requested contextually after value is explained, not
  as an unexplained first-launch demand.
- Location use is transient/coarse by default; broader persistent profiling is
  not authorized.
- Device-local history is minimal, deletable and purpose-bound.
- KVKK purpose, notice, retention and exact-location handling review remains open.

### OM-R19=A and OM-R20=A

- Semantic color roles are fixed: teal/green primary, terracotta accent.
- Pilot visual acceptance is light-only.
- Dark-mode completion becomes later scope; inconsistent legacy dark behavior is
  not an accepted fallback.
- Status/fallback token roles can now be reconciled by engineering without a new
  Product Owner palette question.

### OM-R21=A — 6 downstream records

- Home, listing, product details and seller comparison retain the current
  direction after bounded C1 verification.
- UI-R08 fallback/icon treatment follows the approved palette and critical-screen
  direction; exact assets remain an implementation detail.
- UI-R09 motion uses a conservative/reduced-motion-safe engineering baseline.
- UI-R10 Turkish tone follows established product terms in the bounded content pass.
- UI-R11 may show only truthful, currently available trust signals.
- UI-R12/UI-R13 resolve to critical-screen-first rollout and baseline tablet
  support; broad tablet polish remains later scope.

### OM-R22=A, OM-R23=A and OM-R24=A

- Shop Details hierarchy can be implemented without another CTA decision.
- Cart V2 must not imply online payment or checkout; QR education and estimated
  total support physical shopping preparation.
- Product/category cards use balanced local-context density; compact price-only
  and wide editorial directions are rejected for the current direction.

## Newly unblocked work — implementation not authorized here

1. Android-only release-lane and exact-artifact acceptance preparation.
2. Guest discovery and contextual AuthGuard design-to-code mapping.
3. Location permission/fallback UX specification, subject to KVKK review.
4. Teal-primary/terracotta-accent semantic token reconciliation.
5. Consistent light-only theme cleanup and acceptance matrix.
6. Bounded C1 work for Home, listing, product and seller screens.
7. Shop Details CTA hierarchy implementation.
8. Cart V2 physical-shopping semantics and QR education implementation.
9. Product/category card density plus dependent fallback/icon/content passes.
10. Immutable visual references and exact-artifact physical acceptance planning.

All ten workstreams are `UNBLOCKED_FOR_PLANNING`, not implemented or accepted.

## Remaining dependent decisions and gates

- `OM-R03` cohort/distribution sequence remains open and still sizes the Android
  rollout.
- `OM-R18` lawyer/KVKK-reviewed terms, privacy, deletion and platform-role
  surfaces remain a commercial release blocker.
- `OM-R31` pause/expansion rules remain open.
- `OM-R17` acquisition/feedback instrumentation remains open after guest access.
- `OM-R13` QR rollout remains open; Cart V2 may prepare customers but cannot imply
  QR is enabled for every merchant.
- Exact signed Android artifact, physical device checks and final visual evidence
  remain unexecuted gates.
- `OM-R05` KVKK review remains open; the owner decision does not waive it.
- The remaining 23 master roots retain their prior `OPEN`, `PROVISIONAL`,
  `PROFESSIONAL_FIRST` or `POST_PILOT` state.

## Contradiction audit

### Resolved historical contradiction

Wave 14-era terracotta-primary ordering conflicts with `OM-R19=A`. The Product
Owner decision resolves the canonical direction in favor of teal/green primary
and terracotta accent. Runtime tokens are not changed in this task.

### Implementation gaps, not owner contradictions

- Existing mixed/system dark behavior is inconsistent with `OM-R20=A` and must be
  cleaned during a separately authorized UI implementation wave.
- Any checkout/payment-like Cart copy conflicts with `OM-R23=A` and must be
  removed during implementation.
- Current selections are mutually consistent; no unresolved contradiction exists
  among the eight final roots.

## Safety

- Runtime/Flutter/Figma changed: `NO`
- DB/Supabase/Production/Development changed: `NO`
- Professional review waived: `NO`
- Other owner choices inferred: `NO`
- Physical/release gate marked PASS: `NO`

`OWNER_FINAL_ROOTS_APPLIED: 8`

`OTHER_ROOTS_SELECTED: 0`

`RUNTIME_IMPLEMENTATION: NO`
