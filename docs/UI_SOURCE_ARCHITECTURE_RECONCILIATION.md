# UI Source Architecture Reconciliation

> Wave 27 · Agent 3 · Read-only source reconciliation
> Base: `origin/main@fca935fdbe3053d2d9aa4bbb7a10b1f928007b63`
> State: preparation evidence; no visual decision is finalized here.

## Purpose

This document separates verified source facts from rollout assumptions. The Wave
27 plan does not merge any source branch, mutate Figma, or change Flutter.

## Read-only source heads

| Source | Head | Evidence used |
|---|---|---|
| Customer closeout | `origin/agent1/w16-customer-app-commercialization-closeout@1f1812cf9d65cd9ea4c8053f98f9a3c1342caeaa` | Functional, accessibility, text-scale and rollout constraints |
| K'pasa audit | `origin/agent-ui/w14-kpasa-design-system-audit@d5a13ff3153c80e3b9282bb1164af71c70c1deba` | Reference-kit debt and reuse boundary |
| Token proposal | `origin/agent-ui/w14-design-tokens-v1-proposal@bf31c4ae9703e4c3c9819557ee7976944e37ba18` | Proposed semantic foundation |
| Canonical components | `origin/agent-ui/w14-canonical-component-layer-v1@c9ce40c74b974fb91f1101d95e36718930c71b6c` | 14-family component contract |
| Critical screens | `origin/agent-ui/w14-critical-screen-pilot-v1@3b37732439dbd2f41eb9f159b2361e0cea42a87a` | Nine 390×844 pilot frames and five critical flows |
| Token integration | `origin/integration/wave-14-design-tokens-v1-final@911e326609fed85e3d6b55be6d27d75a91ce2176` | Final token documentation currently present in the repo |
| Audit integration | `origin/integration/wave-14-phase-a-design-audit@a3cc0971175f5401b1cf0cbe5b914e42d5dc0088` | Integrated reference audit |

## Reconciled product/UI constraints

- Customer App is the public showcase; visual acceptance is stricter than the
  Merchant App, but functional behavior remains the authority.
- Local discovery, physical shop interaction and QR verified purchase are the
  product model. Shipping, payment, classic checkout and order tracking are not
  valid UI patterns.
- The five bottom destinations are Home, Nearby, Cart V2, Wishlist and Profile.
  Visual migration must preserve the current guest authentication continuation.
- Category UI must accept variable taxonomy depth and labels; pilot labels are not
  runtime taxonomy data.
- Ads, reward and gamification slots are future/deferred semantics. They do not
  become launch requirements through a visual redesign.

## K'pasa boundary

K'pasa is a structural reference, not a source to port wholesale. Verified useful
patterns include variant matrices, field anatomy, equal-width navigation,
category/product-card composition and compact status presentation. The source also
contains fixed layouts, mixed typography, duplicated card structures and classic
commerce flows that contradict EsnaftaVar.

The rollout therefore uses this rule:

`K'pasa structural idea → EsnaftaVar semantic token/component → current functional widget`

Raw K'pasa colors, pixel values, demo taxonomy, payment, delivery or order UI must
not cross that boundary.

## Token-direction conflict that needs owner review

Two verified visual directions coexist:

| Evidence | Direction |
|---|---|
| Current Home V1 scoped tokens | petrol `#146C6E`, coral `#F06449`, cream `#FFF8EE` |
| Wave 14 canonical token/component docs | terracotta primary `#B54732`, teal accent `#1F6B5D`, warm surfaces |
| Current global Flutter theme | blue/violet primary `#4B68FF`, cold legacy neutrals |
| Wave 27 brief wording | teal/green primary direction, terracotta-like accent |

The global legacy theme is clearly migration debt. The ordering of teal and
terracotta semantic roles, however, is a real visual owner decision. This plan
does not silently select one. Implementation may begin with neutral foundations
and token plumbing, but release-candidate brand tokens require owner approval.

## C1 refinement evidence audit

| Requested refinement | Repository evidence | Wave 27 status |
|---|---|---|
| Home placeholder/developer copy cleanup | No dedicated follow-up branch, commit or closure artifact found | **NOT VERIFIED** |
| Remove designer annotations from customer frames | No dedicated follow-up branch, commit or closure artifact found | **NOT VERIFIED** |
| Compact mobile `SellerPriceRow` | Critical-screen doc records three Mobile variants and node IDs | **DOCUMENTED, VISUAL RECHECK REQUIRED** |
| Shop Details CTA hierarchy | Critical-screen doc states physical visit is primary | **DOCUMENTED, VISUAL RECHECK REQUIRED** |
| Cart V2 sample arithmetic correction | No explicit correction evidence found | **NOT VERIFIED** |

The last visual board itself was not modified or re-read through Figma in this
task. “Documented” is therefore not equivalent to final owner acceptance.

## Dark-mode dependency

Runtime currently uses `ThemeMode.system`, while the final token/component source
is primarily a light, warm-surface system and explicitly deferred dark mode. The
rollout cannot safely recolor light screens while leaving an unspecified automatic
dark branch. Owner approval is required for one of: launch-quality dark tokens,
temporary light-only release, or a separately gated dark rollout.

## Source confidence

- **Verified:** Git heads, current Flutter files, navigation/auth behavior,
  documented Figma node contracts and canonical token/component counts.
- **Partially verified:** C1 items explicitly described in the critical-screen
  document but not independently re-rendered in Wave 27.
- **Not verified:** live Figma board state, visual owner approval, physical-device
  rendering and exact pilot arithmetic after the original Phase C artifact.
