import 'package:dartz/dartz.dart';
import 'package:t_store/features/trust_commerce/domain/trust_commerce.dart';

enum PromotionFamily { store, product, offer, invitation }

enum PromotionFailure {
  session,
  changed,
  invalid,
  unavailable,
  uncertain;

  String get message => switch (this) {
    session => 'Oturum değişti. Tanıtım merkezini yeniden aç.',
    changed => 'Bilgiler değişmiş. Listeyi veya önizlemeyi yenile.',
    invalid => 'İşlem doğrulanamadı. Bilgileri yeniden kontrol et.',
    unavailable => 'Tanıtım merkezi şu anda kullanılamıyor.',
    uncertain => 'İşlemin sonucu alınamadı. Aynı işlemi tekrar kontrol et.',
  };
}

class PromotionSelection {
  const PromotionSelection({
    this.family = PromotionFamily.store,
    this.variant = 0,
    this.listingId,
    this.campaignId,
    this.imageId,
  });
  final PromotionFamily family;
  final int variant;
  final String? listingId, campaignId, imageId;
  Map<String, dynamic> toJson() => {
    'family': family.name,
    'variant': variant,
    'listing_id': listingId,
    'campaign_id': campaignId,
    'image_id': imageId,
  };
  factory PromotionSelection.fromJson(Map<String, dynamic> j) {
    final family = PromotionFamily.values
        .where((e) => e.name == j['family'])
        .single;
    final variant = j['variant'];
    if (variant != 0 && variant != 1) throw const FormatException();
    return PromotionSelection(
      family: family,
      variant: variant as int,
      listingId: optionalId(j['listing_id']),
      campaignId: optionalId(j['campaign_id']),
      imageId: optionalId(j['image_id']),
    );
  }
}

class PromotionCopy {
  const PromotionCopy(
    this.title,
    this.body, {
    this.startsAt,
    this.endsAt,
    this.products = const [],
  });
  final String title, body;
  final DateTime? startsAt, endsAt;
  final List<String> products;
  factory PromotionCopy.fromJson(Map<String, dynamic> j) {
    final facts = object(j['facts']);
    return PromotionCopy(
      string(j['title']),
      string(j['body']),
      startsAt: optionalDate(facts['starts_at']),
      endsAt: optionalDate(facts['ends_at']),
      products: List.unmodifiable(
        facts['products'] == null
            ? <String>[]
            : array(facts['products']).map((p) => string(object(p)['name'])),
      ),
    );
  }
}

class PromotionPhoto {
  const PromotionPhoto({
    required this.id,
    required this.listingId,
    required this.path,
    this.url,
  });
  final String id, listingId, path;
  final String? url;
}

class PromotionPreview {
  const PromotionPreview({
    required this.enabled,
    required this.ready,
    this.copy,
    this.fingerprint,
    this.images = const [],
  });
  final bool enabled, ready;
  final PromotionCopy? copy;
  final String? fingerprint;
  final List<PromotionPhoto> images;
}

class PromotionDraft {
  const PromotionDraft({
    required this.id,
    required this.revisionId,
    required this.shopId,
    required this.status,
    required this.selection,
    required this.copy,
    required this.recordedAt,
  });
  final String id, revisionId, shopId, status;
  final PromotionSelection selection;
  final PromotionCopy copy;
  final DateTime recordedAt;
  factory PromotionDraft.fromJson(Map<String, dynamic> j) {
    final status = string(j['status']);
    if (!['draft', 'needs_update', 'archived'].contains(status)) {
      throw const FormatException();
    }
    return PromotionDraft(
      id: promotionId(j['id']),
      revisionId: promotionId(j['revision_id']),
      shopId: promotionId(j['shop_id']),
      status: status,
      selection: PromotionSelection.fromJson(object(j['selection'])),
      copy: PromotionCopy.fromJson(object(j['snapshot'])),
      recordedAt: DateTime.parse(string(j['recorded_at'])),
    );
  }
  String get statusLabel => switch (status) {
    'needs_update' => 'Güncellenmeli',
    'archived' => 'Arşivde',
    _ => 'Taslak',
  };
}

class PromotionPage {
  const PromotionPage({
    required this.enabled,
    required this.items,
    required this.hasMore,
  });
  final bool enabled, hasMore;
  final List<PromotionDraft> items;
}

class PromotionSource {
  const PromotionSource(this.id, this.label);
  final String id, label;
}

class PromotionHistoryEntry {
  const PromotionHistoryEntry(
    this.revisionId,
    this.action,
    this.copy,
    this.recordedAt,
  );
  final String revisionId, action;
  final PromotionCopy copy;
  final DateTime recordedAt;
}

class PromotionCommand {
  PromotionCommand({
    required this.shopId,
    this.draftId,
    this.expectedRevision,
    required this.action,
    this.selection,
    this.fingerprint,
    String? requestId,
  }) : requestId = requestId ?? newCampaignRequestId();
  final String shopId, action, requestId;
  final String? draftId, expectedRevision, fingerprint;
  final PromotionSelection? selection;
  Map<String, dynamic> toJson() => {
    'p_shop_id': shopId,
    'p_draft_id': draftId,
    'p_expected_revision': expectedRevision,
    'p_request_id': requestId,
    'p_action': action,
    'p_selection': selection?.toJson(),
    'p_fingerprint': fingerprint,
  };
}

class PromotionReceipt {
  const PromotionReceipt(this.id, this.revisionId, this.action);
  final String id, revisionId, action;
}

abstract interface class MerchantPromotionRepository {
  String? get currentUserId;
  Stream<String?> get sessionChanges;
  Future<Either<PromotionFailure, PromotionPage>> read(
    String shopId, {
    int offset = 0,
  });
  Future<Either<PromotionFailure, List<PromotionSource>>> sources(
    String shopId,
    String kind, {
    String query = '',
    int offset = 0,
  });
  Future<Either<PromotionFailure, PromotionPreview>> preview(
    String shopId,
    PromotionSelection selection,
  );
  Future<Either<PromotionFailure, PromotionReceipt>> mutate(
    PromotionCommand command,
  );
  Future<Either<PromotionFailure, List<PromotionHistoryEntry>>> history(
    String shopId,
    String draftId, {
    int offset = 0,
  });
}

// Fail closed on wire schema drift; PostgREST is untrusted input.
Map<String, dynamic> object(dynamic value) {
  if (value is! Map<String, dynamic>) throw const FormatException();
  return value;
}

String string(dynamic value) {
  if (value is! String || value.isEmpty) throw const FormatException();
  return value;
}

String promotionId(dynamic value) {
  final result = string(value);
  if (!RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  ).hasMatch(result)) {
    throw const FormatException();
  }
  return result;
}

String? optionalId(dynamic value) => value == null ? null : promotionId(value);
DateTime? optionalDate(dynamic value) =>
    value == null ? null : DateTime.parse(string(value));
List<dynamic> array(dynamic value) {
  if (value is! List) throw const FormatException();
  return value;
}

bool boolean(dynamic value) {
  if (value is! bool) throw const FormatException();
  return value;
}
