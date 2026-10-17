import 'dart:convert';
import '../../../core/supabase/supabase_config.dart';

/// Offline validation only. Passing this contract grants no remote authority.
final class MerchantPilotConfig {
  MerchantPilotConfig._(this.backend);
  final SupabaseConfig backend;
  static const applicationId = 'com.esnaftavar.app.merchant.pilot';
  static const target = 'lib/main_merchant_pilot.dart';
  static const flavor = 'merchantPilot';
  static const enabledKey = 'MERCHANT_PILOT_ENABLED';
  static const urlKey = 'MERCHANT_PILOT_URL';
  static const anonKey = 'MERCHANT_PILOT_ANON_KEY';
  static const forbiddenCapabilities = [
    'QR_CLAIMS_V2_ENABLED',
    'REWARD_EARNING_V1_ENABLED',
    'COUPON_CHECKOUT_V1_ENABLED',
    'TRUST_COMMERCE_V1_ENABLED',
    'REVIEWS_V2_ENABLED',
    'MERCHANT_STATEMENT_V1_ENABLED',
    'MERCHANT_PROMOTION_V1_ENABLED',
    'MERCHANT_PUSH_SCHEMA_LOCAL_ENABLED',
  ];

  factory MerchantPilotConfig.fromValues(Map<String, String> values) {
    void reject(String message) => throw SupabaseConfigurationException(
      AppEnvironment.development,
      message,
    );
    if (values[enabledKey] != 'true') {
      reject('Merchant pilot configuration is not enabled.');
    }
    final allowed = {enabledKey, urlKey, anonKey, ...forbiddenCapabilities};
    if (values[anonKey] != values[anonKey]?.trim()) {
      reject('Pilot client key must not contain surrounding whitespace.');
    }
    if (values.keys.any((k) => !allowed.contains(k))) {
      reject('Unknown or mixed configuration fields are not accepted.');
    }
    // This increment prepares the existing nonproduction project only. A new
    // environment/Production requires a separately reviewed binding, not a URL override.
    const expected =
        'https://${SupabaseConfig.developmentProjectRef}.supabase.co';
    if (values[urlKey] != expected) {
      reject('Merchant pilot requires the reviewed nonproduction URL.');
    }
    for (final field in forbiddenCapabilities) {
      if (values.containsKey(field) && values[field] != 'false') {
        reject(
          'A capability outside the pilot runtime preparation was requested.',
        );
      }
    }
    final backend = SupabaseConfig.forEnvironment(
      environment: AppEnvironment.development,
      supabaseUrl: values[urlKey] ?? '',
      supabaseAnonKey: values[anonKey] ?? '',
    );
    if (!backend.supabaseAnonKey.startsWith('sb_publishable_')) {
      try {
        final payload =
            jsonDecode(
                  utf8.decode(
                    base64Url.decode(
                      base64Url.normalize(
                        backend.supabaseAnonKey.split('.')[1],
                      ),
                    ),
                  ),
                )
                as Map;
        if (payload['ref'] != SupabaseConfig.developmentProjectRef) {
          reject('Legacy client key project does not match the pilot.');
        }
      } on FormatException {
        reject('Invalid pilot client key.');
      }
    }
    return MerchantPilotConfig._(backend);
  }
}
