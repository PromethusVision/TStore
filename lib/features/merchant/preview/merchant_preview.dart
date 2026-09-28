import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';
import 'package:t_store/features/cart/domain/repositories/qr_session_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_credentials.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/domain/repositories/notification_repository.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';

/// Synthetic, memory-only host; imported exclusively by the preview entrypoint/tests.
class MerchantPreview {
  MerchantPreview({
    bool signedIn = true,
    bool hasShop = true,
    bool empty = false,
    String role = UserEntity.merchantRole,
  }) {
    user = UserEntity(
      id: userId,
      email: 'esnaf@example.invalid',
      fullName: 'Örnek Esnaf',
      role: role,
    );
    currentId = signedIn ? userId : null;
    repository = PreviewMerchantRepository(
      this,
      hasShop: hasShop,
      empty: empty,
    );
    notifications = PreviewNotifications(this);
    services = MerchantServices(
      merchants: repository,
      credentials: _PreviewCredentials(this),
      notifications: notifications,
      qr: _PreviewQr(this),
      preferences: PreviewPreferences(),
      sessionChanges: changes.stream,
      currentUserId: () => currentId,
      preview: true,
    );
  }
  static const userId = '11111111-1111-4111-8111-111111111111';
  static const shopId = '22222222-2222-4222-8222-222222222222';
  late UserEntity user;
  String? currentId;
  final changes = StreamController<String?>.broadcast(sync: true);
  late final PreviewMerchantRepository repository;
  late final PreviewNotifications notifications;
  late final MerchantServices services;
  Future<void> dispose() async {
    await changes.close();
    await notifications.events.close();
  }
}

class PreviewMerchantRepository implements MerchantRepository {
  PreviewMerchantRepository(
    this.host, {
    required bool hasShop,
    required bool empty,
  }) {
    if (hasShop) {
      shop = ShopEntity(
        id: MerchantPreview.shopId,
        ownerUserId: host.user.id,
        name: 'Mahalle Market • Örnek',
        description: 'Yerel önizleme mağazası',
        address: 'Örnek sokak, Esenler',
        updatedAt: DateTime.utc(2026, 9, 1),
      );
    }
    if (!empty && hasShop) {
      items = [
        for (var i = 0; i < 3; i++)
          ShopProductEntity(
            id: 'listing-$i',
            shopId: shop!.id,
            productId: catalog[i].id,
            price: [49.90, 32.50, 85.0][i],
            isAvailable: i != 1,
            isActive: i != 2,
            product: catalog[i],
            shop: shop,
            updatedAt: DateTime.utc(2026, 9, 1),
          ),
      ];
    }
  }
  final MerchantPreview host;
  ShopEntity? shop;
  List<ShopProductEntity> items = [];
  String? failure;
  int saveCount = 0;
  static final catalog = [
    for (final entry in [
      'Tam yağlı süt 1 L',
      'Maden suyu 6 × 200 ml',
      'Türk kahvesi 100 g',
      'Pirinç 1 kg',
      'Zeytinyağı 1 L',
    ].asMap().entries)
      ProductEntity(
        id: 'catalog-${entry.key}',
        name: entry.value,
        price: 0,
        categoryId: 'preview-category',
        stock: 0,
        images: const [],
        brandName: 'Örnek marka',
      ),
  ];
  bool _allowed(MerchantAccess access) =>
      host.currentId == access.user.id &&
      host.user.isMerchant &&
      shop?.id == access.shop?.id &&
      (shop == null || shop!.isActive);
  @override
  Future<Either<String, MerchantAccess?>> loadAccess() async => failure != null
      ? Left(failure!)
      : Right(
          host.currentId == null
              ? null
              : MerchantAccess(user: host.user, shop: shop),
        );
  @override
  Future<Either<String, ShopEntity>> saveShop(
    MerchantAccess access,
    MerchantShopDraft draft,
  ) async {
    if (!_allowed(access)) return const Left(merchantAccessDenied);
    if (failure != null || draft.error != null) {
      return Left(failure ?? draft.error!);
    }
    ++saveCount;
    shop = ShopEntity(
      id: MerchantPreview.shopId,
      ownerUserId: host.user.id,
      name: draft.name.trim(),
      description: draft.description.trim(),
      address: draft.address.trim(),
      phone: draft.phone.trim(),
      openingHours: draft.openingHours,
      updatedAt: DateTime.now().toUtc(),
    );
    return Right(shop!);
  }

  @override
  Future<Either<String, MerchantOverview>> overview(
    MerchantAccess access,
  ) async {
    if (!_allowed(access)) return const Left(merchantAccessDenied);
    if (failure != null) return Left(failure!);
    return Right(
      MerchantOverview(
        total: items.length,
        available: items.where((i) => i.isActive && i.isAvailable).length,
        unavailable: items.where((i) => i.isActive && !i.isAvailable).length,
        inactive: items.where((i) => !i.isActive).length,
      ),
    );
  }

