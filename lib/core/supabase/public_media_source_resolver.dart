import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_config.dart';

typedef PublicStorageUrlBuilder =
    String Function(String bucket, String objectPath);

/// Resolves the read-only public media contract used by customer discovery.
///
/// The database may temporarily contain either a legacy absolute HTTPS URL or
/// a controlled Storage object path. Only the three Wave 6 read-active media
/// buckets are exposed by this typed boundary; deferred buckets and arbitrary
/// object paths are deliberately unsupported.
final class PublicMediaSourceResolver {
  PublicMediaSourceResolver.fromSupabaseClient(SupabaseClient client)
    : this.withUrlBuilder(
        (bucket, objectPath) =>
            client.storage.from(bucket).getPublicUrl(objectPath),
      );

  PublicMediaSourceResolver.withUrlBuilder(
    PublicStorageUrlBuilder publicUrlBuilder,
  ) : _publicUrlBuilder = publicUrlBuilder;

  final PublicStorageUrlBuilder _publicUrlBuilder;

  String? resolveCatalogProduct(String? source, {required String productId}) {
    return _resolve(
      source,
      bucket: SupabaseConfig.productImagesBucket,
      expectedSegments: ['catalog', productId],
    );
  }

  String? resolveShopProduct(
    String? source, {
    required String shopId,
    required String shopProductId,
  }) {
    return _resolve(
      source,
      bucket: SupabaseConfig.productImagesBucket,
      expectedSegments: ['shops', shopId, shopProductId],
    );
  }

  String? resolveCategory(String? source, {required String categoryId}) {
    return _resolve(
      source,
      bucket: SupabaseConfig.categoryImagesBucket,
      expectedSegments: ['catalog', categoryId],
    );
  }

  String? resolveBanner(String? source, {required String bannerId}) {
    return _resolve(
      source,
      bucket: SupabaseConfig.bannerImagesBucket,
      expectedSegments: ['catalog', bannerId],
    );
  }

  List<String> resolveCatalogProducts(
    Iterable<String> sources, {
    required String productId,
  }) {
    return _resolveMany(
      sources,
      (source) => resolveCatalogProduct(source, productId: productId),
    );
  }

  List<String> resolveShopProducts(
    Iterable<String> sources, {
    required String shopId,
    required String shopProductId,
  }) {
    return _resolveMany(
      sources,
      (source) => resolveShopProduct(
        source,
        shopId: shopId,
        shopProductId: shopProductId,
      ),
    );
  }

  List<String> _resolveMany(
    Iterable<String> sources,
    String? Function(String source) resolve,
  ) {
    final resolved = <String>[];
    for (final source in sources) {
      final value = resolve(source);
      if (value != null) resolved.add(value);
    }
    return List.unmodifiable(resolved);
  }

  String? _resolve(
    String? source, {
    required String bucket,
    required List<String> expectedSegments,
  }) {
    final value = source?.trim();
    if (value == null || value.isEmpty || _containsUnsafeCharacters(value)) {
      return null;
    }

    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    if (uri.hasScheme || uri.hasAuthority) return _legacyHttpsUrl(uri, value);
    if (!_isControlledPath(uri, value, expectedSegments)) return null;

    try {
      final publicUrl = _publicUrlBuilder(bucket, value);
      return _safeGeneratedPublicUrl(publicUrl);
    } on Object {
      return null;
    }
  }

  static String? _legacyHttpsUrl(Uri uri, String original) {
    if (!uri.isAbsolute ||
        uri.scheme.toLowerCase() != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      return null;
    }
    return original;
  }

  static String? _safeGeneratedPublicUrl(String value) {
    if (_containsUnsafeCharacters(value)) return null;
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.isAbsolute ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      return null;
    }

    if (uri.scheme.toLowerCase() == 'https') return value;
    if (uri.scheme.toLowerCase() == 'http' && _isLoopbackHost(uri.host)) {
      return value;
    }
    return null;
  }

  static bool _isControlledPath(
    Uri uri,
    String original,
    List<String> expectedSegments,
  ) {
    if (uri.isAbsolute ||
        uri.hasAuthority ||
        uri.hasQuery ||
        uri.hasFragment ||
        original.startsWith('/') ||
        original.endsWith('/') ||
        original.contains('\\')) {
      return false;
    }

    final segments = original.split('/');
    if (segments.length <= expectedSegments.length) return false;

    for (var index = 0; index < segments.length; index++) {
      final segment = segments[index];
      if (!_isSafePathSegment(segment)) return false;
      if (index < expectedSegments.length &&
          segment != expectedSegments[index]) {
        return false;
      }
    }
    return true;
  }

  static bool _isSafePathSegment(String segment) {
    if (segment.isEmpty ||
        segment == '.' ||
        segment == '..' ||
        !_safePathSegment.hasMatch(segment)) {
      return false;
    }

    try {
      final decoded = Uri.decodeComponent(segment);
      return decoded == segment &&
          decoded != '.' &&
          decoded != '..' &&
          !decoded.contains('/') &&
          !decoded.contains('\\') &&
          !_containsUnsafeCharacters(decoded);
    } on FormatException {
      return false;
    }
  }

  static bool _containsUnsafeCharacters(String value) {
    return value.codeUnits.any(
      (codeUnit) => codeUnit <= 0x20 || codeUnit == 0x7f,
    );
  }

  static bool _isLoopbackHost(String host) {
    final normalizedHost = host.toLowerCase();
    return normalizedHost == 'localhost' ||
        normalizedHost == '127.0.0.1' ||
        normalizedHost == '::1';
  }

  static final RegExp _safePathSegment = RegExp(r'^[A-Za-z0-9._-]+$');
}
