import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/merchant_promotion.dart';

import 'package:t_store/core/supabase/authenticated_session_key.dart';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';

typedef PromotionRpc =
    Future<dynamic> Function(String name, Map<String, dynamic> args);
typedef PromotionSign = Future<String> Function(String path);

class SupabaseMerchantPromotionRepository
    implements
        MerchantPromotionRepository,
        PromotionRecoveryRepository,
        PromotionPendingRepository,
        AuthenticatedSessionEvents {
  SupabaseMerchantPromotionRepository(
    SupabaseClient client, {
    PromotionRpc? rpc,
    PromotionSign? sign,
    String? Function()? currentUserId,
    String? Function()? currentSessionKey,
    Stream<String?>? sessionChanges,
    Stream<String?>? sessionKeyChanges,
    this.timeout = const Duration(seconds: 15),
  }) : _rpc = rpc ?? ((name, args) => client.rpc(name, params: args)),
       _sign =
           sign ??
           ((path) =>
               client.storage.from('listing-media').createSignedUrl(path, 120)),
       _user = currentUserId ?? (() => client.auth.currentUser?.id),
       _sessionKey =
           currentSessionKey ?? (() => authenticatedSessionKey(client)),
       _sessions =
           sessionChanges ??
           client.auth.onAuthStateChange.map((e) => e.session?.user.id),
       _keys =
           sessionKeyChanges ??
           client.auth.onAuthStateChange.map(
             (e) => authenticatedSessionKeyFromSession(e.session),
           );
  final PromotionRpc _rpc;
  final PromotionSign _sign;
  final String? Function() _user;
  final Stream<String?> _sessions;
  final Stream<String?> _keys;
  final _attempts = <String, _PromotionAttempt>{};
  @override
  Stream<String?> get sessionKeyChanges => _keys;
  final Duration timeout;
  final String? Function() _sessionKey;
  @override
  String? get currentSessionKey => _sessionKey();
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
  AuthenticatedRequestScope _scope() => AuthenticatedRequestScope(
    user: currentUserId,
    session: currentSessionKey,
    currentUser: () => currentUserId,
    currentSession: () => currentSessionKey,
    changes: sessionChanges,
    sessionKeys: sessionKeyChanges,
  );

  @override
  PromotionCommand? pendingCommand(String shopId) {
    final attempt = _attempts[shopId];
    if (attempt == null) return null;
    if (attempt.scope.current) return attempt.command;
    // A dispatched request is not cancelled by losing its view/session.
    if (attempt.inFlight == null) {
      _attempts.remove(shopId);
      unawaited(attempt.scope.close());
    }
    return null;
  }

  Future<Either<PromotionFailure, T>> _call<T>(
    String name,
    Map<String, dynamic> args,
    FutureOr<T> Function(Map<String, dynamic>, AuthenticatedRequestScope)
    decode, {
    bool write = false,
    AuthenticatedRequestScope? attemptScope,
  }) async {
    final scope = attemptScope ?? _scope();
    try {
      Future<T> request() => scope.run(() async {
        final raw = await _rpc(name, args);
        scope.check();
        return await decode(object(raw), scope);
      });
      final result = await (write ? request() : request().timeout(timeout));
      return Right(result);
    } on PostgrestException catch (e) {
      if (!scope.current) return const Left(PromotionFailure.session);
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
      if (!scope.current) return const Left(PromotionFailure.session);
      return Left(
        write ? PromotionFailure.uncertain : PromotionFailure.unavailable,
      );
    } finally {
      if (attemptScope == null) await scope.close();
    }
  }

  @override
  Future<Either<PromotionFailure, PromotionPage>> read(
    String shopId, {
    int offset = 0,
  }) => _call(
    'read_merchant_promotions_v1',
    {'p_shop_id': shopId, 'p_offset': offset},
    (j, scope) {
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
  Future<Either<PromotionFailure, PromotionDraft?>> readPromotion(
    String shopId,
    String draftId,
  ) => _call(
    'read_merchant_promotion_detail_v1',
    {'p_shop_id': shopId, 'p_draft_id': draftId},
    (j, scope) {
      if (promotionId(j['shop_id']) != shopId) throw const FormatException();
      if (!boolean(j['enabled'])) {
        throw const PostgrestException(message: 'disabled', code: '55000');
      }
      if (j['draft'] == null) return null;
      final draft = PromotionDraft.fromJson(object(j['draft']));
      if (draft.id != draftId || draft.shopId != shopId) {
        throw const FormatException();
      }
      return draft;
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
    (j, scope) => List.unmodifiable(
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
    (j, scope) async {
      final enabled = boolean(j['enabled']), ready = boolean(j['ready']);
      if (!enabled || !ready) {
        return PromotionPreview(enabled: enabled, ready: false);
      }
      final fingerprint = string(j['fingerprint']);
      if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(fingerprint)) {
        throw const FormatException();
      }
      final photos = <PromotionPhoto>[];
      if (array(j['images']).length > 5) throw const FormatException();
      final signing = Stopwatch()..start();
      for (final raw in array(j['images'])) {
        scope.check();
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
          final remaining = const Duration(seconds: 5) - signing.elapsed;
          if (remaining > Duration.zero) {
            url = await _sign(path).timeout(remaining);
          }
          scope.check();
        } catch (_) {
          scope.check();
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
  ) {
    pendingCommand(command.shopId); // Retire an obsolete, settled attempt.
    final previous = _attempts[command.shopId];
    if (previous != null) {
      if (!previous.scope.current) {
        return Future.value(const Left(PromotionFailure.unavailable));
      }
      if (jsonEncode(previous.command.toJson()) !=
          jsonEncode(command.toJson())) {
        return Future.value(const Left(PromotionFailure.unavailable));
      }
      if (previous.inFlight case final pending?) return pending;
    }
    final attempt = previous ?? _PromotionAttempt(command, _scope());
    _attempts[command.shopId] = attempt;
    final result = _mutate(attempt);
    attempt.inFlight = result;
    return result;
  }

  Future<Either<PromotionFailure, PromotionReceipt>> _mutate(
    _PromotionAttempt attempt,
  ) async {
    final command = attempt.command;
    final result = await _call(
      'mutate_merchant_promotion_v1',
      command.toJson(),
      (j, scope) {
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
      },
      write: true,
      attemptScope: attempt.scope,
    );
    attempt.inFlight = null;
    if (!attempt.scope.current ||
        !result.fold((e) => e == PromotionFailure.uncertain, (_) => false)) {
      if (identical(_attempts[command.shopId], attempt)) {
        _attempts.remove(command.shopId);
      }
      await attempt.scope.close();
    }
    return result;
  }

  @override
  Future<Either<PromotionFailure, List<PromotionHistoryEntry>>> history(
    String shopId,
    String draftId, {
    int offset = 0,
  }) => _call(
    'read_promotion_history_v1',
    {'p_shop_id': shopId, 'p_draft_id': draftId, 'p_offset': offset},
    (j, scope) => List.unmodifiable(
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

/// One original command, retained in memory until an explicit reconciliation or
/// authority loss. It is never replayed automatically or persisted to disk.
class _PromotionAttempt {
  _PromotionAttempt(this.command, this.scope);
  final PromotionCommand command;
  final AuthenticatedRequestScope scope;
  Future<Either<PromotionFailure, PromotionReceipt>>? inFlight;
}
