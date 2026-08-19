import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/common/widgets/customer_light_input_theme.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/theme/theme.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/widgets/customer_auth_form_card.dart';
import 'package:t_store/features/auth/presentation/widgets/forget_password_form_section.dart';
import 'package:t_store/features/auth/presentation/widgets/login_form_section.dart';
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
  });

  tearDown(() => authCubit.close());

  Widget buildSubject(Widget form) {
    return BlocProvider<AuthCubit>.value(
      value: authCubit,
      child: MaterialApp(
        theme: TAppTheme.lightTheme,
        darkTheme: TAppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: Scaffold(
          backgroundColor: CustomerHomeV1Tokens.cream,
          body: SingleChildScrollView(child: CustomerAuthFormCard(child: form)),
        ),
      ),
    );
  }

  Color? editableColor(WidgetTester tester, Key fieldKey) {
    return tester
        .widget<EditableText>(
          find.descendant(
            of: find.byKey(fieldKey),
            matching: find.byType(EditableText),
          ),
        )
        .style
        .color;
  }

  testWidgets('login values remain readable and password stays obscured', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(const LoginFormSection()));

    expect(
      editableColor(tester, const Key('login-email')),
      CustomerHomeV1Tokens.navy,
    );
    final password = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('login-password')),
        matching: find.byType(EditableText),
      ),
    );
    expect(password.style.color, CustomerHomeV1Tokens.navy);
    expect(password.obscureText, isTrue);
  });

  testWidgets('signup values remain readable in dark system mode', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(const SignUpFormSection()));

    for (final key in const [
      Key('signup-first-name'),
      Key('signup-last-name'),
      Key('signup-email'),
      Key('signup-phone'),
      Key('signup-password'),
      Key('signup-confirm-password'),
    ]) {
      expect(editableColor(tester, key), CustomerHomeV1Tokens.navy);
    }
  });

  testWidgets('password recovery value remains readable', (tester) async {
    await tester.pumpWidget(buildSubject(const ForgetPasswordFormSection()));

    expect(
      editableColor(tester, const Key('forgot-password-email')),
      CustomerHomeV1Tokens.navy,
    );
    expect(find.byType(CustomerLightInputTheme), findsOneWidget);
  });
}
