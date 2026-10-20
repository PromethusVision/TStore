import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';
import 'package:t_store/core/supabase/authenticated_session_key.dart';
import 'package:t_store/features/reviews/data/models/review_model.dart';
import 'package:t_store/features/reviews/domain/entities/purchase_evaluation.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';
import 'package:t_store/features/reviews/domain/repositories/purchase_evaluation_repository.dart';

typedef EvaluationRpc =
    Future<dynamic> Function(String name, Map<String, dynamic> parameters);

class SupabasePurchaseEvaluationRepository
    implements PurchaseEvaluationRepository {
  SupabasePurchaseEvaluationRepository(
    SupabaseClient client, {
    EvaluationRpc? rpc,
    String? Function()? currentUserId,
    String? Function()? currentSessionKey,
    Stream<String?>? sessionChanges,
    Stream<String?>? sessionKeyChanges,
    this.requestTimeout = const Duration(seconds: 20),
  }) : _rpc =
           rpc ?? ((name, parameters) => client.rpc(name, params: parameters)),
       sessionChanges =
           sessionChanges ??
           client.auth.onAuthStateChange.map((event) => event.session?.user.id),
       sessionKeyChanges =
           sessionKeyChanges ??
           client.auth.onAuthStateChange.map(
             (event) => authenticatedSessionKeyFromSession(event.session),
           ),
       _currentSessionKey =
           currentSessionKey ?? (() => authenticatedSessionKey(client)),
       _currentUserId = currentUserId ?? (() => client.auth.currentUser?.id);
  final EvaluationRpc _rpc;
  final String? Function() _currentUserId;
  final String? Function() _currentSessionKey;
  final Duration requestTimeout;
  @override
  String? get currentSessionKey => _currentSessionKey();
  @override
  final Stream<String?> sessionKeyChanges;
  @override
  String? get currentUserId => _currentUserId();
  @override
  final Stream<String?> sessionChanges;
  static final _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );
  static const _auth = ReviewFailure(
    ReviewFailureKind.authRequired,
    'Oturumunuz değişti. Lütfen yeniden giriş yapın.',
  );
  static const _invalid = ReviewFailure(
    ReviewFailureKind.invalidArgument,
    'Değerlendirme bilgilerini kontrol edin.',
  );

  Future<Either<ReviewFailure, T>> _call<T>(
    String name,
    Map<String, dynamic> parameters,
    T Function(Map<String, dynamic>) decode, {
    bool valid = true,
  }) async {
    if (!valid) return const Left(_invalid);
    final scope = AuthenticatedRequestScope(
      user: currentUserId,
      session: currentSessionKey,
      currentUser: () => currentUserId,
      currentSession: () => currentSessionKey,
      changes: sessionChanges,
      sessionKeys: sessionKeyChanges,
    );
    try {
      final value = await scope.run(() async {
        final response = await _rpc(name, parameters).timeout(requestTimeout);
        scope.check();
        return decode(_object(response));
      });
      return Right(value);
    } catch (error) {
      if (!scope.current) return const Left(_auth);
      return Left(evaluationFailure(error));
    } finally {
      await scope.close();
    }
  }

  @override
  Future<Either<ReviewFailure, bool>> enabled() =>
      _call('review_capabilities_v2', {}, (j) {
        if (j['version'] != 2) throw const FormatException();
        return _bool(j, 'enabled');
      });

  @override
  Future<Either<ReviewFailure, PurchaseEvaluation>> purchase(
    String purchaseId,
  ) => _call(
    'read_purchase_evaluation_v2',
    {'p_purchase_id': purchaseId},
    (j) {
      final id = _string(j, 'purchase_id');
      if (id != purchaseId) throw const FormatException();
      return PurchaseEvaluation(
        purchaseId: id,
        shopId: _string(j, 'shop_id'),
        shopName: _string(j, 'shop_name'),
        enabled: _bool(j, 'enabled'),
        valid: _bool(j, 'valid'),
        service: j['service'] == null ? null : _criteria(_object(j['service'])),
        products: List.unmodifiable(
          _list(j['products']).map(
            (p) => EvaluationProduct(
              productId: _string(p, 'product_id'),
              name: _string(p, 'product_name'),
              canSubmit: _bool(p, 'can_submit'),
              existingReview: p['existing_review'] == null
                  ? null
                  : ReviewModel.fromJson(_object(p['existing_review'])),
            ),
          ),
        ),
      );
    },
    valid: _uuid.hasMatch(purchaseId),
  );

  @override
  Future<Either<ReviewFailure, Unit>> submit(
    PurchaseEvaluationCommand command,
  ) => _call(
    'submit_purchase_evaluation_v2',
    {
      'p_purchase_id': command.purchaseId,
      'p_request_id': command.requestId,
      'p_service': command.service?.toJson(),
      'p_products': command.products
          .map((p) => p.toJson())
          .toList(growable: false),
    },
    (j) {
      if (_string(j, 'purchase_id') != command.purchaseId) {
        throw const FormatException();
      }
      _string(j, 'service_evaluation_id');
      final results = _list(j['reviews']);
      if (results.length != command.products.length ||
          results.map((r) => _string(r, 'product_id')).toSet().length !=
              command.products.length ||
          results
              .map((r) => _string(r, 'product_id'))
              .toSet()
              .difference(command.products.map((p) => p.productId).toSet())
              .isNotEmpty) {
        throw const FormatException();
      }
      for (final r in results) {
        _string(r, 'review_id');
        _string(r, 'revision_id');
        DateTime.parse(_string(r, 'edit_until'));
      }
      return unit;
    },
    valid:
        _uuid.hasMatch(command.purchaseId) &&
        _uuid.hasMatch(command.requestId) &&
        (command.service?.valid ?? true) &&
        command.products.length <= 50 &&
        command.products.every((p) => _uuid.hasMatch(p.productId) && p.valid) &&
        command.products.map((p) => p.productId).toSet().length ==
            command.products.length,
  );

  @override
  Future<Either<ReviewFailure, MerchantReviewsPage>> merchant(
    String shopId, {
    MerchantReviewFilter filter = MerchantReviewFilter.all,
    int offset = 0,
  }) => _call(
    'read_merchant_reviews_v2',
    {
      'p_shop_id': shopId,
      'p_filter': filter.name,
      'p_limit': 20,
      'p_offset': offset,
    },
    (j) {
      if (_string(j, 'shop_id') != shopId) throw const FormatException();
      return MerchantReviewsPage(
        shopId: shopId,
        scores: _scores(_object(j['scores'])),
        awaitingReplyCount: _integer(j, 'awaiting_reply_count'),
        total: _integer(j, 'total'),
        reviews: List.unmodifiable(
          _list(j['reviews']).map(
            (r) => MerchantReview(
              id: _string(r, 'review_id'),
              revisionId: _string(r, 'revision_id'),
              productId: _string(r, 'product_id'),
              productName: r['product_name'] as String? ?? 'Ürün',
              visibility: _string(r, 'visibility'),
              canReply: _bool(r, 'can_reply'),
              replied: _bool(r, 'replied'),
              reported: _bool(r, 'reported'),
              rating: r['rating'] as int?,
              title: r['title'] as String?,
              comment: r['comment'] as String?,
              reply: r['merchant_reply'] as String?,
              updatedAt: r['updated_at'] == null
                  ? null
                  : DateTime.parse(r['updated_at'] as String),
            ),
          ),
        ),
      );
    },
    valid: _uuid.hasMatch(shopId) && offset >= 0,
  );

  @override
  Future<Either<ReviewFailure, Unit>> reply({
    required String shopId,
    required MerchantReview review,
    required String requestId,
    required String text,
  }) => _call(
    'reply_to_review_v2',
    {
      'p_shop_id': shopId,
      'p_review_id': review.id,
      'p_revision_id': review.revisionId,
      'p_request_id': requestId,
      'p_text': text.trim(),
    },
    (j) {
      if (_string(j, 'review_id') != review.id) throw const FormatException();
      _string(j, 'reply_id');
      return unit;
    },
    valid:
        _ids(shopId, review, requestId) &&
        text.trim().isNotEmpty &&
        text.trim().length <= 2000,
  );

  @override
  Future<Either<ReviewFailure, Unit>> report({
    required String shopId,
    required MerchantReview review,
    required String requestId,
    required String reason,
  }) => _call(
    'review_action_v2',
    {
      'p_shop_id': shopId,
      'p_review_id': review.id,
      'p_revision_id': review.revisionId,
      'p_request_id': requestId,
      'p_action': 'report',
      'p_reason': reason.trim(),
    },
    (j) {
      if (_string(j, 'review_id') != review.id || j['action'] != 'report') {
        throw const FormatException();
      }
      _string(j, 'event_id');
      return unit;
    },
    valid:
        _ids(shopId, review, requestId) &&
        reason.trim().isNotEmpty &&
        reason.trim().length <= 500,
  );

  static bool _ids(String shop, MerchantReview review, String request) =>
      [shop, review.id, review.revisionId, request].every(_uuid.hasMatch);
  static Map<String, dynamic> _object(dynamic value) {
    if (value is! Map) throw const FormatException();
    return Map<String, dynamic>.from(value);
  }

  static List<Map<String, dynamic>> _list(dynamic value) {
    if (value is! List) throw const FormatException();
    return value.map(_object).toList();
  }

  static String _string(Map<String, dynamic> j, String key) {
    final v = j[key];
    if (v is! String || v.isEmpty) throw const FormatException();
    return v;
  }

  static bool _bool(Map<String, dynamic> j, String key) {
    final v = j[key];
    if (v is! bool) throw const FormatException();
    return v;
  }

  static int _integer(Map<String, dynamic> j, String key) {
    final v = j[key];
    if (v is! int || v < 0) throw const FormatException();
    return v;
  }

  static ServiceCriteria _criteria(Map<String, dynamic> j) {
    final v = ServiceCriteria(
      friendliness: _integer(j, 'friendliness'),
      communication: _integer(j, 'communication'),
      cleanliness: _integer(j, 'cleanliness'),
    );
    if (!v.valid) throw const FormatException();
    return v;
  }

  static ServiceScores _scores(Map<String, dynamic> j) {
    double? score(String key) {
      final v = j[key];
      if (v == null) return null;
      if (v is! num || !v.isFinite || v < 1 || v > 5) {
        throw const FormatException();
      }
      return v.toDouble();
    }

    final count = _integer(j, 'sample_count'),
        average = score('average_rating'),
        friendliness = score('friendliness'),
        communication = score('communication'),
        cleanliness = score('cleanliness');
    if (count > 0 &&
        [
          average,
          friendliness,
          communication,
          cleanliness,
        ].any((v) => v == null)) {
      throw const FormatException();
    }
    if (count == 0 &&
        [
          average,
          friendliness,
          communication,
          cleanliness,
        ].any((v) => v != null)) {
      throw const FormatException();
    }
    return ServiceScores(
      sampleCount: count,
      average: average,
      friendliness: friendliness,
      communication: communication,
      cleanliness: cleanliness,
    );
  }
}

