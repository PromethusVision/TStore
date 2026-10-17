import 'dart:async';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/authenticated_session_key.dart';
import 'package:t_store/features/merchant/data/merchant_request_scope.dart';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/shop/data/models/product_model.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';

class SupabaseCatalogMediaRepository implements CatalogMediaRepository {
  SupabaseCatalogMediaRepository(
    this.client, {
    String? Function()? currentUserId,
    String? Function()? currentSessionKey,
    this.readTimeout = const Duration(seconds: 15),
  }) : currentUserId = currentUserId ?? (() => client.auth.currentUser?.id),
       currentSessionKey =
           currentSessionKey ?? (() => authenticatedSessionKey(client));
  final SupabaseClient client;
  final String? Function() currentUserId;
  final String? Function() currentSessionKey;
  final Duration readTimeout;

  Future<Either<String, T>> _run<T>(
    MerchantAccess a,
    Future<T> Function(MerchantRequestScope scope) fn, {
    bool read = true,
  }) async {
    final scope = MerchantRequestScope(
      userId: currentUserId(),
      sessionKey: currentSessionKey(),
      currentUserId: currentUserId,
      currentSessionKey: currentSessionKey,
    );
    try {
      scope.expect(a.user.id);
      if (!a.canManage) throw const _CatalogFailure(merchantAccessDenied);
      final request = fn(scope);
      final value = await (read ? request.timeout(readTimeout) : request);
      scope.check();
      return Right<String, T>(value);
    } on MerchantRequestChanged {
      return Left<String, T>(merchantSessionChanged);
    } on TimeoutException {
      return Left<String, T>(merchantReadTimeout);
    } on _CatalogFailure catch (e) {
      return Left<String, T>(e.message);
    } on FormatException catch (e) {
      return Left<String, T>(e.message);
    } on PostgrestException catch (e) {
      final message = switch (e.message) {
        'CATALOG_INVALID_GTIN' => 'Barkod geçersiz.',
        'MEDIA_LIMIT' => 'Fotoğraf sınırına ulaştın.',
        'CATALOG_CATEGORY_UNAVAILABLE' =>
          'Bu kategori şu anda ürün kabul etmiyor.',
        'MEDIA_UPLOAD_INCOMPLETE' =>
          'Fotoğraf yüklemesi tamamlanmadı. Yeniden dene.',
        _ =>
          e.code == '42501'
              ? merchantAccessDenied
              : 'İşlem tamamlanamadı. Yeniden dene.',
      };
      return Left<String, T>(message);
    } catch (_) {
      return Left<String, T>('Bağlantı kurulamadı. Yeniden dene.');
    } finally {
      scope.close();
    }
  }

