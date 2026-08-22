import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/browser_url_sanitizer.dart';
import 'package:t_store/features/auth/domain/entities/password_recovery_verification.dart';
import 'package:t_store/features/auth/presentation/views/password_configuration/invalid_password_recovery_view.dart';
import 'package:t_store/features/auth/presentation/views/password_configuration/update_password_view.dart';

class PasswordRecoveryListener extends StatefulWidget {
  const PasswordRecoveryListener({
    super.key,
    required this.authStateChanges,
    required this.navigatorKey,
    required this.initialPasswordRecoveryStatus,
    this.initialRecoveryIdentity,
    required this.child,
  });

  final Stream<supabase.AuthState> authStateChanges;
  final GlobalKey<NavigatorState> navigatorKey;
  final PasswordRecoveryLaunchStatus initialPasswordRecoveryStatus;
  final PasswordRecoveryIdentity? initialRecoveryIdentity;
  final Widget child;

  @override
  State<PasswordRecoveryListener> createState() =>
      _PasswordRecoveryListenerState();
}

class _PasswordRecoveryListenerState extends State<PasswordRecoveryListener> {
  StreamSubscription<supabase.AuthState>? _subscription;
  bool _recoveryScreenOpened = false;

  @override
  void initState() {
    super.initState();
    _listenForPasswordRecovery();
    if (widget.initialPasswordRecoveryStatus ==
        PasswordRecoveryLaunchStatus.verified) {
      _openRecoveryScreen(widget.initialRecoveryIdentity);
    } else if (widget.initialPasswordRecoveryStatus ==
        PasswordRecoveryLaunchStatus.invalid) {
      _openInvalidRecoveryScreen();
    }
  }

  @override
  void didUpdateWidget(covariant PasswordRecoveryListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authStateChanges != widget.authStateChanges) {
      _subscription?.cancel();
      _listenForPasswordRecovery();
    }
    if (oldWidget.initialPasswordRecoveryStatus !=
            widget.initialPasswordRecoveryStatus &&
        widget.initialPasswordRecoveryStatus ==
            PasswordRecoveryLaunchStatus.verified) {
      _openRecoveryScreen(widget.initialRecoveryIdentity);
    } else if (oldWidget.initialPasswordRecoveryStatus !=
            widget.initialPasswordRecoveryStatus &&
        widget.initialPasswordRecoveryStatus ==
            PasswordRecoveryLaunchStatus.invalid) {
      _openInvalidRecoveryScreen();
    }
  }

  void _listenForPasswordRecovery() {
    _subscription = widget.authStateChanges.listen(
      (authState) {
        if (authState.event != supabase.AuthChangeEvent.passwordRecovery ||
            _recoveryScreenOpened) {
          return;
        }

        final user = authState.session?.user;
        final email = user?.email;
        final identity = user == null || email == null
            ? null
            : PasswordRecoveryIdentity(userId: user.id, email: email);
        _openRecoveryScreen(identity);
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Şifre yenileme bağlantısı dinlenemedi: $error');
      },
    );
  }

  void _openRecoveryScreen(PasswordRecoveryIdentity? identity) {
    if (identity == null || !identity.isValid) {
      _openInvalidRecoveryScreen();
      return;
    }
    _openScreen((_) => UpdatePasswordView(recoveryIdentity: identity));
  }

  void _openInvalidRecoveryScreen() {
    _openScreen((_) => const InvalidPasswordRecoveryView());
  }

  void _openScreen(WidgetBuilder builder) {
    if (_recoveryScreenOpened) return;

    _recoveryScreenOpened = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (widget.initialPasswordRecoveryStatus !=
          PasswordRecoveryLaunchStatus.none) {
        replaceCurrentBrowserUrl('/');
      }

      final navigator = widget.navigatorKey.currentState;
      if (navigator == null) {
        _recoveryScreenOpened = false;
        return;
      }

      unawaited(
        navigator
            .pushAndRemoveUntil<void>(
              MaterialPageRoute<void>(builder: builder),
              (_) => false,
            )
            .whenComplete(() => _recoveryScreenOpened = false),
      );
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
