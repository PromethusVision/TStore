import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';

/// UI read deadline; it never wraps mutations or claims to cancel transport.
Future<Either<String, T>> merchantRead<T>(
  Future<Either<String, T>> Function() request, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  try {
    return await request().timeout(timeout);
  } on TimeoutException {
    return const Left(merchantReadTimeout);
  } catch (_) {
    return const Left(
      'Bilgiler alınamadı. Bağlantını kontrol edip yeniden dene.',
    );
  }
}
