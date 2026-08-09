import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/personalization/domain/usecases/get_profile_usecase.dart';
import 'package:t_store/features/personalization/domain/usecases/update_profile_usecase.dart';
import 'package:t_store/features/personalization/presentation/cubit/profile_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/profile_state.dart';
import 'package:t_store/features/personalization/presentation/views/profile_view.dart';
import 'package:t_store/features/personalization/presentation/widgets/edit_profile_bottom_sheet.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockGetProfileUsecase extends Mock implements GetProfileUsecase {}

class MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}

class FakeUpdateProfileParams extends Fake implements UpdateProfileParams {}

void main() {
  const user = UserEntity(
    id: 'customer-1',
    email: 'ayse@example.com',
    fullName: 'Ayşe Yılmaz',
    phone: '0555 111 22 33',
  );
  const updatedUser = UserEntity(
    id: 'customer-1',
    email: 'ayse@example.com',
    fullName: 'Ayşe Demir',
    phone: '0555 222 33 44',
  );

  late MockAuthCubit authCubit;
  late MockGetProfileUsecase getProfileUsecase;
  late MockUpdateProfileUsecase updateProfileUsecase;
  late ProfileCubit profileCubit;
  late int profileCubitResolveCount;

  setUpAll(() {
    registerFallbackValue(FakeUpdateProfileParams());
    registerFallbackValue(
      const UserEntity(id: 'fallback-user', email: 'fallback@example.com'),
    );
  });

  setUp(() async {
    await sl.reset();
    authCubit = MockAuthCubit();
    getProfileUsecase = MockGetProfileUsecase();
    updateProfileUsecase = MockUpdateProfileUsecase();
    profileCubitResolveCount = 0;

    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: const AuthAuthenticated(user),
    );
    when(() => authCubit.syncUserProfile(any())).thenReturn(null);
    when(
      () => authCubit.deleteCurrentCustomerAccount(),
    ).thenAnswer((_) async => 'Hesap silinemedi.');

    profileCubit = ProfileCubit(
      getProfileUsecase: getProfileUsecase,
      updateProfileUsecase: updateProfileUsecase,
    );
    sl.registerFactory<ProfileCubit>(() {
      profileCubitResolveCount++;
      return profileCubit;
    });
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const ProfileView(user: user),
      ),
    );
  }

  Future<void> openEditor(WidgetTester tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.tap(find.byKey(const Key('edit-profile-button')));
    await tester.pumpAndSettle();
    expect(find.byType(EditProfileBottomSheet), findsOneWidget);
  }

  Future<void> tapSave(WidgetTester tester) async {
    final saveButton = find.byKey(const Key('edit-profile-save-button'));
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
  }

  testWidgets('geçerli ad ve telefonu kaydedip ekranlara anında yansıtır', (
    tester,
  ) async {
    when(
      () => updateProfileUsecase(any()),
    ).thenAnswer((_) async => const Right(updatedUser));

    await openEditor(tester);
    await tester.enterText(
      find.byKey(const Key('edit-profile-full-name-field')),
      '  Ayşe Demir  ',
    );
    await tester.enterText(
      find.byKey(const Key('edit-profile-phone-field')),
      '  0555 222 33 44  ',
    );
    await tapSave(tester);
    await tester.pumpAndSettle();

    final captured =
        verify(() => updateProfileUsecase(captureAny())).captured.single
            as UpdateProfileParams;
    expect(captured.fullName, 'Ayşe Demir');
    expect(captured.phone, '0555 222 33 44');
    expect(find.byType(EditProfileBottomSheet), findsNothing);
    expect(find.text('Ayşe Demir'), findsOneWidget);
    expect(find.text('0555 222 33 44'), findsOneWidget);
    verify(() => authCubit.syncUserProfile(updatedUser)).called(1);
  });

  testWidgets('değişiklik yoksa kaydetme butonunu etkinleştirmez', (
    tester,
  ) async {
    await openEditor(tester);

    expect(find.byKey(const Key('edit-profile-sheet')), findsOneWidget);
    expect(find.byKey(const Key('edit-profile-header')), findsOneWidget);
    expect(find.text('Değişiklikleri Kaydet'), findsOneWidget);
    expect(
      find.text('E-posta adresin hesap güvenliği için sabittir.'),
      findsOneWidget,
    );

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('edit-profile-save-button')),
    );
    expect(button.onPressed, isNull);
    verifyNever(() => updateProfileUsecase(any()));
  });

  testWidgets('boş ad ve hatalı telefonun kaydedilmesini engeller', (
    tester,
  ) async {
    await openEditor(tester);
    await tester.enterText(
      find.byKey(const Key('edit-profile-full-name-field')),
      ' ',
    );
    await tester.enterText(
      find.byKey(const Key('edit-profile-phone-field')),
      '12345',
    );
    await tapSave(tester);
    await tester.pump();

    expect(find.text('Ad soyad boş bırakılamaz'), findsOneWidget);
    expect(
      find.text('Telefonu 05xx xxx xx xx biçiminde girin'),
      findsOneWidget,
    );
    verifyNever(() => updateProfileUsecase(any()));
  });

  testWidgets('kayıt hatasında bilgileri koruyup sade uyarı gösterir', (
    tester,
  ) async {
    when(
      () => updateProfileUsecase(any()),
    ).thenAnswer((_) async => const Left('database details'));

    await openEditor(tester);
    await tester.enterText(
      find.byKey(const Key('edit-profile-full-name-field')),
      'Ayşe Demir',
    );
    await tester.pump();
    await tapSave(tester);
    await tester.pumpAndSettle();

    expect(profileCubit.state, isA<ProfileError>());
    expect(find.byType(EditProfileBottomSheet), findsOneWidget);
    expect(
      find.text('Bilgiler kaydedilemedi. Lütfen tekrar deneyin.'),
      findsOneWidget,
    );
    expect(find.text('database details'), findsNothing);
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const Key('edit-profile-full-name-field')),
          )
          .controller!
          .text,
      'Ayşe Demir',
    );
    verifyNever(() => authCubit.syncUserProfile(any()));
  });

  testWidgets('kapatma düğmesi değişiklik yapmadan hesaba geri döner', (
    tester,
  ) async {
    await openEditor(tester);

    await tester.tap(find.byKey(const Key('edit-profile-close-button')));
    await tester.pumpAndSettle();

    expect(find.byType(EditProfileBottomSheet), findsNothing);
    expect(find.byKey(const Key('customer-account-content')), findsOneWidget);
    verifyNever(() => updateProfileUsecase(any()));
  });

  testWidgets(
    'düzenleme penceresini çift dokunmada bir kez açar ve güvenli kapatır',
    (tester) async {
      await tester.pumpWidget(buildSubject());

      final editAction = tester.widget<FilledButton>(
        find.byKey(const Key('edit-profile-button')),
      );
      editAction.onPressed?.call();
      editAction.onPressed?.call();
      await tester.pumpAndSettle();

      expect(find.byType(EditProfileBottomSheet), findsOneWidget);
      expect(profileCubitResolveCount, 1);

      final closeAction = tester.widget<IconButton>(
        find.byKey(const Key('edit-profile-close-button')),
      );
      closeAction.onPressed?.call();
      closeAction.onPressed?.call();
      await tester.pumpAndSettle();

      expect(find.byType(EditProfileBottomSheet), findsNothing);
      expect(find.byKey(const Key('customer-account-content')), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('edit-profile-button')))
            .onPressed,
        isNotNull,
      );
      verifyNever(() => updateProfileUsecase(any()));
    },
  );

  testWidgets('dar ekranda alanlar kaydırılabilir ve taşma yapmaz', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await openEditor(tester);

    expect(find.byKey(const Key('edit-profile-header')), findsOneWidget);
    expect(find.byKey(const Key('edit-profile-phone-field')), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('edit-profile-save-button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Değişiklikleri Kaydet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kayıt sürerken ikinci gönderimi engeller', (tester) async {
    final updateResult = Completer<Either<String, UserEntity>>();
    when(
      () => updateProfileUsecase(any()),
    ).thenAnswer((_) => updateResult.future);

    await openEditor(tester);
    await tester.enterText(
      find.byKey(const Key('edit-profile-full-name-field')),
      'Ayşe Demir',
    );
    await tapSave(tester);
    await tester.pump();

    final updatingButton = tester.widget<FilledButton>(
      find.byKey(const Key('edit-profile-save-button')),
    );
    expect(updatingButton.onPressed, isNull);
    expect(find.text('Kaydediliyor...'), findsOneWidget);

    await tester.tap(find.byKey(const Key('edit-profile-save-button')));
    await tester.pump();
    verify(() => updateProfileUsecase(any())).called(1);

    updateResult.complete(const Right(updatedUser));
    await tester.pumpAndSettle();
    expect(find.byType(EditProfileBottomSheet), findsNothing);
  });

  testWidgets('hızlı çift kaydetme yalnız bir güncelleme gönderir', (
    tester,
  ) async {
    final updateResult = Completer<Either<String, UserEntity>>();
    when(
      () => updateProfileUsecase(any()),
    ).thenAnswer((_) => updateResult.future);

    await openEditor(tester);
    await tester.enterText(
      find.byKey(const Key('edit-profile-full-name-field')),
      'Ayşe Demir',
    );
    await tester.pump();

    final saveAction = tester.widget<FilledButton>(
      find.byKey(const Key('edit-profile-save-button')),
    );
    saveAction.onPressed?.call();
    saveAction.onPressed?.call();
    await tester.pump();

    verify(() => updateProfileUsecase(any())).called(1);
    expect(find.text('Kaydediliyor...'), findsOneWidget);

    updateResult.complete(const Right(updatedUser));
    await tester.pumpAndSettle();

    expect(find.byType(EditProfileBottomSheet), findsNothing);
    verify(() => authCubit.syncUserProfile(updatedUser)).called(1);
  });
}
