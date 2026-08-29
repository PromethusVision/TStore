import 'package:dartz/dartz.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/taxonomy_scoped_product_repository.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_product_query_scope.dart';

class GetProductsByTaxonomyScopeUsecase {
  const GetProductsByTaxonomyScopeUsecase(this.repository);

  final TaxonomyScopedProductRepository repository;

  Future<Either<String, List<ProductEntity>>> call(
    GetProductsByTaxonomyScopeParams params,
  ) {
    return repository.getProductsByTaxonomyScope(
      scope: params.scope,
      page: params.page,
      limit: params.limit,
      brandId: params.brandId,
      isFeatured: params.isFeatured,
      sortBy: params.sortBy,
      ascending: params.ascending,
    );
  }
}

class GetProductsByTaxonomyScopeParams {
  const GetProductsByTaxonomyScopeParams({
    required this.scope,
    this.page = 0,
    this.limit = 20,
    this.brandId,
    this.isFeatured,
    this.sortBy,
    this.ascending = true,
  });

  final TaxonomyProductQueryScope scope;
  final int page;
  final int limit;
  final String? brandId;
  final bool? isFeatured;
  final String? sortBy;
  final bool ascending;
}
