import 'package:dartz/dartz.dart';
import 'dart:math';

String newCampaignRequestId() {
  final random = Random.secure();
  final bytes = List.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

enum TrustFailureKind { auth, invalid, changed, unavailable, uncertain }

class TrustFailure {
  const TrustFailure(this.kind, this.message);
  final TrustFailureKind kind;
  final String message;
  bool get retrySameRequest => kind == TrustFailureKind.uncertain;
}

class TrustBadge {
  const TrustBadge({
    required this.code,
    required this.family,
    required this.level,
    required this.title,
    required this.explanation,
    required this.eligible,
    this.pending = false,
    this.count,
    this.requiredCount,
    this.value,
    this.requiredValue,
  });
  final String code, family, title, explanation;
  final int level;
  final bool eligible, pending;
  final int? count, requiredCount;
  final double? value, requiredValue;
  double get progress => requiredCount == null || requiredCount == 0
      ? 0
      : ((count ?? 0) / requiredCount!).clamp(0, 1);
}

List<TrustBadge> highestTrustBadges(List<TrustBadge> badges) {
  final families = <String, TrustBadge>{};
  for (final badge in badges.where((b) => b.eligible)) {
    if ((families[badge.family]?.level ?? 0) < badge.level) {
      families[badge.family] = badge;
    }
  }
  return List.unmodifiable(families.values);
}

class TrustEvent {
  const TrustEvent(
    this.id,
    this.code,
    this.event,
    this.reason,
    this.recordedAt,
  );
  final int id;
  final String code, event, reason;
  final DateTime recordedAt;
}

class TrustSnapshot {
  const TrustSnapshot({
    required this.enabled,
    this.badges = const [],
    this.history = const [],
    this.nextBefore,
  });
  final bool enabled;
  final List<TrustBadge> badges;
  final List<TrustEvent> history;
  final int? nextBefore;
}

enum CampaignType { announcement, price, percentage }

enum CampaignScope { single, multiple, all }

class CampaignDraft {
  CampaignDraft({
    required this.title,
    required this.description,
    required this.type,
    required this.scope,
    required this.startsAt,
    required this.endsAt,
    List<String> listingIds = const [],
    List<String> imageIds = const [],
    this.priceMinor,
    this.percentageBasisPoints,
  }) : listingIds = List.unmodifiable(listingIds),
       imageIds = List.unmodifiable(imageIds);
  final String title, description;
  final CampaignType type;
  final CampaignScope scope;
  final DateTime startsAt, endsAt;
  final List<String> listingIds, imageIds;
  final int? priceMinor, percentageBasisPoints;
  String? get error {
    if (title.trim().isEmpty ||
        title.trim().length > 100 ||
        description.trim().length > 500) {
      return 'Başlık 1–100, açıklama en fazla 500 karakter olmalı.';
    }
    if (!endsAt.isAfter(startsAt)) return 'Bitiş, başlangıçtan sonra olmalı.';
    if ((scope == CampaignScope.single && listingIds.length != 1) ||
        (scope == CampaignScope.multiple &&
            (listingIds.length < 2 || listingIds.length > 100)) ||
        (scope == CampaignScope.all && listingIds.isNotEmpty) ||
        listingIds.toSet().length != listingIds.length ||
        imageIds.length > 5 ||
        imageIds.toSet().length != imageIds.length) {
      return 'Kapsama uygun ürünleri ve en fazla 5 fotoğraf seçin.';
    }
    if (type == CampaignType.price &&
        (priceMinor == null ||
            priceMinor! < 1 ||
            priceMinor! > 999999999 ||
            percentageBasisPoints != null)) {
      return 'Geçerli bir indirimli fiyat girin.';
    }
    if (type == CampaignType.percentage &&
        (percentageBasisPoints == null ||
            percentageBasisPoints! < 1 ||
            percentageBasisPoints! > 10000 ||
            priceMinor != null)) {
      return 'İndirim oranı %0,01–100 arasında olmalı.';
    }
    if (type == CampaignType.announcement &&
        (priceMinor != null || percentageBasisPoints != null)) {
      return 'Duyuruya fiyat veya indirim oranı eklenemez.';
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'title': title.trim(),
    'description': description.trim(),
    'type': type.name,
    'scope': scope.name,
    'starts_at': startsAt.toUtc().toIso8601String(),
    'ends_at': endsAt.toUtc().toIso8601String(),
    'listing_ids': listingIds,
    'image_ids': imageIds,
    'price_minor': priceMinor,
    'percentage_basis_points': percentageBasisPoints,
  };
  String get offerLabel => switch (type) {
    CampaignType.announcement => 'Mağaza duyurusu',
    CampaignType.price =>
      '${((priceMinor ?? 0) / 100).toStringAsFixed(2).replaceAll('.', ',')} TL',
    CampaignType.percentage =>
      '%${((percentageBasisPoints ?? 0) / 100).toStringAsFixed(2).replaceAll('.', ',')} indirim',
  };
}

class CampaignImage {
  const CampaignImage(this.id, this.listingId, this.path, {this.url});
  final String id, listingId, path;
  final String? url;
}

class CampaignProduct {
  const CampaignProduct(this.listingId, this.name);
  final String listingId, name;
}

class Campaign {
  const Campaign({
    required this.id,
    required this.shopId,
    required this.revisionId,
    required this.draft,
    required this.status,
    this.active = false,
    this.blockedReason,
    this.images = const [],
    this.products = const [],
    this.displayExpiresAt,
  });
  final String id, shopId, revisionId, status;
  final CampaignDraft draft;
  final bool active;
  final String? blockedReason;
  final List<CampaignImage> images;
  final List<CampaignProduct> products;

  /// Local deadline derived from the server clock, only on public projections.
  final DateTime? displayExpiresAt;
  String get statusLabel => switch (status) {
    'draft' => 'Taslak',
    'scheduled' => 'Planlandı',
    'active' => 'Yayında',
    'ended' => 'Sona erdi',
    'paused' => 'Yayında değil',
    _ => 'Yayın beklemede',
  };
  String? get blockedMessage => switch (blockedReason) {
    'price_publication_pending' =>
      'Fiyatlı kampanyaların yayını henüz açılmadı. Taslağını hazırlayabilirsin.',
    'listing_unavailable' => 'Seçili ürünlerden biri satışa açık değil.',
    'price_changed' => 'İndirimli fiyat güncel ürün fiyatından düşük olmalı.',
    'shop_unavailable' => 'Mağaza şu anda yayına açık değil.',
    'disabled' => 'Kampanyalar henüz kullanıma açılmadı.',
    _ => null,
  };
}

class CampaignPage {
  const CampaignPage({
    required this.enabled,
    required this.pricePublicationEnabled,
    this.campaigns = const [],
    this.total = 0,
  });
  final bool enabled, pricePublicationEnabled;
  final List<Campaign> campaigns;
  final int total;
}

/// Retain this exact immutable command after an unknown network outcome.
class CampaignCommand {
  const CampaignCommand({
    required this.shopId,
    required this.requestId,
    required this.action,
    this.campaignId,
    this.expectedRevision,
    this.draft,
  });
  final String shopId, requestId, action;
  final String? campaignId, expectedRevision;
  final CampaignDraft? draft;
}

class CampaignReceipt {
  const CampaignReceipt(this.id, this.shopId, this.revisionId, this.action);
  final String id, shopId, revisionId, action;
}

abstract interface class TrustCommerceRepository {
  String? get currentUserId;
  Stream<String?> get sessionChanges;
  Future<Either<TrustFailure, TrustSnapshot>> trust({
    String? shopId,
    int? before,
  });
  Future<Either<TrustFailure, List<TrustBadge>>> shopBadges(String shopId);
  Future<Either<TrustFailure, CampaignPage>> campaigns(
    String shopId, {
    int offset = 0,
  });
  Future<Either<TrustFailure, List<Campaign>>> shopCampaigns(String shopId);
  Future<Either<TrustFailure, CampaignReceipt>> mutate(CampaignCommand command);
}
