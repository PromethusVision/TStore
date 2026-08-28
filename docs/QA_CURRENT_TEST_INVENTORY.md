# Current Test Inventory

**State:** STATIC AUDIT — origin/main@fca935fdbe3053d2d9aa4bbb7a10b1f928007b63

## Summary

| Type | Tracked Dart files |
|---|---:|
| Unit | 58 |
| Widget | 59 |
| Architecture/static contract | 6 |
| Controlled integration under test/ | 3 |
| Live opt-in under test/live | 3 |
| Root app smoke | 1 |
| **Total** | **130** |

There is no tracked `integration_test/` directory. `test/live/README.md` is documentation and is excluded from the Dart count. Five explicit skip declarations gate six remote/live cases in the recorded full-suite baseline; default `flutter test --no-pub` must remain network-safe.

## Inventory fields

`Backend dependency` describes what the file can actually prove. `MOCK_OR_FAKE_BOUNDARY` does not prove deployed RLS/RPC. Criticality is a QA routing proposal, not code ownership or a statement that every file is complete.

| File | Feature | Type | Scope signal | Backend dependency | Mock/live | Criticality |
|---|---|---|---|---|---|---|
| `test/architecture/auth_redirect_wiring_contract_test.dart` | platform | ARCHITECTURE | auth redirect wiring contract | STATIC_SOURCE_CONTRACT | STATIC | P1 |
| `test/architecture/legacy_order_isolation_test.dart` | platform | ARCHITECTURE | legacy order isolation | STATIC_SOURCE_CONTRACT | STATIC | P1 |
| `test/architecture/mobile_release_signing_contract_test.dart` | platform | ARCHITECTURE | mobile release signing contract | STATIC_SOURCE_CONTRACT | STATIC | P0 |
| `test/architecture/production_platform_contract_test.dart` | platform | ARCHITECTURE | production platform contract | STATIC_SOURCE_CONTRACT | STATIC | P1 |
| `test/architecture/release_logging_contract_test.dart` | platform | ARCHITECTURE | release logging contract | STATIC_SOURCE_CONTRACT | STATIC | P0 |
| `test/architecture/review_client_security_contract_test.dart` | platform | ARCHITECTURE | review client security contract | STATIC_SOURCE_CONTRACT | STATIC | P0 |
| `test/integration/auth_flow_test.dart` | auth | INTEGRATION | auth flow | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P0 |
| `test/integration/live_development_auth_rls_test.dart` | auth | INTEGRATION | live development auth rls | REMOTE_SUPABASE_OPT_IN | LIVE_OPT_IN | P0 |
| `test/integration/live_development_product_reviews_test.dart` | reviews | INTEGRATION | live development product reviews | REMOTE_SUPABASE_OPT_IN | LIVE_OPT_IN | P0 |
| `test/live/development_realtime_integration_test.dart` | chat_notifications | LIVE | development realtime integration | REMOTE_SUPABASE_OPT_IN | LIVE_OPT_IN | P0 |
| `test/live/production_demo_functional_smoke_test.dart` | environment | LIVE | production demo functional smoke | REMOTE_SUPABASE_OPT_IN | LIVE_OPT_IN | P0 |
| `test/live/production_readonly_integration_test.dart` | environment | LIVE | production readonly integration | REMOTE_SUPABASE_OPT_IN | LIVE_OPT_IN | P0 |
| `test/unit/auth/auth_callback_contract_test.dart` | auth | UNIT | auth callback contract | NONE_OR_FAKE | LOCAL_UNIT | P0 |
| `test/unit/auth/auth_cubit_test.dart` | auth | UNIT | auth cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P0 |
| `test/unit/auth/auth_deep_link_contract_test.dart` | auth | UNIT | auth deep link contract | NONE_OR_FAKE | LOCAL_UNIT | P0 |
| `test/unit/auth/auth_repository_impl_test.dart` | auth | UNIT | auth repository impl | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P0 |
| `test/unit/auth/auth_repository_test.dart` | auth | UNIT | auth repository | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P0 |
| `test/unit/auth/auth_usecases_test.dart` | auth | UNIT | auth usecases | NONE_OR_FAKE | LOCAL_UNIT | P0 |
| `test/unit/auth/customer_onboarding_preferences_test.dart` | auth | UNIT | customer onboarding preferences | NONE_OR_FAKE | LOCAL_UNIT | P0 |
| `test/unit/auth/password_recovery_launch_test.dart` | auth | UNIT | password recovery launch | NONE_OR_FAKE | LOCAL_UNIT | P0 |
| `test/unit/cart/cart_item_purchase_verification_test.dart` | cart | UNIT | cart item purchase verification | NONE_OR_FAKE | LOCAL_UNIT | P0 |
| `test/unit/cart/cart_v2_cubit_test.dart` | cart | UNIT | cart v2 cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P0 |
| `test/unit/cart/qr_release_migration_contract_test.dart` | cart | UNIT | qr release migration contract | STATIC_ARTIFACT_CONTRACT | STATIC | P0 |
| `test/unit/cart/qr_session_cubit_test.dart` | cart | UNIT | qr session cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P0 |
| `test/unit/cart/qr_verification_cubit_test.dart` | cart | UNIT | qr verification cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P0 |
| `test/unit/cart/qr_verification_model_test.dart` | cart | UNIT | qr verification model | NONE_OR_FAKE | LOCAL_UNIT | P0 |
| `test/unit/chat/chat_conversations_cubit_test.dart` | chat | UNIT | chat conversations cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P1 |
| `test/unit/chat/chat_cubit_test.dart` | chat | UNIT | chat cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P1 |
| `test/unit/chat/chat_realtime_snapshot_tracker_test.dart` | chat | UNIT | chat realtime snapshot tracker | NONE_OR_FAKE | LOCAL_UNIT | P1 |
| `test/unit/chat/chat_thread_model_test.dart` | chat | UNIT | chat thread model | NONE_OR_FAKE | LOCAL_UNIT | P1 |
| `test/unit/chat/chat_unread_cubit_test.dart` | chat | UNIT | chat unread cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P1 |
| `test/unit/chat/shared_preferences_pending_product_chat_storage_test.dart` | chat | UNIT | shared preferences pending product chat storage | NONE_OR_FAKE | LOCAL_UNIT | P1 |
| `test/unit/core/customer_error_message_test.dart` | core | UNIT | customer error message | NONE_OR_FAKE | LOCAL_UNIT | P1 |
| `test/unit/core/iconsax_compat_test.dart` | core | UNIT | iconsax compat | NONE_OR_FAKE | LOCAL_UNIT | P2 |
| `test/unit/core/production_release_preflight_test.dart` | core | UNIT | production release preflight | STATIC_ARTIFACT_CONTRACT | STATIC | P0 |
| `test/unit/core/supabase_config_test.dart` | core | UNIT | supabase config | STATIC_ARTIFACT_CONTRACT | STATIC | P1 |
| `test/unit/demo_seed/esenler_demo_v1_contract_test.dart` | demo_seed | UNIT | esenler demo v1 contract | NONE_OR_FAKE | LOCAL_UNIT | P1 |
| `test/unit/navigation/navigation_menu_cubit_test.dart` | navigation | UNIT | navigation menu cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P1 |
| `test/unit/notifications/notification_repository_impl_test.dart` | notifications | UNIT | notification repository impl | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P1 |
| `test/unit/notifications/notifications_cubit_test.dart` | notifications | UNIT | notifications cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P1 |
| `test/unit/notifications/notifications_pagination_test.dart` | notifications | UNIT | notifications pagination | NONE_OR_FAKE | LOCAL_UNIT | P1 |
| `test/unit/orders/orders_cubit_test.dart` | orders | UNIT | orders cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P2 |
| `test/unit/personalization/customer_saved_locations_cubit_test.dart` | personalization | UNIT | customer saved locations cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P1 |
| `test/unit/personalization/personalization_cubit_test.dart` | personalization | UNIT | personalization cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P1 |
| `test/unit/purchases/purchase_history_cubit_test.dart` | purchases | UNIT | purchase history cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P0 |
| `test/unit/purchases/verified_purchase_model_test.dart` | purchases | UNIT | verified purchase model | NONE_OR_FAKE | LOCAL_UNIT | P0 |
| `test/unit/reviews/review_repository_impl_test.dart` | reviews | UNIT | review repository impl | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P0 |
| `test/unit/reviews/reviews_cubit_test.dart` | reviews | UNIT | reviews cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P0 |
| `test/unit/reviews/shop_rating_cubit_test.dart` | reviews | UNIT | shop rating cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P0 |
| `test/unit/reviews/verified_review_storage_contract_test.dart` | reviews | UNIT | verified review storage contract | STATIC_ARTIFACT_CONTRACT | STATIC | P0 |
| `test/unit/shop/banner_entity_test.dart` | shop | UNIT | banner entity | NONE_OR_FAKE | LOCAL_UNIT | P2 |
| `test/unit/shop/banner_model_test.dart` | shop | UNIT | banner model | NONE_OR_FAKE | LOCAL_UNIT | P2 |
| `test/unit/shop/banners_cubit_test.dart` | shop | UNIT | banners cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P2 |
| `test/unit/shop/customer_proximity_helper_test.dart` | shop | UNIT | customer proximity helper | NONE_OR_FAKE | LOCAL_UNIT | P1 |
| `test/unit/shop/customer_search_cubit_test.dart` | shop | UNIT | customer search cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P1 |
| `test/unit/shop/geolocator_customer_location_service_test.dart` | shop | UNIT | geolocator customer location service | NONE_OR_FAKE | LOCAL_UNIT | P1 |
| `test/unit/shop/get_banners_usecase_test.dart` | shop | UNIT | get banners usecase | NONE_OR_FAKE | LOCAL_UNIT | P2 |
| `test/unit/shop/get_products_by_ids_usecase_test.dart` | shop | UNIT | get products by ids usecase | NONE_OR_FAKE | LOCAL_UNIT | P1 |
| `test/unit/shop/get_shop_by_id_usecase_test.dart` | shop | UNIT | get shop by id usecase | NONE_OR_FAKE | LOCAL_UNIT | P1 |
| `test/unit/shop/media_model_resolution_test.dart` | shop | UNIT | media model resolution | NONE_OR_FAKE | LOCAL_UNIT | P1 |
| `test/unit/shop/nearby_shops_cubit_test.dart` | shop | UNIT | nearby shops cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P1 |
| `test/unit/shop/products_cubit_test.dart` | shop | UNIT | products cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P1 |
| `test/unit/shop/recently_viewed_products_cubit_test.dart` | shop | UNIT | recently viewed products cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P1 |
| `test/unit/shop/shared_preferences_recent_product_searches_storage_test.dart` | shop | UNIT | shared preferences recent product searches storage | NONE_OR_FAKE | LOCAL_UNIT | P1 |
| `test/unit/shop/shared_preferences_recently_viewed_products_storage_test.dart` | shop | UNIT | shared preferences recently viewed products storage | NONE_OR_FAKE | LOCAL_UNIT | P1 |
| `test/unit/shop/shop_product_customer_purchasability_test.dart` | shop | UNIT | shop product customer purchasability | NONE_OR_FAKE | LOCAL_UNIT | P1 |
| `test/unit/shop/shop_usecases_test.dart` | shop | UNIT | shop usecases | NONE_OR_FAKE | LOCAL_UNIT | P1 |
| `test/unit/supabase/canonical_migrations_contract_test.dart` | supabase | UNIT | canonical migrations contract | STATIC_ARTIFACT_CONTRACT | STATIC | P0 |
| `test/unit/supabase/public_media_source_resolver_test.dart` | supabase | UNIT | public media source resolver | NONE_OR_FAKE | LOCAL_UNIT | P1 |
| `test/unit/wishlist/wishlist_cubit_test.dart` | wishlist | UNIT | wishlist cubit | MOCK_OR_FAKE_BOUNDARY | MOCKED_LOCAL | P1 |
| `test/widget/auth/auth_input_visibility_test.dart` | auth | WIDGET | auth input visibility | NONE_OR_FAKE | LOCAL_WIDGET | P0 |
| `test/widget/auth/customer_launch_gate_test.dart` | auth | WIDGET | customer launch gate | NONE_OR_FAKE | LOCAL_WIDGET | P0 |
| `test/widget/auth/customer_session_listener_test.dart` | auth | WIDGET | customer session listener | NONE_OR_FAKE | LOCAL_WIDGET | P0 |
| `test/widget/auth/email_confirmation_listener_test.dart` | auth | WIDGET | email confirmation listener | NONE_OR_FAKE | LOCAL_WIDGET | P0 |
| `test/widget/auth/email_confirmation_navigation_test.dart` | auth | WIDGET | email confirmation navigation | NONE_OR_FAKE | LOCAL_WIDGET | P0 |
| `test/widget/auth/login_form_section_test.dart` | auth | WIDGET | login form section | NONE_OR_FAKE | LOCAL_WIDGET | P0 |
| `test/widget/auth/login_view_test.dart` | auth | WIDGET | login view | NONE_OR_FAKE | LOCAL_WIDGET | P0 |
| `test/widget/auth/on_boarding_view_test.dart` | auth | WIDGET | on boarding view | NONE_OR_FAKE | LOCAL_WIDGET | P0 |
| `test/widget/auth/password_recovery_flow_test.dart` | auth | WIDGET | password recovery flow | NONE_OR_FAKE | LOCAL_WIDGET | P0 |
| `test/widget/auth/password_recovery_listener_test.dart` | auth | WIDGET | password recovery listener | NONE_OR_FAKE | LOCAL_WIDGET | P0 |
| `test/widget/auth/sign_up_legal_consent_test.dart` | auth | WIDGET | sign up legal consent | NONE_OR_FAKE | LOCAL_WIDGET | P0 |
| `test/widget/auth/sign_up_view_test.dart` | auth | WIDGET | sign up view | NONE_OR_FAKE | LOCAL_WIDGET | P0 |
| `test/widget/auth/verify_email_view_test.dart` | auth | WIDGET | verify email view | NONE_OR_FAKE | LOCAL_WIDGET | P0 |
| `test/widget/cart/cart_qr_session_bottom_sheet_test.dart` | cart | WIDGET | cart qr session bottom sheet | NONE_OR_FAKE | LOCAL_WIDGET | P0 |
| `test/widget/cart/cart_v2_view_test.dart` | cart | WIDGET | cart v2 view | NONE_OR_FAKE | LOCAL_WIDGET | P0 |
| `test/widget/chat/chat_view_test.dart` | chat | WIDGET | chat view | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/chat/conversations_view_test.dart` | chat | WIDGET | conversations view | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/chat/pending_product_chat_listener_test.dart` | chat | WIDGET | pending product chat listener | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/common/customer_light_input_theme_test.dart` | common | WIDGET | customer light input theme | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/common/horizontal_product_card_favorite_test.dart` | common | WIDGET | horizontal product card favorite | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/common/location_dialog_localization_test.dart` | common | WIDGET | location dialog localization | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/common/vertical_product_card_favorite_test.dart` | common | WIDGET | vertical product card favorite | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/navigation/customer_bottom_navigation_test.dart` | navigation | WIDGET | customer bottom navigation | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/navigation/navigation_menu_unread_badge_test.dart` | navigation | WIDGET | navigation menu unread badge | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/notifications/customer_notifications_view_test.dart` | notifications | WIDGET | customer notifications view | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/personalization/account_deletion_confirmation_dialog_test.dart` | personalization | WIDGET | account deletion confirmation dialog | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/personalization/customer_coupons_view_test.dart` | personalization | WIDGET | customer coupons view | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/personalization/customer_profile_view_test.dart` | personalization | WIDGET | customer profile view | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/personalization/customer_saved_locations_view_test.dart` | personalization | WIDGET | customer saved locations view | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/personalization/edit_profile_bottom_sheet_test.dart` | personalization | WIDGET | edit profile bottom sheet | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/personalization/help_and_support_view_test.dart` | personalization | WIDGET | help and support view | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/personalization/privacy_and_permissions_view_test.dart` | personalization | WIDGET | privacy and permissions view | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/personalization/settings_cart_navigation_test.dart` | personalization | WIDGET | settings cart navigation | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/purchases/customer_ratings_view_test.dart` | purchases | WIDGET | customer ratings view | NONE_OR_FAKE | LOCAL_WIDGET | P0 |
| `test/widget/purchases/purchases_view_test.dart` | purchases | WIDGET | purchases view | NONE_OR_FAKE | LOCAL_WIDGET | P0 |
| `test/widget/shop/all_products_view_test.dart` | shop | WIDGET | all products view | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/banner_carousel_slider_test.dart` | shop | WIDGET | banner carousel slider | NONE_OR_FAKE | LOCAL_WIDGET | P2 |
| `test/widget/shop/customer_home_v1_layout_test.dart` | shop | WIDGET | customer home v1 layout | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/home_app_bar_test.dart` | shop | WIDGET | home app bar | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/home_categories_test.dart` | shop | WIDGET | home categories | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/home_location_bar_test.dart` | shop | WIDGET | home location bar | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/home_nearby_shops_section_test.dart` | shop | WIDGET | home nearby shops section | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/home_products_section_test.dart` | shop | WIDGET | home products section | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/home_saved_locations_navigation_test.dart` | shop | WIDGET | home saved locations navigation | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/home_search_bar_test.dart` | shop | WIDGET | home search bar | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/nearby_view_test.dart` | shop | WIDGET | nearby view | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/product_details_view_layout_test.dart` | shop | WIDGET | product details view layout | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/product_image_fallback_test.dart` | shop | WIDGET | product image fallback | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/product_image_slider_favorite_test.dart` | shop | WIDGET | product image slider favorite | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/product_metadata_test.dart` | shop | WIDGET | product metadata | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/product_reviews_view_test.dart` | shop | WIDGET | product reviews view | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/product_seller_price_summary_test.dart` | shop | WIDGET | product seller price summary | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/product_sellers_section_test.dart` | shop | WIDGET | product sellers section | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/promo_banner_carousel_slider_test.dart` | shop | WIDGET | promo banner carousel slider | NONE_OR_FAKE | LOCAL_WIDGET | P2 |
| `test/widget/shop/recently_viewed_products_view_test.dart` | shop | WIDGET | recently viewed products view | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/shop_profile_view_test.dart` | shop | WIDGET | shop profile view | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/sub_category_view_test.dart` | shop | WIDGET | sub category view | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/shop/wishlist_view_test.dart` | shop | WIDGET | wishlist view | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget/wishlist/product_favorite_button_login_test.dart` | wishlist | WIDGET | product favorite button login | NONE_OR_FAKE | LOCAL_WIDGET | P1 |
| `test/widget_test.dart` | app | APP_SMOKE | widget | NONE_OR_FAKE | STATIC | P1 |

## Supporting non-test harnesses

- `tool/live_test/live_qr_purchase_integration_test.dart`: Development-only opt-in QR integration with multiple independent sessions; outside the default `test/` suite.
- `tool/sql_contract/validate_canonical_migrations.mjs`: PGlite clean-room migration/RPC/Storage contract harness.
- `tool/verify_migration_artifact_manifest.mjs`: LF-normalized SHA-256 validation for the nine canonical migrations.
- `tool/demo_seed/*`: deterministic Esenler demo generation/validation.
- `tool/production_release_preflight.dart`: environment/config preflight without revealing values.

## Audit conclusions

The local pyramid is broad at unit/widget level and strong in Auth, Cart, Shop/discovery, Review, QR client contracts and release configuration. The main structural gaps are a first-class device integration harness, automated local Supabase RLS/RPC tests, exact-artifact device automation, iOS runner evidence and future Merchant/backend/analytics implementations. Physical QR, GPS, notification delivery and store release gates remain manual.

`CURRENT_TEST_INVENTORY_COMPLETE: YES`

`CURRENT_SUITE_RESULT_REEXECUTED_IN_W22: NO`
