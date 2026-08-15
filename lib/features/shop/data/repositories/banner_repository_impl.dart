import 'package:dartz/dartz.dart';
import 'package:t_store/core/supabase/public_media_source_resolver.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/core/utils/helpers/customer_error_message.dart';
import 'package:t_store/features/shop/data/models/banner_model.dart';
import 'package:t_store/features/shop/domain/entities/banner_entity.dart';
import 'package:t_store/features/shop/domain/repositories/banner_repository.dart';

class BannerRepositoryImpl implements BannerRepository {
  final SupabaseService supabaseService;
  final PublicMediaSourceResolver mediaResolver;

  BannerRepositoryImpl({
    required this.supabaseService,
    PublicMediaSourceResolver? mediaResolver,
  }) : mediaResolver =
           mediaResolver ??
           PublicMediaSourceResolver.fromSupabaseClient(supabaseService.client);

  @override
  Future<Either<String, List<BannerEntity>>> getBanners() async {
    try {
      final response = await supabaseService.client
          .from(SupabaseTables.banners)
          .select()
          .order('sort_order', ascending: true)
          .order('id', ascending: true);

      final banners = _parseRows(response);

      return Right(banners);
    } catch (e) {
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Kampanyalar yüklenemedi. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  @override
  Future<Either<String, List<BannerEntity>>> getActiveBanners() async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await supabaseService.client
          .from(SupabaseTables.banners)
          .select()
          .eq('is_active', true)
          .or('start_date.is.null,start_date.lte.$now')
          .or('end_date.is.null,end_date.gte.$now')
          .order('sort_order', ascending: true)
          .order('id', ascending: true);

      final banners = _parseRows(response);

      return Right(banners);
    } catch (e) {
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Kampanyalar yüklenemedi. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  List<BannerEntity> _parseRows(Object? response) {
    if (response is! List) {
      throw const FormatException('Unexpected banner response.');
    }

    final banners = <BannerEntity>[];
    for (final row in response) {
      if (row is! Map) continue;

      try {
        final model = BannerModel.tryFromJson(
          Map<String, dynamic>.from(row),
          mediaResolver: mediaResolver,
        );
        if (model != null) banners.add(model);
      } on Object {
        continue;
      }
    }
    return banners;
  }
}
