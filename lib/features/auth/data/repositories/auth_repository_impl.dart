import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/features/auth/data/models/user_model.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseService supabaseService;

  AuthRepositoryImpl({required this.supabaseService});

  @override
  Future<Either<String, UserEntity?>> getCurrentUser() async {
    try {
      final user = supabaseService.currentUser;
      if (user == null) {
        return const Right(null);
      }

      // Get profile data
      final profileData = await supabaseService.client
          .from(SupabaseTables.profiles)
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profileData != null) {
        return Right(UserModel.fromJson(profileData));
      }

      // Return basic user info if no profile exists
      return Right(
        UserEntity(
          id: user.id,
          email: user.email ?? '',
          fullName: user.userMetadata?['full_name'] as String?,
        ),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return const Left('Giriş yapılamadı. Lütfen tekrar deneyin.');
      }

      // Get profile
      final profileData = await supabaseService.client
          .from(SupabaseTables.profiles)
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (profileData != null) {
        return Right(UserModel.fromJson(profileData));
      }

      return Right(
        UserEntity(id: response.user!.id, email: response.user!.email ?? email),
      );
    } on AuthException catch (e) {
      return Left(
        _getAuthErrorMessage(
          e.message,
          fallbackMessage: 'Giriş yapılamadı. Lütfen tekrar deneyin.',
        ),
      );
    } catch (e) {
      return Left(_getSignInErrorMessage(e));
    }
  }

  @override
  Future<Either<String, UserEntity>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String privacyNoticeVersion,
    required String termsOfUseVersion,
    String? phone,
  }) async {
    try {
      final response = await supabaseService.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'privacy_notice_acknowledged': true,
          'privacy_notice_version': privacyNoticeVersion,
          'terms_of_use_accepted': true,
          'terms_of_use_version': termsOfUseVersion,
        },
      );

      if (response.user == null) {
        return const Left('Hesap oluşturulamadı. Lütfen tekrar deneyin.');
      }

      return Right(
        UserEntity(
          id: response.user!.id,
          email: email,
          fullName: fullName,
          phone: phone,
        ),
      );
    } on AuthException catch (e) {
      return Left(_getAuthErrorMessage(e.message));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> signInWithGoogle() async {
    try {
      final success = await supabaseService.signInWithGoogle();
      return Right(success);
    } on AuthException catch (e) {
      return Left(_getAuthErrorMessage(e.message));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> signInWithFacebook() async {
    try {
      final success = await supabaseService.signInWithFacebook();
      return Right(success);
    } on AuthException catch (e) {
      return Left(_getAuthErrorMessage(e.message));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> signInWithApple() async {
    try {
      final success = await supabaseService.signInWithApple();
      return Right(success);
    } on AuthException catch (e) {
      return Left(_getAuthErrorMessage(e.message));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> signOut() async {
    try {
      await supabaseService.signOut();
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteCurrentCustomerAccount() async {
    try {
      await supabaseService.deleteCurrentCustomerAccount();
      return const Right(null);
    } on PostgrestException catch (e) {
      final message = e.message.toLowerCase();

      if (e.code == '42501' ||
          message.contains('only customer accounts can be deleted')) {
        return const Left(
          'Bu hesap müşteri uygulamasından silinemez. '
          'Lütfen destek ekibiyle iletişime geçin.',
        );
      }
      if (e.code == '28000' ||
          message.contains('authentication required') ||
          message.contains('jwt')) {
        return const Left(
          'Oturumunuz sona erdi. Lütfen yeniden giriş yapıp tekrar deneyin.',
        );
      }
      if (_isConnectionError(message)) {
        return const Left('İnternet bağlantınızı kontrol edip tekrar deneyin.');
      }

      return const Left(
        'Hesabınız silinemedi. Lütfen daha sonra tekrar deneyin.',
      );
    } catch (e) {
      final message = e.toString().toLowerCase();
      if (_isConnectionError(message)) {
        return const Left('İnternet bağlantınızı kontrol edip tekrar deneyin.');
      }
      return const Left(
        'Hesabınız silinemedi. Lütfen daha sonra tekrar deneyin.',
      );
    }
  }

  @override
  Future<Either<String, void>> resetPassword(String email) async {
    try {
      await supabaseService.resetPassword(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(_getAuthErrorMessage(e.message));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updatePassword(String newPassword) async {
    try {
      await supabaseService.updatePassword(newPassword);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(_getAuthErrorMessage(e.message));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> resendConfirmation(String email) async {
    try {
      await supabaseService.resendConfirmation(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(_getAuthErrorMessage(e.message));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  bool get isLoggedIn => supabaseService.isLoggedIn;

  @override
  Stream<UserEntity?> get authStateChanges {
    return supabaseService.authStateChanges.asyncMap((state) async {
      if (state.session?.user == null) {
        return null;
      }

      final user = state.session!.user;

      // Get profile
      final profileData = await supabaseService.client
          .from(SupabaseTables.profiles)
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profileData != null) {
        return UserModel.fromJson(profileData);
      }

      return UserEntity(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] as String?,
      );
    });
  }

  String _getSignInErrorMessage(Object error) {
    final lowerMessage = error.toString().toLowerCase();

    if (_isConnectionError(lowerMessage)) {
      return 'İnternet bağlantınızı kontrol edip tekrar deneyin.';
    }
    if (_isServiceUnavailableError(lowerMessage)) {
      return 'Giriş hizmeti şu anda yanıt vermiyor. '
          'Lütfen kısa süre sonra tekrar deneyin.';
    }

    return 'Giriş yapılamadı. Lütfen tekrar deneyin.';
  }

  String _getAuthErrorMessage(
    String message, {
    String fallbackMessage = 'İşlem tamamlanamadı. Lütfen tekrar deneyin.',
  }) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('rate limit')) {
      return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
    }
    if (_isConnectionError(lowerMessage)) {
      return 'İnternet bağlantınızı kontrol edip tekrar deneyin.';
    }
    if (_isServiceUnavailableError(lowerMessage)) {
      return 'Giriş hizmeti şu anda yanıt vermiyor. '
          'Lütfen kısa süre sonra tekrar deneyin.';
    }
    if (lowerMessage.contains('session missing') ||
        lowerMessage.contains('not authenticated') ||
        lowerMessage.contains('jwt expired') ||
        lowerMessage.contains('invalid token')) {
      return 'Şifre yenileme bağlantısı geçersiz veya süresi dolmuş. '
          'Lütfen yeni bir bağlantı isteyin.';
    }
    if (lowerMessage.contains('same password')) {
      return 'Yeni şifreniz önceki şifrenizden farklı olmalıdır.';
    }
    if (lowerMessage.contains('invalid login credentials')) {
      return 'E-posta veya şifre hatalı.';
    }
    if (lowerMessage.contains('email not confirmed')) {
      return 'E-posta adresinizi doğrulamanız gerekiyor.';
    }
    if (lowerMessage.contains('user already registered')) {
      return 'Bu e-posta adresiyle daha önce hesap oluşturulmuş.';
    }
    if (lowerMessage.contains('password')) {
      return 'Şifre güvenlik şartlarını karşılamıyor.';
    }
    if (lowerMessage.contains('email')) {
      return 'Geçerli bir e-posta adresi girin.';
    }

    return fallbackMessage;
  }

  bool _isConnectionError(String lowerMessage) {
    return lowerMessage.contains('network') ||
        lowerMessage.contains('socketexception') ||
        lowerMessage.contains('failed host lookup') ||
        lowerMessage.contains('failed to fetch') ||
        lowerMessage.contains('xmlhttprequest') ||
        lowerMessage.contains('clientexception') ||
        lowerMessage.contains('connection reset') ||
        lowerMessage.contains('connection refused') ||
        lowerMessage.contains('timed out') ||
        lowerMessage.contains('timeout');
  }

  bool _isServiceUnavailableError(String lowerMessage) {
    return lowerMessage.contains('service unavailable') ||
        lowerMessage.contains('temporarily unavailable') ||
        lowerMessage.contains('internal server error') ||
        lowerMessage.contains('bad gateway');
  }
}
