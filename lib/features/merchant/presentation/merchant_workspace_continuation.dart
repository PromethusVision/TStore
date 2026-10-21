import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/merchant/presentation/merchant_session_cubit.dart';

/// A mounted route can outlive its host authority until the next rendered frame.
/// Reuse the host's irreversible revision and Auth identity before any local
/// continuation. Navigation/private-content removal remains owned by that host.
/// Standalone previews without a host retain their existing local behavior.
mixin MerchantWorkspaceContinuation<T extends StatefulWidget> on State<T> {
  late final MerchantSessionCubit? _workspace;
  late final int? _revision;
  late final String? _actor, _key;
  bool _retired = false;

  @override
  void initState() {
    super.initState();
    _workspace = context.read<MerchantSessionCubit?>();
    _revision = _workspace?.state.scopeRevision;
    _actor = _workspace?.currentUserId();
    _key = _workspace?.currentSessionKey?.call();
  }

  bool get workspaceCurrent {
    if (!mounted || _retired) return false;
    final host = _workspace;
    if (host == null) return true;
    final state = host.state;
    if (host.isClosed ||
        state.busy ||
        state.scopeRevision != _revision ||
        _actor == null ||
        host.currentUserId() != _actor ||
        state.access?.user.id != _actor ||
        (host.currentSessionKey != null &&
            (_key == null || host.currentSessionKey!() != _key)) ||
        (state.status != MerchantSessionStatus.ready &&
            state.status != MerchantSessionStatus.onboarding)) {
      _retired = true;
    }
    return !_retired;
  }
}
