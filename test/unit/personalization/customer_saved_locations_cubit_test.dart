import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/personalization/domain/entities/customer_saved_location_entity.dart';
import 'package:t_store/features/personalization/domain/repositories/customer_saved_location_repository.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_state.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';

class MockCustomerSavedLocationRepository extends Mock
    implements CustomerSavedLocationRepository {}

class MockCustomerLocationService extends Mock
    implements CustomerLocationService {}

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

  late MockCustomerSavedLocationRepository repository;
  late MockCustomerLocationService locationService;
  late CustomerSavedLocationsCubit cubit;

  setUp(() {
    repository = MockCustomerSavedLocationRepository();
    locationService = MockCustomerLocationService();
    cubit = CustomerSavedLocationsCubit(
      repository: repository,
      customerLocationService: locationService,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  test('kayıtlı konumları güvenli durumla yükler', () async {
    when(
      () => repository.getLocations(),
    ).thenAnswer((_) async => const Right([home, work]));

    await cubit.loadLocations();

    expect(
      cubit.state,
      const CustomerSavedLocationsLoaded(locations: [home, work]),
    );
  });

  test('yükleme hatasında kullanıcıya teknik ayrıntı göstermez', () async {
    when(
      () => repository.getLocations(),
    ).thenAnswer((_) async => const Left('database internals'));

    await cubit.loadLocations();

    expect(
      cubit.state,
      const CustomerSavedLocationsError(
        'Kayıtlı konumların şu anda yüklenemiyor. Lütfen tekrar dene.',
      ),
    );
  });

  test('konum kaydederken cihazdan güncel koordinatı ister', () async {
    when(
      () => locationService.getCurrentLocation(forceRefresh: true),
    ).thenAnswer(
      (_) async => const CustomerLocationResult.success(coordinates),
    );

    final result = await cubit.captureCurrentLocation();

    expect(result, const CustomerLocationResult.success(coordinates));
    verify(
      () => locationService.getCurrentLocation(forceRefresh: true),
    ).called(1);
  });

  test('ilk kaydedilen konumu otomatik olarak ana konum yapar', () async {
    when(
      () => repository.getLocations(),
    ).thenAnswer((_) async => const Right([]));
    when(
      () => repository.addLocation(
        name: 'Ev',
        addressText: 'Esenler, İstanbul',
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
        isDefault: true,
      ),
    ).thenAnswer((_) async => const Right(home));

    await cubit.loadLocations();
    final didAdd = await cubit.addLocation(
      name: ' Ev ',
      addressText: ' Esenler, İstanbul ',
      coordinates: coordinates,
    );

    expect(didAdd, isTrue);
    expect(cubit.state, const CustomerSavedLocationsLoaded(locations: [home]));
  });

  test('ana konum seçimini listede tek kayıt olarak günceller', () async {
    when(
      () => repository.getLocations(),
    ).thenAnswer((_) async => const Right([home, work]));
    when(
      () => repository.setDefaultLocation(work.id),
    ).thenAnswer((_) async => const Right(null));

    await cubit.loadLocations();
    final didSet = await cubit.setDefaultLocation(work.id);

    final state = cubit.state as CustomerSavedLocationsLoaded;
    expect(didSet, isTrue);
    expect(state.locations.first.id, work.id);
    expect(state.locations.first.isDefault, isTrue);
    expect(
      state.locations.where((location) => location.isDefault),
      hasLength(1),
    );
  });

  test(
    'ana konum silinince sıradaki konumu ana konum olarak gösterir',
    () async {
      when(
        () => repository.getLocations(),
      ).thenAnswer((_) async => const Right([home, work]));
      when(
        () => repository.deleteLocation(home.id),
      ).thenAnswer((_) async => const Right(null));

      await cubit.loadLocations();
      final didDelete = await cubit.deleteLocation(home.id);

      final state = cubit.state as CustomerSavedLocationsLoaded;
      expect(didDelete, isTrue);
      expect(state.locations, [work.copyWith(isDefault: true)]);
    },
  );

  test('işlem başarısız olursa mevcut konum listesini korur', () async {
    when(
      () => repository.getLocations(),
    ).thenAnswer((_) async => const Right([home, work]));
    when(
      () => repository.deleteLocation(work.id),
    ).thenAnswer((_) async => const Left('database internals'));

    await cubit.loadLocations();
    final didDelete = await cubit.deleteLocation(work.id);

    expect(didDelete, isFalse);
    expect(
      cubit.state,
      const CustomerSavedLocationsLoaded(locations: [home, work]),
    );
  });
}