ReviewFailure evaluationFailure(Object error) {
  if (error is FormatException || error is TypeError) {
    return const ReviewFailure(
      ReviewFailureKind.invalidResponse,
      'Sunucunun yanıtı doğrulanamadı. Yenileyip tekrar deneyin.',
    );
  }
  if (error is PostgrestException) {
    final message = error.message;
    if (error.code == '28000' || error.code == 'PGRST301') {
      return const ReviewFailure(
        ReviewFailureKind.authRequired,
        'Oturumunuz sona erdi. Yeniden giriş yapın.',
      );
    }
    if (message.contains('REVIEW_EDIT_CLOSED')) {
      return const ReviewFailure(
        ReviewFailureKind.unauthorized,
        'Düzenleme süresi doldu veya değerlendirme şu anda düzenlenemiyor.',
      );
    }
    if (message.contains('REVIEW_CHANGED')) {
      return const ReviewFailure(
        ReviewFailureKind.unavailable,
        'Değerlendirme değişti. Güncel halini açıp tekrar deneyin.',
      );
    }
    if (message.contains('REVIEW_DISABLED')) {
      return const ReviewFailure(
        ReviewFailureKind.unavailable,
        'Değerlendirme özelliği henüz kullanıma açılmadı.',
      );
    }
    if (message.contains('REVIEW_ENTITLEMENT_USED') ||
        message.contains('REVIEW_ALREADY_') ||
        message.contains('REVIEW_SERVICE_ALREADY')) {
      return const ReviewFailure(
        ReviewFailureKind.invalidArgument,
        'Bu işlem daha önce tamamlandı. Güncel durumu yenileyin.',
      );
    }
    if (message.contains('REVIEW_SERVICE_REQUIRED')) {
      return const ReviewFailure(
        ReviewFailureKind.invalidArgument,
        'Güleryüz, iletişim ve temizlik puanlarının tümünü seçin.',
      );
    }
    if (message.contains('REVIEW_REQUEST_CONFLICT')) {
      return const ReviewFailure(
        ReviewFailureKind.invalidArgument,
        'Bekleyen işlemin bilgileri değişti. Güncel durumu yenileyin.',
      );
    }
    if (message.contains('REVIEW_NEWER_PURCHASE_REQUIRED') ||
        message.contains('REVIEW_NOT_VERIFIED')) {
      return const ReviewFailure(
        ReviewFailureKind.notVerified,
        'Bu işlem için uygun doğrulanmış alışveriş bulunamadı.',
      );
    }
    if (error.code == '42501') {
      return const ReviewFailure(
        ReviewFailureKind.unauthorized,
        'Bu değerlendirme üzerinde işlem yapma yetkiniz yok.',
      );
    }
    if (error.code == '22023') {
      return const ReviewFailure(
        ReviewFailureKind.invalidArgument,
        'Değerlendirme bilgilerini kontrol edin.',
      );
    }
    if (error.code == 'PGRST202' || error.code == '42883') {
      return const ReviewFailure(
        ReviewFailureKind.unavailable,
        'Değerlendirme özelliği henüz kullanıma açılmadı.',
      );
    }
  }
  if (error is TimeoutException) {
    return const ReviewFailure(
      ReviewFailureKind.network,
      'Yanıt alınamadı. Aynı işlemi güvenle tekrar deneyebilirsiniz.',
    );
  }
  return const ReviewFailure(
    ReviewFailureKind.network,
    'Bağlantı kurulamadı. Aynı işlemi güvenle tekrar deneyebilirsiniz.',
  );
}
