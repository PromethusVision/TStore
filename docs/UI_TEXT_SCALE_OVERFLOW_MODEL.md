# UI Text Scale and Overflow Model

## Policy

Long Turkish text and user/content data must drive layout growth. Ellipsis is an
information-priority tool, not the default response to overflow.

## Content classes

| Content | Preferred behavior | Allowed truncation |
|---|---|---|
| Product name | Two lines in cards; full on details | Card only, with full semantics/details access |
| Shop/merchant name | One or two lines depending density | Compact row only; identity must remain recoverable |
| Category/breadcrumb | Wrap, scroll or collapse intermediate crumbs | Never hardcode depth; final node remains visible |
| Price | Keep value and currency together | No truncation |
| Distance/rating/stock | Wrap into metadata row/column | Hide only explicitly secondary duplicated text |
| Primary CTA | Grow height or use shorter approved copy | No ellipsis |
| Error/eligibility/support text | Multi-line and selectable where useful | No truncation |
| Bottom-nav label | Approved short labels, stable five items | One line only after 320/2.0 validation |
| User message/chat | Wrap naturally | Platform-appropriate max line width, no semantic loss |

## Layout response order

1. Allow text to wrap and container height to grow.
2. Reflow horizontal metadata into rows/columns.
3. Move secondary action below primary content.
4. Use approved shorter copy with identical meaning.
5. Use ellipsis only for bounded preview components.
6. Never reduce type below the semantic role to force a fit.

## Turkish stress corpus categories

- dotted/dotless `i`, `İ`, `ı`; `ş`, `ğ`, `ç`, `ö`, `ü`;
- long compound shop and product names;
- long canonical category labels and multi-level breadcrumbs;
- four-to-six digit prices with decimals and `₺`;
- plural/count phrases and zero/one/many cases;
- error, permission, review eligibility and account-deletion explanations;
- unknown external content with no spaces, punctuation or unusually long tokens;
- RTL is not a Wave 27 product requirement, but layout code must avoid fragile
  manual positioning.

## Critical failures

- RenderFlex overflow or clipped scroll content.
- Price or destructive-action meaning hidden.
- Primary CTA inaccessible below a fixed-height panel.
- Badge/count obscuring navigation label.
- Text painted outside its hit target or card.
- Dialog action row overflowing instead of stacking.
- Keyboard plus text scale making submit/cancel unreachable.

## Acceptance grid

Every critical screen must cover 320/360/390/430 widths at 1.0 and 1.3. A 2.0
suite covers all critical screens and representative secondary families. At least
one physical 2.0 traversal is required for Home → listing → details → seller/shop →
Cart V2 → AuthGuard and for review/QR/account deletion flows.

Golden comparison tolerances must ignore harmless raster differences but fail on
overflow markers, missing actions, unintended clipping and hierarchy changes.
