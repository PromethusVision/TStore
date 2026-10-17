import 'package:dartz/dartz.dart';

/// A UI read deadline also covers injected/preview repositories. It does not
/// cancel transport. Writes retain their original command until transport ends.
Future<Either<E, T>> managementRequest<E, T>(
  Future<Either<E, T>> Function() request, {
  required E failure,
  bool write = false,
}) async {
  try {
    final pending = request();
    return await (write
        ? pending
        : pending.timeout(const Duration(seconds: 15)));
  } catch (_) {
    return Left(failure);
  }
}
