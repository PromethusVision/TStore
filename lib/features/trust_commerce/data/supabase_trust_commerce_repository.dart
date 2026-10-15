import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/trust_commerce/domain/trust_commerce.dart';

typedef TrustRpc =
    Future<dynamic> Function(String name, Map<String, dynamic> parameters);
typedef TrustImageSigner = Future<String?> Function(String path);

class SupabaseTrustCommerceRepository implements TrustCommerceRepository {
  SupabaseTrustCommerceRepository(
    SupabaseClient client, {
    TrustRpc? rpc,
    String? Function()? currentUserId,
    Stream<String?>? sessionChanges,
    TrustImageSigner? imageSigner,
  }) : _rpc =
           rpc ?? ((name, parameters) => client.rpc(name, params: parameters)),
       _user = currentUserId ?? (() => client.auth.currentUser?.id),
       sessionChanges =
           sessionChanges ??
           client.auth.onAuthStateChange.map((e) => e.session?.user.id),
       _sign =
           imageSigner ??
           ((path) =>
               client.storage.from('listing-media').createSignedUrl(path, 120));
  final TrustRpc _rpc;
  final String? Function() _user;
  final TrustImageSigner _sign;
  @override
  String? get currentUserId => _user();
  @override
  final Stream<String?> sessionChanges;
  static final _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );
  static const _auth = TrustFailure(
    TrustFailureKind.auth,
    'Oturumunuz değişti. Yeniden giriş yapın.',
  );
  static const _invalid = TrustFailure(
    TrustFailureKind.invalid,
    'Bilgileri kontrol edip tekrar deneyin.',
  );

  Future<Either<TrustFailure, T>> _call<T>(
    String name,
    Map<String, dynamic> args,
    FutureOr<T> Function(Map<String, dynamic>) decode, {
    bool private = true,
    bool valid = true,
    bool write = false,
  }) async {
    if (!valid) return const Left(_invalid);
    final actor = currentUserId;
    if (private && actor == null) return const Left(_auth);
    var changed = false;
    final subscription = sessionChanges.listen((id) {
      if (id != actor) changed = true;
    });
    try {
      final response = await _rpc(
        name,
        args,
      ).timeout(const Duration(seconds: 20));
      if (changed || currentUserId != actor) return const Left(_auth);
      final result = await decode(_map(response));
      if (changed || currentUserId != actor) return const Left(_auth);
      return Right(result);
    } catch (e) {
      if (changed || currentUserId != actor) return const Left(_auth);
      if (e is PostgrestException) {
        final code = e.message;
        if (e.code == '28000' || e.code == '42501') return const Left(_auth);
        if (code.contains('CAMPAIGN_CHANGED')) {
          return const Left(
            TrustFailure(
              TrustFailureKind.changed,
              'Kampanya başka bir işlemle değişti. Güncel kaydı açın.',
            ),
          );
        }
        if (code.contains('price_publication_pending')) {
          return const Left(
            TrustFailure(
              TrustFailureKind.unavailable,
              'Fiyatlı kampanyaların yayını henüz açılmadı. Taslağınız korunuyor.',
            ),
          );
        }
        if (e.code == '55000') {
          return const Left(
            TrustFailure(
              TrustFailureKind.unavailable,
              'Yayın şu anda mümkün değil. Ürünleri ve yayın durumunu kontrol edin.',
            ),
          );
        }
        if (e.code == '22023' || e.code == 'P0002') return const Left(_invalid);
      }
      return Left(
        TrustFailure(
          write ? TrustFailureKind.uncertain : TrustFailureKind.unavailable,
          write
              ? 'İşlem sonucu doğrulanamadı. Aynı işlemi güvenle yeniden deneyin.'
              : 'Bilgiler yüklenemedi. Bağlantınızı kontrol edip tekrar deneyin.',
        ),
      );
    } finally {
      await subscription.cancel();
    }
  }

  @override
  Future<Either<TrustFailure, TrustSnapshot>> trust({
    String? shopId,
    int? before,
  }) => _call(
    'read_my_trust_v1',
    {'p_shop_id': shopId, 'p_limit': 30, 'p_before': before},
    (j) => TrustSnapshot(
      enabled: _bool(j, 'enabled'),
      badges: List.unmodifiable(_list(j['badges']).map(_badge)),
      history: List.unmodifiable(
        _list(j['history']).map(
          (e) => TrustEvent(
            _int(e, 'id'),
            _str(e, 'code'),
            _str(e, 'event'),
            _str(e, 'reason'),
            _date(e, 'recorded_at'),
          ),
        ),
      ),
      nextBefore: j['next_before'] == null ? null : _int(j, 'next_before'),
    ),
    valid:
        (shopId == null || _uuid.hasMatch(shopId)) &&
        (before == null || before > 0),
  );

  @override
  Future<Either<TrustFailure, List<TrustBadge>>> shopBadges(String shopId) =>
      _call(
        'read_badges_v1',
        {
          'p_shop_ids': [shopId],
        },
        (j) {
          if (!_bool(j, 'enabled')) return <TrustBadge>[];
          final rows = _list(j['shops']);
          if (rows.length != 1 || _str(rows.single, 'shop_id') != shopId) {
            throw const FormatException();
          }
          return List.unmodifiable(
            _list(rows.single['badges']).map(_badge).where((b) => b.eligible),
          );
        },
        private: false,
        valid: _uuid.hasMatch(shopId),
      );

  @override
  Future<Either<TrustFailure, CampaignPage>> campaigns(
    String shopId, {
    int offset = 0,
  }) => _call(
    'read_merchant_campaigns_v1',
    {'p_shop_id': shopId, 'p_limit': 30, 'p_offset': offset},
    (j) async => CampaignPage(
      enabled: _bool(j, 'enabled'),
      pricePublicationEnabled: _bool(j, 'price_publication_enabled'),
      total: _int(j, 'total'),
      campaigns: await _campaigns(j['campaigns'], shopId),
    ),
    valid: _uuid.hasMatch(shopId) && offset >= 0 && offset <= 500,
  );

  @override
  Future<Either<TrustFailure, List<Campaign>>> shopCampaigns(String shopId) =>
      _call(
        'read_shop_campaigns_v1',
        {'p_shop_id': shopId, 'p_listing_id': null},
        (j) async {
          if (!_bool(j, 'enabled')) return <Campaign>[];
          final rows = await _campaigns(
            j['campaigns'],
            shopId,
            serverTime: _date(j, 'server_time'),
          );
          if (rows.any((c) => c.status != 'active')) {
            throw const FormatException();
          }
          return rows;
        },
        private: false,
        valid: _uuid.hasMatch(shopId),
      );

  @override
  Future<Either<TrustFailure, CampaignReceipt>> mutate(
    CampaignCommand command,
  ) => _call(
    'mutate_campaign_v1',
    {
      'p_shop_id': command.shopId,
      'p_campaign_id': command.campaignId,
      'p_expected_revision': command.expectedRevision,
      'p_request_id': command.requestId,
      'p_action': command.action,
      'p_draft': command.draft?.toJson(),
    },
    (j) {
      final result = CampaignReceipt(
        _id(j, 'id'),
        _id(j, 'shop_id'),
        _id(j, 'revision_id'),
        _str(j, 'action'),
      );
      if (result.shopId != command.shopId ||
          result.action != command.action ||
          (command.campaignId != null && result.id != command.campaignId)) {
        throw const FormatException();
      }
      return result;
    },
    write: true,
    valid:
        _uuid.hasMatch(command.shopId) &&
        _uuid.hasMatch(command.requestId) &&
        (command.campaignId == null || _uuid.hasMatch(command.campaignId!)) &&
        (command.expectedRevision == null ||
            _uuid.hasMatch(command.expectedRevision!)) &&
        ['save', 'activate', 'pause'].contains(command.action) &&
        (command.action == 'save'
            ? command.draft != null && command.draft!.error == null
            : command.draft == null) &&
        (command.draft?.listingIds.every(_uuid.hasMatch) ?? true) &&
        (command.draft?.imageIds.every(_uuid.hasMatch) ?? true),
  );

  Future<List<Campaign>> _campaigns(
    dynamic value,
    String shopId, {
    DateTime? serverTime,
  }) async {
    final receivedAt = DateTime.now();
    final result = <Campaign>[];
    for (final j in _list(value)) {
      if (_id(j, 'shop_id') != shopId) throw const FormatException();
      final type = CampaignType.values.byName(_str(j, 'type'));
      final scope = CampaignScope.values.byName(_str(j, 'scope'));
      final draft = CampaignDraft(
        title: _str(j, 'title'),
        description: _str(j, 'description'),
        type: type,
        scope: scope,
        startsAt: _date(j, 'starts_at'),
        endsAt: _date(j, 'ends_at'),
        listingIds: _ids(j['listing_ids']),
        imageIds: _ids(j['image_ids'] ?? const []),
        priceMinor: j['price_minor'] == null ? null : _int(j, 'price_minor'),
        percentageBasisPoints: j['percentage_basis_points'] == null
            ? null
            : _int(j, 'percentage_basis_points'),
      );
      if (draft.error != null ||
          ![
            'draft',
            'scheduled',
            'active',
            'ended',
            'paused',
            'blocked',
          ].contains(j['status'])) {
        throw const FormatException();
      }
      final images = <CampaignImage>[];
      for (final i in _list(j['images'])) {
        final id = _id(i, 'id'),
            listing = _id(i, 'listing_id'),
            path = _str(i, 'object_path');
        // Paths come from A's immutable allocation; never sign arbitrary URLs.
        if (i['bucket_id'] != 'listing-media' ||
            path.contains('..') ||
            path.contains('://') ||
            !path.startsWith('shops/$shopId/$listing/')) {
          throw const FormatException();
        }
        images.add(CampaignImage(id, listing, path));
      }
      result.add(
        Campaign(
          id: _id(j, 'id'),
          shopId: shopId,
          revisionId: _id(j, 'revision_id'),
          draft: draft,
          displayExpiresAt: serverTime == null
              ? null
              : receivedAt.add(draft.endsAt.difference(serverTime)),
          status: _str(j, 'status'),
          active: j['active'] == null
              ? j['status'] == 'active'
              : _bool(j, 'active'),
          blockedReason: j['blocked_reason'] as String?,
          images: List.unmodifiable(images),
          products: List.unmodifiable(
            _list(j['products']).map(
              (p) => CampaignProduct(_id(p, 'listing_id'), _str(p, 'name')),
            ),
          ),
        ),
      );
    }
    // One bounded image budget for the whole response; a missing image must not
    // turn a 500-row catalog into sequential multi-minute network waits.
    final images = result.expand((c) => c.images).toList();
    final urls = <String, String?>{};
    final watch = Stopwatch()..start();
    var next = 0;
    Future<void> signBatch() async {
      while (next < images.length && watch.elapsedMilliseconds < 5000) {
        final image = images[next++];
        try {
          urls[image.id] = await _sign(
            image.path,
          ).timeout(Duration(milliseconds: 5000 - watch.elapsedMilliseconds));
        } catch (_) {
          /* Preserve readable offer text with an image fallback. */
        }
      }
    }

    await Future.wait(List.generate(4, (_) => signBatch()));
    return List.unmodifiable(
      result.map(
        (c) => Campaign(
          id: c.id,
          shopId: c.shopId,
          revisionId: c.revisionId,
          draft: c.draft,
          status: c.status,
          active: c.active,
          blockedReason: c.blockedReason,
          products: c.products,
          displayExpiresAt: c.displayExpiresAt,
          images: List.unmodifiable(
            c.images.map(
              (i) => CampaignImage(i.id, i.listingId, i.path, url: urls[i.id]),
            ),
          ),
        ),
      ),
    );
  }

  static TrustBadge _badge(Map<String, dynamic> j) => TrustBadge(
    code: _str(j, 'code'),
    family: _str(j, 'family'),
    level: _int(j, 'level'),
    title: _str(j, 'title'),
    explanation: _str(j, 'explanation'),
    eligible: _bool(j, 'eligible'),
    pending: _bool(j, 'pending'),
    count: j['count'] == null ? null : _int(j, 'count'),
    requiredCount: j['required_count'] == null
        ? null
        : _int(j, 'required_count'),
    value: (j['value'] as num?)?.toDouble(),
    requiredValue: (j['required_value'] as num?)?.toDouble(),
  );
  static Map<String, dynamic> _map(dynamic v) {
    if (v is! Map) throw const FormatException();
    return Map<String, dynamic>.from(v);
  }

  static List<Map<String, dynamic>> _list(dynamic v) {
    if (v is! List) throw const FormatException();
    return v.map(_map).toList();
  }

  static List<String> _ids(dynamic v) {
    if (v is! List || v.any((id) => id is! String || !_uuid.hasMatch(id))) {
      throw const FormatException();
    }
    return List<String>.unmodifiable(v);
  }

  static String _str(Map<String, dynamic> j, String k) {
    final v = j[k];
    if (v is! String) throw const FormatException();
    return v;
  }

  static String _id(Map<String, dynamic> j, String k) {
    final v = _str(j, k);
    if (!_uuid.hasMatch(v)) throw const FormatException();
    return v;
  }

  static int _int(Map<String, dynamic> j, String k) {
    final v = j[k];
    if (v is! int || v < 0) throw const FormatException();
    return v;
  }

  static bool _bool(Map<String, dynamic> j, String k) {
    final v = j[k];
    if (v is! bool) throw const FormatException();
    return v;
  }

  static DateTime _date(Map<String, dynamic> j, String k) =>
      DateTime.parse(_str(j, k));
}
