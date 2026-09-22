import 'package:t_store/features/shop/data/services/production_public_taxonomy_adapter.dart';
import 'package:t_store/features/shop/data/repositories/canonical_rpc_product_repository.dart';

class ProductionPublicProductRepository extends CanonicalRpcProductRepository {
  ProductionPublicProductRepository({
    required this.adapter,
    super.mediaResolver,
  }) : super(
         readProducts: adapter.readProducts,
         failureMessage:
             'Ürün bilgileri şu anda doğrulanamıyor. Lütfen tekrar deneyin.',
       );
  final ProductionPublicTaxonomyAdapter adapter;
}
