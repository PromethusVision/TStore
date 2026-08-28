# Text Scale Acceptance Matrix

**State:** PROPOSED

| Scale | Automated purpose | Human/device purpose |
|---:|---|---|
| 1.0 | reference layout and semantics | normal system setting |
| 1.2–1.4 | common larger text; no clipped controls | keyboard/forms and navigation |
| 2.0 | high-risk responsive stress | critical journey usability |
| platform maximum | selected critical screens | scroll/focus/read order, not pixel parity |

## Critical surfaces

Login/signup/confirmation/recovery, legal consent, Home/location, product price/seller, cart/QR sheet, reviews, chat composer, notifications, saved locations, destructive confirmations and future Merchant price/QR forms.

## Assertions

- no RenderFlex overflow or hidden primary action;
- text wraps or scrolls without horizontal clipping;
- tap targets and semantic labels remain distinct;
- keyboard/focus does not cover submit/error;
- price/unit/identifier meaning is not truncated ambiguously;
- screen-reader order remains logical.

The repo already contains several 320 px and 1.4/2.0 widget cases; coverage should expand by reusable critical-screen matrix after final UI-kit rollout, not by snapshotting every screen.

`OWNER_DECISION_REQUIRED: ACCESSIBILITY_TEXT_SCALE_RELEASE_FLOOR`
