# Customer App Final Functional Issues

Status: **NO OPEN AUTOMATIC P0/P1 CODE DEFECT**

## Fixed functional/security defects

| ID | Severity | Resolution | Regression |
|---|---|---|---|
| CUST-REL-001 | P1 | Release loggers disabled and shared diagnostics sanitized | Release logging architecture tests |
| CUST-AUTH-001 | P1 | Signup ignores duplicate in-flight submission | Auth Cubit test |
| CUST-CART-001 | P1 | Replace-cart uses exclusive mutation lock | Cart V2 Cubit test |

## Still-open functional/release issues

| ID | Severity | State | Why not fixed here |
|---|---|---|---|
| CUST-QR-001 | P1 | PHYSICAL_TEST_REQUIRED | Requires real two-device/camera/merchant fixtures |
| CUST-IOS-001 | P1 | PHYSICAL_TEST_REQUIRED | Requires Apple release environment and device |
| CUST-STORE-001 | P1 | PRODUCTION_CONFIG_REQUIRED | Requires secure signing/store owner operations |
| CUST-CONFIG-001 | P1 | PRODUCTION_CONFIG_REQUIRED | Requires JIT authorized Production checks |
| CUST-PRIV-001 | P2 | OWNER_DECISION_REQUIRED | Recent-search retention policy is a product/privacy choice |
| CUST-PRIV-002 | P2 | OWNER_DECISION_REQUIRED | Pre-login chat-draft retention is a product/privacy choice |
| CUST-NAV-001 | P2 | OWNER_DECISION_REQUIRED | Public vs authenticated Nearby is unresolved in source decisions |
| CUST-ADDR-001 | P2 | FUTURE_FEATURE | Postal address is outside current O2O V1 and prototype remains unreachable |
| CUST-AVATAR-001 | P2 | BACKEND_SCHEMA_REQUIRED | Avatar bucket/policy not active |
| CUST-SCALE-001 | P2 | ACCEPTED_RISK | Eager lists are acceptable at pilot scale, not growth scale |
| CUST-MON-001 | P2 | FUTURE_FEATURE | Monitoring provider/privacy decision absent |
| CUST-DEPS-001 | P2 | ACCEPTED_RISK | Dedicated compatibility upgrades safer than closeout mass upgrade |
| CUST-ASSET-001 | P2 | ACCEPTED_RISK | Visual QA required before re-encoding oversized assets |
| CUST-PUSH-001 | P2 | FUTURE_FEATURE | In-app notifications are active; push is not V1 scope |
| CUST-TAX-001 | P2 | TAXONOMY_DEFER | Final taxonomy requires data/schema/query/navigation plan |

## Cosmetic issues

`CUST-UI-001` (P3) covers final UI-kit/token/component rollout. Cosmetic
spacing, typography, card, icon and alignment differences are not presented as
functional failures. No cosmetic code was changed in Wave 16.

The final registry contains 19 unique ids: 3 fixed and 16 open/deferred. There
are no P0 findings and no failed automated customer journey.
