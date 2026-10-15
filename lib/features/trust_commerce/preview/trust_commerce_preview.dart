import 'package:dartz/dartz.dart';
import 'package:t_store/features/trust_commerce/domain/trust_commerce.dart';

const previewTrustActor = '11111111-1111-4111-8111-111111111111';
const previewTrustShop = '22222222-2222-4222-8222-222222222222';
const previewCampaignId = '33333333-3333-4333-8333-333333333333';
const previewCampaignRevision = '44444444-4444-4444-8444-444444444444';
const previewCampaignListing = '55555555-5555-4555-8555-555555555555';

/// Synthetic memory-only fixtures. Imported by the explicit preview host/tests;
/// never registered by Customer or Merchant development/production bootstraps.
class PreviewTrustCommerceRepository implements TrustCommerceRepository {
  PreviewTrustCommerceRepository({
    required String? Function() user,
    required this.sessionChanges,
  }) : _user = user;
  final String? Function() _user;
  @override
  String? get currentUserId => _user();
  @override
  final Stream<String?> sessionChanges;
  bool enabled = true, pricePublicationEnabled = false;
  static const badges = [
    TrustBadge(
      code: 'friendliness',
      family: 'friendliness',
      level: 1,
      title: 'Güleryüzlü Esnaf',
      explanation: 'En az 20 farklı doğrulanmış müşteri ve 4,70 ortalama.',
      eligible: true,
      count: 26,
      requiredCount: 20,
      value: 4.81,
      requiredValue: 4.7,
    ),
    TrustBadge(
      code: 'products',
      family: 'products',
      level: 1,
      title: 'Ürünleri Sevilen Esnaf',
      explanation:
          'Bu mağazadaki alışverişlerden en az 20 farklı müşteri ve 4,80 ürün puanı.',
      eligible: false,
      count: 17,
      requiredCount: 20,
      value: 4.9,
      requiredValue: 4.8,
    ),
    TrustBadge(
      code: 'neighborhood',
      family: 'neighborhood',
      level: 1,
      title: 'Mahallenin Yıldızı',
      explanation:
          'Son 90 günde doğrulanmış farklı müşteri sayısıyla onaylı mahallesindeki ilk %10.',
      eligible: false,
      pending: true,
    ),
    TrustBadge(
      code: 'communication',
      family: 'communication',
      level: 1,
      title: 'İletişimi İyi',
      explanation: 'En az 20 farklı doğrulanmış müşteri ve 4,80 ortalama.',
      eligible: true,
      count: 26,
      requiredCount: 20,
      value: 4.85,
      requiredValue: 4.8,
    ),
    TrustBadge(
      code: 'cleanliness',
      family: 'cleanliness',
      level: 1,
      title: 'Tertemiz Esnaf',
      explanation: 'En az 20 farklı doğrulanmış müşteri ve 4,80 ortalama.',
      eligible: true,
      count: 26,
      requiredCount: 20,
      value: 4.92,
      requiredValue: 4.8,
    ),
  ];
  static final customerBadges = [
    for (final family in ['purchases', 'reviews'])
      for (final (index, goal) in [10, 50, 100, 250].indexed)
        TrustBadge(
          code: '${family}_$goal',
          family: family,
          level: index + 1,
          title: family == 'purchases'
              ? (goal == 250 ? "EsnaftaVar'ın Yıldızı" : '$goal Alışveriş')
              : [
                  'Aktif Yorumcu',
                  'Deneyimli Yorumcu',
                  'Uzman Yorumcu',
                  'Mahalle Rehberi',
                ][index],
          explanation:
              '$goal farklı doğrulanmış ${family == 'purchases' ? 'alışveriş' : 'ürün değerlendirmesi'}.',
          eligible: goal <= 10,
          count: family == 'purchases' ? 32 : 12,
          requiredCount: goal,
        ),
  ];
  static CampaignDraft exampleDraft({
    CampaignType type = CampaignType.announcement,
  }) => CampaignDraft(
    title: 'Haftanın mahalle buluşması',
    description: 'Taze ürünlerimizi mağazada inceleyebilirsiniz.',
    type: type,
    scope: CampaignScope.single,
    startsAt: DateTime(2026, 10, 15, 9),
    endsAt: DateTime(2026, 10, 22, 21),
    listingIds: const [previewCampaignListing],
    priceMinor: type == CampaignType.price ? 1000 : null,
    percentageBasisPoints: type == CampaignType.percentage ? 1000 : null,
  );
  final rows = <Campaign>[
    Campaign(
      id: previewCampaignId,
      shopId: previewTrustShop,
      revisionId: previewCampaignRevision,
      draft: exampleDraft(),
      status: 'active',
      active: true,
      products: const [
        CampaignProduct(
          previewCampaignListing,
          'Geleneksel öğütülmüş Türk kahvesi',
        ),
      ],
    ),
    Campaign(
      id: '66666666-6666-4666-8666-666666666666',
      shopId: previewTrustShop,
      revisionId: '77777777-7777-4777-8777-777777777777',
      draft: exampleDraft(type: CampaignType.percentage),
      status: 'draft',
      blockedReason: 'price_publication_pending',
    ),
  ];
  @override
  Future<Either<TrustFailure, TrustSnapshot>> trust({
    String? shopId,
    int? before,
  }) async => Right(
    TrustSnapshot(
      enabled: enabled,
      badges: enabled ? (shopId == null ? customerBadges : badges) : const [],
      history: enabled
          ? [
              TrustEvent(
                2,
                shopId == null ? 'purchases_10' : 'friendliness',
                'awarded',
                'qualification_changed',
                DateTime(2026, 10, 15, 10),
              ),
            ]
          : const [],
    ),
  );
  @override
  Future<Either<TrustFailure, List<TrustBadge>>> shopBadges(
    String shopId,
  ) async => Right(enabled ? highestTrustBadges(badges) : []);
  @override
  Future<Either<TrustFailure, CampaignPage>> campaigns(
    String shopId, {
    int offset = 0,
  }) async => Right(
    CampaignPage(
      enabled: enabled,
      pricePublicationEnabled: pricePublicationEnabled,
      campaigns: rows.skip(offset).take(30).toList(),
      total: rows.length,
    ),
  );
  @override
  Future<Either<TrustFailure, List<Campaign>>> shopCampaigns(
    String shopId,
  ) async =>
      Right(enabled ? rows.where((c) => c.status == 'active').toList() : []);
  @override
  Future<Either<TrustFailure, CampaignReceipt>> mutate(
    CampaignCommand command,
  ) async {
    final id = command.campaignId ?? newCampaignRequestId(),
        revision = newCampaignRequestId();
    final old = rows.where((c) => c.id == id).firstOrNull;
    final draft = command.draft ?? old!.draft;
    rows.removeWhere((c) => c.id == id);
    rows.insert(
      0,
      Campaign(
        id: id,
        shopId: command.shopId,
        revisionId: revision,
        draft: draft,
        status: command.action == 'activate'
            ? 'active'
            : command.action == 'pause'
            ? 'paused'
            : 'draft',
        active: command.action == 'activate',
      ),
    );
    return Right(CampaignReceipt(id, command.shopId, revision, command.action));
  }
}
