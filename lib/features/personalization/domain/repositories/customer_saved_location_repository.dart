import 'package:dartz/dartz.dart';
import 'package:t_store/features/personalization/domain/entities/customer_saved_location_entity.dart';

abstract class CustomerSavedLocationRepository {
  Future<Either<String, List<CustomerSavedLocationEntity>>> getLocations();

  Future<Either<String, CustomerSavedLocationEntity>> addLocation({
    required String name,
    required String addressText,
    required double latitude,
    required double longitude,
    required bool isDefault,
  });

  Future<Either<String, void>> setDefaultLocation(String locationId);

  Future<Either<String, void>> deleteLocation(String locationId);
}