  Map<String, dynamic> _row(dynamic j) => Map<String, dynamic>.from(j as Map);
  @override
  Future<Either<String, List<CatalogCategory>>> categories(MerchantAccess a) =>
      _run(a, (scope) async {
        final rows = await scope.run(
          () => client.rpc(
            'merchant_catalog_categories_v1',
            params: {'p_shop_id': a.shop!.id},
          ),
        );
        return [
          for (final j in rows as List) CatalogCategory(j['id'], j['name']),
        ];
      });
  @override
  Future<Either<String, CatalogLookup>> lookup(
    MerchantAccess a,
    String name,
    String gtin,
  ) => _run(a, (scope) async {
    final j = await scope.run(
      () => client.rpc(
        'merchant_catalog_lookup_v1',
        params: {
          'p_shop_id': a.shop!.id,
          'p_name': name,
          'p_gtin': normalizeGtin(gtin),
        },
      ),
    );
    return CatalogLookup([
      for (final p in j['products'] as List) ProductModel.fromJson(_row(p)),
    ], exact: j['exact'] == true);
  });
  @override
  Future<Either<String, SubmissionResult>> submit(
    MerchantAccess a,
    String requestId,
    ProductSubmissionDraft draft,
  ) => _run(a, (scope) async {
    if (draft.error != null) throw _CatalogFailure(draft.error!);
    final j = await scope.run(
      () => client.rpc(
        'merchant_submit_product_v1',
        params: {
          'p_shop_id': a.shop!.id,
          'p_request_id': requestId,
          'p_draft': draft.toJson(),
        },
      ),
    );
    return SubmissionResult(
      submission: j['submission'] == null
          ? null
          : ProductSubmission.fromJson(_row(j['submission'])),
      existing: j['existing'] == null
          ? null
          : ProductModel.fromJson(_row(j['existing'])),
    );
  }, read: false);
  @override
  Future<Either<String, List<ProductSubmission>>> submissions(
    MerchantAccess a, {
    int page = 0,
  }) => _run(a, (scope) async {
    if (page < 0) throw const _CatalogFailure('Geçersiz sayfa.');
    final rows = await scope.run(
      () => client
          .from('product_submissions')
          .select()
          .eq('shop_id', a.shop!.id)
          .order('created_at', ascending: false)
          .order('id')
          .range(page * 100, page * 100 + 99),
    );
    return rows.map(ProductSubmission.fromJson).toList(growable: false);
  });
  @override
  Future<Either<String, ProductEntity?>> approvedProduct(
    MerchantAccess a,
    String id,
  ) => _run(a, (scope) async {
    final j = await scope.run(
      () => client
          .from('products')
          .select('*, brands(name)')
          .eq('id', id)
          .eq('is_active', true)
          .maybeSingle(),
    );
    return j == null ? null : ProductModel.fromJson(j);
  });
  @override
  Future<Either<String, ListingMedia>> media(MerchantAccess a, String id) =>
      _run(a, (scope) async {
        final j = await scope.run(
          () => client.rpc(
            'merchant_listing_media_v1',
            params: {'p_listing_id': id},
          ),
        );
        final images = <ListingImage>[];
        for (final row in j['images'] as List) {
          String? url;
          if (row['publication_state'] == 'published') {
            try {
              url = await scope.run(
                () => client.storage
                    .from('listing-media')
                    .createSignedUrl(row['object_path'], 300),
              );
            } catch (_) {
              /* metadata still allows retirement */
            }
            scope.check();
          }
          images.add(
            ListingImage(
              id: row['id'],
              path: row['object_path'],
              state: row['publication_state'],
              primary: row['is_primary'],
              order: row['sort_order'],
              url: url,
            ),
          );
        }
        return ListingMedia(
          images,
          maxPhotos: j['max_photos'],
          maxBytes: j['max_bytes'],
        );
      });
  @override
  Future<Either<String, void>> upload(
    MerchantAccess a,
    String id,
    Uint8List bytes,
  ) => _run(a, (scope) async {
    final mime = listingImageMime(bytes);
    if (mime == null) {
      throw const _CatalogFailure('JPEG, PNG veya WebP fotoğraf seçin.');
    }
    final prepared = await scope.run(
      () => client.rpc(
        'merchant_prepare_listing_image_v1',
        params: {'p_listing_id': id, 'p_mime': mime, 'p_bytes': bytes.length},
      ),
    );
    final j = _row(prepared is List ? prepared.single : prepared);
    // A lost acknowledgement can follow a committed upload or publication.
    // Never compensate by retiring: refresh the existing intent for recovery.
    await scope.run(
      () => client.storage
          .from(j['bucket_id'])
          .uploadBinary(
            j['object_path'],
            bytes,
            fileOptions: FileOptions(contentType: mime, upsert: false),
          ),
    );
    await scope.run(
      () => client.rpc(
        'merchant_change_listing_images_v1',
        params: {
          'p_listing_id': id,
          'p_action': 'publish',
          'p_image_id': j['id'],
        },
      ),
    );
  }, read: false);
  @override
  Future<Either<String, void>> changeMedia(
    MerchantAccess a,
    String id,
    String action, {
    String? imageId,
    List<String>? order,
  }) => _run(a, (scope) async {
    await scope.run(
      () => client.rpc(
        'merchant_change_listing_images_v1',
        params: {
          'p_listing_id': id,
          'p_action': action,
          'p_image_id': imageId,
          'p_order': order,
        },
      ),
    );
  }, read: false);
}

class _CatalogFailure implements Exception {
  const _CatalogFailure(this.message);
  final String message;
}
