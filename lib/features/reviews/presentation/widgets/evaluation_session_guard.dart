import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:t_store/features/reviews/domain/repositories/purchase_evaluation_repository.dart';

/// A sheet/detail can outlive its parent auth page. Once its actor leaves,
/// discard pending display state and never revive it for a later session.
mixin EvaluationSessionGuard<T extends StatefulWidget> on State<T> {
  PurchaseEvaluationRepository get evaluationRepository;
  String? get evaluationActor;
  StreamSubscription<String?>? _sessionSubscription;
  bool _sessionInvalidated = false;
  bool get evaluationSessionCurrent =>
      !_sessionInvalidated &&
      evaluationActor != null &&
      evaluationRepository.currentUserId == evaluationActor;
  void clearEvaluationSession() {}
  @override
  void initState() {
    super.initState();
    _sessionSubscription = evaluationRepository.sessionChanges.listen((actor) {
      if (actor != evaluationActor && mounted) {
        setState(() {
          _sessionInvalidated = true;
          clearEvaluationSession();
        });
      }
    });
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }
}
