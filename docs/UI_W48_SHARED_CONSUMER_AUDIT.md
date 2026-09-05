# W48 shared consumer audit

Scope: one writer on `astra-ui/w48-remaining-customer-utility-engagement-final-ui`.

The typed snackbar helper preserves type, duration, hide/queue and action behavior.
Material snackbar defaults preserve caller action/duration while using Final UI
typography, spacing, surface and foreground. Raw spinner defaults retain the
approved Home track appearance; TLoadingIndicator owns its labeled mint track.

The four actual TLoadingIndicator consumers are Wishlist, Recently Viewed,
Notifications and QR. Its old declaration had no runtime callers. Generic
progress elsewhere already uses Material; the shared theme supplies primary.

Reserved Purchases/Reviews/Chat and non-Customer callers below are audited
transitive consumers, not newly implemented screens. Their files are unchanged.
Auth/session, repositories, cubits and route construction are unchanged.

Changed shared files:

- `lib/core/common/widgets/progress_indicator.dart`
- `lib/core/ui/foundation/esnaftavar_theme.dart`
- `lib/core/utils/helpers/helper_functions.dart` (snackbar method only)

LocationHelper and its two compatibility dialog methods are unchanged.
No global navigation, provider, service binding or dependency/config edit.

## Typed snackbar helper

- `lib/core/utils/helpers/location_helper.dart`
- `lib/features/auth/presentation/views/password_configuration/reset_password_view.dart`
- `lib/features/auth/presentation/views/password_configuration/update_password_view.dart`
- `lib/features/auth/presentation/views/signup/verify_email_view.dart`
- `lib/features/auth/presentation/widgets/forget_password_form_section.dart`
- `lib/features/auth/presentation/widgets/login_form_section.dart`
- `lib/features/auth/presentation/widgets/sign_up_form_section.dart`
- `lib/features/personalization/presentation/views/settings_view.dart`

## TLoadingIndicator

- `lib/features/cart/presentation/widgets/cart_qr_session_bottom_sheet.dart`
- `lib/features/notifications/presentation/views/customer_notifications_view.dart`
- `lib/features/shop/presentation/views/recently_viewed_products_view.dart`
- `lib/features/shop/presentation/views/wishlist_view.dart`

## Material snackbar consumers (shared theme; caller code unchanged unless scoped)

- `lib/core/common/widgets/horizontal_small_list_view_item.dart`
- `lib/core/utils/helpers/location_helper.dart`
- `lib/features/auth/presentation/views/password_configuration/reset_password_view.dart`
- `lib/features/auth/presentation/views/password_configuration/update_password_view.dart`
- `lib/features/auth/presentation/views/signup/verify_email_view.dart`
- `lib/features/auth/presentation/widgets/customer_session_listener.dart`
- `lib/features/auth/presentation/widgets/email_confirmation_listener.dart`
- `lib/features/auth/presentation/widgets/forget_password_form_section.dart`
- `lib/features/auth/presentation/widgets/login_form_section.dart`
- `lib/features/auth/presentation/widgets/sign_up_form_section.dart`
- `lib/features/chat/presentation/views/chat_view.dart`
- `lib/features/chat/presentation/widgets/pending_product_chat_listener.dart`
- `lib/features/notifications/presentation/views/customer_notifications_view.dart`
- `lib/features/personalization/presentation/views/customer_saved_locations_view.dart`
- `lib/features/personalization/presentation/views/profile_view.dart`
- `lib/features/personalization/presentation/views/settings_view.dart`
- `lib/features/purchases/presentation/views/purchases_view.dart`
- `lib/features/shop/presentation/views/cart_v2_view.dart`
- `lib/features/shop/presentation/views/my_shop_form_view.dart`
- `lib/features/shop/presentation/views/nearby_view.dart`
- `lib/features/shop/presentation/views/product_reviews_view.dart`
- `lib/features/shop/presentation/views/recently_viewed_products_view.dart`
- `lib/features/shop/presentation/views/shop_profile_view.dart`
- `lib/features/shop/presentation/widgets/product_sellers_section.dart`
- `lib/features/wishlist/presentation/widgets/product_favorite_button.dart`

## Material progress consumers (shared primary default)

- `lib/core/common/widgets/vertical_product_card.dart`
- `lib/core/utils/helpers/location_helper.dart`
- `lib/features/auth/presentation/views/on_boarding/customer_launch_gate.dart`
- `lib/features/cart/presentation/views/merchant_qr_scanner_view.dart`
- `lib/features/cart/presentation/widgets/cart_qr_session_bottom_sheet.dart`
- `lib/features/chat/presentation/views/chat_view.dart`
- `lib/features/chat/presentation/views/conversations_view.dart`
- `lib/features/notifications/presentation/views/customer_notifications_view.dart`
- `lib/features/personalization/presentation/views/customer_saved_locations_view.dart`
- `lib/features/personalization/presentation/widgets/account_deletion_confirmation_dialog.dart`
- `lib/features/personalization/presentation/widgets/app_settings_section.dart`
- `lib/features/personalization/presentation/widgets/edit_profile_bottom_sheet.dart`
- `lib/features/purchases/presentation/views/customer_ratings_view.dart`
- `lib/features/purchases/presentation/views/purchases_view.dart`
- `lib/features/shop/presentation/views/cart_v2_view.dart`
- `lib/features/shop/presentation/views/cart_v2_visual_prototype.dart`
- `lib/features/shop/presentation/views/my_shop_form_view.dart`
- `lib/features/shop/presentation/views/my_shop_view.dart`
- `lib/features/shop/presentation/views/nearby_view.dart`
- `lib/features/shop/presentation/views/product_reviews_view.dart`
- `lib/features/shop/presentation/views/shop_profile_view.dart`
- `lib/features/shop/presentation/views/taxonomy_browse_view.dart`
- `lib/features/shop/presentation/views/wishlist_view.dart`
- `lib/features/shop/presentation/widgets/home_categories.dart`
- `lib/features/shop/presentation/widgets/home_location_bar.dart`
- `lib/features/shop/presentation/widgets/home_search_bar.dart`
- `lib/features/shop/presentation/widgets/product_seller_price_summary.dart`
- `lib/features/shop/presentation/widgets/product_sellers_section.dart`
- `lib/features/shop/presentation/widgets/seller_comparison_offer_card.dart`
- `lib/features/wishlist/presentation/widgets/product_favorite_button.dart`

## Verified boundaries

- Reserved QR completion/rating class source: identical to base.
- Legacy location helper and its two dialog methods: identical to base.
- W47 source overlap: none at the fetched scope audit; rechecked at delivery.
- Regression: Home golden, Account 73 tests/goldens, Auth light input, nearby,
  sellers/single-shop conflict, QR, history storage, wishlist and notifications.
- Final full suite/analyzer and exact counts are in UI_W48_TASK_RESULT.md.
