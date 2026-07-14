import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/reviews/domain/usecases/submit_shop_rating_usecase.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_state.dart';

class ShopRatingCubit extends Cubit<ShopRatingState> {
  final SubmitShopRatingUsecase submitShopRatingUsecase;

  ShopRatingCubit({required this.submitShopRatingUsecase})
    : super(ShopRatingInitial());

  Future<void> submitRating({
    required String qrSessionId,
    required int rating,
  }) async {
    if (qrSessionId.trim().isEmpty) {
      emit(const ShopRatingFailure('Doğrulanmış alışveriş bulunamadı.'));
      return;
    }

    if (rating < 1 || rating > 5) {
      emit(const ShopRatingFailure('Lütfen 1 ile 5 arasında bir puan seçin.'));
      return;
    }

    emit(ShopRatingSubmitting());
    final result = await submitShopRatingUsecase(
      SubmitShopRatingParams(qrSessionId: qrSessionId, rating: rating),
    );

    if (isClosed) return;

    result.fold(
      (error) => emit(ShopRatingFailure(error)),
      (shopRating) => emit(ShopRatingSuccess(shopRating)),
    );
  }
}
