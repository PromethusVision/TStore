import 'package:t_store/features/shop/data/services/production_preview_taxonomy_adapter.dart';
import 'package:t_store/features/shop/data/repositories/canonical_rpc_product_repository.dart';

class ProductionPreviewProductRepository extends CanonicalRpcProductRepository {
  ProductionPreviewProductRepository({
    required this.adapter,
    super.mediaResolver,
  }) : super(
         readProducts: adapter.readProducts,
         failureMessage:
             'Önizleme ürün erişimi doğrulanamadı. Lütfen tekrar deneyin.',
       );
  final ProductionPreviewTaxonomyAdapter adapter;
}
