import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/shop/domain/entities/banner_entity.dart';
import 'package:t_store/features/shop/domain/services/home_campaign_catalog.dart';
import 'package:t_store/features/shop/presentation/cubit/banners_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/banners_state.dart';
import 'package:t_store/features/shop/presentation/widgets/promo_banner_carousel_slider.dart';

class _Banners extends MockCubit<BannersState> implements BannersCubit {}

void main() {
  late _Banners cubit;
  setUp(() {
    cubit = _Banners();
    when(() => cubit.getBanners()).thenAnswer((_) async {});
  });
  Widget subject(
    BannersState state, {
    bool reduced = false,
    FutureOr<void> Function()? tap,
    double scale = 1,
  }) {
    whenListen(cubit, const Stream<BannersState>.empty(), initialState: state);
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          disableAnimations: reduced,
          textScaler: TextScaler.linear(scale),
        ),
        child: BlocProvider<BannersCubit>.value(
          value: cubit,
          child: Scaffold(
            body: SingleChildScrollView(
              child: PromoBannerCarouselSlider(onDiscover: tap),
            ),
          ),
        ),
      ),
    );
  }

  for (final state in [
    BannersInitial(),
    BannersLoading(),
    BannersError('offline'),
    const BannersLoaded([]),
    const BannersLoaded([BannerEntity(id: 'stock', imageUrl: 'old-stock.png')]),
  ]) {
    testWidgets('safe five compositions for ${state.runtimeType} $state', (
      tester,
    ) async {
      await tester.pumpWidget(subject(state));
      expect(
        find.text(HomeCampaignCatalog.fallback.first.title!),
        findsOneWidget,
      );
      expect(
        tester
            .widget<PageView>(find.byKey(const Key('campaign-pages')))
            .childrenDelegate
            .estimatedChildCount,
        5,
      );
      expect(find.byType(Image), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });
  }
  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('all five messages fit width $width and large text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        subject(const BannersLoaded([]), reduced: true, scale: 1.3),
      );
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byTooltip('${i + 1}. kampanya'));
        await tester.pumpAndSettle();
        expect(
          find.text(HomeCampaignCatalog.fallback[i].title!),
          findsOneWidget,
        );
        expect(
          find.text(HomeCampaignCatalog.fallback[i].subtitle!),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets(
    'remote campaign owns its copy; manual navigation restarts timer',
    (tester) async {
      const remote = BannerEntity(
        id: 'remote',
        sortOrder: -1,
        imageUrl: '',
        contentVersion: 2,
        title: 'Yerel başlık',
        subtitle: 'Kampanyaya özel açıklama',
      );
      await tester.pumpWidget(
        subject(BannersLoaded([remote, HomeCampaignCatalog.fallback[1]])),
      );
      expect(find.text('Yerel başlık'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
      expect(find.text(HomeCampaignCatalog.fallback[1].title!), findsOneWidget);
      await tester.drag(
        find.byKey(const Key('campaign-pages')),
        const Offset(500, 0),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('Yerel başlık'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('reduced motion stops auto advance and double taps open once', (
    tester,
  ) async {
    var count = 0;
    final pending = Completer<void>();
    await tester.pumpWidget(
      subject(
        const BannersLoaded([]),
        reduced: true,
        tap: () {
          count++;
          return pending.future;
        },
      ),
    );
    await tester.pump(const Duration(seconds: 7));
    expect(
      find.text(HomeCampaignCatalog.fallback.first.title!),
      findsOneWidget,
    );
    final button = tester.widget<FilledButton>(
      find.byKey(const ValueKey('campaign-cta-local-discover')),
    );
    button.onPressed!();
    button.onPressed!();
    expect(count, 1);
    pending.complete();
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
  });
}
