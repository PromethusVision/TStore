import 'package:flutter/material.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:t_store/features/cart/data/repositories/qr_session_repository_impl.dart';
import 'package:t_store/features/merchant/data/supabase_merchant_repository.dart';
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
        credentials: SharedMerchantCredentials(
          AuthRepositoryImpl(supabaseService: service),
        ),
        notifications: NotificationRepositoryImpl(supabaseService: service),
        qr: QrSessionRepositoryImpl(supabaseService: service),
        preferences: LocalNotificationPreferencesRepository(),
        sessionChanges: service.authStateChanges.map((s) => s.session?.user.id),
        currentUserId: () => service.currentUser?.id,
      ),
    ),
  );
}
