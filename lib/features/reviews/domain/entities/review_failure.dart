import 'package:equatable/equatable.dart';

enum ReviewFailureKind {
  authRequired,
  invalidArgument,
  invalidRating,
  productNotFound,
  notVerified,
  reviewNotFound,
  unauthorized,
  network,
  unavailable,
  invalidResponse,
  unknown,
}

class ReviewFailure extends Equatable {
  final ReviewFailureKind kind;
  final String message;

  const ReviewFailure(this.kind, this.message);

  bool get requiresAuthentication => kind == ReviewFailureKind.authRequired;

  @override
  List<Object?> get props => [kind, message];
}
