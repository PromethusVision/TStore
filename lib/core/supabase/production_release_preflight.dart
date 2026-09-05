import 'package:t_store/core/supabase/auth_callback_contract.dart';
import 'package:t_store/core/supabase/supabase_config.dart';

enum ProductionReleasePreflightMode { release, compileContract }

/// A safe preflight failure that never includes configuration values.
final class ProductionReleasePreflightException implements Exception {
  const ProductionReleasePreflightException(this.message);

  final String message;

  @override
  String toString() => 'Production release preflight error: $message';
}

/// Validates the release manifest before a Production entrypoint build.
///
/// The manifest deliberately contains only client-safe build values and the
/// non-secret Auth redirect decisions that an operator must verify remotely.
/// It never connects to Supabase and never logs supplied values.
final class ProductionReleasePreflight {
  const ProductionReleasePreflight._();

  static const productionEntrypoint = 'lib/main_production.dart';
  static const productionProjectRefField = 'PRODUCTION_PROJECT_REF';
  static const authSiteUrlField = 'PRODUCTION_AUTH_SITE_URL';
  static const authWebRedirectUrlField = 'PRODUCTION_AUTH_WEB_REDIRECT_URL';
  static const authMobileCallbackUrlField =
      'PRODUCTION_AUTH_MOBILE_CALLBACK_URL';

  static const canonicalMobileCallback =
      AuthCallbackContract.productionMobileCallback;
  static const passwordRecoveryAction = 'password_recovery';

  static const compileContractProjectRef = 'w9compilecontract001';
  static const compileContractSupabaseUrl =
      'https://w9compilecontract001.supabase.co';
  static const compileContractPublishableKey =
      'sb_publishable_w9_compile_contract_public_client';
  static const compileContractSiteUrl = 'https://w9-compile-contract.invalid/';
  static const compileContractWebRedirectUrl =
      'https://w9-compile-contract.invalid/'
      '?auth_action=password_recovery';

  static const requiredFields = <String>{
    SupabaseConfig.productionUrlDartDefine,
    SupabaseConfig.productionAnonKeyDartDefine,
    productionProjectRefField,
    authSiteUrlField,
    authWebRedirectUrlField,
    authMobileCallbackUrlField,
  };

  static void validate({
    required ProductionReleasePreflightMode mode,
    required Map<String, String> values,
    required String target,
  }) {
    if (_normalizedTarget(target) != productionEntrypoint) {
      throw const ProductionReleasePreflightException(
        'the build target must be lib/main_production.dart.',
      );
    }

    final suppliedFields = values.keys.toSet();
    final missingFields = requiredFields.difference(suppliedFields).toList()
      ..sort();
    if (missingFields.isNotEmpty) {
      throw ProductionReleasePreflightException(
        'required manifest fields are missing: ${missingFields.join(', ')}.',
      );
    }

    final unexpectedFields = suppliedFields.difference(requiredFields).toList()
      ..sort();
    if (unexpectedFields.isNotEmpty) {
      throw ProductionReleasePreflightException(
        'unexpected manifest fields are not allowed: '
        '${unexpectedFields.join(', ')}.',
      );
    }

    final config = SupabaseConfig.fromEnvironmentValues(
      AppEnvironment.production,
      values,
    );
    final projectRef = _requiredValue(values, productionProjectRefField);
    if (!RegExp(r'^[a-z0-9]{20}$').hasMatch(projectRef)) {
      throw const ProductionReleasePreflightException(
        'PRODUCTION_PROJECT_REF must be a 20-character Supabase project ref.',
      );
    }
    if (projectRef == SupabaseConfig.developmentProjectRef) {
      throw const ProductionReleasePreflightException(
        'PRODUCTION_PROJECT_REF cannot identify the Development project.',
      );
    }

    final projectUri = Uri.parse(config.supabaseUrl);
    if (projectUri.host.toLowerCase() != '$projectRef.supabase.co') {
      throw const ProductionReleasePreflightException(
        'SUPABASE_PRODUCTION_URL must match PRODUCTION_PROJECT_REF.',
      );
    }

    _validateModeFixture(
      mode: mode,
      values: values,
      projectRef: projectRef,
      config: config,
    );

    if (_requiredValue(values, authMobileCallbackUrlField) !=
        canonicalMobileCallback) {
      throw const ProductionReleasePreflightException(
        'PRODUCTION_AUTH_MOBILE_CALLBACK_URL must match the app callback.',
      );
    }

    final siteUrl = _requiredValue(values, authSiteUrlField);
    // The owner-final Android pilot uses the exact mobile callback as Site URL.
    // A mobile-only release must not invent a hosted web recovery destination.
    // Keep the web field present and explicitly empty to make that scope clear.
    if (mode == ProductionReleasePreflightMode.release &&
        siteUrl == canonicalMobileCallback) {
      if (values[authWebRedirectUrlField]!.trim().isNotEmpty) {
        throw const ProductionReleasePreflightException(
          'a mobile-only Site URL requires an empty '
          'PRODUCTION_AUTH_WEB_REDIRECT_URL.',
        );
      }
      return;
    }

    final siteUri = _validatedSiteUri(siteUrl, mode);
    _validateWebRedirect(
      rawValue: _requiredValue(values, authWebRedirectUrlField),
      siteUri: siteUri,
      mode: mode,
    );
  }

