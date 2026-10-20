import 'package:flutter/foundation.dart';
import '../../../core/supabase/authenticated_session_key.dart';
import '../../../core/supabase/supabase_service.dart';
import '../../auth/data/repositories/auth_repository_impl.dart';
import '../../cart/data/repositories/qr_session_repository_impl.dart';
import '../../commerce_ledger/data/supabase_commerce_ledger_repository.dart';
import '../../merchant_promotions/data/supabase_merchant_promotion_repository.dart';
import '../../notifications/data/repositories/notification_preferences_repository.dart';
import '../../notifications/data/repositories/notification_repository_impl.dart';
import '../../notifications/data/repositories/push_backend_adapter.dart';
import '../../notifications/data/repositories/push_installation_store.dart';
import '../../notifications/domain/push_contract.dart';
import '../../notifications/domain/push_coordinator.dart';
import '../../purchases/data/repositories/supabase_purchase_evidence_repository.dart';
import '../../reviews/data/repositories/supabase_purchase_evaluation_repository.dart';
import '../../rewards/data/supabase_reward_program_repository.dart';
import '../../trust_commerce/data/supabase_trust_commerce_repository.dart';
import '../data/supabase_catalog_media_repository.dart';
import '../data/supabase_merchant_operations_repository.dart';
import '../data/supabase_merchant_repository.dart';
import '../domain/merchant_account_recovery.dart';
import '../domain/merchant_credentials.dart';
import '../domain/merchant_session_identity.dart';
import '../merchant_services.dart';

/// Shared composition, isolated from Customer's locator. Defaults do not activate
/// downstream business capabilities or configure a notification provider.
MerchantServices createMerchantServices(
  SupabaseService service, {
  MerchantAccountRecovery? recovery,
  bool qrClaims = false,
  bool rewardEarning = false,
  bool couponCheckout = false,
  bool statement = false,
  bool trust = false,
  bool reviews = false,
  bool promotions = false,
  bool pushSchema = false,
}) {
  final client = service.client;
  final claims = qrClaims || rewardEarning || couponCheckout;
  final rewards = rewardEarning || couponCheckout;
  final pushBackend = SupabasePushBackend(client, deployed: pushSchema);
  const pushProvider = UnconfiguredMobilePushProvider();
  return MerchantServices(
    merchants: SupabaseMerchantRepository(client: client),
    catalogMedia: SupabaseCatalogMediaRepository(client),
    operations: SupabaseMerchantOperationsRepository(client),
    promotions: promotions ? SupabaseMerchantPromotionRepository(client) : null,
    statement: statement ? SupabaseCommerceLedgerRepository(client) : null,
    rewardProgram: rewards ? SupabaseRewardProgramRepository(client) : null,
    trustCommerce: trust ? SupabaseTrustCommerceRepository(client) : null,
    evaluations: reviews ? SupabasePurchaseEvaluationRepository(client) : null,
    purchaseEvidence: claims
        ? SupabasePurchaseEvidenceRepository(client)
        : null,
    credentials: SharedMerchantCredentials(
      AuthRepositoryImpl(supabaseService: service),
    ),
    recovery: recovery,
    notifications: NotificationRepositoryImpl(supabaseService: service),
    qr: QrSessionRepositoryImpl(
      supabaseService: service,
      claimsEnabled: claims,
      rewardEarningEnabled: rewards,
      couponCheckoutEnabled: couponCheckout,
    ),
    preferences: pushBackend.deployed
        ? pushBackend
        : LocalNotificationPreferencesRepository(),
    pushFactory: (onOpen) => PushCoordinator(
      provider: pushProvider,
      registry: pushBackend,
      currentIdentity: () => service.currentUser == null
          ? null
          : PushIdentity(service.currentUser!.id, NotificationAppRole.merchant),
      currentSessionKey: () => authenticatedSessionKey(client),
      lookup: pushBackend.lookup,
      onOpen: onOpen,
      installationId: 'not-loaded',
      installations: LocalPushInstallationStore(NotificationAppRole.merchant),
      platform: defaultTargetPlatform == TargetPlatform.iOS
          ? PushPlatform.ios
          : PushPlatform.android,
    ),
    sessionChanges: service.authStateChanges.map((s) => s.session?.user.id),
    currentUserId: () => service.currentUser?.id,
    currentSessionKey: () => authenticatedSessionKey(client),
    sessionIdentities: service.authStateChanges.map(
      (event) => MerchantSessionIdentity(
        userId: event.session?.user.id,
        sessionKey: authenticatedSessionKeyFromSession(event.session),
      ),
    ),
  );
}
