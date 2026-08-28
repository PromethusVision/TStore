# UI Owner Root Decisions

> Minimum defensible owner set derived from 24 raw questions. Recommended options
> are advisory; none is selected.

## URD-01 — Semantic brand palette (P0)

- **Question:** Which exact palette and primary/accent role ordering is approved?
- **Options:** A) teal/green primary + terracotta accent; B) terracotta primary +
  teal accent as Wave 14 artifact; C) revise both within the warm local direction.
- **Recommended:** A, then reconcile the Figma token source before Flutter rollout.
- **Why:** It matches the current Wave 27 direction and Home's petrol-led proof,
  while retaining terracotta warmth.
- **Customer effect:** Determines brand recognition and CTA hierarchy.
- **Implementation effect:** Blocks final color tokens and screenshots.

## URD-02 — Dark-mode launch policy (P0)

- **Question:** Must final dark mode ship in the pilot?
- **Options:** A) explicit light-only pilot; B) complete light and dark together; C)
  retain system mode with mixed legacy dark visuals.
- **Recommended:** A for pilot speed, with B as a separately scheduled wave; reject C.
- **Why:** A is honest and consistent; C undermines “final visual.”
- **Customer effect:** Consistency for customers using system dark mode.
- **Implementation effect:** A requires an explicit release policy; B expands token,
  golden and physical acceptance scope.

## URD-03 — Critical discovery/product board (P0)

- **Question:** Are Home, listing and Product/Seller directions approved after C1 review?
- **Options:** A) approve with listed C1 corrections; B) request bounded revisions;
  C) replace the direction.
- **Recommended:** A if current-board inspection closes every C1 row.
- **Why:** Existing structure already fits the local-commerce model and limits delay.
- **Customer effect:** Defines the public showcase and discovery comprehension.
- **Implementation effect:** Releases Waves 3–5.

## URD-04 — Shop Details CTA hierarchy (P0)

- **Question:** What is the primary Shop Details action?
- **Options:** A) directions/physical visit primary; B) shop products primary; C)
  chat primary.
- **Recommended:** A, with products as core content and chat secondary/auth-gated.
- **Why:** Aligns with physical local commerce and avoids online-order expectations.
- **Customer effect:** Clarifies the next real-world action.
- **Implementation effect:** Controls header/action composition and golden baseline.

## URD-05 — Cart V2 visual contract (P0)

- **Question:** How should Cart V2 explain its role?
- **Options:** A) single-shop physical shopping preparation with estimated total and
  QR education; B) generic basket appearance; C) checkout-like progression.
- **Recommended:** A; reject C and verify all sample arithmetic.
- **Why:** Matches canonical product behavior.
- **Customer effect:** Prevents payment/shipping assumptions.
- **Implementation effect:** Controls header, total, conflict, QR and copy states.

## URD-06 — Guest AuthGuard presentation (P0)

- **Question:** How should a protected customer action request login?
- **Options:** A) concise contextual gate then existing login route; B) silent redirect;
  C) separate custom auth flow per feature.
- **Recommended:** A.
- **Why:** Explains value, preserves cancel/resume and avoids duplicated auth UI.
- **Customer effect:** More trustworthy guest-to-login transition.
- **Implementation effect:** One reusable gate with existing auth behavior.

## URD-07 — Density and card information (P1)

- **Question:** What 390 px density and metadata priority is approved?
- **Options:** A) balanced two-line content with local availability/merchant count;
  B) very compact price-first; C) spacious editorial cards.
- **Recommended:** A, with CategoryCard on Home and CategoryRow in dense lists.
- **Why:** Supports Turkish content and local-commerce differentiation.
- **Customer effect:** Faster scanning without hiding shop/availability context.
- **Implementation effect:** Defines ProductCard/Category variants and grid metrics.

## URD-08 — Media fallback and icons (P1)

- **Question:** What visual language should missing media and icons use?
- **Options:** A) restrained warm-neutral fallback + one Iconsax-led system; B)
  illustrative fallbacks + mixed icons; C) text-only fallback.
