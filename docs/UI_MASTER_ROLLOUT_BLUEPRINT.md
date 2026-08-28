# Customer App Final UI Rollout Master Blueprint

## Mission

Move the functionally complete Customer App from four fragmented styling sources
to one owner-approved warm local-commerce system without changing customer-domain
behavior. Wave 27 prepares the work; it does not implement the final UI.

## Baseline

| Measure | Baseline |
|---|---:|
| View files | 38 |
| Primary Customer view files | 33 |
| Merchant-adjacent | 3 |
| Legacy/unreferenced | 2 |
| Reusable/widget files | 93 |
| Component widget classes | 157 |
| All visual widget classes | 405 |
| Exact file-impact rows | 131 |
| Raw/root owner decisions | 24 / 15 |
| Static stress scenarios | 2,000 |

## Exactly what remains for visual completion

1. Resolve 7 P0 owner gates, especially brand role, dark mode, critical-screen/C1
   review, Shop/Cart/AuthGuard hierarchy and freeze evidence.
2. Implement semantic tokens in Flutter with visual-parity plumbing first.
3. Implement a bounded canonical primitive/component layer.
4. Migrate 33 primary Customer view files through the ten-wave sequence.
5. Verify every state, Turkish/text-scale/accessibility and functional invariant.
6. Close C1 evidence gaps and compare the exact Flutter artifact to immutable Figma
   references.
7. Complete final polish, physical checks and freeze record.

## Files and components that change

The exact path-by-path plan is `UI_FLUTTER_FILE_IMPACT_MATRIX.csv`; the control
summary is `UI_FLUTTER_FILE_IMPACT_MAP.md`. Expected implementation scope is:

- serialized global theme/constants/widget-theme and navigation files;
- 33 primary customer views (MIGRATE);
- 67 reusable files currently classified ADAPT;
- 24 reusable/view files classified REVIEW;
- no automatic work in 4 DEFER and 3 EXCLUDE rows.

Models, Cubits, repositories, service locator, database, Supabase and taxonomy
runtime are not visual rollout ownership.

## First screens

1. Launch/AuthGuard shell and global BottomNav after primitives.
2. Home.
3. Category/Product Listing and search states.
4. Product Details and Seller Comparison.
5. Shop Details.
6. Cart V2 and QR presentation.

Reviews/purchases and secondary Customer groups follow without blocking the first
critical-screen validation tranche.

## Parallel work for three agents

- Lane A owns tokens, primitives, global theme/navigation/AuthGuard and integration.
- Lane B owns Home → listing → product/seller → shop.
- Lane C owns Cart/QR → reviews/purchases → communication/account groups.

Shared APIs and each large view are single-owner. Tranches integrate only after
foundation interfaces freeze; no lane creates private duplicate primitives.

## Owner visual decisions

The 24 raw questions deduplicate to 15 roots: 7 P0, 6 P1 and 2 P2. The recommended
first review order is URD-01 through URD-15 in
`UI_OWNER_ROOT_DECISIONS.md`. Recommendations are not owner selections.

## Taxonomy-dependent versus independent

Dependent: displayed category name/order/image, ancestry, availability and resolved
search context. Independent: token/component implementation, variable-depth layout,
long-label behavior, breadcrumb responsiveness, stable-ID API and accessibility.
No proposed taxonomy node is embedded in Flutter by this rollout.

## Cosmetic-only items

- fine shadow/radius variation after semantic consistency;
- non-essential decorative motion;
- optional illustrations and ornamental empty-state art;
- minor low-traffic icon/layout preferences;
- bespoke tablet composition where max-width behavior is already safe.

These are cosmetic only if they do not affect contrast, touch, text visibility,
state meaning, product truth or action hierarchy.

## Pilot-deferable polish

Advanced motion, full tablet layouts, Merchant-adjacent parity, dormant ads/reward/
gamification UI, low-traffic legal/help decoration and, with explicit owner/release
approval, launch-quality dark mode may wait. Usability/accessibility and consistent
fallback/state behavior may not wait.

## Acceptance pipeline

```text
Owner decisions
  → parity token foundation
  → canonical primitives
  → critical-screen migration
  → feature regression + responsive/state evidence
  → secondary Customer coherence
  → exact-artifact physical/visual acceptance
  → final visual freeze
```

## Final visual freeze

Freeze requires immutable Flutter/Figma identifiers, approved semantic tokens and
critical hierarchy, no V0/V1 defects, responsive/text-scale/state/accessibility
proof, physical-device review and explicit deferments. Figma-only or 390 px-only
approval is insufficient.

## Readiness verdict

Architecture and execution preparation are complete for Product Owner review.
Runtime implementation is not authorized by this task and should not begin until
the P0 visual gates are answered and the target Figma frames are current.
