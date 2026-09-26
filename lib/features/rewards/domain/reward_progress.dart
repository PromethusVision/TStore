import 'package:equatable/equatable.dart';

class RewardEligibleMerchant extends Equatable {
  const RewardEligibleMerchant({
    required this.id,
    required this.name,
    this.logoUrl,
  });
  final String id, name;
  final String? logoUrl;
  @override
  List<Object?> get props => [id, name, logoUrl];
}

/// Presentation progress only. No earning, money, eligibility or redemption rule.
class RewardProgress extends Equatable {
  const RewardProgress({
    this.steps = 0,
    this.merchants = const [],
    this.available = false,
  });
  static const goal = 5;
  final int steps;
  final List<RewardEligibleMerchant> merchants;
  final bool available;
  int get completed => steps.clamp(0, goal);
  int get remaining => goal - completed;
  double get fraction => completed / goal;
  @override
  List<Object?> get props => [steps, merchants, available];
}

class RewardProgressEvent {
  const RewardProgressEvent({
    required this.id,
    required this.before,
    required this.after,
  });
  final String id;
  final RewardProgress before, after;
}

abstract interface class RewardRepository {
  /// Future implementations must scope and cancel streams on account changes.
  Stream<RewardProgress> watchProgress(String? customerId);
}

class PendingRewardRepository implements RewardRepository {
  const PendingRewardRepository();
  @override
  Stream<RewardProgress> watchProgress(String? customerId) =>
      Stream.value(const RewardProgress());
}
