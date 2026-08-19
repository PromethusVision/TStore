import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/personalization/domain/entities/customer_saved_location_entity.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_state.dart';
import 'package:t_store/features/personalization/presentation/views/customer_saved_locations_view.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';

class MockCustomerSavedLocationsCubit
    extends MockCubit<CustomerSavedLocationsState>
    implements CustomerSavedLocationsCubit {}

void main() {
  const coordinates = CustomerCoordinates(latitude: 41.043, longitude: 28.876);
  const home = CustomerSavedLocationEntity(
    id: 'location-1',
    userId: 'customer-1',
    name: 'Ev',
    addressText: 'Esenler, İstanbul',
    latitude: 41.043,
    longitude: 28.876,
    isDefault: true,
  );
  const work = CustomerSavedLocationEntity(
    id: 'location-2',
    userId: 'customer-1',
    name: 'İş',
    addressText: 'Şişli, İstanbul',
    latitude: 41.061,
    longitude: 28.987,
  );

  late MockCustomerSavedLocationsCubit cubit;

  setUpAll(() {
    registerFallbackValue(coordinates);
  });

  setUp(() {
    cubit = MockCustomerSavedLocationsCubit();
    when(() => cubit.loadLocations()).thenAnswer((_) async {});
    when(() => cubit.close()).thenAnswer((_) async {});
    when(() => cubit.captureCurrentLocation()).thenAnswer(
      (_) async => const CustomerLocationResult.success(coordinates),
    );
    when(
      () => cubit.addLocation(
        name: any(named: 'name'),
        addressText: any(named: 'addressText'),
        coordinates: any(named: 'coordinates'),
      ),
    ).thenAnswer((_) async => true);
    when(() => cubit.setDefaultLocation(any())).thenAnswer((_) async => true);
    when(() => cubit.deleteLocation(any())).thenAnswer((_) async => true);
  });

  Widget buildSubject(CustomerSavedLocationsState state) {
    whenListen(
      cubit,
      const Stream<CustomerSavedLocationsState>.empty(),
      initialState: state,
    );

    return MaterialApp(
      home: CustomerSavedLocationsView(customerSavedLocationsCubit: cubit),
    );
  }

  testWidgets('boş durumda müşteriyi konum kaydetmeye yönlendirir', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(const CustomerSavedLocationsLoaded(locations: [])),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('customer-saved-locations-content')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('customer-saved-locations-header')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('customer-saved-locations-status')),
      findsOneWidget,
    );
    expect(find.text('Kayıtlı Konumlarım'), findsOneWidget);
    expect(find.text('Henüz kayıtlı konumun yok'), findsOneWidget);
    expect(find.text('Mevcut Konumumu Kaydet'), findsOneWidget);
    verify(() => cubit.loadLocations()).called(1);
  });

  testWidgets('konum bilgilerini ve ana konum durumunu gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(const CustomerSavedLocationsLoaded(locations: [home, work])),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('customer-saved-locations-list')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('saved-location-card-location-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('saved-location-card-location-2')),
      findsOneWidget,
    );
    expect(find.text('Ev'), findsOneWidget);
    expect(find.text('Esenler, İstanbul'), findsOneWidget);
    expect(find.text('İş'), findsOneWidget);
    expect(find.text('Şişli, İstanbul'), findsOneWidget);
    expect(find.text('Ana Konum'), findsOneWidget);
    expect(find.text('Ana Konum Yap'), findsOneWidget);

    await tester.tap(find.text('Ana Konum Yap'));
    await tester.pump();

    verify(() => cubit.setDefaultLocation(work.id)).called(1);
  });

  testWidgets('mevcut konumu alıp form bilgileriyle kaydeder', (tester) async {
    await tester.pumpWidget(
      buildSubject(const CustomerSavedLocationsLoaded(locations: [])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mevcut Konumumu Kaydet'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('saved-location-add-sheet')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('saved-location-name-field')),
      'Ev',
    );
    await tester.enterText(
      find.byKey(const Key('saved-location-address-field')),
      'Esenler, İstanbul',
    );
    await tester.tap(find.byKey(const Key('saved-location-capture-button')));
    await tester.pumpAndSettle();
    expect(find.text('Konum Alındı'), findsOneWidget);

    await tester.tap(find.byKey(const Key('saved-location-save-button')));
    await tester.pumpAndSettle();

    verify(() => cubit.captureCurrentLocation()).called(1);
    verify(
      () => cubit.addLocation(
        name: 'Ev',
        addressText: 'Esenler, İstanbul',
        coordinates: coordinates,
      ),
    ).called(1);
    expect(find.text('Konumun kaydedildi.'), findsOneWidget);
  });

  testWidgets('konum ekleme penceresini çift dokunmada bir kez açar', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(const CustomerSavedLocationsLoaded(locations: [])),
    );
    await tester.pumpAndSettle();

    final addAction = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Mevcut Konumumu Kaydet'),
    );
    addAction.onPressed?.call();
    addAction.onPressed?.call();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('saved-location-add-sheet')), findsOneWidget);

    Navigator.of(
      tester.element(find.byKey(const Key('saved-location-add-sheet'))),
    ).pop();
    await tester.pumpAndSettle();

    final reopenedAddAction = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Mevcut Konumumu Kaydet'),
    );
    expect(reopenedAddAction.onPressed, isNotNull);
  });

  testWidgets('konum alma işlemini çift dokunmada bir kez çalıştırır', (
    tester,
  ) async {
    final locationResult = Completer<CustomerLocationResult>();
    when(
      () => cubit.captureCurrentLocation(),
    ).thenAnswer((_) => locationResult.future);
    await tester.pumpWidget(
      buildSubject(const CustomerSavedLocationsLoaded(locations: [])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mevcut Konumumu Kaydet'));
    await tester.pumpAndSettle();
    final captureAction = tester.widget<OutlinedButton>(
      find.byKey(const Key('saved-location-capture-button')),
    );
    captureAction.onPressed?.call();
    captureAction.onPressed?.call();
    await tester.pump();

    verify(() => cubit.captureCurrentLocation()).called(1);

    locationResult.complete(const CustomerLocationResult.success(coordinates));
    await tester.pumpAndSettle();

    expect(find.text('Konum Alındı'), findsOneWidget);
  });

  testWidgets('konum kaydını çift dokunmada bir kez gönderir', (tester) async {
    final saveResult = Completer<bool>();
    when(
      () => cubit.addLocation(
        name: any(named: 'name'),
        addressText: any(named: 'addressText'),
        coordinates: any(named: 'coordinates'),
      ),
    ).thenAnswer((_) => saveResult.future);
    await tester.pumpWidget(
      buildSubject(const CustomerSavedLocationsLoaded(locations: [])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mevcut Konumumu Kaydet'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('saved-location-name-field')),
      'Ev',
    );
    await tester.enterText(
      find.byKey(const Key('saved-location-address-field')),
      'Esenler, İstanbul',
    );
    await tester.tap(find.byKey(const Key('saved-location-capture-button')));
    await tester.pumpAndSettle();

    final saveAction = tester.widget<FilledButton>(
      find.byKey(const Key('saved-location-save-button')),
    );
    saveAction.onPressed?.call();
    saveAction.onPressed?.call();
    await tester.pump();

    verify(
      () => cubit.addLocation(
        name: 'Ev',
        addressText: 'Esenler, İstanbul',
        coordinates: coordinates,
      ),
    ).called(1);

    saveResult.complete(true);
    await tester.pumpAndSettle();

    expect(find.text('Konumun kaydedildi.'), findsOneWidget);
  });

  testWidgets('konum izni reddedildiğinde anlaşılır açıklama gösterir', (
    tester,
  ) async {
    when(() => cubit.captureCurrentLocation()).thenAnswer(
      (_) async => const CustomerLocationResult.failed(
        CustomerLocationFailure.permissionDenied,
      ),
    );
    await tester.pumpWidget(
      buildSubject(const CustomerSavedLocationsLoaded(locations: [])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mevcut Konumumu Kaydet'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saved-location-capture-button')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Konum izni verilmedi. Tekrar deneyerek sistem izin ekranını açabilirsin.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('konumu silmeden önce onay ister', (tester) async {
    await tester.pumpWidget(
      buildSubject(const CustomerSavedLocationsLoaded(locations: [home, work])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Konumu sil').first);
    await tester.pumpAndSettle();
    expect(find.text('Konum silinsin mi?'), findsOneWidget);

    await tester.tap(find.text('Sil'));
    await tester.pumpAndSettle();

    verify(() => cubit.deleteLocation(home.id)).called(1);
  });

  testWidgets(
    'silme penceresi ve silme işlemi çift dokunmada bir kez çalışır',
    (tester) async {
      final deleteResult = Completer<bool>();
      when(
        () => cubit.deleteLocation(home.id),
      ).thenAnswer((_) => deleteResult.future);
      await tester.pumpWidget(
        buildSubject(
          const CustomerSavedLocationsLoaded(locations: [home, work]),
        ),
      );
      await tester.pumpAndSettle();

      final deleteAction = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.delete_outline_rounded).first,
      );
      deleteAction.onPressed?.call();
      deleteAction.onPressed?.call();
      await tester.pumpAndSettle();

      expect(find.text('Konum silinsin mi?'), findsOneWidget);

      final cancelAction = tester.widget<TextButton>(
        find.byKey(const Key('saved-location-delete-cancel')),
      );
      cancelAction.onPressed?.call();
      cancelAction.onPressed?.call();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('customer-saved-locations-content')),
        findsOneWidget,
      );
      verifyNever(() => cubit.deleteLocation(any()));

      await tester.tap(
        find.widgetWithIcon(IconButton, Icons.delete_outline_rounded).first,
      );
      await tester.pumpAndSettle();
      final confirmAction = tester.widget<FilledButton>(
        find.byKey(const Key('saved-location-delete-confirm')),
      );
      confirmAction.onPressed?.call();
      confirmAction.onPressed?.call();
      await tester.pump();

      verify(() => cubit.deleteLocation(home.id)).called(1);

      deleteResult.complete(true);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('customer-saved-locations-content')),
        findsOneWidget,
      );
    },
  );

  testWidgets('ana konum seçimini çift dokunmada bir kez gönderir', (
    tester,
  ) async {
    final setDefaultResult = Completer<bool>();
    when(
      () => cubit.setDefaultLocation(work.id),
    ).thenAnswer((_) => setDefaultResult.future);
    await tester.pumpWidget(
      buildSubject(const CustomerSavedLocationsLoaded(locations: [home, work])),
    );
    await tester.pumpAndSettle();

    final setDefaultAction = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Ana Konum Yap'),
    );
    setDefaultAction.onPressed?.call();
    setDefaultAction.onPressed?.call();
    await tester.pump();

    verify(() => cubit.setDefaultLocation(work.id)).called(1);

    setDefaultResult.complete(true);
    await tester.pumpAndSettle();

    expect(find.text('İş ana konum olarak seçildi.'), findsOneWidget);
    final availableAction = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Ana Konum Yap'),
    );
    expect(availableAction.onPressed, isNotNull);
  });

  testWidgets('yükleme hatasında tekrar deneme sunar', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        const CustomerSavedLocationsError(
          'Kayıtlı konumların şu anda yüklenemiyor. Lütfen tekrar dene.',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Konumların yüklenemedi'), findsOneWidget);
    await tester.tap(find.text('Tekrar Dene'));
    await tester.pump();

    verify(() => cubit.loadLocations()).called(2);
  });

  testWidgets('yüklenirken markalı bekleme durumunu gösterir', (tester) async {
    await tester.pumpWidget(
      buildSubject(const CustomerSavedLocationsLoading()),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('customer-saved-locations-loading-state')),
      findsOneWidget,
    );
    expect(find.text('Konumların yükleniyor'), findsOneWidget);
  });

  testWidgets('dar ekranda uzun konum bilgileri taşma yapmaz', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 620);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    const longLocation = CustomerSavedLocationEntity(
      id: 'location-responsive',
      userId: 'customer-1',
      name: 'Ailemin Sık Kullandığı Uzun İsimli Konum',
      addressText:
          '15 Temmuz Mahallesi, Esenler Teknopark çevresi, Esenler, İstanbul',
      latitude: 41.043,
      longitude: 28.876,
    );

    await tester.pumpWidget(
      buildSubject(
        const CustomerSavedLocationsLoaded(locations: [longLocation]),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('saved-location-card-location-responsive')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
