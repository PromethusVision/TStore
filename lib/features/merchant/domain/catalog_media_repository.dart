import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';

/// GS1 check digit, canonical 14 digits. No punctuation stripping or fuzzy match.
String? normalizeGtin(String input) {
  final value = input.trim();
  if (value.isEmpty) return null;
  if (!RegExp(r'^(?:\d{8}|\d{12}|\d{13}|\d{14})$').hasMatch(value) ||
      RegExp(r'^0+$').hasMatch(value)) {
    throw const FormatException('Geçerli bir barkod girin.');
  }
  var sum = 0;
  for (var i = 0; i < value.length - 1; i++) {
    sum += int.parse(value[i]) * ((value.length - i).isEven ? 3 : 1);
  }
  if ((10 - sum % 10) % 10 != int.parse(value[value.length - 1])) {
    throw const FormatException('Barkodun kontrol basamağı geçersiz.');
  }
  return value.padLeft(14, '0');
}

class CatalogCategory {
  const CatalogCategory(this.id, this.name);
  final String id, name;
}

class ProductSubmissionDraft {
  const ProductSubmissionDraft({
    required this.name,
    required this.categoryId,
    this.brand = '',
    this.model = '',
    this.variant = '',
    this.gtin = '',
    this.uniqueToShop = false,
  });
  final String name, categoryId, brand, model, variant, gtin;
  final bool uniqueToShop;
  String? get error {
    if (name.trim().isEmpty || name.trim().length > 200) {
      return 'Ürün adı 1–200 karakter olmalı.';
    }
    if (categoryId.isEmpty) return 'Bir ürün kategorisi seçin.';
    if ([brand, model, variant].any((v) => v.length > 120)) {
      return 'Ürün bilgileri en fazla 120 karakter olmalı.';
    }
    try {
      normalizeGtin(gtin);
    } on FormatException catch (e) {
      return e.message;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'name': name.trim(),
    'brand': brand.trim(),
    'model': model.trim(),
    'variant': variant.trim(),
    'gtin': normalizeGtin(gtin),
    'canonical_category_id': categoryId,
    'product_type': uniqueToShop
        ? 'merchant_unique_product'
        : 'shared_catalog_product',
  };
}

class ProductSubmission {
  const ProductSubmission({
    required this.id,
    required this.name,
    required this.status,
    this.productId,
    this.reason,
  });
  final String id, name, status;
  final String? productId, reason;
  String get statusLabel => switch (status) {
    'approved' => 'Onaylandı',
    'rejected' => 'Reddedildi',
    _ => 'İnceleniyor',
  };
  factory ProductSubmission.fromJson(Map<String, dynamic> j) =>
      ProductSubmission(
        id: j['id'],
        name: j['name'],
        status: j['status'],
        productId: j['approved_product_id'],
        reason: j['decision_reason'],
      );
}

class CatalogLookup {
  const CatalogLookup(this.products, {this.exact = false});
  final List<ProductEntity> products;
  final bool exact;
}

class SubmissionResult {
  const SubmissionResult({this.submission, this.existing});
  final ProductSubmission? submission;
  final ProductEntity? existing;
}

class ListingImage {
  const ListingImage({
    required this.id,
    required this.path,
    required this.state,
    required this.primary,
    required this.order,
    this.url,
  });
  final String id, path, state;
  final bool primary;
  final int order;
  final String? url;
}

class ListingMedia {
  const ListingMedia(
    this.images, {
    required this.maxPhotos,
    required this.maxBytes,
  });
  final List<ListingImage> images;
  final int maxPhotos, maxBytes;
}

/// Separate capability port preserves the frozen Merchant V1 repository.
abstract interface class CatalogMediaRepository {
  Future<Either<String, List<CatalogCategory>>> categories(
    MerchantAccess access,
  );
  Future<Either<String, CatalogLookup>> lookup(
    MerchantAccess access,
    String name,
    String gtin,
  );
  Future<Either<String, SubmissionResult>> submit(
    MerchantAccess access,
    String requestId,
    ProductSubmissionDraft draft,
  );
  Future<Either<String, List<ProductSubmission>>> submissions(
    MerchantAccess access, {
    int page = 0,
  });
  Future<Either<String, ProductEntity?>> approvedProduct(
    MerchantAccess access,
    String productId,
  );
  Future<Either<String, ListingMedia>> media(
    MerchantAccess access,
    String listingId,
  );
  Future<Either<String, void>> upload(
    MerchantAccess access,
    String listingId,
    Uint8List bytes,
  );
  Future<Either<String, void>> changeMedia(
    MerchantAccess access,
    String listingId,
    String action, {
    String? imageId,
    List<String>? order,
  });
}

String? listingImageMime(Uint8List bytes) {
  if (bytes.length >= 3 &&
      bytes[0] == 0xff &&
      bytes[1] == 0xd8 &&
      bytes[2] == 0xff) {
    return 'image/jpeg';
  }
  const png = [137, 80, 78, 71, 13, 10, 26, 10];
  if (bytes.length >= 8 &&
      List.generate(8, (i) => bytes[i] == png[i]).every((v) => v)) {
    return 'image/png';
  }
  if (bytes.length >= 12 &&
      String.fromCharCodes(bytes.take(4)) == 'RIFF' &&
      String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
    return 'image/webp';
  }
  return null;
}
