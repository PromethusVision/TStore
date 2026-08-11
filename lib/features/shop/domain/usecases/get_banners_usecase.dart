import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/banner_entity.dart';
import 'package:t_store/features/shop/domain/repositories/banner_repository.dart';

class GetBannersUsecase implements UseCase<List<BannerEntity>, NoParams> {
  final BannerRepository repository;
  final DateTime Function() _clock;

  GetBannersUsecase(this.repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  @override
  Future<Either<String, List<BannerEntity>>> call(NoParams params) async {
    final result = await repository.getActiveBanners();
    return result.map((banners) => _normalize(banners, _clock()));
  }

  List<BannerEntity> _normalize(List<BannerEntity> banners, DateTime instant) {
    final candidates =
        banners
            .where(
              (banner) =>
                  banner.id.trim().isNotEmpty &&
                  banner.imageUrl.trim().isNotEmpty &&
                  banner.isActiveAt(instant),
            )
            .map(
              (banner) => banner.copyWith(
                id: banner.id.trim(),
                imageUrl: banner.imageUrl.trim(),
              ),
            )
            .toList()
          ..sort((left, right) {
            final sortOrder = left.sortOrder.compareTo(right.sortOrder);
            if (sortOrder != 0) return sortOrder;

            final id = left.id.compareTo(right.id);
            if (id != 0) return id;
            return left.imageUrl.compareTo(right.imageUrl);
          });

    final uniqueBanners = <BannerEntity>[];
    final seenIds = <String>{};
    for (final banner in candidates) {
      if (seenIds.add(banner.id)) uniqueBanners.add(banner);
    }
    return List.unmodifiable(uniqueBanners);
  }
}
