import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show appFlavor;
import 'package:shared_preferences/shared_preferences.dart';
import 'core/supabase/auth_callback_contract.dart';
import 'core/supabase/supabase_service.dart';
import 'core/ui/foundation/esnaftavar_theme.dart';
import 'features/merchant/data/supabase_merchant_recovery_backend.dart';
import 'features/merchant/domain/merchant_account_recovery.dart';
import 'features/merchant/merchant_app.dart';
import 'features/merchant/runtime/merchant_pilot_config.dart';
import 'features/merchant/runtime/merchant_runtime.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MerchantAccountRecovery? recovery;
  StreamSubscription<Uri>? links;
  try {
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android ||
        appFlavor != MerchantPilotConfig.flavor) {
      throw StateError('This pilot preparation targets Android only.');
    }
    final config = MerchantPilotConfig.fromValues(const {
      'MERCHANT_PILOT_ENABLED': String.fromEnvironment(
        'MERCHANT_PILOT_ENABLED',
      ),
      'MERCHANT_PILOT_URL': String.fromEnvironment('MERCHANT_PILOT_URL'),
      'MERCHANT_PILOT_ANON_KEY': String.fromEnvironment(
        'MERCHANT_PILOT_ANON_KEY',
      ),
      'QR_CLAIMS_V2_ENABLED': String.fromEnvironment(
        'QR_CLAIMS_V2_ENABLED',
        defaultValue: 'false',
      ),
      'REWARD_EARNING_V1_ENABLED': String.fromEnvironment(
        'REWARD_EARNING_V1_ENABLED',
        defaultValue: 'false',
      ),
      'COUPON_CHECKOUT_V1_ENABLED': String.fromEnvironment(
        'COUPON_CHECKOUT_V1_ENABLED',
        defaultValue: 'false',
      ),
      'TRUST_COMMERCE_V1_ENABLED': String.fromEnvironment(
        'TRUST_COMMERCE_V1_ENABLED',
        defaultValue: 'false',
      ),
      'REVIEWS_V2_ENABLED': String.fromEnvironment(
        'REVIEWS_V2_ENABLED',
        defaultValue: 'false',
      ),
      'MERCHANT_STATEMENT_V1_ENABLED': String.fromEnvironment(
        'MERCHANT_STATEMENT_V1_ENABLED',
        defaultValue: 'false',
      ),
      'MERCHANT_PROMOTION_V1_ENABLED': String.fromEnvironment(
        'MERCHANT_PROMOTION_V1_ENABLED',
        defaultValue: 'false',
      ),
      'MERCHANT_PUSH_SCHEMA_LOCAL_ENABLED': String.fromEnvironment(
        'MERCHANT_PUSH_SCHEMA_LOCAL_ENABLED',
        defaultValue: 'false',
      ),
    });
    final contract = AuthCallbackContract.merchantPilot();
    await SupabaseService.initialize(
      config: config.backend,
      callbackContract: contract,
      observeAuthCallbacks: false,
    );
    final service = SupabaseService.instance;
    final backend = SupabaseMerchantRecoveryBackend(
      service.client,
      contract,
      await SharedPreferences.getInstance(),
    );
    final controller = MerchantAccountRecovery(
      backend: backend,
      contract: contract,
    );
    recovery = controller;
    if (backend.hasPending) controller.restorePending();
    final appLinks = AppLinks();
    links = appLinks.uriLinkStream.listen(
      (uri) => unawaited(controller.receive(uri)),
      onError: (Object _) => controller.restorePending(),
    );
    final initial = await appLinks.getInitialLink();
    if (initial != null) unawaited(controller.receive(initial));
    runApp(
      MerchantApp(
        services: createMerchantServices(service, recovery: controller),
      ),
    );
  } catch (_) {
    await links?.cancel();
    recovery?.dispose();
    // Never render raw configuration, callback, Auth or transport errors.
    runApp(const MerchantPilotSetupRequired());
  }
}

class MerchantPilotSetupRequired extends StatelessWidget {
  const MerchantPilotSetupRequired({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: EsnaftaVarTheme.light,
    home: Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storefront_outlined, size: 56),
                const SizedBox(height: 24),
                Text(
                  'Pilot kurulumu gerekli',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bu sürüm kullanıma hazır değil. Pilot ekibinden güncel kurulum paketini isteyin.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
