import 'package:dartz/dartz.dart';
import 'package:t_store/core/supabase/public_media_source_resolver.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/core/utils/helpers/customer_error_message.dart';
import 'package:t_store/features/shop/data/models/product_model.dart';
import 'package:t_store/features/shop/data/services/supabase_canonical_taxonomy_rpc_adapter.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/taxonomy_scoped_product_repository.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_product_query_scope.dart';

class CanonicalTaxonomyScopedProductRepositoryImpl
    implements TaxonomyScopedProductRepository {
  CanonicalTaxonomyScopedProductRepositoryImpl({
    required this.supabaseService,
    required this.taxonomyAdapter,
    CanonicalTaxonomyProductScopeResolver? scopeResolver,
    PublicMediaSourceResolver? mediaResolver,
  }) : scopeResolver =
           scopeResolver ??
           CanonicalTaxonomyProductScopeResolver(taxonomyAdapter),
       mediaResolver =
           mediaResolver ??
           PublicMediaSourceResolver.fromSupabaseClient(supabaseService.client);

  final SupabaseService supabaseService;
  final SupabaseCanonicalTaxonomyRpcAdapter taxonomyAdapter;
  final CanonicalTaxonomyProductScopeResolver scopeResolver;
  final PublicMediaSourceResolver mediaResolver;

  @override
  Future<Either<String, List<ProductEntity>>> getProductsByTaxonomyScope({
    required TaxonomyProductQueryScope scope,
    int page = 0,
    int limit = 20,
    String? brandId,
    bool? isFeatured,
    String? sortBy,
    bool ascending = true,
  }) async {
    if (page < 0 || limit < 1) {
      return const Left('Ürün sayfalama bilgisi geçersiz.');
    }
    try {
      final categoryIds = await scopeResolver.resolveCategoryIds(scope);
      if (categoryIds.isEmpty) return const Right([]);

      var query = supabaseService.client
          .from(SupabaseTables.products)
          .select('*, categories(name), brands(name)')
          .eq('is_active', true)
          .inFilter('category_id', categoryIds);
      if (brandId != null) query = query.eq('brand_id', brandId);
      if (isFeatured != null) {
        query = query.eq('is_featured', isFeatured);
      }
      final from = page * limit;
      final response = await query
          .order(sortBy ?? 'created_at', ascending: ascending)
          .range(from, from + limit - 1);
      return Right(
        (response as List)
            .map(
              (json) => ProductModel.fromJson(
                json as Map<String, dynamic>,
                mediaResolver: mediaResolver,
              ),
            )
            .toList(growable: false),
      );
    } catch (error) {
      return Left(
        CustomerErrorMessage.from(
          error,
          fallback: 'Kategori ürünleri yüklenemedi. Lütfen tekrar deneyin.',
        ),
      );
    }
  }
}

class CanonicalTaxonomyProductScopeResolver {
  const CanonicalTaxonomyProductScopeResolver(this.taxonomyAdapter);

  final CanonicalTaxonomyRpcAdapter taxonomyAdapter;

  Future<List<String>> resolveCategoryIds(
    TaxonomyProductQueryScope scope,
  ) async {
    if (scope.kind == TaxonomyProductQueryScopeKind.exactLeaf) {
      final result = await taxonomyAdapter.qualifyExactLeaf(scope.categoryId);
      return result.map((node) => node.id).toList(growable: false);
    }
    final result = await taxonomyAdapter.getDescendants(scope.categoryId);
    return result.map((node) => node.id).toSet().toList(growable: false);
  }
}
