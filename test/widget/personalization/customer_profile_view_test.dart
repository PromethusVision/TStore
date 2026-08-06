import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/personalization/presentation/views/profile_view.dart';
import 'package:t_store/features/personalization/presentation/widgets/settings_view_header_section.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit authCubit;

  setUp(() {
    authCubit = MockAuthCubit();
    when(
      () => authCubit.deleteCurrentCustomerAccount(),
    ).thenAnswer((_) async => 'Hesap silinemedi.');
  });

  Widget buildHeader({
    required AuthState state,
    required String? currentUserId,
  }) {
    whenListen(authCubit, const Stream<AuthState>.empty(), initialState: state);

    return BlocProvider<AuthCubit>.value(
      value: authCubit,
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SettingsViewHeaderSection(currentUserId: currentUserId),
          ),
        ),
      ),
    );
  }

  testWidgets('oturumdaki müşterinin gerçek bilgilerini gösterir', (
    tester,
  ) async {
    const user = UserEntity(
      id: 'customer-1',
      email: 'ayse@example.com',
      fullName: 'Ayşe Yılmaz',
      phone: '+90 555 111 22 33',
    );

    await tester.pumpWidget(
      buildHeader(state: const AuthAuthenticated(user), currentUserId: user.id),
    );

    expect(find.text('Ayşe Yılmaz'), findsOneWidget);
    expect(find.text('ayse@example.com'), findsOneWidget);
    expect(find.text('Turgut Duman'), findsNothing);
    expect(find.text('turgut.duman@example.com'), findsNothing);

    await tester.tap(find.text('Ayşe Yılmaz'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileView), findsOneWidget);
    expect(find.text('Ayşe Yılmaz'), findsOneWidget);
    expect(find.text('ayse@example.com'), findsOneWidget);
    expect(find.text('+90 555 111 22 33'), findsOneWidget);
    expect(find.byKey(const Key('customer-account-content')), findsOneWidget);
    expect(
      find.byKey(const Key('customer-account-identity-card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('customer-account-contact-card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('customer-account-danger-zone')),
      findsOneWidget,
    );
    expect(find.text('Profil Fotoğrafını Değiştir'), findsNothing);
    expect(find.text('Kullanıcı Adı'), findsNothing);
    expect(find.text('Cinsiyet'), findsNothing);
    expect(find.text('Doğum Tarihi'), findsNothing);
  });

  testWidgets('hesap bilgileri 320 piksel genişlikte taşma yapmaz', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const user = UserEntity(
      id: 'customer-1',
      email: 'uzunepostaadresi@example.com',
      fullName: 'Oldukça Uzun Müşteri Adı Soyadı',
      phone: '+90 555 111 22 33',
    );

    await tester.pumpWidget(
      buildHeader(state: const AuthAuthenticated(user), currentUserId: user.id),
    );
    await tester.tap(find.text('Oldukça Uzun Müşteri Adı Soyadı'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-account-content')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hesabı sil düğmesi korumalı onay penceresini açar', (
    tester,
  ) async {
    const user = UserEntity(
      id: 'customer-1',
      email: 'ayse@example.com',
      fullName: 'Ayşe Yılmaz',
    );

    await tester.pumpWidget(
      buildHeader(state: const AuthAuthenticated(user), currentUserId: user.id),
    );
    await tester.tap(find.text('Ayşe Yılmaz'));
    await tester.pumpAndSettle();

    final deleteButton = find.byKey(const Key('delete-account-button'));
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('account-deletion-dialog')), findsOneWidget);
    expect(find.text('Hesabını kalıcı olarak sil'), findsOneWidget);

    await tester.tap(find.byKey(const Key('account-deletion-cancel-button')));
    await tester.pumpAndSettle();

    verifyNever(() => authCubit.deleteCurrentCustomerAccount());
  });

  testWidgets('eksik profil alanlarında yanıltıcı örnek bilgi göstermez', (
    tester,
  ) async {
    const user = UserEntity(id: 'customer-1', email: '   ', fullName: '   ');

    await tester.pumpWidget(
      buildHeader(state: const AuthAuthenticated(user), currentUserId: user.id),
    );

    expect(find.text('Ad soyad eklenmemiş'), findsOneWidget);
    expect(find.text('E-posta bilgisi bulunamadı'), findsOneWidget);

    await tester.tap(find.text('Ad soyad eklenmemiş'));
    await tester.pumpAndSettle();

    expect(find.text('Belirtilmemiş'), findsNWidgets(3));
    expect(find.text('Turgut Duman'), findsNothing);
  });

  testWidgets('hesap kimliği değiştiğinde eski kullanıcıyı göstermez', (
    tester,
  ) async {
    const oldUser = UserEntity(
      id: 'customer-old',
      email: 'old@example.com',
      fullName: 'Eski Kullanıcı',
    );

    await tester.pumpWidget(
      buildHeader(
        state: const AuthAuthenticated(oldUser),
        currentUserId: 'customer-new',
      ),
    );

    expect(find.text('Eski Kullanıcı'), findsNothing);
    expect(find.text('old@example.com'), findsNothing);
    expect(find.text('Bilgiler yükleniyor'), findsOneWidget);
  });

  testWidgets('profil yüklenemezse sade uyarı ve yeniden deneme sunar', (
    tester,
  ) async {
    when(() => authCubit.checkAuthStatus()).thenAnswer((_) async {});

    await tester.pumpWidget(
      buildHeader(
        state: const AuthError('network details'),
        currentUserId: 'customer-1',
      ),
    );

    expect(find.text('Bilgiler yüklenemedi'), findsOneWidget);
    expect(find.text('Tekrar denemek için dokunun'), findsOneWidget);
    expect(find.text('network details'), findsNothing);

    await tester.tap(find.text('Bilgiler yüklenemedi'));
    await tester.pump();

    verify(() => authCubit.checkAuthStatus()).called(1);
  });
}
