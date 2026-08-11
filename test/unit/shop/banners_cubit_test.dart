import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/banner_entity.dart';
import 'package:t_store/features/shop/domain/usecases/get_banners_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/banners_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/banners_state.dart';

class MockGetBannersUsecase extends Mock implements GetBannersUsecase {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late MockGetBannersUsecase getBannersUsecase;
  late BannersCubit cubit;

  setUpAll(() {
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    getBannersUsecase = MockGetBannersUsecase();
    cubit = BannersCubit(getBannersUsecase: getBannersUsecase);
  });

  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
  });

  test('emits loading then loaded or error states', () async {
    const banner = BannerEntity(id: 'banner-1', imageUrl: 'image.png');
    when(
      () => getBannersUsecase(any()),
    ).thenAnswer((_) async => const Right([banner]));

    final successStates = <BannersState>[];
    final successSubscription = cubit.stream.listen(successStates.add);
    await cubit.getBanners();
    await Future<void>.delayed(Duration.zero);

    expect(successStates, [
      BannersLoading(),
      const BannersLoaded([banner]),
    ]);
    await successSubscription.cancel();

    when(
      () => getBannersUsecase(any()),
    ).thenAnswer((_) async => const Left('temporary failure'));
    await cubit.getBanners();
    expect(cubit.state, const BannersError('temporary failure'));
  });

  test('a delayed old response cannot overwrite a newer refresh', () async {
    final oldCompleter = Completer<Either<String, List<BannerEntity>>>();
    final newCompleter = Completer<Either<String, List<BannerEntity>>>();
    const oldBanner = BannerEntity(id: 'old', imageUrl: 'old.png');
    const newBanner = BannerEntity(id: 'new', imageUrl: 'new.png');
    var requestCount = 0;
    when(() => getBannersUsecase(any())).thenAnswer((_) {
      requestCount++;
      return requestCount == 1 ? oldCompleter.future : newCompleter.future;
    });

    final oldRequest = cubit.getBanners();
    final newRequest = cubit.getBanners();

    newCompleter.complete(const Right([newBanner]));
    await newRequest;
    oldCompleter.complete(const Right([oldBanner]));
    await oldRequest;

    expect(cubit.state, const BannersLoaded([newBanner]));
  });

  test('a pending response completes safely after cubit disposal', () async {
    final completer = Completer<Either<String, List<BannerEntity>>>();
    when(() => getBannersUsecase(any())).thenAnswer((_) => completer.future);

    final request = cubit.getBanners();
    await cubit.close();
    completer.complete(const Right([]));

    await expectLater(request, completes);
  });
}
