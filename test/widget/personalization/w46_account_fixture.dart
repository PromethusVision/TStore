import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_state.dart';
import 'package:t_store/features/personalization/domain/entities/customer_saved_location_entity.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_state.dart';
import 'package:t_store/features/personalization/presentation/cubit/profile_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/profile_state.dart';
import 'package:t_store/features/personalization/presentation/views/customer_saved_locations_view.dart';
import 'package:t_store/features/personalization/presentation/views/help_and_support_view.dart';
import 'package:t_store/features/personalization/presentation/views/privacy_and_permissions_view.dart';
import 'package:t_store/features/personalization/presentation/views/profile_view.dart';
import 'package:t_store/features/personalization/presentation/views/settings_view.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';

class AccountAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class AccountUnreadCubit extends MockCubit<ChatUnreadState>
    implements ChatUnreadCubit {}

class AccountProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

class AccountLocationsCubit extends MockCubit<CustomerSavedLocationsState>
    implements CustomerSavedLocationsCubit {}

// Synthetic fixture data only. These coordinates are never sent to a service.
const accountCoordinates = CustomerCoordinates(latitude: 41, longitude: 29);
const accountUser = UserEntity(
  id: 'w46-customer',
  email: 'ayse@example.com',
  fullName: 'Ayşe Yılmaz',
  phone: '0555 111 22 33',
);
const accountLongName = 'Çağrı Şükran Öztürk Çiçekçi Uzun Müşteri Adı Soyadı';
const accountLongAddress =
    'Çınarlı Mahallesi, Öğretmen Şükrü Bey Caddesi, Yağmur Apartmanı, ikinci giriş, üst kat, uzun adres açıklaması. Kapı yanında küçük bir çiçekçi bulunuyor.';
const accountHome = CustomerSavedLocationEntity(
  id: 'w46-home',
  userId: 'w46-customer',
  name: 'Ev',
  addressText: 'Çınar Mahallesi, Pazar Caddesi, İstanbul',
  latitude: 41,
  longitude: 29,
  isDefault: true,
);
const accountWork = CustomerSavedLocationEntity(
  id: 'w46-work',
  userId: 'w46-customer',
  name: 'İş',
  addressText: 'Çiçek Sokak, İstanbul',
  latitude: 41,
  longitude: 29,
);

class AccountFixture {
  AccountFixture({
    bool longContent = false,
    AuthState? authState,
    ProfileState? profileState,
    CustomerSavedLocationsState? locationsState,
  }) : user = longContent
           ? const UserEntity(
               id: 'w46-customer',
               email: 'uzun.turkce.musteri.adresi@example.com',
               fullName: accountLongName,
               phone: '0555 111 22 33',
             )
           : accountUser {
    whenListen(
      auth,
      const Stream<AuthState>.empty(),
      initialState: authState ?? AuthAuthenticated(user),
    );
    whenListen(
      unread,
      const Stream<ChatUnreadState>.empty(),
      initialState: const ChatUnreadLoaded(128),
    );
    whenListen(
      profile,
      const Stream<ProfileState>.empty(),
      initialState: profileState ?? ProfileInitial(),
    );
    whenListen(
      locations,
      const Stream<CustomerSavedLocationsState>.empty(),
      initialState:
          locationsState ??
          CustomerSavedLocationsLoaded(
            locations: [
              longContent
                  ? accountHome.copyWith(
                      name: accountLongName,
                      addressText: accountLongAddress,
                    )
                  : accountHome,
              accountWork,
            ],
          ),
    );
    when(() => auth.checkAuthStatus()).thenAnswer((_) async {});
    when(
      () => auth.deleteCurrentCustomerAccount(),
    ).thenAnswer((_) async => 'Hesap şu anda silinemedi. Lütfen tekrar dene.');
    when(() => unread.loadUnreadCount()).thenAnswer((_) async {});
    when(() => unread.refreshUnreadCount()).thenAnswer((_) async {});
    when(
      () => profile.updateProfile(
        fullName: any(named: 'fullName'),
        phone: any(named: 'phone'),
      ),
    ).thenAnswer((_) async {});
    when(() => locations.loadLocations()).thenAnswer((_) async {});
    when(() => locations.captureCurrentLocation()).thenAnswer(
      (_) async => const CustomerLocationResult.success(accountCoordinates),
    );
    when(
      () => locations.addLocation(
        name: any(named: 'name'),
        addressText: any(named: 'addressText'),
        coordinates: any(named: 'coordinates'),
      ),
    ).thenAnswer((_) async => true);
    when(
      () => locations.setDefaultLocation(any()),
    ).thenAnswer((_) async => true);
    when(() => locations.deleteLocation(any())).thenAnswer((_) async => true);
    sl.registerFactory<ProfileCubit>(() => profile);
  }

