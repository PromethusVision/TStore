import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/shop/domain/repositories/listing_hero_media_repository.dart';
import 'package:t_store/features/shop/presentation/helpers/seller_ranking.dart';

class ListingHeroCubit extends Cubit<List<ListingHeroPhoto>> {
  ListingHeroCubit(this.repository) : super(const []);
  final ListingHeroMediaRepository repository;
  int _epoch = 0;
  Future<void> load(List<RankedSeller> ranking) async {
    final epoch = ++_epoch;
    emit(const []); // Never show a previous seller's photograph during refresh.
    try {
      final photos = await repository.photos(
        ranking.map((s) => s.shopProduct).toList(growable: false),
      );
      if (!isClosed && epoch == _epoch) emit(photos);
    } catch (_) {
      if (!isClosed && epoch == _epoch) emit(const []);
    }
  }

  @override
  Future<void> close() {
    ++_epoch;
    return super.close();
  }
}
