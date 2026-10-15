import 'reward_fixtures.dart';

Map<String, dynamic> checkoutPreview({
  bool enabled = true,
  String maximum = '25000',
  String eligibility = 'eligible',
}) => {
  'version': 1,
  'currency': 'TRY',
  'cart_id': rewardId,
  'shop_id': rewardShop,
  'enabled': enabled,
  'fingerprint': 'a' * 64,
  'sale_minor': '50000',
  'coupon_available_minor': '25000',
  'maximum_coupon_minor': maximum,
  'eligibility': eligibility,
};
Map<String, dynamic> checkoutTerms() => {
  'version': 1,
  'sale_minor': '50000',
  'coupon_minor': '25000',
  'payment_minor': '25000',
  'fingerprint': 'a' * 64,
  'approved_at': rewardNow,
};
Map<String, dynamic> checkoutQr() => {
  'id': 'qr',
  'session_token': 'token',
  'user_id': rewardUser,
  'cart_id': rewardId,
  'shop_id': rewardShop,
  'status': 'active',
  'protocol_version': 2,
  'manual_code': '123456',
  'expires_at': '2099-01-01T00:00:00Z',
  'created_at': rewardNow,
  'updated_at': rewardNow,
  'item_count': 1,
  'total_amount': 500,
  'coupon_checkout': checkoutTerms(),
};
