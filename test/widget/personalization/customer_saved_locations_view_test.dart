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
        'Konum izni verilmedi. Tarayıcı izinlerinden konuma izin verebilirsin.',
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
}
