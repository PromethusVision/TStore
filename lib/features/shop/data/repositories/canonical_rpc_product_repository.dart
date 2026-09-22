import 'package:dartz/dartz.dart';
import 'package:t_store/core/supabase/public_media_source_resolver.dart';
import 'package:t_store/features/shop/data/models/product_model.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/product_repository.dart';
import 'package:t_store/features/shop/domain/repositories/taxonomy_scoped_product_repository.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_product_query_scope.dart';

/// Uses the server's exact shadow mappings for listings AND product details.
/// Never translates legacy IDs, guesses a category, or falls back on RPC errors.
class CanonicalRpcProductRepository
    implements ProductRepository, TaxonomyScopedProductRepository {
  const CanonicalRpcProductRepository({
    required this.readProducts,
    required this.failureMessage,
    this.mediaResolver,
  });
  final Future<dynamic> Function(Map<String, dynamic>) readProducts;
  final String failureMessage;
  final PublicMediaSourceResolver? mediaResolver;

  Future<Either<String, List<ProductEntity>>> _read(
    Map<String, dynamic> args,
  ) async {
    try {
      final raw = await readProducts(args);
      if (raw is! List) {
        throw const FormatException('Canonical product response.');
      }
      final ids = <String>{};
      final products = raw
          .map((item) {
            if (item is! Map) {
              throw const FormatException('Canonical product row.');
            }
            final row = Map<String, dynamic>.from(item);
            final product = Map<String, dynamic>.from(row['product'] as Map);
            if (row['canonical_category_id'] != product['category_id'] ||
                row['product_id'] != product['id'] ||
                product['legacy_category_id'] is! String ||
                row['canonical_path'] is! String ||
                !ids.add(product['id'] as String)) {
              throw const FormatException(
                'Canonical product mapping mismatch.',
              );
            }
            return ProductModel.fromJson(product, mediaResolver: mediaResolver);
          })
          .toList(growable: false);
      return Right(products);
    } on Object {
      return Left(failureMessage);
    }
  }

  @override
  Future<Either<String, List<ProductEntity>>> getProducts({
    int page = 0,
    int limit = 20,
    String? categoryId,
    String? brandId,
    bool? isFeatured,
    String? sortBy,
    bool ascending = true,
  }) {
    if (page < 0 || limit < 1 || limit > 100) {
      return Future.value(const Left('Ürün sayfalama bilgisi geçersiz.'));
    }
    return _read({
      'p_category_id': categoryId,
      'p_brand_id': brandId,
      'p_is_featured': isFeatured,
      'p_sort_by': sortBy ?? 'created_at',
      'p_ascending': ascending,
      'p_limit': limit,
      'p_offset': page * limit,
    });
  }

  @override
  Future<Either<String, List<ProductEntity>>> getProductsByTaxonomyScope({
    required TaxonomyProductQueryScope scope,
    int page = 0,
    int limit = 20,
    String? brandId,
    bool? isFeatured,
    String? sortBy,
    bool ascending = true,
  }) {
    if (!scope.hasCanonicalHierarchyEvidence) {
      return Future.value(const Left('Canonical ürün kapsamı doğrulanamadı.'));
    }
    if (page < 0 || limit < 1 || limit > 100) {
      return Future.value(const Left('Ürün sayfalama bilgisi geçersiz.'));
    }
    return _read({
      'p_category_id': scope.categoryId,
      'p_exact_leaf': scope.kind == TaxonomyProductQueryScopeKind.exactLeaf,
      'p_brand_id': brandId,
      'p_is_featured': isFeatured,
      'p_sort_by': sortBy ?? 'created_at',
      'p_ascending': ascending,
      'p_limit': limit,
      'p_offset': page * limit,
    });
  }

  @override
  Future<Either<String, ProductEntity>> getProductById(String id) async {
    final result = await _read({'p_product_id': id, 'p_limit': 1});
    return result.bind(
      (items) => items.length == 1 && items.single.id == id
          ? Right(items.single)
          : Left(failureMessage),
    );
  }

  @override
  Future<Either<String, List<ProductEntity>>> getProductsByIds(
    List<String> ids,
  ) async {
    final products = <ProductEntity>[];
    for (final id in ids.toSet()) {
      final result = await getProductById(id);
      if (result.isLeft()) {
        return Left(failureMessage);
      }
      result.fold((_) {}, products.add);
    }
    return Right(products);
  }

  @override
  Future<Either<String, List<ProductEntity>>> searchProducts(String query) =>
      _read({'p_term': query, 'p_limit': 50});
  @override
  Future<Either<String, List<ProductEntity>>> getProductsByCategory(
    String categoryId,
  ) => getProducts(categoryId: categoryId);
  @override
  Future<Either<String, List<ProductEntity>>> getProductsByBrand(
    String brandId,
  ) => getProducts(brandId: brandId);
  @override
  Future<Either<String, List<ProductEntity>>> getFeaturedProducts() =>
      getProducts(isFeatured: true);
}
