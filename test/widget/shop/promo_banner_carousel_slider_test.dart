import 'package:bloc_test/bloc_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/features/shop/domain/entities/banner_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/banners_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/banners_state.dart';
import 'package:t_store/features/shop/presentation/widgets/promo_banner_carousel_slider.dart';

class MockHomeBannersCubit extends MockCubit<BannersState>
    implements BannersCubit {}

void main() {
  late MockHomeBannersCubit bannersCubit;

  setUp(() {
    bannersCubit = MockHomeBannersCubit();
    when(() => bannersCubit.getBanners()).thenAnswer((_) async {});
  });

  Widget buildSubject(BannersState state, {VoidCallback? onDiscover}) {
    whenListen(
      bannersCubit,
      const Stream<BannersState>.empty(),
      initialState: state,
    );
    return BlocProvider<BannersCubit>.value(
      value: bannersCubit,
      child: MaterialApp(
        home: Scaffold(body: PromoBannerCarouselSlider(onDiscover: onDiscover)),
      ),
    );
  }

  testWidgets('yükleme durumunda markalı hero iskeletini gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(BannersLoading()));

    expect(find.byKey(const Key('customer-home-hero-loading')), findsOneWidget);
  });

  testWidgets('gerçek banner adresini onaylı hero yapısında kullanır', (
    tester,
  ) async {
    const banner = BannerEntity(
      id: 'banner-1',
      imageUrl: 'https://example.com/banner.png',
    );
    await tester.pumpWidget(buildSubject(const BannersLoaded([banner])));

    expect(find.byKey(const Key('customer-home-hero')), findsOneWidget);
    expect(
      find.text('Mahallendeki\nesnafa destek ol,\nkazanan sen ol!'),
      findsOneWidget,
    );
    expect(find.text('Aradığın ürün\nsana en yakın esnafta.'), findsOneWidget);
    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.imageUrl, banner.imageUrl);
  });

  testWidgets('keşfet eylemi hızlı çift dokunmada yalnız bir kez çalışır', (
    tester,
  ) async {
    var tapCount = 0;
    await tester.pumpWidget(
      buildSubject(const BannersLoaded([]), onDiscover: () => tapCount++),
    );

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('customer-home-discover')),
    );
    button.onPressed?.call();
    button.onPressed?.call();

    expect(tapCount, 1);

    await tester.pump();
    button.onPressed?.call();
    await tester.pump();

    expect(tapCount, 2);
  });

  testWidgets('uses approved local banners when the result is empty', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(const BannersLoaded([])));

    final assetNames = tester
        .widgetList<Image>(find.byType(Image))
        .map((image) => image.image)
        .whereType<AssetImage>()
        .map((image) => image.assetName);
    expect(assetNames, contains(TImages.promoBanner1));
  });

  testWidgets('uses approved local banners when loading fails', (tester) async {
    await tester.pumpWidget(
      buildSubject(const BannersError('temporary failure')),
    );

    final assetNames = tester
        .widgetList<Image>(find.byType(Image))
        .map((image) => image.image)
        .whereType<AssetImage>()
        .map((image) => image.assetName);
    expect(assetNames, contains(TImages.promoBanner1));
  });

  testWidgets('does not display inactive or repeated banner images', (
    tester,
  ) async {
    final now = DateTime.now();
    final banners = [
      const BannerEntity(
        id: 'active',
        imageUrl: 'https://example.com/active.png',
      ),
      const BannerEntity(
        id: 'active',
        imageUrl: 'https://example.com/repeated-id.png',
      ),
      const BannerEntity(
        id: 'different-id',
        imageUrl: 'https://example.com/active.png',
      ),
      BannerEntity(
        id: 'future',
        imageUrl: 'https://example.com/future.png',
        startDate: now.add(const Duration(hours: 1)),
      ),
      BannerEntity(
        id: 'expired',
        imageUrl: 'https://example.com/expired.png',
        endDate: now.subtract(const Duration(hours: 1)),
      ),
    ];

    await tester.pumpWidget(buildSubject(BannersLoaded(banners)));

    final images = tester.widgetList<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(images.map((image) => image.imageUrl), [
      'https://example.com/active.png',
    ]);
  });

  testWidgets('uses branded artwork for a malformed image address', (
    tester,
  ) async {
    const banner = BannerEntity(id: 'broken', imageUrl: 'https://');
    await tester.pumpWidget(buildSubject(const BannersLoaded([banner])));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('customer-home-hero-image-fallback')),
      findsOneWidget,
    );
  });

  testWidgets('uses branded artwork when a network image fails', (
    tester,
  ) async {
    const banner = BannerEntity(
      id: 'network-failure',
      imageUrl: 'https://example.com/missing.png',
    );
    await tester.pumpWidget(buildSubject(const BannersLoaded([banner])));

    final finder = find.byType(CachedNetworkImage);
    final image = tester.widget<CachedNetworkImage>(finder);
    final fallback = image.errorWidget!(
      tester.element(finder),
      image.imageUrl,
      Exception('network failure'),
    );
    await tester.pumpWidget(MaterialApp(home: fallback));

    expect(
      find.byKey(const Key('customer-home-hero-image-fallback')),
      findsOneWidget,
    );
  });
}
