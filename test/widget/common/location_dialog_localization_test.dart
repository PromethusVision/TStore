import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';

void main() {
  testWidgets('konum hizmeti penceresi müşteriye Türkçe açıklama gösterir', (
    tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await THelperFunctions.showLocationServiceDialog(
                  context,
                );
              },
              child: const Text('Pencereyi Aç'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Pencereyi Aç'));
    await tester.pumpAndSettle();

    expect(find.text('Konum hizmeti kapalı'), findsOneWidget);
    expect(
      find.text('Devam etmek için cihaz ayarlarından konum hizmetini açın.'),
      findsOneWidget,
    );
    expect(find.text('Ayarları Aç'), findsOneWidget);

    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets('konum izin penceresi müşteriye Türkçe açıklama gösterir', (
    tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await THelperFunctions.showPermissionDialog(context);
              },
              child: const Text('İzin Penceresini Aç'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('İzin Penceresini Aç'));
    await tester.pumpAndSettle();

    expect(find.text('Konum izni gerekiyor'), findsOneWidget);
    expect(
      find.text(
        'Yakınınızdaki mağazaları gösterebilmek için konumunuza erişmemiz gerekiyor.',
      ),
      findsOneWidget,
    );
    expect(find.text('İzin Ver'), findsOneWidget);

    await tester.tap(find.text('Şimdi Değil'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });
}
