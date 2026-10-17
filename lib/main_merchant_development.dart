import 'package:flutter/material.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/merchant/merchant_app.dart';
import 'package:t_store/features/merchant/runtime/merchant_runtime.dart';

/// Explicit local host. It cannot connect to Production or Development cloud.
/// Remote enablement and mobile callback/provider setup require separate review.
SupabaseConfig createMerchantLocalConfig({
  String url = const String.fromEnvironment('SUPABASE_DEVELOPMENT_URL'),
  String anonKey = const String.fromEnvironment(
    'SUPABASE_DEVELOPMENT_ANON_KEY',
  ),
}) {
  final uri = Uri.tryParse(url);
  if (uri == null ||
      !['localhost', '127.0.0.1', '::1', '[::1]'].contains(uri.host)) {
    throw const SupabaseConfigurationException(
      AppEnvironment.development,
      'Merchant V1 requires an explicit local backend; remote activation is pending.',
    );
  }
  return SupabaseConfig.forEnvironment(
    environment: AppEnvironment.development,
    supabaseUrl: url,
    supabaseAnonKey: anonKey,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize(config: createMerchantLocalConfig());
  runApp(
    MerchantApp(
      services: createMerchantServices(
        SupabaseService.instance,
        qrClaims: const bool.fromEnvironment('QR_CLAIMS_V2_ENABLED'),
        rewardEarning: const bool.fromEnvironment('REWARD_EARNING_V1_ENABLED'),
        couponCheckout: const bool.fromEnvironment(
          'COUPON_CHECKOUT_V1_ENABLED',
        ),
        statement: const bool.fromEnvironment('MERCHANT_STATEMENT_V1_ENABLED'),
        trust: const bool.fromEnvironment('TRUST_COMMERCE_V1_ENABLED'),
        reviews: const bool.fromEnvironment('REVIEWS_V2_ENABLED'),
        promotions: const bool.fromEnvironment('MERCHANT_PROMOTION_V1_ENABLED'),
        pushSchema: const bool.fromEnvironment(
          'MERCHANT_PUSH_SCHEMA_LOCAL_ENABLED',
        ),
      ),
    ),
  );
}
