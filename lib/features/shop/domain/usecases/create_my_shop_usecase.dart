import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';

class CreateMyShopUsecase implements UseCase<ShopEntity, CreateMyShopParams> {
  final ShopRepository repository;

  CreateMyShopUsecase(this.repository);

  @override
  Future<Either<String, ShopEntity>> call(CreateMyShopParams params) async {
    final name = params.name.trim();
    if (name.isEmpty) {
      return const Left('Magaza adi bos olamaz.');
    }

    return await repository.createMyShop(
      name: name,
      description: params.description,
      phone: params.phone,
      address: params.address,
      openingHours: params.openingHours,
    );
  }
}

class CreateMyShopParams {
  final String name;
  final String? description;
  final String? phone;
  final String? address;
  final Map<String, dynamic>? openingHours;

  const CreateMyShopParams({
    required this.name,
    this.description,
    this.phone,
    this.address,
    this.openingHours,
  });
}
