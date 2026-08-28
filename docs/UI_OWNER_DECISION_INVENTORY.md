# UI Owner Decision Inventory

> These are genuine visual/product choices. Ordinary Flutter architecture, file
> ownership, test technique and component extraction are engineering decisions and
> are intentionally absent. Every item remains OPEN.

| DECISION_ID | QUESTION | AFFECTED_SURFACES | WHY_OWNER | PRIORITY | STATUS |
|---|---|---|---|---|---|
| UOD-001 | Should teal/green or terracotta own the primary action/brand role? | All Customer screens | Brief and Wave 14 artifact currently reverse these roles | P0 | OPEN |
| UOD-002 | Which exact warm brand palette is approved for release? | Tokens, Figma references, screenshots | Brand identity cannot be inferred from code | P0 | OPEN |
| UOD-003 | Is the pilot light-only or must launch-quality dark mode ship together? | Entire app under system mode | Current runtime can enter an unspecified legacy dark theme | P0 | OPEN |
| UOD-004 | Is the refined Home direction visually approved? | Home | Main public showcase | P0 | OPEN |
| UOD-005 | Is Category/Product Listing hierarchy approved? | Listing/search/category | Sets discovery density and taxonomy presentation | P0 | OPEN |
| UOD-006 | Is Product Details + Seller Comparison hierarchy approved? | Product/seller | Defines core local-commerce value proposition | P0 | OPEN |
| UOD-007 | Which action is visually primary on Shop Details? | Shop | Physical-visit intent and customer comprehension | P0 | OPEN |
| UOD-008 | Is Cart V2's physical-intent hierarchy and sample arithmetic approved? | Cart V2 | Must not resemble online checkout | P0 | OPEN |
| UOD-009 | Should protected actions use contextual AuthGuard then existing login, or a distinct auth presentation? | Navigation/auth | Shapes guest trust and conversion | P0 | OPEN |
| UOD-010 | What visual density should the 390 px Customer baseline use? | All commerce screens | Balance polish, scan speed and long Turkish content | P1 | OPEN |
| UOD-011 | Which metadata is visually essential on ProductCard? | Home/listing/wishlist/recent/shop | Determines card density and local-commerce emphasis | P1 | OPEN |
| UOD-012 | Should category entry favor image cards, compact rows or context-dependent use? | Home/listing | Affects discovery rhythm and taxonomy scalability | P1 | OPEN |
| UOD-013 | What is the approved missing-image/fallback art direction? | Products/categories/banners/shops | Fallbacks are frequent and brand-visible | P1 | OPEN |
| UOD-014 | Should iconography stay Iconsax-led or move to another approved style later? | All actions/navigation/states | Mixed icon systems reduce perceived polish | P2 | OPEN |
| UOD-015 | What level of motion is appropriate for the pilot? | Navigation/cards/states | Brand feel versus performance/accessibility | P2 | OPEN |
| UOD-016 | What customer-facing Turkish tone should final microcopy use? | Home/auth/errors/empty/support | Developer/generic marketplace wording needs a coherent voice | P1 | OPEN |
| UOD-017 | How prominent should verified-purchase trust markers be? | Reviews/purchases/shop/product | Trust signal importance without visual noise | P1 | OPEN |
| UOD-018 | Should dormant ads/reward/gamification visual slots be invisible in pilot? | Cards/status/account | Avoid implying unavailable engines | P1 | OPEN |
| UOD-019 | Which low-traffic screens require full polish before pilot? | Legal/help/recovery/coupons | Trade-off between completeness and launch timing | P1 | OPEN |
| UOD-020 | Is tablet-specific composition required for pilot or only safe max-width behavior? | All screens | Scope/cost decision, not a Flutter detail | P2 | OPEN |
| UOD-021 | How closely should Customer and future Merchant visual systems resemble each other? | Cross-app brand | Shared identity versus role-specific density | P1 | OPEN |
| UOD-022 | What is the acceptable customization ceiling for K'pasa? | Components/screens | Prevent template residue and design-system overbuild | P1 | OPEN |
| UOD-023 | What visual comparison tolerance and evidence constitutes approval? | Acceptance process | Avoid subjective “looks close” sign-off | P0 | OPEN |
| UOD-024 | Which V2/V3 imperfections may be deferred after pilot-critical acceptance? | Release scope | Prevent endless polish from delaying commercialization | P1 | OPEN |

## Priority totals

| Priority | Raw decisions |
|---|---:|
| P0 | 9 |
| P1 | 12 |
| P2 | 3 |
| **Total** | **24** |

No option is selected and no decision is final in this inventory.
