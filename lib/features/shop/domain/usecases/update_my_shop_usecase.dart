import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';

class UpdateMyShopUsecase implements UseCase<ShopEntity, UpdateMyShopParams> {
  final ShopRepository repository;

  UpdateMyShopUsecase(this.repository);

  @override
  Future<Either<String, ShopEntity>> call(UpdateMyShopParams params) async {
    final name = params.name.trim();
    if (name.isEmpty) {
      return const Left('Magaza adi bos olamaz.');
    }

    return await repository.updateMyShop(
      shopId: params.shopId.trim(),
      name: name,
      description: params.description,
      phone: params.phone,
      address: params.address,
      openingHours: params.openingHours,
    );
  }
}

class UpdateMyShopParams {
  final String shopId;
  final String name;
  final String? description;
  final String? phone;
  final String? address;
  final Map<String, dynamic>? openingHours;

  const UpdateMyShopParams({
    required this.shopId,
    required this.name,
    this.description,
    this.phone,
    this.address,
    this.openingHours,
  });
}
