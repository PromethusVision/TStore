import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart'
    show listingImageMime;
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/authenticated_session_key.dart';
import 'package:t_store/features/merchant/data/merchant_request_scope.dart';
import 'package:t_store/core/supabase/public_media_source_resolver.dart';
import 'package:t_store/features/auth/data/models/user_model.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/shop/data/models/product_model.dart';
import 'package:t_store/features/shop/data/models/shop_model.dart';
import 'package:t_store/features/shop/data/models/shop_product_model.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';

/// Reuses owner RLS and the Slice A publication gate when installed. The
/// pre-Slice-A catalog read remains compatible until the reviewed migration.
class SupabaseMerchantRepository
    implements
        MerchantRepository,
        MerchantRecoveryRepository,
        MerchantShopPhotoRepository {
  SupabaseMerchantRepository({
    required this.client,
    String? Function()? currentUserId,
    String? Function()? currentSessionKey,
    this.readTimeout = const Duration(seconds: 15),
  }) : currentUserId = currentUserId ?? (() => client.auth.currentUser?.id),
       currentSessionKey =
           currentSessionKey ?? (() => authenticatedSessionKey(client)),
       media = PublicMediaSourceResolver.fromSupabaseClient(client);
  final SupabaseClient client;
  final String? Function() currentUserId;
  final String? Function() currentSessionKey;
  final Duration readTimeout;
  final PublicMediaSourceResolver media;

  // Keep owned listings visible even when the shared catalog product is hidden.
  static const _listingSelect = '*, products(*, brands(name)), shops(*)';
  static const _listingSearchSelect =
      '*, products!inner(*, brands(name)), shops(*)';
  static const _conflict =
      'Kayıt değişmiş olabilir. Güncel bilgileri yükleyip yeniden deneyin.';

  Future<Either<String, T>> _safe<T>(
    Future<T> Function(MerchantRequestScope scope) action, {
    bool read = true,
  }) async {
    final scope = MerchantRequestScope(
      userId: currentUserId(),
      sessionKey: currentSessionKey(),
      currentUserId: currentUserId,
      currentSessionKey: currentSessionKey,
      changes: client.auth.onAuthStateChange.map(
        (event) => event.session?.user.id,
      ),
      sessionKeys: client.auth.onAuthStateChange.map(
        (event) => authenticatedSessionKeyFromSession(event.session),
      ),
    );
    try {
      scope.check();
      final request = action(scope);
      return Right<String, T>(
        await scope.run(() => read ? request.timeout(readTimeout) : request),
      );
    } on MerchantRequestChanged {
      return Left<String, T>(merchantSessionChanged);
    } on TimeoutException {
      return Left<String, T>(merchantReadTimeout);
    } on _MerchantFailure catch (e) {
      return Left<String, T>(e.message);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return Left<String, T>(
          'Bu kayıt zaten var. Listeyi yenileyip mevcut kaydı düzenleyin.',
        );
      }
      if (e.code == '42501') return Left<String, T>(merchantAccessDenied);
      return Left<String, T>(
        'İşlem tamamlanamadı. Bilgileri yenileyip tekrar deneyin.',
      );
    } catch (_) {
      return Left<String, T>('Bağlantı kurulamadı. Lütfen tekrar deneyin.');
    } finally {
      await scope.close();
    }
  }

  Future<MerchantAccess> _access(MerchantRequestScope scope) async {
    final id = scope.userId!;
    final profile = await scope.run(
      () => client.from('profiles').select().eq('id', id).maybeSingle(),
    );
    if (profile == null || profile['id'] != id) {
      throw const _MerchantFailure(
        'Hesap bilgileri doğrulanamadı. Tekrar deneyin.',
      );
    }
    final user = UserModel.fromJson(profile);
    if (!user.isMerchant) return MerchantAccess(user: user);
    final shops = await scope.run(
      () => client.from('shops').select().eq('owner_user_id', id).limit(2),
    );
    if (shops.length > 1) throw const _MerchantFailure(merchantAccessDenied);
    return MerchantAccess(
      user: user,
      shop: shops.isEmpty ? null : ShopModel.fromJson(shops.single),
    );
  }

  Future<MerchantAccess> _authorize(
    MerchantRequestScope scope,
    MerchantAccess expected, {
    bool allowOnboarding = false,
  }) async {
    scope.expect(expected.user.id);
    final fresh = await _access(scope).timeout(readTimeout);
    if (fresh.user.id != expected.user.id || !fresh.hasRole) {
      throw const _MerchantFailure(merchantAccessDenied);
    }
    if (allowOnboarding && expected.shop == null && fresh.shop == null) {
      return fresh;
    }
    if (!fresh.canManage || fresh.shop!.id != expected.shop?.id) {
      throw const _MerchantFailure(merchantAccessDenied);
    }
    return fresh;
  }

  @override
  Future<Either<String, String>> stageShopPhoto(
    MerchantAccess access,
    Uint8List bytes,
  ) => _safe((scope) async {
    final mime = listingImageMime(bytes);
    if (mime == null || bytes.isEmpty || bytes.length > shopPhotoMaxBytes) {
      throw const _MerchantFailure(
        'En fazla 5 MB boyutunda JPEG, PNG veya WebP fotoğraf seçin.',
      );
    }
    final fresh = await _authorize(scope, access);
    final random = Random.secure();
    final nonce = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final ext = mime == 'image/jpeg'
        ? 'jpg'
        : mime == 'image/png'
        ? 'png'
        : 'webp';
    final path = 'shops/${fresh.shop!.id}/$nonce.$ext';
    await scope.run(
      () => client.storage
          .from(shopPhotoBucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: mime, upsert: false),
          )
          .timeout(const Duration(seconds: 40)),
    );
    return path;
  }, read: false);

  @override
  Future<Either<String, MerchantAccess?>> loadAccess() =>
      currentUserId() == null
      ? Future.value(const Right(null))
      : _safe(_access);

  @override
  Future<Either<String, ShopEntity>> saveShop(
    MerchantAccess access,
    MerchantShopDraft draft,
  ) => _safe((scope) async {
    if (draft.error != null) throw _MerchantFailure(draft.error!);
    final fresh = await _authorize(scope, access, allowOnboarding: true);
    final id = fresh.user.id;
    Map<String, dynamic>? row;
    if (fresh.shop == null) {
      row = await scope.run(
        () => client
            .from('shops')
            .insert({...draft.toPayload(), 'owner_user_id': id})
            .select()
            .single(),
      );
    } else {
      final original = access.shop!;
      if (original.updatedAt == null) throw const _MerchantFailure(_conflict);
      row = await scope.run(
        () => client
            .from('shops')
            .update(draft.toPayload())
            .eq('id', original.id)
            .eq('owner_user_id', id)
            .eq('updated_at', original.updatedAt!.toUtc().toIso8601String())
            .select()
            .maybeSingle(),
      );
    }
    if (row == null) throw const _MerchantFailure(_conflict);
    final shop = ShopModel.fromJson(row);
    if (shop.ownerUserId != id) {
      throw const _MerchantFailure(merchantAccessDenied);
    }
    return shop;
  }, read: false);

  @override
  Future<Either<String, MerchantOverview>> overview(MerchantAccess access) =>
      _safe((scope) async {
        final fresh = await _authorize(scope, access);
        final shopId = fresh.shop!.id;
        Future<int> count({bool? active, bool? available}) {
          var q = client
              .from('shop_products')
              .count(CountOption.exact)
              .eq('shop_id', shopId);
          if (active != null) q = q.eq('is_active', active);
          if (available != null) q = q.eq('is_available', available);
          return q;
        }

        final values = await scope.run(
          () => Future.wait([
            count(),
            count(active: true, available: true),
            count(active: true, available: false),
            count(active: false),
          ]),
        );
        return MerchantOverview(
          total: values[0],
          available: values[1],
          unavailable: values[2],
          inactive: values[3],
        );
      });

  @override
  Future<Either<String, List<ShopProductEntity>>> listings(
    MerchantAccess access, {
    int page = 0,
    String query = '',
  }) => _safe((scope) async {
    if (page < 0) throw const _MerchantFailure('Geçersiz sayfa.');
    final fresh = await _authorize(scope, access);
    final term = _term(query);
    var q = client
        .from('shop_products')
        .select(term.isEmpty ? _listingSelect : _listingSearchSelect)
        .eq('shop_id', fresh.shop!.id);
    if (term.isNotEmpty) q = q.ilike('products.name', '%$term%');
    final rows = await scope.run(
      () => q
          .order('created_at', ascending: false)
          .order('id')
          .range(page * merchantPageSize, (page + 1) * merchantPageSize - 1),
    );
    return rows
        .map((r) => ShopProductModel.fromJson(r, mediaResolver: media))
        .toList(growable: false);
  });

  @override
  Future<Either<String, List<ProductEntity>>> searchCatalog(
    MerchantAccess access, {
    required String query,
    int page = 0,
  }) => _safe((scope) async {
    if (page < 0) throw const _MerchantFailure('Geçersiz sayfa.');
    final fresh = await _authorize(scope, access);
    // Only an absent capability uses legacy reads; auth/network errors remain
    // fail closed. The server checks canonical publication and unique ownership.
    _term(query);
    try {
      final rows = await scope.run(
        () => client.rpc(
          'merchant_catalog_search_v1',
          params: {
            'p_shop_id': fresh.shop!.id,
            'p_query': query.trim(),
            'p_limit': merchantPageSize,
            'p_offset': page * merchantPageSize,
          },
        ),
      );
      return (rows as List)
          .map(
            (r) => ProductModel.fromJson(
              Map<String, dynamic>.from(r as Map),
              mediaResolver: media,
            ),
          )
          .toList(growable: false);
    } on PostgrestException catch (e) {
      if (e.code != 'PGRST202' && e.code != '42883') rethrow;
    }
    var q = client
        .from('products')
        .select('*, brands(name)')
        .eq('is_active', true);
    final term = _term(query);
    if (term.isNotEmpty) q = q.ilike('name', '%$term%');
    final rows = await scope.run(
      () => q
          .order('name')
          .order('id')
          .range(page * merchantPageSize, (page + 1) * merchantPageSize - 1),
    );
    return rows
        .map((r) => ProductModel.fromJson(r, mediaResolver: media))
        .toList(growable: false);
  });

  @override
  Future<Either<String, ShopProductEntity>> saveListing(
    MerchantAccess access,
    MerchantListingDraft draft, {
    ShopProductEntity? existing,
  }) => _safe((scope) async {
    if (draft.error != null) throw _MerchantFailure(draft.error!);
    final fresh = await _authorize(scope, access);
    final shopId = fresh.shop!.id;
    if (existing != null &&
        (existing.shopId != shopId || existing.productId != draft.productId)) {
      throw const _MerchantFailure(merchantAccessDenied);
    }
    Map<String, dynamic>? row;
    if (existing == null) {
      // Never upsert: re-adding a product must not overwrite an existing listing.
      final product = await scope
          .run(
            () => client
                .from('products')
                .select('id')
                .eq('id', draft.productId)
                .eq('is_active', true)
                .maybeSingle(),
          )
          .timeout(readTimeout);
      if (product == null) {
        throw const _MerchantFailure('Bu ürün artık katalogda yok.');
      }
      row = await scope.run(
        () => client
            .from('shop_products')
            .insert({
              ...draft.toPayload(),
              'shop_id': shopId,
              'product_id': draft.productId,
            })
            .select(_listingSelect)
            .single(),
      );
    } else {
      if (existing.updatedAt == null) throw const _MerchantFailure(_conflict);
      row = await scope.run(
        () => client
            .from('shop_products')
            .update(draft.toPayload())
            .eq('id', existing.id)
            .eq('shop_id', shopId)
            .eq('product_id', existing.productId)
            .eq('updated_at', existing.updatedAt!.toUtc().toIso8601String())
            .select(_listingSelect)
            .maybeSingle(),
      );
    }
    if (row == null) throw const _MerchantFailure(_conflict);
    final listing = ShopProductModel.fromJson(row, mediaResolver: media);
    if (listing.shopId != shopId || listing.productId != draft.productId) {
      throw const _MerchantFailure(merchantAccessDenied);
    }
    return listing;
  }, read: false);

  @override
  Future<Either<String, ShopProductEntity?>> readListing(
    MerchantAccess access,
    String productId,
  ) => _safe((scope) async {
    final fresh = await _authorize(scope, access);
    final row = await scope.run(
      () => client
          .from('shop_products')
          .select(_listingSelect)
          .eq('shop_id', fresh.shop!.id)
          .eq('product_id', productId)
          .maybeSingle(),
    );
    if (row == null) return null;
    final listing = ShopProductModel.fromJson(row, mediaResolver: media);
    if (listing.shopId != fresh.shop!.id || listing.productId != productId) {
      throw const _MerchantFailure(merchantAccessDenied);
    }
    return listing;
  });

  static String _term(String query) {
    final term = query.trim();
    if (term.length > 100) {
      throw const _MerchantFailure('Arama en fazla 100 karakter olmalı.');
    }
    return term
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
  }
}

class _MerchantFailure implements Exception {
  const _MerchantFailure(this.message);
  final String message;
}