  @override
  Future<Either<String, List<ShopProductEntity>>> listings(
    MerchantAccess access, {
    int page = 0,
    String query = '',
  }) async {
    if (!_allowed(access)) return const Left(merchantAccessDenied);
    if (failure != null) return Left(failure!);
    return Right(
      items
          .where(
            (i) => (i.product?.name ?? '').toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .skip(page * merchantPageSize)
          .take(merchantPageSize)
          .toList(),
    );
  }

  @override
  Future<Either<String, List<ProductEntity>>> searchCatalog(
    MerchantAccess access, {
    required String query,
    int page = 0,
  }) async {
    if (!_allowed(access)) return const Left(merchantAccessDenied);
    if (failure != null) return Left(failure!);
    return Right(
      catalog
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .skip(page * merchantPageSize)
          .take(merchantPageSize)
          .toList(),
    );
  }

  @override
  Future<Either<String, ShopProductEntity>> saveListing(
    MerchantAccess access,
    MerchantListingDraft draft, {
    ShopProductEntity? existing,
  }) async {
    if (!_allowed(access)) return const Left(merchantAccessDenied);
    if (failure != null || draft.error != null) {
      return Left(failure ?? draft.error!);
    }
    if (existing == null && items.any((i) => i.productId == draft.productId)) {
      return const Left('Bu ürün zaten var. Mevcut kaydı düzenleyin.');
    }
    ++saveCount;
    final item = ShopProductEntity(
      id: existing?.id ?? 'listing-new-$saveCount',
      shopId: shop!.id,
      productId: draft.productId,
      price: draft.priceMinor / 100,
      description: draft.description,
      isActive: draft.active,
      isAvailable: draft.available,
      product: catalog.firstWhere((p) => p.id == draft.productId),
      shop: shop,
      updatedAt: DateTime.now().toUtc(),
    );
    items = [...items.where((i) => i.id != item.id), item];
    return Right(item);
  }
}

class _PreviewCredentials implements MerchantCredentials {
  const _PreviewCredentials(this.host);
  final MerchantPreview host;
  @override
  Future<Either<String, void>> signIn(String email, String password) async {
    host.currentId = host.user.id;
    host.changes.add(host.currentId);
    return const Right(null);
  }

  @override
  Future<Either<String, void>> signOut() async {
    host.currentId = null;
    host.changes.add(null);
    return const Right(null);
  }
}

class PreviewPreferences implements NotificationPreferencesRepository {
  final _values = <String, NotificationPreferences>{};
  @override
  bool get serverBacked => false;
  @override
  Future<NotificationPreferences> read(PushIdentity identity) async =>
      _values['${identity.userId}:${identity.role.name}'] ??
      const NotificationPreferences();
  @override
  Future<void> save(
    PushIdentity identity,
    NotificationPreferences preferences,
  ) async {
    _values['${identity.userId}:${identity.role.name}'] = preferences;
  }
}

class PreviewNotifications implements NotificationRepository {
  PreviewNotifications(this.host);
  final MerchantPreview host;
  final events = StreamController<NotificationEntity>.broadcast();
  List<NotificationEntity> items = const [
    NotificationEntity(
      id: 'notice-1',
      userId: MerchantPreview.userId,
      title: 'Esnaf uygulamasına hoş geldin',
      body: 'Bu, yerel önizleme için örnek bir bildirimdir.',
      type: NotificationType.system,
      data: {'app_role': 'merchant'},
    ),
  ];
  @override
  Stream<NotificationEntity> get notificationsStream => events.stream;
  @override
  Future<Either<String, List<NotificationEntity>>> getNotifications({
    int page = 0,
    int limit = 20,
  }) async => Right(
    items
        .where((n) => n.userId == host.currentId)
        .skip(page * limit)
        .take(limit)
        .toList(),
  );
  @override
  Future<Either<String, int>> getUnreadCount() async =>
      Right(items.where((n) => !n.isRead).length);
  @override
  Future<Either<String, void>> markAsRead(String notificationId) async {
    items = items
        .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
        .toList();
    return const Right(null);
  }

  @override
  Future<Either<String, void>> markAllAsRead() async {
    items = items.map((n) => n.copyWith(isRead: true)).toList();
    return const Right(null);
  }

  @override
  Future<Either<String, void>> deleteNotification(String notificationId) async {
    items = items.where((n) => n.id != notificationId).toList();
    return const Right(null);
  }

  @override
  Future<Either<String, void>> deleteAllNotifications() async {
    items = [];
    return const Right(null);
  }
}

class _PreviewQr implements QrSessionRepository {
  _PreviewQr(this.host);
  final MerchantPreview host;
  QrVerificationEntity? _record;
  @override
  Future<Either<String, QrVerificationEntity>> getQrVerification({
    required String sessionToken,
  }) async {
    if (sessionToken != 'merchant-v1-preview') {
      return const Left('Yerel test QR kodu bulunamadı.');
    }
    _record ??= QrVerificationEntity(
      sessionId: 'preview-session',
      sessionToken: sessionToken,
      status: 'active',
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      shopId: MerchantPreview.shopId,
      shopName: 'Örnek mağaza',
      itemCount: 1,
      totalAmount: 49.90,
      items: const [
        QrVerificationItemEntity(
          id: 'line-1',
          shopProductId: 'listing-0',
          productName: 'Tam yağlı süt 1 L',
          quantity: 1,
          unitPrice: 49.90,
          lineTotal: 49.90,
        ),
      ],
    );
    return Right(_record!);
  }

  @override
  Future<Either<String, QrVerificationEntity>> confirmQrVerification({
    required String sessionToken,
  }) async {
    final old = _record;
    if (host.currentId == null ||
        old == null ||
        !old.canBeConfirmed ||
        old.sessionToken != sessionToken) {
      return const Left('QR doğrulanamadı.');
    }
    _record = QrVerificationEntity(
      sessionId: old.sessionId,
      sessionToken: old.sessionToken,
      status: 'used',
      expiresAt: old.expiresAt,
      usedAt: DateTime.now(),
      shopId: old.shopId,
      shopName: old.shopName,
      itemCount: old.itemCount,
      totalAmount: old.totalAmount,
      items: old.items,
    );
    return Right(_record!);
  }

  @override
  Future<Either<String, QrSessionEntity>> createQrSession({
    required String cartId,
  }) async => const Left('Müşteri akışı kapsam dışı.');
  @override
  Future<Either<String, String>> getQrSessionStatus({
    required String sessionId,
  }) async => const Left('Müşteri akışı kapsam dışı.');
}
