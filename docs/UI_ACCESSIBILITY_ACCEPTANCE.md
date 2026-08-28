# UI Accessibility Acceptance

## Scope

This is the acceptance contract for the future visual rollout. Existing source
audits found no known functional accessibility blocker in tested critical paths,
but full physical/device acceptance and final-token contrast remain open.

## Mandatory gates

| Area | Acceptance criterion | Evidence |
|---|---|---|
| Touch | Interactive targets are at least 44×44 logical px; preferred primary/form targets are 48 | Widget geometry test + device review |
| Text | Critical content remains available at 2.0 text scale; no hidden action or clipped price/status | Widget/golden + device review |
| Contrast | Text and controls meet agreed WCAG AA targets on final light/dark surfaces | Token contrast report |
| Semantics | Icon-only actions have Turkish labels; selected, checked, expanded and unread states are exposed | Semantics tests |
| Focus | Logical reading/focus order follows visual flow; visible focus indicator exists | Keyboard/screen-reader review |
| State | Error/success/stock/selection is not conveyed by color alone | Visual/state matrix |
| Motion | Reduced-motion preference removes non-essential animation | Widget/manual check |
| Media | Missing image has meaningful fallback; decorative images are not announced | Semantics/widget tests |
| Forms | Label, hint, validation and error association remain clear | Widget/screen-reader tests |
| Navigation | Back/cancel/auth continuation remain predictable | Navigation tests |

## Critical component requirements

- Bottom navigation: five Turkish labels, selected state, cart count and unread
  count; badges capped visually but full meaning exposed semantically.
- Product card: name, price, merchant count, availability and favorite state in a
  sensible order; image is secondary to the product identity.
- SellerPriceRow: merchant, price, distance, rating, availability and CTA remain
  understandable without color.
- Shop action hierarchy: primary physical-visit action and secondary actions have
  descriptive labels.
- Cart item: quantity controls announce resulting quantity and disabled limits;
  remove and store-conflict choices are unambiguous.
- Verified purchase badge: exposed only from authoritative state and announced as
  status, not an interactive control.
- AuthGuard: focus enters the gate, back/cancel returns safely and successful login
  resumes only the requested protected destination.

## Text and language

- Use Turkish semantic labels, not raw icon names or English developer terms.
- Do not concatenate fragments where Turkish grammar or screen-reader pause would
  be unclear.
- Prices use locale-aware formatting and preserve the numeric value at large scale.
- Avoid all-caps for long Turkish labels.
- Tooltips complement, but do not replace, visible primary-action copy.

## Required viewport matrix

| Width | Text scale | Priority |
|---:|---:|---|
| 320 | 1.0, 1.3, 2.0 | Small-device failure boundary |
| 360 | 1.0, 1.3, 2.0 | Common compact Android |
| 390 | 1.0, 1.3, 2.0 | Canonical visual reference |
| 430 | 1.0, 1.3, 2.0 | Larger phone |

Tablet layouts may use centered/max-width content; they must not simply stretch
cards and line lengths.

## Physical/manual gates

Before final visual freeze, test TalkBack on Android, VoiceOver if iOS is in pilot,
keyboard focus on Web if released, high-contrast/large-font platform settings and
one-hand reach for primary actions. These are release acceptance tasks, not Wave 27
runtime work.

## Current baseline caveat

The current narrow lexical scan found 13 direct `Semantics` and 3 direct `Tooltip`
constructors in UI files. The broader existing closeout audit recorded 58
semantics/tooltip call sites because it includes other semantic properties and
patterns. Neither number proves complete coverage; acceptance is behavior-based.
