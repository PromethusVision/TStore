import 'package:t_store/core/supabase/supabase_config.dart';

enum AuthEmailRedirectAction { confirmation, passwordRecovery }

/// Environment-owned Auth redirect and inbound callback contract.
///
/// Production and Development deliberately have separate mobile schemes. The
/// selected environment never falls back to the other environment's callback.
final class AuthCallbackContract {
  const AuthCallbackContract._(this.environment, this.mobileCallbackUri);

  static const productionMobileCallback =
      'com.esnaftavar.app://login-callback/';
  static const developmentMobileCallback =
      'io.supabase.tstore://login-callback/';
  static const callbackHost = 'login-callback';
  static const authActionQueryParameter = 'auth_action';
  static const passwordRecoveryAction = 'password_recovery';

  final AppEnvironment environment;
  final Uri mobileCallbackUri;

  factory AuthCallbackContract.forEnvironment(AppEnvironment environment) {
    return switch (environment) {
      AppEnvironment.production => AuthCallbackContract._(
        environment,
        Uri.parse(productionMobileCallback),
      ),
      AppEnvironment.development => AuthCallbackContract._(
        environment,
        Uri.parse(developmentMobileCallback),
      ),
    };
  }

  String emailRedirectFor({
    required Uri appUri,
    required bool isWeb,
    required AuthEmailRedirectAction action,
  }) {
    final baseUri = callbackBaseFor(appUri: appUri, isWeb: isWeb);
    if (action == AuthEmailRedirectAction.confirmation) {
      return baseUri.toString();
    }

    return baseUri
        .replace(
          queryParameters: const {
            authActionQueryParameter: passwordRecoveryAction,
          },
        )
        .toString();
  }

  Uri callbackBaseFor({required Uri appUri, required bool isWeb}) {
    if (!isWeb) return mobileCallbackUri;

    if ((appUri.scheme != 'http' && appUri.scheme != 'https') ||
        appUri.host.isEmpty) {
      throw StateError('Web Auth callback requires an HTTP(S) app origin.');
    }

    return Uri(
      scheme: appUri.scheme,
      host: appUri.host,
      port: appUri.hasPort ? appUri.port : null,
      path: '/',
    );
  }

  bool acceptsCallbackBase({
    required Uri uri,
    required Uri appUri,
    required bool isWeb,
  }) {
    if (uri.userInfo.isNotEmpty || uri.hasFragment || uri.path != '/') {
      return false;
    }

    if (isWeb) {
      final expected = callbackBaseFor(appUri: appUri, isWeb: true);
      return uri.scheme == expected.scheme &&
          uri.host.toLowerCase() == expected.host.toLowerCase() &&
          uri.hasPort == expected.hasPort &&
          (!uri.hasPort || uri.port == expected.port);
    }

    return uri.scheme == mobileCallbackUri.scheme &&
        uri.host.toLowerCase() == mobileCallbackUri.host.toLowerCase() &&
        !uri.hasPort;
  }

  bool acceptsPkceCallback({
    required Uri uri,
    required Uri appUri,
    required bool isWeb,
  }) {
    final code = uri.queryParameters['code'];
    return acceptsCallbackBase(uri: uri, appUri: appUri, isWeb: isWeb) &&
        code != null &&
        code.trim().isNotEmpty;
  }

  bool isPasswordRecoveryLaunch({
    required Uri uri,
    required Uri appUri,
    required bool isWeb,
  }) {
    return acceptsCallbackBase(uri: uri, appUri: appUri, isWeb: isWeb) &&
        uri.queryParameters[authActionQueryParameter] == passwordRecoveryAction;
  }
}
