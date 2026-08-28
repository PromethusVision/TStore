# Merchant Pilot Runtime Impact Map

State: `FORECAST ONLY — NO RUNTIME CHANGE`

Bu harita uygulama sırasında incelenecek mevcut alanları gösterir; dosya sahipliği veya kesin implementation kararı değildir.

## Mevcut customer-app seams

| Alan | Mevcut dosyalar | Mevcut durum | Minimum pilot etkisi |
|---|---|---|---|
| Auth role | `lib/features/auth/domain/entities/user_entity.dart`, auth repository/profile model | `customer/merchant/admin`, `canManageShop` | Global role tek başına yetki olmamalı; shop membership projection eklenmeli |
| Shop repository | `lib/features/shop/domain/repositories/shop_repository.dart`, `data/repositories/shop_repository_impl.dart` | owner_user_id ile ilk shop; basic profile CRUD/read listing | Dedicated merchant API contract, exact shop scope, listing mutation/freshness gerekir |
| Shop UI | `my_shop_view.dart`, `my_shop_form_view.dart`, `my_shop_cubit.dart` | basic profile + QR giriş noktası | Pilot status/action shell; create shop self-service yerine verified onboarding state |
| QR UI | `lib/features/cart/presentation/views/merchant_qr_scanner_view.dart` | camera lifecycle, preview/confirm/success | Ayrı merchant shell'e taşınabilir/reuse; authorization/history/support state eklenir |
| QR state | `qr_verification_cubit.dart`, states/usecases/repository | in-flight guard, stale op reject, reconciliation | Shop/session revision binding, telemetry ve exact artifact tests korunur |
| Listing entities | `shop_product_entity.dart`, model | price + bool availability | availability enum/unknown, freshness, revision ve policy projection gerekir |
| Navigation/DI | `lib/t_store.dart`, `lib/core/dependency_injection/service_locator.dart` | customer app içinde merchant route/wiring | Merchant App entry composition ayrı olmalı; shared packages kararı implementation gate |
| Reviews | product review views/repositories | verified product review contract | Merchant read/report projection; ayrı merchant free-text yok |

## Önerilen logical modules

- `merchant_auth`: session + membership/shop scope projection.
- `merchant_home`: critical action summary, no vanity dashboard.
- `merchant_shop`: read/basic change request and verification state.
- `merchant_listings`: list, price/availability/freshness mutation, product search/candidate.
- `merchant_qr`: scan, preview, confirm, reconcile, history.
- `merchant_reviews`: read/report only in pilot.
- `merchant_support`: case creation/status.
- shared contracts: catalog/listing identifiers, QR DTOs, safe errors/correlation.

## Build strategy options

1. Dedicated Flutter app with carefully extracted shared domain/data packages.
2. Existing codebase second entry point/flavor as temporary step.
3. Customer app merchant routes retained temporarily (highest boundary confusion).

Dedicated Merchant App remains architectural direction; exact packaging is engineering/integration decision. Pilot scope must not become a reason to expose merchant controls to customer users.