  static String expectedWebRecoveryRedirect(String siteUrl) {
    final siteUri = Uri.parse(siteUrl);
    return Uri(
      scheme: siteUri.scheme,
      host: siteUri.host,
      port: siteUri.hasPort ? siteUri.port : null,
      path: '/',
      queryParameters: const {'auth_action': passwordRecoveryAction},
    ).toString();
  }

  static String _requiredValue(Map<String, String> values, String field) {
    final value = values[field]?.trim() ?? '';
    if (value.isEmpty) {
      throw ProductionReleasePreflightException('$field is required.');
    }
    return value;
  }

  static Uri _validatedSiteUri(
    String rawValue,
    ProductionReleasePreflightMode mode,
  ) {
    final uri = Uri.tryParse(rawValue);
    final isRoot = uri != null && (uri.path.isEmpty || uri.path == '/');
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        !isRoot) {
      throw const ProductionReleasePreflightException(
        'PRODUCTION_AUTH_SITE_URL must be an HTTPS origin root.',
      );
    }
    if (_isLoopback(uri.host) ||
        uri.host.toLowerCase().contains(SupabaseConfig.developmentProjectRef)) {
      throw const ProductionReleasePreflightException(
        'PRODUCTION_AUTH_SITE_URL cannot target Development or localhost.',
      );
    }
    if (mode == ProductionReleasePreflightMode.release &&
        _looksNonProduction(uri.host)) {
      throw const ProductionReleasePreflightException(
        'PRODUCTION_AUTH_SITE_URL contains a non-production host.',
      );
    }
    return uri;
  }

  static void _validateWebRedirect({
    required String rawValue,
    required Uri siteUri,
    required ProductionReleasePreflightMode mode,
  }) {
    final uri = Uri.tryParse(rawValue);
    final hasOnlyRecoveryQuery =
        uri != null &&
        uri.queryParameters.length == 1 &&
        uri.queryParameters['auth_action'] == passwordRecoveryAction;
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.path != '/' ||
        uri.hasFragment ||
        !hasOnlyRecoveryQuery ||
        uri.origin != siteUri.origin) {
      throw const ProductionReleasePreflightException(
        'PRODUCTION_AUTH_WEB_REDIRECT_URL must be the exact web recovery '
        'redirect on PRODUCTION_AUTH_SITE_URL.',
      );
    }
    if (mode == ProductionReleasePreflightMode.release &&
        _looksNonProduction(uri.host)) {
      throw const ProductionReleasePreflightException(
        'PRODUCTION_AUTH_WEB_REDIRECT_URL contains a non-production host.',
      );
    }
  }

  static void _validateModeFixture({
    required ProductionReleasePreflightMode mode,
    required Map<String, String> values,
    required String projectRef,
    required SupabaseConfig config,
  }) {
    final isCompileContractFixture =
        projectRef == compileContractProjectRef &&
        config.supabaseUrl == compileContractSupabaseUrl &&
        config.supabaseAnonKey == compileContractPublishableKey &&
        values[authSiteUrlField]?.trim() == compileContractSiteUrl &&
        values[authWebRedirectUrlField]?.trim() ==
            compileContractWebRedirectUrl;
    final containsCompileContractMarker =
        projectRef == compileContractProjectRef ||
        config.supabaseUrl.contains('compilecontract') ||
        config.supabaseAnonKey.contains('compile_contract') ||
        values.values.any(
          (value) => value.toLowerCase().contains('compile-contract'),
        );

    if (mode == ProductionReleasePreflightMode.compileContract &&
        !isCompileContractFixture) {
      throw const ProductionReleasePreflightException(
        'compile-contract mode requires the canonical synthetic fixture.',
      );
    }
    if (mode == ProductionReleasePreflightMode.release &&
        containsCompileContractMarker) {
      throw const ProductionReleasePreflightException(
        'the compile-contract fixture is not deployable release config.',
      );
    }
  }

  static String _normalizedTarget(String target) {
    var normalized = target.trim().replaceAll('\\', '/');
    while (normalized.startsWith('./')) {
      normalized = normalized.substring(2);
    }
    return normalized;
  }

  static bool _isLoopback(String host) {
    final normalized = host.toLowerCase();
    return normalized == 'localhost' ||
        normalized.startsWith('127.') ||
        normalized == '0.0.0.0' ||
        normalized == '::1';
  }

  static bool _looksNonProduction(String host) {
    final normalized = host.toLowerCase();
    return normalized.endsWith('.invalid') ||
        normalized.endsWith('.example') ||
        normalized.endsWith('.test') ||
        normalized.contains('example') ||
        normalized.contains('dummy') ||
        normalized.contains('placeholder') ||
        normalized.contains('replace_me') ||
        normalized.contains('replace-me') ||
        normalized.contains('changeme') ||
        normalized.contains('your_') ||
        normalized.contains('your-');
  }
}
