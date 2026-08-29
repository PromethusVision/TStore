import 'package:dartz/dartz.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_product_query_scope.dart';

abstract class TaxonomyScopedProductRepository {
  Future<Either<String, List<ProductEntity>>> getProductsByTaxonomyScope({
    required TaxonomyProductQueryScope scope,
    int page = 0,
    int limit = 20,
    String? brandId,
    bool? isFeatured,
    String? sortBy,
    bool ascending = true,
  });
}
