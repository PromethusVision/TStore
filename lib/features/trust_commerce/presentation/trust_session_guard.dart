import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_store/features/trust_commerce/domain/trust_commerce.dart';

/// Once a private route's actor leaves it never revives, even after re-login.
mixin TrustSessionGuard<T extends StatefulWidget> on State<T> {
  TrustCommerceRepository get trustRepository;
  String get trustActor;
  StreamSubscription<String?>? _subscription;
  bool _invalid = false;
  bool get sessionCurrent =>
      !_invalid && trustRepository.currentUserId == trustActor;
  void clearTrustSession() {}
  @override
  void initState() {
    super.initState();
    _subscription = trustRepository.sessionChanges.listen((actor) {
      if (actor != trustActor && mounted) {
        setState(() {
          _invalid = true;
          clearTrustSession();
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class TrustSessionExpired extends StatelessWidget {
  const TrustSessionExpired({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Oturum değişti')),
    body: const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Bu ekranı kapatıp hesabınızla yeniden giriş yapın.'),
      ),
    ),
  );
}

class PrivateTrustOverlay extends StatefulWidget {
  const PrivateTrustOverlay({
    super.key,
    required this.repository,
    required this.actor,
    required this.child,
  });
  final TrustCommerceRepository repository;
  final String actor;
  final Widget child;
  @override
  State<PrivateTrustOverlay> createState() => _PrivateTrustOverlayState();
}

class _PrivateTrustOverlayState extends State<PrivateTrustOverlay>
    with TrustSessionGuard<PrivateTrustOverlay> {
  @override
  TrustCommerceRepository get trustRepository => widget.repository;
  @override
  String get trustActor => widget.actor;
  @override
  Widget build(BuildContext context) => sessionCurrent
      ? widget.child
      : AlertDialog(
          title: const Text('Oturum değişti'),
          content: const Text('Bu ekranı kapatıp yeniden giriş yapın.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        );
}
