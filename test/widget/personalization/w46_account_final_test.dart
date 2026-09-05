import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_state.dart';
import 'package:t_store/features/personalization/presentation/cubit/profile_state.dart';
import 'package:t_store/features/personalization/presentation/views/customer_saved_locations_view.dart';
import 'package:t_store/features/personalization/presentation/views/privacy_and_permissions_view.dart';
import 'package:t_store/features/personalization/presentation/views/settings_view.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';

import 'w46_account_fixture.dart';

void main() {
  setUp(() async => sl.reset());
  tearDown(() async => sl.reset());
  setUpAll(() async {
    registerFallbackValue(accountCoordinates);
    await loadAccountFonts();
  });

  for (final screen in ['hub', 'profile', 'privacy', 'help', 'locations']) {
    for (final width in [320.0, 390.0, 430.0]) {
      for (final scale in [1.0, 1.3]) {
        testWidgets('$screen at $width / $scale with long Turkish content', (
          tester,
        ) async {
          accountViewport(tester, width);
          final fixture = AccountFixture(longContent: true);
          await fixture.open(tester, screen, scale: scale);
          expect(tester.takeException(), isNull);
          expect(
            Theme.of(
              tester.element(
                find
                    .text(
                      screen == 'profile'
                          ? 'Hesap Bilgilerim'
                          : screen == 'privacy'
                          ? 'Gizlilik ve İzinler'
                          : screen == 'help'
                          ? 'Yardım ve Destek'
                          : screen == 'locations'
                          ? 'Kayıtlı Konumlarım'
                          : 'Profilim',
                    )
                    .first,
              ),
            ).textTheme.bodyMedium?.fontFamily,
            'Poppins',
          );
          await accountAccessibility(tester);
          final scroll = find.byType(Scrollable).first;
          final position = tester.state<ScrollableState>(scroll).position;
          position.jumpTo(position.maxScrollExtent);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await accountAccessibility(tester);
          if (screen == 'hub') {
            expect(
              find.byKey(const Key('customer-sign-out')).hitTestable(),
              findsOneWidget,
            );
          }
        });
      }
    }
  }

  for (final surface in ['edit', 'add', 'deletion', 'location-delete']) {
    for (final width in [320.0, 390.0, 430.0]) {
      testWidgets('$surface at $width / 130% with keyboard and validation', (
        tester,
      ) async {
        accountViewport(tester, width);
        final fixture = AccountFixture(longContent: true);
        await fixture.open(
          tester,
          surface,
          scale: 1.3,
          keyboard: surface == 'location-delete' ? 0 : 280,
        );
        if (surface == 'edit') {
          await tester.enterText(
            find.byKey(const Key('edit-profile-full-name-field')),
            'X',
          );
          await tester.enterText(
            find.byKey(const Key('edit-profile-phone-field')),
            'telefon',
          );
          await tester.pump();
          expect(find.text('Ad soyad en az 2 karakter olmalı'), findsOneWidget);
          expect(
            find.text('Geçerli bir telefon numarası girin'),
            findsOneWidget,
          );
          await tester.ensureVisible(
            find.byKey(const Key('edit-profile-save-button')),
          );
          await tester.tap(find.byKey(const Key('edit-profile-save-button')));
          verifyNever(
            () => fixture.profile.updateProfile(
              fullName: any(named: 'fullName'),
              phone: any(named: 'phone'),
            ),
          );
        } else if (surface == 'add') {
          await tester.ensureVisible(
            find.byKey(const Key('saved-location-save-button')),
          );
          await tester.tap(find.byKey(const Key('saved-location-save-button')));
          await tester.pump();
          expect(find.text('Konum adı gerekli.'), findsOneWidget);
          expect(find.text('Adres açıklaması gerekli.'), findsOneWidget);
          verifyNever(() => fixture.locations.captureCurrentLocation());
          verifyNever(
            () => fixture.locations.addLocation(
              name: any(named: 'name'),
              addressText: any(named: 'addressText'),
              coordinates: any(named: 'coordinates'),
            ),
          );
        } else if (surface == 'deletion') {
          expect(
            tester
                .widget<FilledButton>(
                  find.byKey(const Key('account-deletion-confirm-button')),
                )
                .onPressed,
            isNull,
          );
          await tester.enterText(
            find.byKey(const Key('account-deletion-confirmation-field')),
            'SİL',
          );
          await tester.pumpAndSettle();
          expect(
            find
                .byKey(const Key('account-deletion-confirm-button'))
                .hitTestable(),
            findsOneWidget,
          );
          expect(
            find
                .byKey(const Key('account-deletion-cancel-button'))
                .hitTestable(),
            findsOneWidget,
          );
          verifyNever(() => fixture.auth.deleteCurrentCustomerAccount());
        } else {
          expect(
            find.text('$accountLongName kayıtlı konumlardan kaldırılacak.'),
            findsOneWidget,
          );
          await tester.tap(
            find.byKey(const Key('saved-location-delete-cancel')),
          );
          await tester.pumpAndSettle();
          verifyNever(() => fixture.locations.deleteLocation(any()));
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await accountAccessibility(tester);
      });
    }
  }

  for (final status in CustomerLocationPermissionStatus.values) {
    testWidgets('privacy reads $status without requesting GPS', (tester) async {
      accountViewport(tester, 320);
      final fixture = AccountFixture();
      var reads = 0;
      await tester.pumpWidget(
        fixture.app(
          PrivacyAndPermissionsView(
            locationPermissionLoader: () async {
              reads++;
              return status;
            },
          ),
          scale: 1.3,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('location-permission-refresh')));
      await tester.pumpAndSettle();
      expect(reads, 2);
      expect(tester.takeException(), isNull);
      verifyNever(() => fixture.locations.captureCurrentLocation());
    });
  }

  testWidgets('privacy loading and error remain readable and retryable', (
    tester,
  ) async {
    accountViewport(tester, 320);
    final fixture = AccountFixture();
    final pending = Completer<CustomerLocationPermissionStatus>();
    await tester.pumpWidget(
      fixture.app(
        PrivacyAndPermissionsView(
          locationPermissionLoader: () => pending.future,
        ),
        scale: 1.3,
      ),
    );
    await tester.pump();
    expect(
      find.byKey(const Key('location-permission-progress')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const Key('location-permission-refresh')),
          )
          .onPressed,
      isNull,
    );
    pending.completeError(StateError('offline'));
    await tester.pumpAndSettle();
    expect(find.text('İzin durumu alınamadı'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const Key('location-permission-refresh')),
          )
          .onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });

  for (final state in [
    AuthUnauthenticated(),
    AuthLoading(),
    AuthError('offline'),
  ]) {
    testWidgets('hub reflects ${state.runtimeType} at 320 / 130%', (
      tester,
    ) async {
      accountViewport(tester, 320);
      final fixture = AccountFixture(authState: state);
      await tester.pumpWidget(
        fixture.app(
          SettingsView(
            currentUserIdProvider: () =>
                state is AuthUnauthenticated ? null : accountUser.id,
            useInheritedChatUnreadCubit: true,
            unreadAutoRefreshInterval: const Duration(hours: 1),
          ),
          scale: 1.3,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ayşe Yılmaz'), findsNothing);
      expect(
        find.text(
          state is AuthUnauthenticated
              ? 'Giriş yap'
              : state is AuthLoading
              ? 'Bilgiler yükleniyor'
              : 'Bilgiler yüklenemedi',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final state in [
    const CustomerSavedLocationsLoaded(locations: []),
    const CustomerSavedLocationsLoading(),
    const CustomerSavedLocationsError(
      'Kayıtlı konumların şu anda yüklenemiyor. Lütfen tekrar dene.',
    ),
    const CustomerSavedLocationsLoaded(
      locations: [accountHome, accountWork],
      isBusy: true,
      busyLocationId: 'w46-home',
    ),
  ]) {
    testWidgets(
      'locations ${state.runtimeType} ${state is CustomerSavedLocationsLoaded ? state.isBusy : ''} at 320 / 130%',
      (tester) async {
        accountViewport(tester, 320);
        final fixture = AccountFixture(locationsState: state);
        await tester.pumpWidget(
          fixture.app(
            CustomerSavedLocationsView(
              customerSavedLocationsCubit: fixture.locations,
            ),
            scale: 1.3,
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        if (state is CustomerSavedLocationsLoaded && state.isBusy) {
          expect(
            tester
                .widget<FilledButton>(
                  find.byKey(const Key('saved-location-add-button')),
                )
                .onPressed,
            isNull,
          );
        } else {
          expect(find.byType(EsnaftaVarStateCard), findsOneWidget);
        }
      },
    );
  }

  for (final failure in CustomerLocationFailure.values) {
    testWidgets(
      'add preserves location failure $failure and never saves coordinates',
      (tester) async {
        accountViewport(tester, 320);
        final fixture = AccountFixture();
        when(
          () => fixture.locations.captureCurrentLocation(),
        ).thenAnswer((_) async => CustomerLocationResult.failed(failure));
        await fixture.open(tester, 'add', scale: 1.3);
        await tester.ensureVisible(
          find.byKey(const Key('saved-location-capture-button')),
        );
        await tester.tap(
          find.byKey(const Key('saved-location-capture-button')),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('saved-location-add-error')),
          findsOneWidget,
        );
        verifyNever(
          () => fixture.locations.addLocation(
            name: any(named: 'name'),
            addressText: any(named: 'addressText'),
            coordinates: any(named: 'coordinates'),
          ),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final state in [
    ProfileUpdating(),
    const ProfileError('raw-private-error'),
  ]) {
    testWidgets(
      'profile ${state.runtimeType} exposes safe state at 320 / 130%',
      (tester) async {
        accountViewport(tester, 320);
        final fixture = AccountFixture(profileState: state);
        await tester.pumpWidget(
          fixture.app(fixture.screen('edit'), scale: 1.3),
        );
        await tester.ensureVisible(
          find.byKey(const Key('edit-profile-button')),
        );
        await tester.tap(find.byKey(const Key('edit-profile-button')));
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('raw-private-error'), findsNothing);
        if (state is ProfileUpdating) {
          expect(
            tester
                .widget<TextFormField>(
                  find.byKey(const Key('edit-profile-full-name-field')),
                )
                .enabled,
            isFalse,
          );
          expect(
            tester
                .widget<IconButton>(
                  find.byKey(const Key('edit-profile-close-button')),
                )
                .onPressed,
            isNull,
          );
        } else {
          expect(find.byKey(const Key('edit-profile-error')), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  const evidence =
      <
        ({
          String surface,
          double width,
          double scale,
          double keyboard,
          bool longContent,
        })
      >[
        (surface: 'hub', width: 390, scale: 1, keyboard: 0, longContent: false),
        (
          surface: 'profile',
          width: 390,
          scale: 1,
          keyboard: 0,
          longContent: false,
        ),
        (
          surface: 'privacy',
          width: 390,
          scale: 1,
          keyboard: 0,
          longContent: false,
        ),
        (
          surface: 'help',
          width: 390,
          scale: 1,
          keyboard: 0,
          longContent: false,
        ),
        (
          surface: 'locations',
          width: 390,
          scale: 1,
          keyboard: 0,
          longContent: false,
        ),
        (
          surface: 'edit',
          width: 390,
          scale: 1,
          keyboard: 0,
          longContent: false,
        ),
        (surface: 'add', width: 390, scale: 1, keyboard: 0, longContent: false),
        (
          surface: 'deletion',
          width: 390,
          scale: 1,
          keyboard: 0,
          longContent: false,
        ),
        (
          surface: 'hub',
          width: 320,
          scale: 1.3,
          keyboard: 0,
          longContent: true,
        ),
        (
          surface: 'profile',
          width: 430,
          scale: 1.3,
          keyboard: 0,
          longContent: true,
        ),
        (
          surface: 'add',
          width: 320,
          scale: 1.3,
          keyboard: 280,
          longContent: true,
        ),
        (
          surface: 'locations',
          width: 430,
          scale: 1.3,
          keyboard: 0,
          longContent: true,
        ),
      ];
  for (final item in evidence) {
    testWidgets('evidence ${item.surface} ${item.width} ${item.scale}', (
      tester,
    ) async {
      accountViewport(tester, item.width);
      final fixture = AccountFixture(longContent: item.longContent);
      await fixture.open(
        tester,
        item.surface,
        scale: item.scale,
        keyboard: item.keyboard,
      );
      if (item.surface == 'add' && item.longContent) {
        await tester.enterText(
          find.byKey(const Key('saved-location-name-field')),
          accountLongName,
        );
        await tester.enterText(
          find.byKey(const Key('saved-location-address-field')),
          accountLongAddress,
        );
        await tester.ensureVisible(
          find.byKey(const Key('saved-location-save-button')),
        );
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('w46-evidence')),
        matchesGoldenFile(
          'goldens/w46_${item.surface}_${item.width.toInt()}_${(item.scale * 100).toInt()}.png',
        ),
      );
    });
  }
}
