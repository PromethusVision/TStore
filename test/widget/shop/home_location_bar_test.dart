import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/personalization/domain/entities/customer_saved_location_entity.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_state.dart';
import 'package:t_store/features/shop/presentation/widgets/home_location_bar.dart';

class MockCustomerSavedLocationsCubit
    extends MockCubit<CustomerSavedLocationsState>
    implements CustomerSavedLocationsCubit {}

void main() {
  late MockCustomerSavedLocationsCubit locationsCubit;

  setUp(() {
    locationsCubit = MockCustomerSavedLocationsCubit();
  });

  Widget buildSubject({
    required CustomerSavedLocationsState state,
    VoidCallback? onTap,
    bool isAuthenticated = true,
  }) {
    whenListen(
      locationsCubit,
      const Stream<CustomerSavedLocationsState>.empty(),
      initialState: state,
    );

    return BlocProvider<CustomerSavedLocationsCubit>.value(
      value: locationsCubit,
      child: MaterialApp(
        home: Scaffold(
          body: HomeLocationBar(
            isAuthenticated: isAuthenticated,
            onTap: onTap ?? () {},
          ),
        ),
      ),
    );
  }

  testWidgets('ana konumun gerçek adını ve adresini gösterir', (tester) async {
    const location = CustomerSavedLocationEntity(
      id: 'location-1',
      userId: 'customer-1',
      name: 'Ev',
      addressText: 'Fevzi Çakmak Mahallesi, Esenler',
      latitude: 41.04,
      longitude: 28.87,
      isDefault: true,
    );

    await tester.pumpWidget(
      buildSubject(
        state: const CustomerSavedLocationsLoaded(locations: [location]),
      ),
    );

    expect(find.text('Ev'), findsOneWidget);
    expect(find.text('Fevzi Çakmak Mahallesi, Esenler'), findsOneWidget);
  });

  testWidgets('konum yokken sahte adres yerine seçim çağrısı gösterir', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      buildSubject(
        state: const CustomerSavedLocationsLoaded(locations: []),
        onTap: () => tapped = true,
      ),
    );

    expect(find.text('Konumunu seç'), findsOneWidget);
    expect(
      find.text('Yakınındaki mağazaları görmek için dokun'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('home-location-bar')));
    expect(tapped, isTrue);
  });

  testWidgets('yükleme durumunu açıkça gösterir', (tester) async {
    await tester.pumpWidget(
      buildSubject(state: const CustomerSavedLocationsLoading()),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('hata durumunda teknik ayrıntıyı gizler', (tester) async {
    await tester.pumpWidget(
      buildSubject(state: const CustomerSavedLocationsError('Teknik ayrıntı')),
    );
    expect(
      find.text('Konum yüklenemedi, tekrar denemek için dokun'),
      findsOneWidget,
    );
    expect(find.text('Teknik ayrıntı'), findsNothing);
  });
}
