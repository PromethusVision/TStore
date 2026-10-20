import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';
import '../domain/merchant_promotion.dart';

/// A private route/overlay keeps the authority of its opener, including events
/// queued before its first frame. Ordinary access-token renewal is unchanged.
class PromotionViewSession {
  PromotionViewSession({
    required this.repository,
    required this.owner,
    required this.onLost,
    this.originIsCurrent,
  }) {
    if (repository case AuthenticatedSessionSource source) {
      _key = source.currentSessionKey;
    }
    _actors = repository.sessionChanges.listen(
      (actor) {
        if (actor != owner || !current) retire();
      },
      onError: (Object _) => retire(),
      onDone: retire,
    );
    if (repository case AuthenticatedSessionEvents source) {
      _keys = source.sessionKeyChanges.listen(
        (key) {
          if (key != _key || !current) retire();
        },
        onError: (Object _) => retire(),
        onDone: retire,
      );
    }
  }
  final MerchantPromotionRepository repository;
  final String owner;
  final void Function() onLost;
  final bool Function()? originIsCurrent;
  String? _key;
  bool _closed = false;
  StreamSubscription<String?>? _actors, _keys;
  bool get current =>
      !_closed &&
      (originIsCurrent?.call() ?? true) &&
      repository.currentUserId == owner &&
      (repository is! AuthenticatedSessionSource ||
          _key != null &&
              (repository as AuthenticatedSessionSource).currentSessionKey ==
                  _key);
  void retire() {
    if (_closed) return;
    _closed = true;
    onLost();
  }

  void close() {
    _closed = true;
    unawaited(_actors?.cancel());
    unawaited(_keys?.cancel());
  }
}

class PromotionPrivateOverlay extends StatefulWidget {
  const PromotionPrivateOverlay({
    super.key,
    required this.repository,
    required this.owner,
    required this.originIsCurrent,
    required this.child,
  });
  final MerchantPromotionRepository repository;
  final String owner;
  final bool Function() originIsCurrent;
  final Widget child;
  @override
  State<PromotionPrivateOverlay> createState() =>
      _PromotionPrivateOverlayState();
}

class _PromotionPrivateOverlayState extends State<PromotionPrivateOverlay> {
  late final PromotionViewSession _session;
  @override
  void initState() {
    super.initState();
    _session = PromotionViewSession(
      repository: widget.repository,
      owner: widget.owner,
      originIsCurrent: widget.originIsCurrent,
      onLost: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _session.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _session.current
      ? widget.child
      : AlertDialog(
          title: const Text('Oturum değişti'),
          content: const Text(
            'Bu pencereyi kapatıp tanıtım merkezini yeniden aç.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        );
}
