import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/public_media_source_resolver.dart';
import 'package:t_store/features/auth/data/models/user_model.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/shop/data/models/product_model.dart';
import 'package:t_store/features/shop/data/models/shop_model.dart';
import 'package:t_store/features/shop/data/models/shop_product_model.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';

/// Uses existing owner RLS. No new grants, role updates, catalog writes or RPCs.
class SupabaseMerchantRepository implements MerchantRepository {
  SupabaseMerchantRepository({
    required this.client,
    String? Function()? currentUserId,
  }) : currentUserId = currentUserId ?? (() => client.auth.currentUser?.id),
       media = PublicMediaSourceResolver.fromSupabaseClient(client);
  final SupabaseClient client;
  final String? Function() currentUserId;
  final PublicMediaSourceResolver media;

  // Keep owned listings visible even when the shared catalog product is hidden.
  static const _listingSelect = '*, products(*, brands(name)), shops(*)';
  static const _listingSearchSelect =
      '*, products!inner(*, brands(name)), shops(*)';
  static const _conflict =
      'Kayıt değişmiş olabilir. Güncel bilgileri yükleyip yeniden deneyin.';

  void _sameUser(String id) {
    if (currentUserId() != id) {
      throw const _MerchantFailure(merchantSessionChanged);
    }
  }

  Future<T> _bound<T>(String id, Future<T> request) async {
    final value = await request;
    _sameUser(id);
    return value;
  }

  Future<Either<String, T>> _safe<T>(Future<T> Function() action) async {
    try {
      return Right<String, T>(await action());
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
    }
  }

  Future<MerchantAccess?> _access() async {
    final id = currentUserId();
    if (id == null) return null;
    final profile = await _bound(
      id,
      client.from('profiles').select().eq('id', id).maybeSingle(),
    );
    if (profile == null || profile['id'] != id) {
      throw const _MerchantFailure(
        'Hesap bilgileri doğrulanamadı. Tekrar deneyin.',
      );
    }
    final user = UserModel.fromJson(profile);
    if (!user.isMerchant) return MerchantAccess(user: user);
    final shops = await _bound(
      id,
      client.from('shops').select().eq('owner_user_id', id).limit(2),
    );
    if (shops.length > 1) throw const _MerchantFailure(merchantAccessDenied);
    return MerchantAccess(
      user: user,
      shop: shops.isEmpty ? null : ShopModel.fromJson(shops.single),
    );
  }

  Future<MerchantAccess> _authorize(
    MerchantAccess expected, {
    bool allowOnboarding = false,
  }) async {
    _sameUser(expected.user.id);
    final fresh = await _access();
    if (fresh == null || fresh.user.id != expected.user.id || !fresh.hasRole) {
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
  Future<Either<String, MerchantAccess?>> loadAccess() => _safe(_access);

  @override
  Future<Either<String, ShopEntity>> saveShop(
    MerchantAccess access,
    MerchantShopDraft draft,
  ) => _safe(() async {
    if (draft.error != null) throw _MerchantFailure(draft.error!);
    final fresh = await _authorize(access, allowOnboarding: true);
    final id = fresh.user.id;
    Map<String, dynamic>? row;
    if (fresh.shop == null) {
      row = await _bound(
        id,
        client
            .from('shops')
            .insert({...draft.toPayload(), 'owner_user_id': id})
            .select()
            .single(),
      );
    } else {
      final original = access.shop!;
      if (original.updatedAt == null) throw const _MerchantFailure(_conflict);
      row = await _bound(
        id,
        client
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
  });

  @override
  Future<Either<String, MerchantOverview>> overview(MerchantAccess access) =>
      _safe(() async {
        final fresh = await _authorize(access);
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

        final values = await _bound(
          fresh.user.id,
          Future.wait([
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
  }) => _safe(() async {
    if (page < 0) throw const _MerchantFailure('Geçersiz sayfa.');
    final fresh = await _authorize(access);
    final term = _term(query);
    var q = client
        .from('shop_products')
        .select(term.isEmpty ? _listingSelect : _listingSearchSelect)
        .eq('shop_id', fresh.shop!.id);
    if (term.isNotEmpty) q = q.ilike('products.name', '%$term%');
    final rows = await _bound(
      fresh.user.id,
      q
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
  }) => _safe(() async {
    if (page < 0) throw const _MerchantFailure('Geçersiz sayfa.');
    final fresh = await _authorize(access);
    var q = client
        .from('products')
        .select('*, brands(name)')
        .eq('is_active', true);
    final term = _term(query);
    if (term.isNotEmpty) q = q.ilike('name', '%$term%');
    final rows = await _bound(
      fresh.user.id,
      q
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
  }) => _safe(() async {
    if (draft.error != null) throw _MerchantFailure(draft.error!);
    final fresh = await _authorize(access);
    final shopId = fresh.shop!.id;
    if (existing != null &&
        (existing.shopId != shopId || existing.productId != draft.productId)) {
      throw const _MerchantFailure(merchantAccessDenied);
    }
    Map<String, dynamic>? row;
    if (existing == null) {
      // Never upsert: re-adding a product must not overwrite an existing listing.
      final product = await _bound(
        fresh.user.id,
        client
            .from('products')
            .select('id')
            .eq('id', draft.productId)
            .eq('is_active', true)
            .maybeSingle(),
      );
      if (product == null) {
        throw const _MerchantFailure('Bu ürün artık katalogda yok.');
      }
      row = await _bound(
        fresh.user.id,
        client
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
      row = await _bound(
        fresh.user.id,
        client
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
