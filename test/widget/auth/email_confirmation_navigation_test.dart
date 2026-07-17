import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/signup/verify_email_view.dart';
import 'package:t_store/features/auth/presentation/widgets/login_form_section.dart';
import 'package:t_store/features/auth/presentation/widgets/sign_up_form_section.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  const email = 'musteri@example.com';

  Widget buildSubject({
    required MockAuthCubit authCubit,
    required Widget child,
  }) {
    return BlocProvider<AuthCubit>.value(
      value: authCubit,
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('successful sign up opens the verification waiting screen', (
    tester,
  ) async {
    final authCubit = MockAuthCubit();
    addTearDown(authCubit.close);
    whenListen(
      authCubit,
      Stream<AuthState>.value(const AuthEmailConfirmationRequired(email)),
      initialState: AuthInitial(),
    );

    await tester.pumpWidget(
      buildSubject(
        authCubit: authCubit,
        child: const SingleChildScrollView(child: SignUpFormSection()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(VerifyEmailView), findsOneWidget);
    expect(find.text(email), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('unconfirmed login opens the same verification screen', (
    tester,
  ) async {
    final authCubit = MockAuthCubit();
    addTearDown(authCubit.close);
    whenListen(
      authCubit,
      Stream<AuthState>.value(const AuthEmailConfirmationRequired(email)),
      initialState: AuthInitial(),
    );

    await tester.pumpWidget(
      buildSubject(
        authCubit: authCubit,
        child: const SingleChildScrollView(child: LoginFormSection()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(VerifyEmailView), findsOneWidget);
    expect(find.text(email), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
