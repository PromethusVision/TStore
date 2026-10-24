import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import '../domain/entities/notification_entity.dart';
import '../runtime/customer_push_binding.dart';
import 'views/customer_notifications_view.dart';

class CustomerPushScope extends InheritedWidget {
  const CustomerPushScope({
    super.key,
    required this.binding,
    required super.child,
  });
  final CustomerPushBinding? binding;
  static CustomerPushBinding? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CustomerPushScope>()?.binding;
  @override
  bool updateShouldNotify(CustomerPushScope oldWidget) =>
      binding != oldWidget.binding;
}

class CustomerPushHost extends StatefulWidget {
  const CustomerPushHost({
    super.key,
    required this.binding,
    required this.navigatorKey,
    required this.child,
    this.destinationBuilder,
  });
  final CustomerPushBinding? binding;
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;
  final Widget Function(NotificationEntity)? destinationBuilder;
  @override
  State<CustomerPushHost> createState() => _CustomerPushHostState();
}

class _CustomerPushHostState extends State<CustomerPushHost> {
  StreamSubscription<NotificationEntity>? _opens;
  StreamSubscription<AuthState>? _auth;
  @override
  void initState() {
    super.initState();
    _opens = widget.binding?.opens.listen(_open);
    widget.binding?.authority.addListener(_ready);
    _auth = context.read<AuthCubit>().stream.listen((_) => _ready());
    _ready();
  }

  @override
  void didUpdateWidget(CustomerPushHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.binding != widget.binding) {
      oldWidget.binding?.authority.removeListener(_ready);
      _opens?.cancel();
      _opens = widget.binding?.opens.listen(_open);
      widget.binding?.authority.addListener(_ready);
      _ready();
    }
  }

  bool _authorized(String user) {
    final state = context.read<AuthCubit>().state;
    return mounted &&
        state is AuthAuthenticated &&
        state.user.id == user &&
        state.user.role == 'customer' &&
        widget.binding?.service.currentUser?.id == user &&
        widget.binding?.session != null;
  }

  void _ready() {
    final binding = widget.binding;
    final user = binding?.service.currentUser?.id;
    if (binding != null && user != null && _authorized(user)) {
      final revision = binding.authority.value;
      final session = binding.session;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            identical(binding, widget.binding) &&
            binding.authority.value == revision &&
            binding.session == session &&
            _authorized(user)) {
          // A replacement session need not emit a new AuthCubit profile. Only
          // observe taps here; coordinator cleanup/enrollment gates still apply.
          binding.coordinator.observeOpens();
        }
      });
      // Authority changes can arrive while the unchanged home screen is idle.
      // A post-frame callback alone would wait for an unrelated UI interaction.
      WidgetsBinding.instance.ensureVisualUpdate();
    }
  }

  void _open(NotificationEntity notification) {
    final binding = widget.binding;
    if (binding == null || !_authorized(notification.userId)) return;
    final revision = binding.authority.value;
    final session = binding.session;
    // Check again at first frame and every authority change: pushing a route
    // does not guarantee its builder runs before logout/replacement login.
    widget.navigatorKey.currentState?.push<void>(
      MaterialPageRoute(
        builder: (_) => ValueListenableBuilder<int>(
          valueListenable: binding.authority,
          builder: (_, current, _) =>
              current == revision &&
                  session == binding.session &&
                  _authorized(notification.userId)
              ? widget.destinationBuilder?.call(notification) ??
                    buildCustomerNotificationDestination(notification) ??
                    const CustomerNotificationsView()
              : const Scaffold(
                  body: Center(
                    child: Text('Bu bildirimi görmek için yeniden giriş yap.'),
                  ),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.binding?.authority.removeListener(_ready);
    _opens?.cancel();
    _auth?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      CustomerPushScope(binding: widget.binding, child: widget.child);
}
