import 'package:t_store/features/cart/domain/repositories/qr_session_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_credentials.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
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
}
