import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/auth_callback_contract.dart';
import 'package:t_store/core/supabase/supabase_config.dart';

enum PasswordRecoveryLaunchStatus { none, verified, invalid }

/// Supabase Service - Singleton class for Supabase operations
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;
  static AuthCallbackContract? _authCallbackContract;
  static StreamSubscription<Uri>? _authCallbackSubscription;
  static PasswordRecoveryLaunchStatus _initialPasswordRecoveryStatus =
      PasswordRecoveryLaunchStatus.none;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Initialize Supabase - Call this in main()
  static Future<void> initialize({required SupabaseConfig config}) async {
    await _authCallbackSubscription?.cancel();
    _authCallbackSubscription = null;
    _authCallbackContract = AuthCallbackContract.forEnvironment(
      config.environment,
    );
    _initialPasswordRecoveryStatus = PasswordRecoveryLaunchStatus.none;

    await Supabase.initialize(
      url: config.supabaseUrl,
      anonKey: config.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        // Supabase Flutter accepts any URI containing `code` by default. The
        // app-owned observer below validates exact environment scheme/host/path
        // before allowing PKCE exchange.
        detectSessionInUri: false,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
    _client = Supabase.instance.client;

    if (kIsWeb) {
      await _handleAuthCallbackUri(
        uri: Uri.base,
        appUri: Uri.base,
        isWeb: true,
      );
    } else {
      _authCallbackSubscription = AppLinks().uriLinkStream.listen(
        (uri) => unawaited(
          _handleAuthCallbackUri(uri: uri, appUri: Uri.base, isWeb: false),
        ),
        onError: (Object _, StackTrace stackTrace) {
          debugPrint('Auth callback could not be read safely.');
        },
      );
    }
  }

  static Future<void> _handleAuthCallbackUri({
    required Uri uri,
    required Uri appUri,
    required bool isWeb,
  }) async {
    final contract = _requiredAuthCallbackContract;
    final isRecovery = contract.isPasswordRecoveryLaunch(
      uri: uri,
      appUri: appUri,
      isWeb: isWeb,
    );

    try {
      AuthSessionUrlResponse? response;
      final exchanged = await exchangeValidatedPkceCallback(
        uri: uri,
        appUri: appUri,
        isWeb: isWeb,
        contract: contract,
        exchangeCode: (validatedUri) async {
          response = await _client!.auth.getSessionFromUrl(validatedUri);
        },
      );
      if (exchanged) {
        if (isRecovery) {
          _initialPasswordRecoveryStatus = response?.session != null
              ? PasswordRecoveryLaunchStatus.verified
              : PasswordRecoveryLaunchStatus.invalid;
        }
        return;
      }

      if (isRecovery) {
        _initialPasswordRecoveryStatus = await resolvePasswordRecoveryLaunch(
          uri: uri,
          appUri: appUri,
          isWeb: isWeb,
          contract: contract,
          verifyToken: (tokenHash) async {
            final verification = await _client!.auth.verifyOTP(
              tokenHash: tokenHash,
              type: OtpType.recovery,
            );
            return verification.session != null;
          },
        );
      }
    } on AuthException catch (error, stackTrace) {
      if (isRecovery) {
        _initialPasswordRecoveryStatus = PasswordRecoveryLaunchStatus.invalid;
      }
      // Keep the established Supabase Auth error channel without logging the
      // callback URI or its one-time code.
      // ignore: invalid_use_of_internal_member
      _client!.auth.notifyException(error, stackTrace);
    } catch (_) {
      if (isRecovery) {
        _initialPasswordRecoveryStatus = PasswordRecoveryLaunchStatus.invalid;
      }
    }
  }

  /// Get Supabase Client
  SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _client!;
  }

  static AuthCallbackContract get _requiredAuthCallbackContract {
    final contract = _authCallbackContract;
    if (contract == null) {
      throw StateError('Supabase Auth callback contract is not initialized.');
    }
    return contract;
  }

  /// Get current user
  User? get currentUser => client.auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Get current session
  Session? get currentSession => client.auth.currentSession;

  /// Result of validating a password recovery email at app startup.
  PasswordRecoveryLaunchStatus get initialPasswordRecoveryStatus =>
      _initialPasswordRecoveryStatus;

  /// Auth state changes stream
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  @visibleForTesting
  static Future<bool> exchangeValidatedPkceCallback({
    required Uri uri,
    required Uri appUri,
    required bool isWeb,
    required AuthCallbackContract contract,
    required Future<void> Function(Uri validatedUri) exchangeCode,
  }) async {
    if (!contract.acceptsPkceCallback(uri: uri, appUri: appUri, isWeb: isWeb)) {
      return false;
    }

    await exchangeCode(uri);
    return true;
  }

  @visibleForTesting
  static bool isPasswordRecoveryLaunchUri({
    required Uri uri,
    required Uri appUri,
    required bool isWeb,
    required AppEnvironment environment,
  }) {
    return AuthCallbackContract.forEnvironment(
      environment,
    ).isPasswordRecoveryLaunch(uri: uri, appUri: appUri, isWeb: isWeb);
  }

  @visibleForTesting
  static Future<PasswordRecoveryLaunchStatus> resolvePasswordRecoveryLaunch({
    required Uri uri,
    required Uri appUri,
    required bool isWeb,
    required AuthCallbackContract contract,
    required Future<bool> Function(String tokenHash) verifyToken,
    bool recoverySessionVerified = false,
  }) async {
    if (!contract.isPasswordRecoveryLaunch(
      uri: uri,
      appUri: appUri,
      isWeb: isWeb,
    )) {
      return PasswordRecoveryLaunchStatus.none;
    }

    // The default Supabase recovery template redirects through the Auth
    // endpoint. With PKCE, Supabase.initialize exchanges that callback before
    // this method runs. Preserve that verified result instead of requiring the
    // custom token_hash template path as well.
    if (recoverySessionVerified) {
      return PasswordRecoveryLaunchStatus.verified;
    }

    final tokenHash = uri.queryParameters['token_hash'];
    final type = uri.queryParameters['type'];
    if (tokenHash == null || tokenHash.trim().isEmpty || type != 'recovery') {
      return PasswordRecoveryLaunchStatus.invalid;
    }

    try {
      final verified = await verifyToken(tokenHash);
      return verified
          ? PasswordRecoveryLaunchStatus.verified
          : PasswordRecoveryLaunchStatus.invalid;
    } catch (_) {
      return PasswordRecoveryLaunchStatus.invalid;
    }
  }

  @visibleForTesting
  static String passwordRecoveryRedirectFor({
    required Uri appUri,
    required bool isWeb,
    required AppEnvironment environment,
  }) {
    return AuthCallbackContract.forEnvironment(environment).emailRedirectFor(
      appUri: appUri,
      isWeb: isWeb,
      action: AuthEmailRedirectAction.passwordRecovery,
    );
  }

  @visibleForTesting
  static String emailConfirmationRedirectFor({
    required Uri appUri,
    required bool isWeb,
    required AppEnvironment environment,
  }) {
    return AuthCallbackContract.forEnvironment(environment).emailRedirectFor(
      appUri: appUri,
      isWeb: isWeb,
      action: AuthEmailRedirectAction.confirmation,
    );
  }

  String get _emailConfirmationRedirect => emailConfirmationRedirectFor(
    appUri: Uri.base,
    isWeb: kIsWeb,
    environment: _requiredAuthCallbackContract.environment,
  );

  // ============== AUTH METHODS ==============

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
      emailRedirectTo: _emailConfirmationRedirect,
    );
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    return await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: _emailConfirmationRedirect,
    );
  }

  /// Sign in with Facebook
  Future<bool> signInWithFacebook() async {
    return await client.auth.signInWithOAuth(
      OAuthProvider.facebook,
      redirectTo: _emailConfirmationRedirect,
    );
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    return await client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: _emailConfirmationRedirect,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Permanently delete the signed-in customer and clear the local session.
  Future<void> deleteCurrentCustomerAccount() async {
    await client.rpc<void>('delete_current_customer_account');
    await client.auth.signOut(scope: SignOutScope.local);
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    final redirectTo = passwordRecoveryRedirectFor(
      appUri: Uri.base,
      isWeb: kIsWeb,
      environment: _requiredAuthCallbackContract.environment,
    );

    await client.auth.resetPasswordForEmail(email, redirectTo: redirectTo);
  }

  /// Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    return await client.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Update user data
  Future<UserResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.updateUser(
      UserAttributes(email: email, password: password, data: data),
    );
  }

  /// Resend confirmation email
  Future<ResendResponse> resendConfirmation(String email) async {
    return await client.auth.resend(
      type: OtpType.signup,
      email: email,
      emailRedirectTo: _emailConfirmationRedirect,
    );
  }

  // ============== DATABASE METHODS ==============

  /// Get data from table
  Future<List<Map<String, dynamic>>> getAll(
    String table, {
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    var query = client.from(table).select(select ?? '*');

    if (filters != null) {
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
    }

    // Chain the transformations
    dynamic result = query;

    if (orderBy != null) {
      result = result.order(orderBy, ascending: ascending);
    }

    if (limit != null) {
      result = result.limit(limit);
    }

    if (offset != null) {
      result = result.range(offset, offset + (limit ?? 10) - 1);
    }

    final response = await result;
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get single record by ID
  Future<Map<String, dynamic>?> getById(String table, String id) async {
    final response = await client
        .from(table)
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  /// Insert data
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    final response = await client.from(table).insert(data).select().single();
    return response;
  }

  /// Update data
  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await client
        .from(table)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  /// Upsert data (insert or update)
  Future<Map<String, dynamic>> upsert(
    String table,
    Map<String, dynamic> data,
  ) async {
    final response = await client.from(table).upsert(data).select().single();
    return response;
  }

  /// Delete data
  Future<void> delete(String table, String id) async {
    await client.from(table).delete().eq('id', id);
  }

  /// Delete with filter
  Future<void> deleteWhere(String table, Map<String, dynamic> filters) async {
    var query = client.from(table).delete();
    filters.forEach((key, value) {
      query = query.eq(key, value);
    });
    await query;
  }

  // ============== STORAGE METHODS ==============

  /// Upload file
  Future<String> uploadFile(
    String bucket,
    String path,
    List<int> fileBytes, {
    String? contentType,
  }) async {
    await client.storage
        .from(bucket)
        .uploadBinary(
          path,
          fileBytes as dynamic,
          fileOptions: FileOptions(contentType: contentType),
        );
    return client.storage.from(bucket).getPublicUrl(path);
  }

  /// Get public URL
  String getPublicUrl(String bucket, String path) {
    return client.storage.from(bucket).getPublicUrl(path);
  }

  /// Delete file
  Future<void> deleteFile(String bucket, String path) async {
    await client.storage.from(bucket).remove([path]);
  }

  // ============== REALTIME METHODS ==============

  /// Subscribe to table changes
  RealtimeChannel subscribeToTable(
    String table, {
    required void Function(PostgresChangePayload payload) onInsert,
    void Function(PostgresChangePayload payload)? onUpdate,
    void Function(PostgresChangePayload payload)? onDelete,
    Map<String, String>? filter,
  }) {
    final channel = client.channel('public:$table');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: table,
      filter: filter != null
          ? PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: filter.keys.first,
              value: filter.values.first,
            )
          : null,
      callback: onInsert,
    );

    if (onUpdate != null) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: table,
        callback: onUpdate,
      );
    }

    if (onDelete != null) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: table,
        callback: onDelete,
      );
    }

    channel.subscribe();
    return channel;
  }

  /// Unsubscribe from channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await client.removeChannel(channel);
  }
}
