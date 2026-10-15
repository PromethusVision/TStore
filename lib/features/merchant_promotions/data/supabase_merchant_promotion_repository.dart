import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/merchant_promotion.dart';

typedef PromotionRpc =
    Future<dynamic> Function(String name, Map<String, dynamic> args);
typedef PromotionSign = Future<String> Function(String path);

class SupabaseMerchantPromotionRepository
    implements MerchantPromotionRepository {
  SupabaseMerchantPromotionRepository(
    SupabaseClient client, {
    PromotionRpc? rpc,
    PromotionSign? sign,
    String? Function()? currentUserId,
    Stream<String?>? sessionChanges,
    this.timeout = const Duration(seconds: 15),
  }) : _rpc = rpc ?? ((name, args) => client.rpc(name, params: args)),
       _sign =
           sign ??
           ((path) =>
               client.storage.from('listing-media').createSignedUrl(path, 120)),
       _user = currentUserId ?? (() => client.auth.currentUser?.id),
       _sessions =
           sessionChanges ??
           client.auth.onAuthStateChange.map((e) => e.session?.user.id);
  final PromotionRpc _rpc;
  final PromotionSign _sign;
  final String? Function() _user;
  final Stream<String?> _sessions;
  final Duration timeout;
  List<dynamic> _enabledItems(Map<String, dynamic> value) {
    if (!boolean(value['enabled'])) {
      throw const PostgrestException(
        message: 'Promotion preparation disabled',
        code: '55000',
      );
    }
    final items = array(value['items']);
    if (items.length > 20) throw const FormatException();
    return items;
  }

  @override
  String? get currentUserId => _user();
  @override
  Stream<String?> get sessionChanges => _sessions;
  Future<Either<PromotionFailure, T>> _call<T>(
    String name,
    Map<String, dynamic> args,
    FutureOr<T> Function(Map<String, dynamic>) decode, {
    bool write = false,
  }) async {
    final actor = _user();
    if (actor == null) return const Left(PromotionFailure.session);
    var invalidated = false;
    final sub = _sessions.listen(
      (_) {
        invalidated = true;
      },
      onError: (Object _) {
        invalidated = true;
      },
    );
    bool stale() => invalidated || actor != _user();
    PromotionFailure invalidatedFailure() => write && actor == _user()
        ? PromotionFailure.uncertain
        : PromotionFailure.session;
    try {
      final raw = await _rpc(name, args).timeout(timeout);
      if (stale()) return Left(invalidatedFailure());
      final result = await Future.sync(
        () => decode(object(raw)),
      ).timeout(timeout);
      return stale() ? Left(invalidatedFailure()) : Right(result);
    } on PostgrestException catch (e) {
      if (stale()) return Left(invalidatedFailure());
      if (['42501', '28000'].contains(e.code)) {
        return const Left(PromotionFailure.session);
      }
      if (e.code == '40001') return const Left(PromotionFailure.changed);
      if (['22023', '22P02', '54000'].contains(e.code)) {
        return const Left(PromotionFailure.invalid);
      }
      if (e.code == '55000') return const Left(PromotionFailure.unavailable);
      return Left(
        write ? PromotionFailure.uncertain : PromotionFailure.unavailable,
      );
    } catch (_) {
      if (stale()) return Left(invalidatedFailure());
      return Left(
        write ? PromotionFailure.uncertain : PromotionFailure.unavailable,
      );
    } finally {
      await sub.cancel();
    }
  }

  @override
  Future<Either<PromotionFailure, PromotionPage>> read(
    String shopId, {
    int offset = 0,
  }) => _call(
    'read_merchant_promotions_v1',
    {'p_shop_id': shopId, 'p_offset': offset},
    (j) {
      if (promotionId(j['shop_id']) != shopId) throw const FormatException();
      final enabled = boolean(j['enabled']), more = boolean(j['has_more']);
      final items = array(
        j['items'],
      ).map((x) => PromotionDraft.fromJson(object(x))).toList();
      if (items.any((x) => x.shopId != shopId) ||
          items.length > 20 ||
          (!enabled && (items.isNotEmpty || more))) {
        throw const FormatException();
      }
      return PromotionPage(
        enabled: enabled,
        items: List.unmodifiable(items),
        hasMore: more,
      );
    },
  );
  @override
  Future<Either<PromotionFailure, List<PromotionSource>>> sources(
    String shopId,
    String kind, {
    String query = '',
    int offset = 0,
  }) => _call(
    'read_promotion_sources_v1',
    {'p_shop_id': shopId, 'p_kind': kind, 'p_query': query, 'p_offset': offset},
    (j) => List.unmodifiable(
      _enabledItems(j).map((x) {
        final row = object(x);
        return PromotionSource(promotionId(row['id']), string(row['label']));
      }),
    ),
  );
  @override
  Future<Either<PromotionFailure, PromotionPreview>> preview(
    String shopId,
    PromotionSelection selection,
  ) => _call(
    'preview_merchant_promotion_v1',
    {'p_shop_id': shopId, 'p_selection': selection.toJson()},
    (j) async {
      final enabled = boolean(j['enabled']), ready = boolean(j['ready']);
      if (!enabled || !ready) {
        return PromotionPreview(enabled: enabled, ready: false);
      }
      final fingerprint = string(j['fingerprint']);
      if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(fingerprint)) {
        throw const FormatException();
      }
      final photos = <PromotionPhoto>[];
      for (final raw in array(j['images'])) {
        final row = object(raw),
            photoId = promotionId(row['id']),
            listingId = promotionId(row['listing_id']),
            path = string(row['object_path']);
        if (row['bucket_id'] != 'listing-media' ||
            listingId != selection.listingId ||
            !RegExp(
              '^shops/${RegExp.escape(shopId)}/${RegExp.escape(listingId)}/v[0-9]{14}/${RegExp.escape(photoId)}[.](jpg|png|webp)'
              r'$',
            ).hasMatch(path)) {
          throw const FormatException();
        }
        String? url;
        try {
          url = await _sign(path).timeout(timeout);
        } catch (_) {
          /* text preview remains usable */
        }
        if (url != null &&
            !['http', 'https'].contains(Uri.tryParse(url)?.scheme)) {
          url = null;
        }
        photos.add(
          PromotionPhoto(
            id: photoId,
            listingId: listingId,
            path: path,
            url: url,
          ),
        );
      }
      if (selection.imageId != null &&
          !photos.any((x) => x.id == selection.imageId)) {
        throw const FormatException();
      }
      return PromotionPreview(
        enabled: true,
        ready: true,
        copy: PromotionCopy.fromJson(object(j['snapshot'])),
        fingerprint: fingerprint,
        images: List.unmodifiable(photos),
      );
    },
  );
  @override
  Future<Either<PromotionFailure, PromotionReceipt>> mutate(
    PromotionCommand command,
  ) => _call('mutate_merchant_promotion_v1', command.toJson(), (j) {
    final receipt = PromotionReceipt(
      promotionId(j['id']),
      promotionId(j['revision_id']),
      string(j['action']),
    );
    if (receipt.action != command.action ||
        (command.draftId != null && receipt.id != command.draftId)) {
      throw const FormatException();
    }
    return receipt;
  }, write: true);
  @override
  Future<Either<PromotionFailure, List<PromotionHistoryEntry>>> history(
    String shopId,
    String draftId, {
    int offset = 0,
  }) => _call(
    'read_promotion_history_v1',
    {'p_shop_id': shopId, 'p_draft_id': draftId, 'p_offset': offset},
    (j) => List.unmodifiable(
      _enabledItems(j).map((x) {
        final row = object(x), action = string(row['action']);
        if (!['save', 'archive'].contains(action)) {
          throw const FormatException();
        }
        return PromotionHistoryEntry(
          promotionId(row['revision_id']),
          action,
          PromotionCopy.fromJson(object(row['snapshot'])),
          DateTime.parse(string(row['recorded_at'])),
        );
      }),
    ),
  );
}