  final UserEntity user;
  final auth = AccountAuthCubit();
  final unread = AccountUnreadCubit();
  final profile = AccountProfileCubit();
  final locations = AccountLocationsCubit();

  Widget screen(String name) => switch (name) {
    'hub' => SettingsView(
      currentUserIdProvider: () => user.id,
      useInheritedChatUnreadCubit: true,
      unreadAutoRefreshInterval: const Duration(hours: 1),
    ),
    'profile' || 'edit' || 'deletion' => ProfileView(user: user),
    'privacy' => PrivacyAndPermissionsView(
      locationPermissionLoader: () async =>
          CustomerLocationPermissionStatus.allowed,
    ),
    'help' => HelpAndSupportView(
      onOpenPurchases: () {},
      onOpenMessages: () {},
      onOpenSavedLocations: () {},
    ),
    'locations' || 'add' || 'location-delete' => CustomerSavedLocationsView(
      customerSavedLocationsCubit: locations,
    ),
    _ => throw ArgumentError(name),
  };

  Widget app(
    Widget child, {
    double scale = 1,
    double keyboard = 0,
  }) => MultiBlocProvider(
    providers: [
      BlocProvider<AuthCubit>.value(value: auth),
      BlocProvider<ChatUnreadCubit>.value(value: unread),
    ],
    child: RepaintBoundary(
      key: const Key('w46-evidence'),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: EsnaftaVarTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            viewInsets: EdgeInsets.only(bottom: keyboard),
          ),
          child: child!,
        ),
        // The hub lives inside NavigationMenu's Scaffold in the application.
        home: child is SettingsView ? Scaffold(body: child) : child,
      ),
    ),
  );

  Future<void> open(
    WidgetTester tester,
    String name, {
    double scale = 1,
    double keyboard = 0,
  }) async {
    // Open before adding keyboard insets, as on the real route.
    await tester.pumpWidget(app(screen(name), scale: scale));
    await tester.pumpAndSettle();
    if (name == 'edit' || name == 'deletion') {
      final action = find.byKey(
        Key(name == 'edit' ? 'edit-profile-button' : 'delete-account-button'),
      );
      await tester.ensureVisible(action);
      await tester.tap(action);
    } else if (name == 'add') {
      await tester.tap(find.byKey(const Key('saved-location-add-button')));
    } else if (name == 'location-delete') {
      await tester.tap(find.byKey(const Key('saved-location-delete-w46-home')));
    }
    await tester.pumpAndSettle();
    if (keyboard > 0) {
      await tester.pumpWidget(
        app(screen(name), scale: scale, keyboard: keyboard),
      );
      await tester.pumpAndSettle();
    }
  }
}

Future<void> loadAccountFonts() async {
  final poppins = FontLoader('Poppins')
    ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Poppins-Bold.ttf'));
  final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
  final material = FontLoader('MaterialIcons')
    ..addFont(
      File(
        '${artifacts.path}${Platform.pathSeparator}material_fonts${Platform.pathSeparator}MaterialIcons-Regular.otf',
      ).readAsBytes().then(ByteData.sublistView),
    );
  await Future.wait([poppins.load(), material.load()]);
}

void accountViewport(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> accountAccessibility(WidgetTester tester) async {
  final handle = tester.ensureSemantics();
  try {
    // Measure complete controls, including those partially clipped at a scroll
    // edge. The platform guideline measures their clipped semantic rectangle.
    final targets = find.byWidgetPredicate(
      (widget) =>
          widget is ButtonStyleButton && widget.onPressed != null ||
          widget is IconButton && widget.onPressed != null ||
          widget is InkWell && widget.onTap != null,
    );
    for (final element in targets.evaluate()) {
      final size = tester.getSize(
        find.byElementPredicate((candidate) => identical(candidate, element)),
      );
      expect(
        size.width,
        greaterThanOrEqualTo(44),
        reason: '${element.widget.runtimeType} width',
      );
      expect(
        size.height,
        greaterThanOrEqualTo(44),
        reason: '${element.widget.runtimeType} height',
      );
    }
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    for (final button
        in find
            .byWidgetPredicate((widget) => widget is ButtonStyleButton)
            .evaluate()) {
      final texts = find.descendant(
        of: find.byElementPredicate((element) => identical(element, button)),
        matching: find.byType(RichText),
      );
      for (final text in tester.widgetList<RichText>(texts)) {
        // Icon also uses RichText; only button labels use Poppins.
        if (text.text.style?.fontFamily == 'MaterialIcons') continue;
        expect(
          text.text.style?.fontFamily,
          'Poppins',
          reason: 'Button label must inherit Final UI typography',
        );
      }
    }
  } finally {
    handle.dispose();
  }
}
