import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';

class EmailConfirmationListener extends StatefulWidget {
  const EmailConfirmationListener({
    super.key,
    required this.callbacks,
    required this.navigatorKey,
    required this.scaffoldMessengerKey,
    required this.authenticatedDestinationBuilder,
    required this.unauthenticatedDestinationBuilder,
    required this.child,
    this.initialCallback,
  });

  final Stream<EmailConfirmationCallbackResult> callbacks;
  final EmailConfirmationCallbackResult? initialCallback;
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final WidgetBuilder authenticatedDestinationBuilder;
  final WidgetBuilder unauthenticatedDestinationBuilder;
  final Widget child;

  @override
  State<EmailConfirmationListener> createState() =>
      _EmailConfirmationListenerState();
}

class _EmailConfirmationListenerState extends State<EmailConfirmationListener> {
  StreamSubscription<EmailConfirmationCallbackResult>? _subscription;
  final Set<int> _handledSequences = <int>{};
  Future<void> _handlingQueue = Future<void>.value();

  @override
  void initState() {
    super.initState();
    _listen();
    final initialCallback = widget.initialCallback;
    if (initialCallback != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _queue(initialCallback);
      });
    }
  }

  @override
  void didUpdateWidget(covariant EmailConfirmationListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.callbacks != widget.callbacks) {
      _subscription?.cancel();
      _listen();
    }
  }

  void _listen() {
    _subscription = widget.callbacks.listen(
      _queue,
      onError: (Object _, StackTrace _) {
        // Callback transport errors must not disclose link/token details.
      },
    );
  }

  void _queue(EmailConfirmationCallbackResult result) {
    if (!_handledSequences.add(result.sequence)) return;
    _handlingQueue = _handlingQueue.then((_) => _handle(result));
  }

  Future<void> _handle(EmailConfirmationCallbackResult result) async {
    if (!mounted) return;

    if (result.status == EmailConfirmationCallbackStatus.invalid) {
      _showMessage(
        'Doğrulama bağlantısı geçersiz veya süresi dolmuş. '
        'Lütfen yeni bir bağlantı isteyin.',
      );
      return;
    }

    final authCubit = context.read<AuthCubit>();
    await authCubit.checkAuthStatus();
    if (!mounted) return;

    final navigator = widget.navigatorKey.currentState;
    if (navigator == null) return;

    final destinationBuilder = authCubit.state is AuthAuthenticated
        ? widget.authenticatedDestinationBuilder
        : widget.unauthenticatedDestinationBuilder;
    unawaited(
      navigator.pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(
          builder: (_) => _EmailConfirmationDestination(
            destinationBuilder: destinationBuilder,
          ),
        ),
        (_) => false,
      ),
    );
  }

  void _showMessage(String message) {
    widget.scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _EmailConfirmationDestination extends StatefulWidget {
  const _EmailConfirmationDestination({required this.destinationBuilder});

  final WidgetBuilder destinationBuilder;

  @override
  State<_EmailConfirmationDestination> createState() =>
      _EmailConfirmationDestinationState();
}

class _EmailConfirmationDestinationState
    extends State<_EmailConfirmationDestination> {
  Animation<double>? _routeAnimation;
  bool _noticeVisible = false;
  bool _noticeDismissed = false;
  bool _visibilityScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animation = ModalRoute.of(context)?.animation;
    if (identical(animation, _routeAnimation)) return;

    _routeAnimation?.removeStatusListener(_onRouteAnimationStatus);
    _routeAnimation = animation;
    if (animation == null || animation.status == AnimationStatus.completed) {
      _scheduleNoticeVisibility();
    } else {
      animation.addStatusListener(_onRouteAnimationStatus);
    }
  }

  void _onRouteAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _scheduleNoticeVisibility();
  }

  void _scheduleNoticeVisibility() {
    if (_visibilityScheduled || _noticeDismissed || _noticeVisible) return;
    _visibilityScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _visibilityScheduled = false;
      if (!mounted || _noticeDismissed || _noticeVisible) return;
      setState(() => _noticeVisible = true);
    });
  }

  void _dismissNotice() {
    if (_noticeDismissed) return;
    setState(() {
      _noticeDismissed = true;
      _noticeVisible = false;
    });
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteAnimationStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.destinationBuilder(context),
        if (_noticeVisible)
          Positioned(
            top: 0,
            left: EsnaftaVarSpacing.sm,
            right: EsnaftaVarSpacing.sm,
            child: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Semantics(
                    liveRegion: true,
                    child: Material(
                      key: const Key('email-confirmation-success-notice'),
                      elevation: 2,
                      color: EsnaftaVarColors.success,
                      borderRadius: BorderRadius.circular(
                        EsnaftaVarRadii.large,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'E-posta adresiniz başarıyla doğrulandı.',
                                style: TextStyle(
                                  color: EsnaftaVarColors.textOnPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              key: const Key(
                                'email-confirmation-success-notice-dismiss',
                              ),
                              tooltip: 'Bildirimi kapat',
                              onPressed: _dismissNotice,
                              color: EsnaftaVarColors.textOnPrimary,
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
