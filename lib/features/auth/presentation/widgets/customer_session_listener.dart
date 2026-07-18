import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';

class CustomerSessionListener extends StatefulWidget {
  const CustomerSessionListener({
    super.key,
    required this.authStateChanges,
    required this.navigatorKey,
    required this.scaffoldMessengerKey,
    required this.initiallyAuthenticated,
    required this.signedOutDestinationBuilder,
    required this.child,
  });

  final Stream<supabase.AuthState> authStateChanges;
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final bool initiallyAuthenticated;
  final WidgetBuilder signedOutDestinationBuilder;
  final Widget child;

  @override
  State<CustomerSessionListener> createState() =>
      _CustomerSessionListenerState();
}

class _CustomerSessionListenerState extends State<CustomerSessionListener> {
  StreamSubscription<supabase.AuthState>? _subscription;
  late bool _hadAuthenticatedSession;
  bool _handlingSignedOut = false;

  @override
  void initState() {
    super.initState();
    _hadAuthenticatedSession = widget.initiallyAuthenticated;
    _listenForSessionChanges();
  }

  @override
  void didUpdateWidget(covariant CustomerSessionListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authStateChanges != widget.authStateChanges) {
      _subscription?.cancel();
      _listenForSessionChanges();
    }
    if (widget.initiallyAuthenticated) {
      _hadAuthenticatedSession = true;
    }
  }

  void _listenForSessionChanges() {
    _subscription = widget.authStateChanges.listen(
      _onAuthStateChanged,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Müşteri oturumu dinlenemedi: $error');
      },
    );
  }

  void _onAuthStateChanged(supabase.AuthState authState) {
    if (authState.event == supabase.AuthChangeEvent.signedOut) {
      _handleSignedOut();
      return;
    }

    if (authState.session != null) {
      _hadAuthenticatedSession = true;
    }
  }

  void _handleSignedOut() {
    if (!mounted || _handlingSignedOut) return;
    _handlingSignedOut = true;

    final authCubit = context.read<AuthCubit>();
    final hadAuthenticatedSession =
        _hadAuthenticatedSession || authCubit.state is AuthAuthenticated;
    final wasUserInitiated = authCubit.handleSignedOutEvent();

    context.read<CartV2Cubit>().clearLocalCart();
    context.read<WishlistCubit>().clearLocalWishlist();
    context.read<NavigationMenuCubit>().changeIndex(0);
    _hadAuthenticatedSession = false;

    if (wasUserInitiated || !hadAuthenticatedSession) {
      _handlingSignedOut = false;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _handlingSignedOut = false;
        return;
      }

      final navigator = widget.navigatorKey.currentState;
      if (navigator == null) {
        _handlingSignedOut = false;
        return;
      }

      unawaited(
        navigator.pushAndRemoveUntil<void>(
          MaterialPageRoute<void>(builder: widget.signedOutDestinationBuilder),
          (_) => false,
        ),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.scaffoldMessengerKey.currentState
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Oturumunuz sona erdi. Devam etmek için yeniden giriş yapın.',
              ),
            ),
          );
      });
      _handlingSignedOut = false;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
