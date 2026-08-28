# UI Content, Icon, Media and Motion Guide

## Turkish content hierarchy

- Lead with product/shop/location truth, not promotional filler.
- Use warm, concise Turkish; remove developer notes, placeholder labels and generic
  marketplace claims.
- Use one term consistently for `Mağaza`, `Esnaf`, `Sepet`, `Yakındakiler`,
  `Favoriler`, `Yol Tarifi` and verified purchase concepts after copy approval.
- Do not say “satın al”, “ödeme”, “teslimat”, “sipariş” or “checkout” where the
  runtime only supports physical-shop intent and QR evidence.
- Error text explains what happened at customer level and the safe next action;
  raw exception/RPC/schema vocabulary is forbidden.

## Text hierarchy

| Role | Purpose | Avoid |
|---|---|---|
| Display/Heading | Screen/product/shop identity | Multiple competing page titles |
| Body | Explanation and description | Fixed-height clipping |
| Label | Action and compact metadata | Sub-10 px navigation/action copy |
| Caption | Supporting status/count | Essential price/action meaning |
| Price | Current value emphasis | Implying paid/settled revenue |
| Status | Availability/trust | Color-only meaning |

## Icon direction

- Use the existing Iconsax dependency as the pilot baseline; do not add another
  icon package solely for cosmetic variation.
- Keep one stroke/fill convention per state and consistent metaphors across routes.
- Every icon-only action has tooltip/semantic label and a 44 px target.
- Do not use truck, credit-card, package-tracking or checkout icons in active
  customer commerce flows.
- Directions, location, shop, availability, QR and verified status must be
  visually distinct.

## Media

- Preserve the central safe media-resolution boundary and supported product,
  category and banner read paths.
- Product photography is not tinted with brand overlays that obscure merchandise.
- Use stable aspect-ratio containers and purpose-specific crop rules.
- Missing, invalid and loading media share geometry but have distinct state cues.
- Shop/merchant fallback must not fabricate a logo or verified badge.
- Decorative media is excluded from semantics; meaningful media has concise context.

## Motion

- Use motion only for state continuity, direct manipulation and clear feedback.
- Avoid auto-playing decorative motion, parallax and large hero choreography in the
  pilot.
- Navigation transitions remain platform-predictable.
- Skeleton/shimmer respects reduced-motion preference.
- Loading never communicates success; verified/review/QR outcomes wait for
  authoritative state.

## Dialog, sheet and message voice

- Dialog title names the decision; buttons use concrete verbs.
- Destructive action is visually and verbally explicit, with cancel available.
- Bottom sheets expose a clear close/back path and survive keyboard/text scale.
- Snackbars are transient and never carry the only copy for auth, QR, purchase,
  review eligibility or account deletion.

## Approval boundary

Exact icon/fallback/tone direction is included in the owner root decisions. This
guide recommends a bounded pilot approach but does not mark it final.
