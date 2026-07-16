import 'package:dartz/dartz.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/features/personalization/data/models/customer_saved_location_model.dart';
import 'package:t_store/features/personalization/domain/entities/customer_saved_location_entity.dart';
import 'package:t_store/features/personalization/domain/repositories/customer_saved_location_repository.dart';

class CustomerSavedLocationRepositoryImpl
    implements CustomerSavedLocationRepository {
  CustomerSavedLocationRepositoryImpl({required this.supabaseService});

  final SupabaseService supabaseService;

  String get _userId => supabaseService.currentUser?.id ?? '';

  @override
  Future<Either<String, List<CustomerSavedLocationEntity>>>
  getLocations() async {
    try {
      if (_userId.isEmpty) return const Left('not_authenticated');

      final response = await supabaseService.client
          .from(SupabaseTables.customerSavedLocations)
          .select()
          .eq('user_id', _userId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      final locations = (response as List)
          .map(
            (json) => CustomerSavedLocationModel.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList(growable: false);

      return Right(locations);
    } catch (error) {
      return Left(error.toString());
    }
  }

  @override
  Future<Either<String, CustomerSavedLocationEntity?>>
  getDefaultLocation() async {
    try {
      if (_userId.isEmpty) return const Left('not_authenticated');

      final response = await supabaseService.client
          .from(SupabaseTables.customerSavedLocations)
          .select()
          .eq('user_id', _userId)
          .eq('is_default', true)
          .maybeSingle();

      if (response == null) return const Right(null);
      return Right(CustomerSavedLocationModel.fromJson(response));
    } catch (error) {
      return Left(error.toString());
    }
  }

  @override
  Future<Either<String, CustomerSavedLocationEntity>> addLocation({
    required String name,
    required String addressText,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    try {
      if (_userId.isEmpty) return const Left('not_authenticated');

      final response = await supabaseService.client
          .from(SupabaseTables.customerSavedLocations)
          .insert({
            'user_id': _userId,
            'name': name,
            'address_text': addressText,
            'latitude': latitude,
            'longitude': longitude,
            'is_default': isDefault,
          })
          .select()
          .single();

      return Right(CustomerSavedLocationModel.fromJson(response));
    } catch (error) {
      return Left(error.toString());
    }
  }

  @override
  Future<Either<String, void>> setDefaultLocation(String locationId) async {
    try {
      if (_userId.isEmpty) return const Left('not_authenticated');

      final response = await supabaseService.client.rpc(
        'set_default_customer_saved_location',
        params: {'p_location_id': locationId},
      );
      if (response != true) return const Left('location_not_found');

      return const Right(null);
    } catch (error) {
      return Left(error.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteLocation(String locationId) async {
    try {
      if (_userId.isEmpty) return const Left('not_authenticated');

      final response = await supabaseService.client.rpc(
        'delete_customer_saved_location',
        params: {'p_location_id': locationId},
      );
      if (response != true) return const Left('location_not_found');

      return const Right(null);
    } catch (error) {
      return Left(error.toString());
    }
  }
}
