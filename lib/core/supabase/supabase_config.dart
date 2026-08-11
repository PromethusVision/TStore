import 'dart:convert';

/// The backend environment selected by the application entrypoint.
enum AppEnvironment { development, production }

/// A safe startup failure caused by missing or invalid client configuration.
///
/// Configuration values are deliberately excluded from this error so secrets
/// or client credentials cannot be copied into logs by accident.
final class SupabaseConfigurationException implements Exception {
  const SupabaseConfigurationException(this.environment, this.message);

  final AppEnvironment environment;
  final String message;

  @override
  String toString() =>
      'Supabase configuration error (${environment.name}): $message';
}

/// Validated, client-safe Supabase configuration.
///
/// Only a project URL and an anonymous/publishable key belong in a Flutter
/// build. Service-role and secret keys are server-only and are rejected.
final class SupabaseConfig {
  SupabaseConfig._({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  static const developmentUrlDartDefine = 'SUPABASE_DEVELOPMENT_URL';
  static const developmentAnonKeyDartDefine = 'SUPABASE_DEVELOPMENT_ANON_KEY';
  static const productionUrlDartDefine = 'SUPABASE_PRODUCTION_URL';
  static const productionAnonKeyDartDefine = 'SUPABASE_PRODUCTION_ANON_KEY';

  final AppEnvironment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;

  /// Creates a configuration from values selected by an entrypoint.
  factory SupabaseConfig.forEnvironment({
    required AppEnvironment environment,
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) {
    return SupabaseConfig._(
      environment: environment,
      supabaseUrl: _validatedUrl(environment, supabaseUrl),
      supabaseAnonKey: _validatedAnonKey(environment, supabaseAnonKey),
    );
  }

  /// Resolves only the namespaced values for [environment].
  ///
  /// This keeps tests and build tooling explicit and, importantly, never falls
  /// back from development names to production names or vice versa.
  factory SupabaseConfig.fromEnvironmentValues(
    AppEnvironment environment,
    Map<String, String> values,
  ) {
    return SupabaseConfig.forEnvironment(
      environment: environment,
      supabaseUrl: values[urlDartDefineFor(environment)] ?? '',
      supabaseAnonKey: values[anonKeyDartDefineFor(environment)] ?? '',
    );
  }

  static String urlDartDefineFor(AppEnvironment environment) =>
      switch (environment) {
        AppEnvironment.development => developmentUrlDartDefine,
        AppEnvironment.production => productionUrlDartDefine,
      };

  static String anonKeyDartDefineFor(AppEnvironment environment) =>
      switch (environment) {
        AppEnvironment.development => developmentAnonKeyDartDefine,
        AppEnvironment.production => productionAnonKeyDartDefine,
      };

  static String _validatedUrl(AppEnvironment environment, String rawValue) {
    final value = rawValue.trim();
    final variableName = urlDartDefineFor(environment);
    if (value.isEmpty) {
      throw SupabaseConfigurationException(
        environment,
        '$variableName is required; no backend fallback was attempted.',
      );
    }
    if (_looksLikePlaceholder(value)) {
      throw SupabaseConfigurationException(
        environment,
        '$variableName still contains a placeholder.',
      );
    }

    final uri = Uri.tryParse(value);
    final hasRootPath = uri != null && (uri.path.isEmpty || uri.path == '/');
    if (uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        !hasRootPath) {
      throw SupabaseConfigurationException(
        environment,
        '$variableName must be an absolute Supabase project URL.',
      );
    }

    final isLoopback = _isLoopbackHost(uri.host);
    final isSecure = uri.scheme == 'https';
    final isLocalDevelopment =
        environment == AppEnvironment.development &&
        uri.scheme == 'http' &&
        isLoopback;
    if (!isSecure && !isLocalDevelopment) {
      throw SupabaseConfigurationException(
        environment,
        '$variableName must use HTTPS (HTTP is allowed only for local development).',
      );
    }
    if (environment == AppEnvironment.production && isLoopback) {
      throw SupabaseConfigurationException(
        environment,
        '$variableName cannot target a local backend in production.',
      );
    }

    return value;
  }

  static String _validatedAnonKey(AppEnvironment environment, String rawValue) {
    final value = rawValue.trim();
    final variableName = anonKeyDartDefineFor(environment);
    if (value.isEmpty) {
      throw SupabaseConfigurationException(
        environment,
        '$variableName is required; no credential fallback was attempted.',
      );
    }
    if (_looksLikePlaceholder(value)) {
      throw SupabaseConfigurationException(
        environment,
        '$variableName still contains a placeholder.',
      );
    }

    final lowerValue = value.toLowerCase();
    final jwtRole = _readJwtRole(value);
    final isPublishableKey = lowerValue.startsWith('sb_publishable_');
    final isLegacyAnonKey = jwtRole == 'anon';
    final isServerOnlyKey =
        lowerValue.startsWith('sb_secret_') ||
        lowerValue.contains('service_role') ||
        (jwtRole != null && jwtRole != 'anon');

    if (isServerOnlyKey) {
      throw SupabaseConfigurationException(
        environment,
        '$variableName must never contain a service-role or server-only key.',
      );
    }
    if (!isPublishableKey && !isLegacyAnonKey) {
      throw SupabaseConfigurationException(
        environment,
        '$variableName must be a Supabase anon or publishable key.',
      );
    }

    return value;
  }

  static bool _looksLikePlaceholder(String value) {
    final lowerValue = value.toLowerCase();
    return lowerValue.contains('placeholder') ||
        lowerValue.contains('replace_me') ||
        lowerValue.contains('your_') ||
        lowerValue.contains('your-') ||
        value.contains('<') ||
        value.contains('>');
  }

  static bool _isLoopbackHost(String host) {
    final normalizedHost = host.toLowerCase();
    return normalizedHost == 'localhost' ||
        normalizedHost == '127.0.0.1' ||
        normalizedHost == '::1';
  }

  static String? _readJwtRole(String value) {
    final parts = value.split('.');
    if (parts.length != 3) return null;

    try {
      final normalizedPayload = base64Url.normalize(parts[1]);
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(normalizedPayload)),
      );
      if (payload is Map<String, dynamic>) {
        final role = payload['role'];
        return role is String ? role : null;
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  // Storage bucket names
  static const String productImagesBucket = 'product-images';
  static const String categoryImagesBucket = 'category-images';
  static const String brandLogosBucket = 'brand-logos';
  static const String bannerImagesBucket = 'banner-images';
  static const String avatarsBucket = 'avatars';
  static const String reviewImagesBucket = 'review-images';
}
