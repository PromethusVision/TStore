import 'package:dartz/dartz.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/reviews/domain/entities/shop_rating_entity.dart';
import 'package:t_store/features/reviews/domain/repositories/shop_rating_repository.dart';

class ShopRatingRepositoryImpl implements ShopRatingRepository {
  final SupabaseService supabaseService;

  ShopRatingRepositoryImpl({required this.supabaseService});

  @override
  Future<Either<String, ShopRatingEntity>> submitVerifiedShopRating({
    required String qrSessionId,
    required int rating,
  }) async {
    try {
      if (supabaseService.currentUser == null) {
        return const Left('Puan vermek için giriş yapın.');
      }

      final normalizedSessionId = qrSessionId.trim();
      if (normalizedSessionId.isEmpty) {
        return const Left('Doğrulanmış alışveriş bulunamadı.');
      }

      if (rating < 1 || rating > 5) {
        return const Left('Lütfen 1 ile 5 arasında bir puan seçin.');
      }

      final response = await supabaseService.client.rpc(
        'submit_verified_shop_rating',
        params: {'p_qr_session_id': normalizedSessionId, 'p_rating': rating},
      );
      final json = _asJsonObject(response);
      if (json == null) {
        return const Left('Puanınız kaydedilemedi. Lütfen tekrar deneyin.');
      }

      return Right(
        ShopRatingEntity(
          id: _requiredString(json, 'rating_id'),
          shopId: _requiredString(json, 'shop_id'),
          rating: _toInt(json['rating']),
          averageRating: _toDouble(json['average_rating']),
          ratingCount: _toInt(json['rating_count']),
        ),
      );
    } catch (error) {
      return Left(_friendlyError(error));
    }
  }

  static Map<String, dynamic>? _asJsonObject(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    if (response is Map) return Map<String, dynamic>.from(response);
    if (response is List && response.length == 1) {
      final first = response.first;
      if (first is Map<String, dynamic>) return first;
      if (first is Map) return Map<String, dynamic>.from(first);
    }
    return null;
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null || value.toString().trim().isEmpty) {
      throw FormatException('$key alanı eksik.');
    }
    return value.toString();
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.parse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.parse(value.toString());
  }

  static String _friendlyError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('already rated') || message.contains('23505')) {
      return 'Bu alışveriş için daha önce puan verdiniz.';
    }
    if (message.contains('verified purchase not found') ||
        message.contains('p0002')) {
      return 'Puan vermek için doğrulanmış bir alışveriş gerekiyor.';
    }
    if (message.contains('rating must be between') ||
        message.contains('22023')) {
      return 'Lütfen 1 ile 5 arasında bir puan seçin.';
    }
    if (message.contains('authentication required') ||
        message.contains('not authenticated') ||
        message.contains('jwt')) {
      return 'Oturumunuz sona ermiş olabilir. Lütfen yeniden giriş yapın.';
    }
    if (message.contains('permission denied') ||
        message.contains('row-level security') ||
        message.contains('42501')) {
      return 'Bu işlem için yetkiniz yok.';
    }

    return 'Puanınız kaydedilemedi. Lütfen tekrar deneyin.';
  }
}
