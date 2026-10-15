import 'package:t_store/features/cart/domain/repositories/qr_session_repository.dart';
import 'package:t_store/features/merchant_promotions/domain/merchant_promotion.dart';
import 'package:t_store/features/commerce_ledger/domain/merchant_statement.dart';
import 'package:t_store/features/rewards/domain/reward_program.dart';
import 'package:t_store/features/trust_commerce/domain/trust_commerce.dart';
import 'package:t_store/features/reviews/domain/repositories/purchase_evaluation_repository.dart';
import 'package:t_store/features/purchases/domain/repositories/purchase_evidence_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_credentials.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_operations_repository.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/domain/push_coordinator.dart';
import 'package:t_store/features/notifications/domain/repositories/notification_repository.dart';

/// Explicit composition: no Customer locator registration or navigation.
class MerchantServices {
  const MerchantServices({
    required this.merchants,
    required this.credentials,
    required this.notifications,
    required this.qr,
    required this.preferences,
    required this.sessionChanges,
    required this.currentUserId,
    this.pushCoordinator,
    this.pushProvider = const UnconfiguredMobilePushProvider(),
    this.preview = false,
    this.catalogMedia,
    this.operations,
    this.purchaseEvidence,
    this.evaluations,
    this.trustCommerce,
    this.rewardProgram,
    this.statement,
    this.promotions,
  });
  final MerchantRepository merchants;
  final MerchantCredentials credentials;
  final NotificationRepository notifications;
  final QrSessionRepository qr;
  final NotificationPreferencesRepository preferences;
  final Stream<String?> sessionChanges;
  final String? Function() currentUserId;
  final MobilePushProvider pushProvider;
  final PushCoordinator? pushCoordinator;
  final bool preview;
  final CatalogMediaRepository? catalogMedia;
  final MerchantOperationsRepository? operations;
  final PurchaseEvidenceRepository? purchaseEvidence;
  final PurchaseEvaluationRepository? evaluations;
  final TrustCommerceRepository? trustCommerce;
  final RewardProgramRepository? rewardProgram;
  final MerchantStatementRepository? statement;
  final MerchantPromotionRepository? promotions;
}
