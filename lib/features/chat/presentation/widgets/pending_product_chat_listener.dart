import 'dart:async';

import 'package:flutter/material.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/chat/domain/services/pending_product_chat_storage.dart';
import 'package:t_store/features/chat/presentation/views/chat_view.dart';

typedef PendingProductChatCurrentUserIdProvider = String? Function();
typedef PendingProductChatLoginBuilder = Widget Function(BuildContext context);
typedef PendingProductChatDestinationBuilder =
    Widget Function(BuildContext context, PendingProductChatIntent intent);

class PendingProductChatListener extends StatefulWidget {
  const PendingProductChatListener({
    super.key,
    required this.navigatorKey,
    required this.scaffoldMessengerKey,
    required this.child,
    this.enabled = true,
    this.storage,
    this.currentUserIdProvider,
    this.loginBuilder,
    this.destinationBuilder,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final Widget child;
  final bool enabled;
  final PendingProductChatStorage? storage;
  final PendingProductChatCurrentUserIdProvider? currentUserIdProvider;
  final PendingProductChatLoginBuilder? loginBuilder;
  final PendingProductChatDestinationBuilder? destinationBuilder;

  @override
  State<PendingProductChatListener> createState() =>
      _PendingProductChatListenerState();
}

class _PendingProductChatListenerState
    extends State<PendingProductChatListener> {
  bool _isRestoring = false;
  bool _didCheckPendingIntent = false;

  PendingProductChatStorage get _storage =>
      widget.storage ?? sl<PendingProductChatStorage>();

  String? get _currentUserId {
    final provider = widget.currentUserIdProvider;
    final userId = provider != null
        ? provider()
        : SupabaseService.instance.currentUser?.id;
    final normalizedUserId = userId?.trim();
    return normalizedUserId == null || normalizedUserId.isEmpty
        ? null
        : normalizedUserId;
  }

  @override
  void initState() {
    super.initState();
    if (!widget.enabled) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_restorePendingIntent());
    });
  }

  Future<void> _restorePendingIntent() async {
    if (_isRestoring || _didCheckPendingIntent) return;
    _isRestoring = true;
    _didCheckPendingIntent = true;

    try {
      final intent = await _storage.getPending();
      if (!mounted || intent == null) return;

      var currentUserId = _currentUserId;
      if (currentUserId == null) {
        final navigator = widget.navigatorKey.currentState;
        if (navigator == null) return;

        final signedIn = await navigator.push<bool>(
          MaterialPageRoute<bool>(
            builder:
                widget.loginBuilder ??
                (_) => const LoginView(returnToCallerAfterCustomerLogin: true),
          ),
        );
        if (!mounted) return;

        if (signedIn != true) {
          await _safeClear();
          return;
        }
        currentUserId = _currentUserId;
      }

      if (currentUserId == null) return;

      if (currentUserId == intent.receiverId) {
        await _safeClear();
        _showSelfMessageWarning();
        return;
      }

      await _safeClear();
      if (!mounted) return;

      final navigator = widget.navigatorKey.currentState;
      if (navigator == null) return;

      await navigator.push<void>(
        MaterialPageRoute<void>(
          builder: (context) {
            final destinationBuilder = widget.destinationBuilder;
            return destinationBuilder?.call(context, intent) ??
                ChatView(
                  receiverId: intent.receiverId,
                  receiverName: intent.receiverName,
                  initialDraft: intent.initialDraft,
                );
          },
        ),
      );
    } catch (_) {
      await _safeClear();
    } finally {
      _isRestoring = false;
    }
  }

  Future<void> _safeClear() async {
    try {
      await _storage.clear();
    } catch (_) {}
  }

  void _showSelfMessageWarning() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.scaffoldMessengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Bu mağazaya kendi hesabınızla mesaj gönderemezsiniz.',
            ),
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
