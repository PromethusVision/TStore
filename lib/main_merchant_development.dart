import 'package:flutter/material.dart';
import 'package:t_store/features/merchant_promotions/data/supabase_merchant_promotion_repository.dart';
import 'package:t_store/features/commerce_ledger/data/supabase_commerce_ledger_repository.dart';
import 'package:t_store/features/rewards/data/supabase_reward_program_repository.dart';
import 'package:t_store/features/trust_commerce/data/supabase_trust_commerce_repository.dart';
import 'package:t_store/features/reviews/data/repositories/supabase_purchase_evaluation_repository.dart';
import 'package:t_store/features/purchases/data/repositories/supabase_purchase_evidence_repository.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:t_store/features/cart/data/repositories/qr_session_repository_impl.dart';
import 'package:t_store/features/merchant/data/supabase_merchant_repository.dart';
import 'package:t_store/features/merchant/data/supabase_catalog_media_repository.dart';
import 'package:t_store/features/merchant/data/supabase_merchant_operations_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_credentials.dart';
import 'package:t_store/features/merchant/merchant_app.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/notifications/data/repositories/notification_preferences_repository.dart';
import 'package:t_store/features/notifications/data/repositories/notification_repository_impl.dart';

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
  final config = createMerchantLocalConfig();
  await SupabaseService.initialize(config: config);
  final service = SupabaseService.instance;
  runApp(
    MerchantApp(
      services: MerchantServices(
        merchants: SupabaseMerchantRepository(client: service.client),
        promotions: const bool.fromEnvironment('MERCHANT_PROMOTION_V1_ENABLED')
            ? SupabaseMerchantPromotionRepository(service.client)
            : null,
        catalogMedia: SupabaseCatalogMediaRepository(service.client),
        operations: SupabaseMerchantOperationsRepository(service.client),
        statement: const bool.fromEnvironment('MERCHANT_STATEMENT_V1_ENABLED')
            ? SupabaseCommerceLedgerRepository(service.client)
            : null,
        rewardProgram:
            const bool.fromEnvironment('REWARD_EARNING_V1_ENABLED') ||
                const bool.fromEnvironment('COUPON_CHECKOUT_V1_ENABLED')
            ? SupabaseRewardProgramRepository(service.client)
            : null,
        trustCommerce: const bool.fromEnvironment('TRUST_COMMERCE_V1_ENABLED')
            ? SupabaseTrustCommerceRepository(service.client)
            : null,
        evaluations: const bool.fromEnvironment('REVIEWS_V2_ENABLED')
            ? SupabasePurchaseEvaluationRepository(service.client)
            : null,
        purchaseEvidence:
            const bool.fromEnvironment('QR_CLAIMS_V2_ENABLED') ||
                const bool.fromEnvironment('REWARD_EARNING_V1_ENABLED') ||
                const bool.fromEnvironment('COUPON_CHECKOUT_V1_ENABLED')
            ? SupabasePurchaseEvidenceRepository(service.client)
            : null,
        credentials: SharedMerchantCredentials(
          AuthRepositoryImpl(supabaseService: service),
        ),
        notifications: NotificationRepositoryImpl(supabaseService: service),
        qr: QrSessionRepositoryImpl(
          supabaseService: service,
          claimsEnabled:
              const bool.fromEnvironment('QR_CLAIMS_V2_ENABLED') ||
              const bool.fromEnvironment('REWARD_EARNING_V1_ENABLED') ||
              const bool.fromEnvironment('COUPON_CHECKOUT_V1_ENABLED'),
          rewardEarningEnabled:
              const bool.fromEnvironment('REWARD_EARNING_V1_ENABLED') ||
              const bool.fromEnvironment('COUPON_CHECKOUT_V1_ENABLED'),
          couponCheckoutEnabled: const bool.fromEnvironment(
            'COUPON_CHECKOUT_V1_ENABLED',
          ),
        ),
        preferences: LocalNotificationPreferencesRepository(),
        sessionChanges: service.authStateChanges.map((s) => s.session?.user.id),
        currentUserId: () => service.currentUser?.id,
      ),
    ),
  );
}
