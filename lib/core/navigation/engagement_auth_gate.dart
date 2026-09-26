import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';

/// Uses existing auth UI; a notification cannot grant a session or a role.
class EngagementAuthGate extends StatelessWidget {
  const EngagementAuthGate({
    super.key,
    required this.builder,
    this.customerOnly = false,
  });
  final WidgetBuilder builder;
  final bool customerOnly;
  @override
  Widget build(BuildContext context) => BlocBuilder<AuthCubit, AuthState>(
    builder: (context, state) {
      if (state is AuthAuthenticated) {
        if (!customerOnly || state.user.isCustomer) {
          return KeyedSubtree(
            key: ValueKey(state.user.id),
            child: builder(context),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('EsnaftaVar')),
          body: const Center(child: Text('Bu içerik müşteri hesabı içindir.')),
        );
      }
      return Scaffold(
        appBar: AppBar(title: const Text('EsnaftaVar')),
        body: Center(
          child: FilledButton(
            onPressed: () => Navigator.of(context).push<bool>(
              MaterialPageRoute<bool>(
                builder: (_) =>
                    const LoginView(returnToCallerAfterCustomerLogin: true),
              ),
            ),
            child: const Text('Devam etmek için giriş yap'),
          ),
        ),
      );
    },
  );
}
