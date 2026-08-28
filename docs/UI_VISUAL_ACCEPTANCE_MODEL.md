# UI Visual Acceptance Model

## Acceptance layers

| Layer | Question | Evidence | Owner |
|---|---|---|---|
| Functional parity | Does the old behavior still work? | Existing + targeted widget/navigation tests | Engineering |
| Structural UI | Does content fit, reflow and expose all states? | Golden/state matrix at defined viewports | Engineering/design |
| Accessibility | Is it perceivable, operable and understandable? | Semantics, contrast, text-scale and physical checks | Engineering/QA |
| Brand fidelity | Does it match approved EsnaftaVar direction? | Figma-to-Flutter comparison | Product Owner/design |
| Product semantics | Does it express local physical commerce correctly? | Copy/CTA/domain review | Product Owner/product |
| Release polish | Is the exact artifact consistent and stable? | Full screenshot tour and defect ledger | Release owner |

Passing engineering checks never substitutes for owner visual approval. Conversely,
owner approval does not waive functional, accessibility or product-safety gates.

## Reference viewport

The canonical comparison is 390×844. It is a reference, not a fixed layout. Each
accepted critical screen also proves 320, 360 and 430 widths and text scale 1.0,
1.3 and critical 2.0 states.

## Screenshot set

Minimum reference fixtures:

- Home guest/default/location-gate/content-loaded/error;
- listing default/search/no-result/loading/pagination/error;
- product image/fallback, seller-loaded/empty/error/unavailable;
- Shop Details open/closed/missing-info and auth-gated secondary action;
- Cart V2 empty/active/wrong-store/unavailable/QR-ready/error;
- AuthGuard, login error/loading/success return;
- review eligible/ineligible/verified/unverified/submitting/error;
- chat/notification/profile core states in their rollout wave.

## Comparison policy

Compare hierarchy, semantic token role, component shape, spacing rhythm, type role,
state cue, touch target and content visibility. Do not chase pixel identity where
Flutter font rasterization, platform system bars or real dynamic data differ.

An acceptance failure is any missing/obscured action, incorrect hierarchy,
unapproved brand token, inaccessible state, overflow, contradictory commerce copy,
wrong dynamic state or material deviation from an owner-approved reference.

## Defect severity

| Severity | Example | Freeze effect |
|---|---|---|
| V0 Blocker | Action missing, overflow hides price, wrong CTA, auth/cart/QR regression | Stop rollout/release |
| V1 Major | Critical screen hierarchy, contrast or component inconsistency | Must fix before visual freeze |
| V2 Minor | Spacing/icon/copy polish with no usability loss | Fix before freeze or explicitly defer |
| V3 Cosmetic | Low-traffic non-critical decoration | May defer post-pilot |

## C1 acceptance gate

The five known C1 items receive explicit screenshots and checklist rows. Their
status remains open until the current Figma artifact and implementation fixture are
both inspected. Historical documentation alone is insufficient.

## Sign-off record

Final evidence records app version/commit, platform, viewport, text scale, locale,
theme mode, data fixture, Figma file/frame version, test result, reviewer and date.
No sign-off uses “latest” without immutable identifiers.
