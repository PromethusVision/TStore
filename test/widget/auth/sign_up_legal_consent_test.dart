import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/auth/domain/legal/legal_document_versions.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/legal/legal_document_views.dart';
import 'package:t_store/features/auth/presentation/widgets/sign_up_form_section.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit authCubit;

  setUp(() {
    authCubit = MockAuthCubit();
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    when(
      () => authCubit.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        fullName: any(named: 'fullName'),
        phone: any(named: 'phone'),
        privacyNoticeVersion: any(named: 'privacyNoticeVersion'),
        termsOfUseVersion: any(named: 'termsOfUseVersion'),
      ),
    ).thenAnswer((_) async {});
  });

  Widget buildSubject() {
    return BlocProvider<AuthCubit>.value(
      value: authCubit,
      child: const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: SignUpFormSection())),
      ),
    );
  }

  testWidgets('legal declarations start unchecked and block registration', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    final privacyCheckbox = find.descendant(
      of: find.byKey(const Key('privacy-notice-agreement')),
      matching: find.byType(Checkbox),
    );
    final termsCheckbox = find.descendant(
      of: find.byKey(const Key('terms-of-use-agreement')),
      matching: find.byType(Checkbox),
    );

    expect(tester.widget<Checkbox>(privacyCheckbox).value, isFalse);
    expect(tester.widget<Checkbox>(termsCheckbox).value, isFalse);

    await tester.ensureVisible(find.byKey(const Key('signup-submit')));
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pump();

    expect(
      find.textContaining('aydınlatma metnini okuduğunuzu'),
      findsOneWidget,
    );
    expect(
      find.textContaining('kullanım koşullarını kabul edin'),
      findsOneWidget,
    );
    verifyNever(
      () => authCubit.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        fullName: any(named: 'fullName'),
        phone: any(named: 'phone'),
        privacyNoticeVersion: any(named: 'privacyNoticeVersion'),
        termsOfUseVersion: any(named: 'termsOfUseVersion'),
      ),
    );
  });

  testWidgets('privacy notice and terms are readable before acceptance', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.ensureVisible(find.byKey(const Key('open-privacy-notice')));
    await tester.tap(find.byKey(const Key('open-privacy-notice')));
    await tester.pumpAndSettle();

    expect(find.byType(KvkkInformationView), findsOneWidget);
    expect(find.text('KVKK Aydınlatma Metni'), findsOneWidget);
    expect(find.textContaining('Musaki Software'), findsWidgets);
    expect(
      find.text('Metin sürümü: ${LegalDocumentVersions.privacyNotice}'),
      findsOneWidget,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('open-terms-of-use')));
    await tester.tap(find.byKey(const Key('open-terms-of-use')));
    await tester.pumpAndSettle();

    expect(find.byType(TermsOfUseView), findsOneWidget);
    expect(find.text('Kullanım Koşulları'), findsOneWidget);
    expect(
      find.text('Metin sürümü: ${LegalDocumentVersions.termsOfUse}'),
      findsOneWidget,
    );
  });

  testWidgets('accepted document versions are sent with registration', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.enterText(find.byKey(const Key('signup-first-name')), 'Ayşe');
    await tester.enterText(find.byKey(const Key('signup-last-name')), 'Yılmaz');
    await tester.enterText(
      find.byKey(const Key('signup-email')),
      'AYSE@EXAMPLE.COM',
    );
    await tester.enterText(
      find.byKey(const Key('signup-phone')),
      '05551234567',
    );
    await tester.enterText(
      find.byKey(const Key('signup-password')),
      'Strong1!',
    );
    await tester.enterText(
      find.byKey(const Key('signup-confirm-password')),
      'Strong1!',
    );

    await tester.ensureVisible(
      find.byKey(const Key('privacy-notice-agreement')),
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('privacy-notice-agreement')),
        matching: find.byType(Checkbox),
      ),
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('terms-of-use-agreement')),
        matching: find.byType(Checkbox),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('signup-submit')));
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pump();

    verify(
      () => authCubit.signUp(
        email: 'ayse@example.com',
        password: 'Strong1!',
        fullName: 'Ayşe Yılmaz',
        phone: '05551234567',
        privacyNoticeVersion: LegalDocumentVersions.privacyNotice,
        termsOfUseVersion: LegalDocumentVersions.termsOfUse,
      ),
    ).called(1);
  });

  testWidgets('loading state prevents a second registration submission', (
    tester,
  ) async {
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthLoading(),
    );

    await tester.pumpWidget(buildSubject());
    await tester.ensureVisible(find.byKey(const Key('signup-submit')));

    final submitButton = tester.widget<ElevatedButton>(
      find.byKey(const Key('signup-submit')),
    );
    expect(submitButton.onPressed, isNull);
  });

  testWidgets('legal documents do not overflow on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: KvkkInformationView()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('KVKK Aydınlatma Metni'), findsOneWidget);
  });
}
