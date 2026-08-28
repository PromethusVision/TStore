# Customer App Deferred Issues

Status: **CLASSIFIED — NO ORPHAN ISSUE**
Wave: **16 — Customer App Commercialization Closeout**

| ID | Classification | Decision / reason | Release effect |
|---|---|---|---|
| CUST-PRIV-001 | OWNER_DECISION_REQUIRED | Decide whether five device-local recent searches survive logout/account switch or become user-scoped/cleared | Does not block core; blocks final privacy policy sign-off |
| CUST-PRIV-002 | OWNER_DECISION_REQUIRED | Decide whether a pre-login product-chat draft may persist device-wide for up to 24h | Does not block core; blocks final privacy policy sign-off |
| CUST-NAV-001 | OWNER_DECISION_REQUIRED | Keep public Nearby discovery (recommended) or gate all Nearby behind login | Affects navigation copy/guard, not backend correctness |
| CUST-TAX-001 | TAXONOMY_DEFER | Runtime taxonomy model, queries and routes must wait for the owner-final taxonomy and migration plan | Current four-category demo works; final catalog launch depends on it |
| CUST-UI-001 | UI_KIT_DEFER | Functional screens await the final Figma/UI-kit rollout | Cosmetic/accessibility visual acceptance remains; no current functional blocker |
| CUST-QR-001 | PHYSICAL_TEST_REQUIRED | Complete real camera, two-device, wrong merchant, replay and concurrency acceptance | Blocks full QR commercialization claim |
| CUST-IOS-001 | PHYSICAL_TEST_REQUIRED | Produce signed archive/TestFlight build and exercise callbacks on iOS | Blocks iOS release, not Android-only pilot logic |
| CUST-STORE-001 | PRODUCTION_CONFIG_REQUIRED | Validate current signed candidate in store/internal track and final package/version/signing state | Blocks public distribution |
| CUST-CONFIG-001 | PRODUCTION_CONFIG_REQUIRED | Human re-check Auth redirect/SMTP, RLS, Realtime, Storage and backup/PITR immediately before release | Blocks final go/no-go |
| CUST-AVATAR-001 | BACKEND_SCHEMA_REQUIRED | Do not expose dormant avatar methods until the bucket/policy contract is explicitly created | No impact while UI remains absent |
| CUST-ADDR-001 | FUTURE_FEATURE | Postal-address prototype is not routed; O2O V1 uses saved locations and does not ship/order online | No pilot blocker under the frozen O2O model |
| CUST-PUSH-001 | FUTURE_FEATURE | In-app notifications ship; remote push requires a separate product/backend contract | No current customer-core blocker |
| CUST-MON-001 | FUTURE_FEATURE | Select privacy-compliant crash/analytics tooling in a separate owner decision | Operational observability risk remains |
| CUST-SCALE-001 | ACCEPTED_RISK | Eager shop/wishlist/purchase/seller/conversation reads are acceptable at current pilot scale; paginate before material growth | Does not block limited pilot |
| CUST-DEPS-001 | ACCEPTED_RISK | Do not mass-upgrade 68 packages in closeout; use a dedicated compatibility branch | Security advisories still require routine monitoring |
| CUST-ASSET-001 | ACCEPTED_RISK | Large visual assets should be re-encoded only with visual QA/final UI-kit input | Increases download size; does not block functional pilot acceptance |

## Explicitly not deferred

Release logging, duplicate signup and duplicate replace-cart writes were safe,
deterministic and locally testable; they were fixed in this wave. No code TODO
was left for them.
