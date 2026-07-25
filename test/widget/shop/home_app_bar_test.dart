import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/shop/presentation/widgets/home_app_bar.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockCartV2Cubit extends MockCubit<CartV2State> implements CartV2Cubit {}

void main() {
  late MockAuthCubit authCubit;
  late MockCartV2Cubit cartV2Cubit;

  setUp(() {
    authCubit = MockAuthCubit();
    cartV2Cubit = MockCartV2Cubit();

    whenListen(
      cartV2Cubit,
      const Stream<CartV2State>.empty(),
      initialState: const CartV2Loaded([]),
    );
  });

  Widget buildAppBar({required AuthState authState, String? sessionFullName}) {
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: authState,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<CartV2Cubit>.value(value: cartV2Cubit),
      ],
      child: MaterialApp(
        home: Scaffold(body: HomeAppBar(sessionFullName: sessionFullName)),
      ),
    );
  }

  testWidgets('giriş yapan müşterinin gerçek adını gösterir', (tester) async {
    const user = UserEntity(
      id: 'customer-1',
      email: 'ayse@example.com',
      fullName: 'Ayşe Yılmaz',
    );

    await tester.pumpWidget(
      buildAppBar(
        authState: const AuthAuthenticated(user),
        sessionFullName: 'Eski Oturum Adı',
      ),
    );

    expect(find.text('Ayşe Yılmaz'), findsOneWidget);
    expect(find.text('Eski Oturum Adı'), findsNothing);
    expect(find.text('Mahmoud Hamdy'), findsNothing);
  });

  testWidgets('oturumdaki adı güvenli yedek olarak gösterir', (tester) async {
    await tester.pumpWidget(
      buildAppBar(authState: AuthInitial(), sessionFullName: 'Mehmet Demir'),
    );

    expect(find.text('Mehmet Demir'), findsOneWidget);
    expect(find.text(TTexts.homeAppbarSubTitle), findsNothing);
  });

  testWidgets('ad bulunmadığında karşılama metnini gösterir', (tester) async {
    await tester.pumpWidget(
      buildAppBar(authState: AuthUnauthenticated(), sessionFullName: ''),
    );

    expect(find.text(TTexts.homeAppbarSubTitle), findsOneWidget);
    expect(find.text('Mahmoud Hamdy'), findsNothing);
  });
}
