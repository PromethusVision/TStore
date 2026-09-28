import 'package:dartz/dartz.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';

/// Authoritative server profile, bound to one shop. Never built from user metadata.
class MerchantAccess {
  const MerchantAccess({required this.user, this.shop});
  final UserEntity user;
  final ShopEntity? shop;
  bool get hasRole => user.isMerchant;
  bool get ownsShop => shop != null && shop!.ownerUserId == user.id;
  bool get canManage => hasRole && ownsShop && shop!.isActive;
}

class MerchantShopDraft {
  const MerchantShopDraft({
    required this.name,
    this.description = '',
    this.phone = '',
    this.address = '',
    this.openingHours = const {},
  });
  final String name, description, phone, address;
  final Map<String, dynamic> openingHours;
  String? get error {
    if (name.trim().isEmpty || name.trim().length > 120) {
      return 'Mağaza adı 1–120 karakter olmalı.';
    }
    if (description.length > 2000 ||
        address.length > 500 ||
        phone.length > 30) {
      return 'Açıklama veya iletişim bilgisi çok uzun.';
    }
    return null;
  }

  Map<String, dynamic> toPayload() => {
    'name': name.trim(),
    'description': _nullable(description),
    'phone': _nullable(phone),
    'address': _nullable(address),
    'opening_hours': openingHours,
  };
  static String? _nullable(String value) =>
      value.trim().isEmpty ? null : value.trim();
}

class MerchantListingDraft {
  const MerchantListingDraft({
    required this.productId,
    required this.priceMinor,
    this.description = '',
    this.available = true,
    this.active = true,
  });
  final String productId;

  /// Integer kuruş, parsed before crossing the database's NUMERIC boundary.
  final int priceMinor;
  final String description;
  final bool available, active;
  String? get error {
    if (productId.trim().isEmpty) return 'Katalogdan bir ürün seçin.';
    if (priceMinor < 0 || priceMinor > 99999999999) {
      return 'Geçerli bir fiyat girin.';
    }
    if (description.length > 2000) {
      return 'Açıklama en fazla 2000 karakter olmalı.';
    }
    return null;
  }

  Map<String, dynamic> toPayload() => {
    'price':
        '${priceMinor ~/ 100}.${(priceMinor % 100).toString().padLeft(2, '0')}',
    'description': description.trim().isEmpty ? null : description.trim(),
    'is_available': available,
    'is_active': active,
  };

  static int? parsePrice(String value) {
    final text = value.trim().replaceAll(',', '.');
    if (!RegExp(r'^\d{1,9}(\.\d{1,2})?$').hasMatch(text)) return null;
    final parts = text.split('.');
    return int.parse(parts.first) * 100 +
        (parts.length == 1 ? 0 : int.parse(parts.last.padRight(2, '0')));
  }
}

class MerchantOverview {
  const MerchantOverview({
    required this.total,
    required this.available,
    required this.unavailable,
    required this.inactive,
  });
  final int total, available, unavailable, inactive;
}

abstract interface class MerchantRepository {
  Future<Either<String, MerchantAccess?>> loadAccess();
  Future<Either<String, ShopEntity>> saveShop(
    MerchantAccess access,
    MerchantShopDraft draft,
  );
  Future<Either<String, MerchantOverview>> overview(MerchantAccess access);
  Future<Either<String, List<ShopProductEntity>>> listings(
    MerchantAccess access, {
    int page = 0,
    String query = '',
  });
  Future<Either<String, List<ProductEntity>>> searchCatalog(
    MerchantAccess access, {
    required String query,
    int page = 0,
  });
  Future<Either<String, ShopProductEntity>> saveListing(
    MerchantAccess access,
    MerchantListingDraft draft, {
    ShopProductEntity? existing,
  });
}

const merchantPageSize = 30;
const merchantSessionChanged = 'Oturumunuz değişti. Yeniden giriş yapın.';
const merchantAccessDenied = 'Bu mağazayı yönetme yetkiniz yok.';
