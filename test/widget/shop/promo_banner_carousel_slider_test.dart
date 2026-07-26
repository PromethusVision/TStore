import 'package:bloc_test/bloc_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

  testWidgets('keşfet eylemini yalnız bir kez çalıştırır', (tester) async {
    var tapCount = 0;
    await tester.pumpWidget(
      buildSubject(const BannersLoaded([]), onDiscover: () => tapCount++),
    );

    await tester.tap(find.byKey(const Key('customer-home-discover')));
    await tester.pump();

    expect(tapCount, 1);
  });
}