- **Recommended:** A for pilot, using existing dependencies.
- **Why:** Consistent, low-risk and does not dominate real product photos.
- **Customer effect:** Missing images feel intentional without misleading content.
- **Implementation effect:** Avoids new dependency and large illustration scope.

## URD-09 — Motion level (P2)

- **Question:** How much motion should the pilot use?
- **Options:** A) restrained functional transitions; B) expressive card/hero motion;
  C) nearly none.
- **Recommended:** A with reduced-motion support.
- **Why:** Adds polish without performance/accessibility cost.
- **Customer effect:** Clear feedback with less distraction.
- **Implementation effect:** Small motion token/API; no animation framework work.

## URD-10 — Turkish customer voice (P1)

- **Question:** What tone should final customer copy use?
- **Options:** A) warm, concise neighborhood-commerce Turkish; B) formal corporate;
  C) generic marketplace/promotional.
- **Recommended:** A.
- **Why:** Matches the differentiated local identity and reduces developer copy.
- **Customer effect:** Clearer, more trustworthy onboarding and recovery.
- **Implementation effect:** Copy review and fixture/golden updates; no behavior change.

## URD-11 — Trust and future signals (P1)

- **Question:** How prominent are verified purchase and dormant future signals?
- **Options:** A) clear but compact verified badge, hide dormant signals; B) highly
  prominent trust decoration and visible placeholders; C) hide all signals.
- **Recommended:** A.
- **Why:** Shows real authority without implying ads/reward functionality.
- **Customer effect:** Understandable trust evidence with less visual noise.
- **Implementation effect:** Authoritative badge input; no future engine UI.

## URD-12 — Pilot deferment boundary (P1)

- **Question:** What can wait after critical Customer acceptance?
- **Options:** A) defer low-traffic decoration and V3 cosmetics; B) polish every
  primary and secondary screen equally before pilot; C) ship critical screens only
  with visibly inconsistent secondary routes.
- **Recommended:** A while retaining usable/accessibile secondary screens.
- **Why:** Protects commercialization without tolerating broken flows.
- **Customer effect:** Core showcase is polished; all routes remain coherent.
- **Implementation effect:** Focuses Waves 1–8 and bounds Wave 9/10.

## URD-13 — Tablet-specific scope (P2)

- **Question:** Does pilot require bespoke tablet layouts?
- **Options:** A) safe centered/max-width behavior; B) bespoke tablet composition;
  C) phone-only with uncontrolled stretch.
- **Recommended:** A unless tablet is an explicit launch target.
- **Why:** Responsive safety without large extra design scope.
- **Customer effect:** Usable larger screens, not necessarily optimized layouts.
- **Implementation effect:** Max-width rules and tests; no second screen system.

## URD-14 — Reference and cross-app consistency ceiling (P1)

- **Question:** How far should K'pasa reuse and Customer/Merchant consistency go?
- **Options:** A) shared semantic foundations with role-specific components; B)
  near-identical apps; C) independent systems.
- **Recommended:** A.
- **Why:** Preserves brand coherence while Customer stays more polished and Merchant
  remains operationally dense.
- **Customer effect:** Distinct local identity without template residue.
- **Implementation effect:** Share tokens/primitives, not screen composition.

## URD-15 — Approval and freeze evidence (P0)

- **Question:** What evidence is sufficient for final visual approval?
- **Options:** A) immutable Figma frames + exact Flutter artifact + defined responsive,
  state and accessibility evidence; B) Figma-only approval; C) subjective device review.
- **Recommended:** A.
- **Why:** Makes “final” repeatable and protects later releases.
- **Customer effect:** Fewer visual and functional surprises.
- **Implementation effect:** Requires baseline manifest, screenshots and sign-off record.

## Summary

| Priority | Root decisions |
|---|---:|
| P0 | 7 |
| P1 | 6 |
| P2 | 2 |
| **Total** | **15** |

All 15 remain OPEN; recommendation is not selection.
