import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:t_store/features/reviews/domain/repositories/purchase_evaluation_repository.dart';

/// A sheet/detail can outlive its parent auth page. Once its actor leaves,
/// discard pending display state and never revive it for a later session.
mixin EvaluationSessionGuard<T extends StatefulWidget> on State<T> {
  PurchaseEvaluationRepository get evaluationRepository;
  String? get evaluationActor;
  Object? get evaluationResource => null;
  StreamSubscription<String?>? _sessionSubscription, _keySubscription;
  late final PurchaseEvaluationRepository _repository;
  late final String? _actor, _sessionKey;
  late final Object? _resource;
  bool _sessionInvalidated = false;
  bool get evaluationSessionCurrent =>
      !_sessionInvalidated &&
      identical(evaluationRepository, _repository) &&
      evaluationActor == _actor &&
      evaluationResource == _resource &&
      _actor != null &&
      _sessionKey != null &&
      _repository.currentUserId == _actor &&
      _repository.currentSessionKey == _sessionKey;
  void clearEvaluationSession() {}

  void _invalidate() {
    if (!mounted || _sessionInvalidated) return;
    setState(() {
      _sessionInvalidated = true;
      clearEvaluationSession();
    });
  }

  bool checkEvaluationContinuation() {
    if (!mounted) return false;
    if (!evaluationSessionCurrent) {
      _invalidate();
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _repository = evaluationRepository;
    _actor = evaluationActor;
    _resource = evaluationResource;
    _sessionKey = _repository.currentSessionKey;
    _sessionSubscription = _repository.sessionChanges.listen(
      (actor) {
        if (actor != _actor || !evaluationSessionCurrent) _invalidate();
      },
      onError: (Object _) => _invalidate(),
      onDone: _invalidate,
    );
    _keySubscription = _repository.sessionKeyChanges.listen(
      (key) {
        if (key != _sessionKey || !evaluationSessionCurrent) _invalidate();
      },
      onError: (Object _) => _invalidate(),
      onDone: _invalidate,
    );
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!evaluationSessionCurrent) _invalidate();
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    _keySubscription?.cancel();
    super.dispose();
  }
}
