# First 10 UI Implementation Waves

> Proposed sequence. No wave is started or owner-finalized by Wave 27.

## Wave 1 — Semantic foundation

- Resolve owner brand-role and dark-mode decisions.
- Add Theme extensions, semantic typography/spacing/radius/elevation/motion.
- Establish parity tests; no broad visible recolor.
- Exit: tokens resolve in supported modes and legacy usage can be measured.

## Wave 2 — Primitives, shell and AuthGuard

- Button, TextField, BottomNav, ScreenShell, StateShell and progress patterns.
- Migrate launch gate, login/signup and protected-tab continuation.
- Exit: five destinations, badges, auth cancel/success and text-scale PASS.

## Wave 3 — Home showcase

- Home, search/location surface, banner, categories, product and merchant cards.
- Resolve Home C1 copy/annotation evidence.
- Exit: guest and authenticated Home states accepted at reference viewport and
  responsive matrix.

## Wave 4 — Category/listing/search

- CategoryRow/Breadcrumb, listing grid/list, search and pagination state visuals.
- No taxonomy runtime change.
- Exit: dynamic-depth/long-label/no-result/pagination regression PASS.

## Wave 5 — Product details and seller comparison

- Media, product hierarchy, rating summary, seller rows, availability and actions.
- Verify compact SellerPriceRow C1 item.
- Exit: product/listing/shop identity and callbacks remain correct.

## Wave 6 — Shop Details

- Shop identity, open state, rating, product list and physical-visit hierarchy.
- Verify Shop CTA C1 item.
- Exit: directions/chat/auth behavior and missing-info states PASS.

## Wave 7 — Cart V2 and QR presentation

- Cart header/items/quantity/total/conflict, QR session sheet and messages.
- Recalculate/verify C1 sample arithmetic.
- Exit: single-store, duplicate-submit, totals, expiry/failure and verified outcome
  behavior PASS.

## Wave 8 — Reviews, purchases and trust

- Review card/editor, eligibility, rating, verified-purchase marker and history.
- Exit: no new rights, no client-derived verification, all mutation states PASS.

## Wave 9 — Secondary Customer surfaces

- Nearby, wishlist, recent, chat, notifications, settings/profile, locations,
  recovery/legal/support.
- Work is split by feature ownership; shared primitives are frozen.
- Exit: full Customer route/state and accessibility matrix PASS.

## Wave 10 — Final polish and visual freeze

- Fix acceptance defects only; no opportunistic redesign.
- Cross-device screenshot tour, physical accessibility, exact artifact QA.
- Exit: freeze contract satisfied and owner accepts the immutable visual set.

## Dependencies

```text
Owner brand/dark gate
  → Wave 1
    → Wave 2
      ├→ Wave 3 → Wave 4 → Wave 5 → Wave 6 → Wave 7
      └→ Wave 8 and Wave 9 after their shared components stabilize
        → Wave 10
```

Wave 8 can overlap Waves 5–7 after Button/TextField/State/Trust APIs stabilize.
Wave 9 feature groups can overlap each other, but global theme/navigation files
remain single-owner.
