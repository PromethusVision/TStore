import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/common/widgets/banner_carousel_slider.dart';
import 'package:t_store/core/common/widgets/rounded_image.dart';
import 'package:t_store/core/cubits/banner_carousel_slider_cubit_cubit/banner_carousel_slider_cubit.dart';

void main() {
  testWidgets('canlı banner adresini ağ görseli olarak gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => BannerCarouselSliderCubit(),
        child: const MaterialApp(
          home: Scaffold(
            body: BannerCarouselSlider(
              images: ['https://example.com/banner.png'],
            ),
          ),
        ),
      ),
    );

    final roundedImage = tester.widget<RoundedImage>(
      find.byType(RoundedImage).first,
    );
    expect(roundedImage.roundedImageModel.isNetworkImage, isTrue);
    expect(roundedImage.roundedImageModel.applyImageRadius, isTrue);
    expect(roundedImage.roundedImageModel.fit, BoxFit.cover);
  });
}
