import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/merchant/presentation/merchant_edit_recovery.dart';
import 'package:t_store/features/merchant/presentation/merchant_read.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';

void main() {
  test(
    'every failed write requires a new read, never the previous reviewed snapshot',
    () async {
      final recovery = MerchantEditRecovery<int>(
        read: () async => const Right(7),
      );
      await recovery.save(() async => const Left('uncertain'));
      await recovery.reload();
      expect(recovery.current, 7);
      recovery.reviewed();
      await recovery.save(() async => const Left('conflict'));
      expect(recovery.needsReview, true);
      expect(recovery.loaded, false);
      expect(recovery.current, isNull);
      recovery.reviewed();
      expect(recovery.needsReview, true);
      recovery.dispose();
    },
  );
  test('pending write serializes both reads and duplicate writes', () async {
    final gate = Completer<Either<String, int>>();
    var reads = 0, writes = 0;
    final recovery = MerchantEditRecovery<int>(
      read: () async {
        reads++;
        return const Right(2);
      },
    );
    final first = recovery.save(() {
      writes++;
      return gate.future;
    });
    expect(
      await recovery.save(() async {
        writes++;
        return const Right(9);
      }),
      isNull,
    );
    await recovery.reload();
    expect(reads, 0);
    expect(writes, 1);
    gate.complete(const Right(1));
    expect(await first, 1);
    expect(recovery.needsReview, false);
    recovery.dispose();
  });
  test(
    'late write after disposal neither notifies nor returns success',
    () async {
      final gate = Completer<Either<String, int>>();
      final recovery = MerchantEditRecovery<int>();
      var notifications = 0;
      recovery.addListener(() => notifications++);
      final write = recovery.save(() => gate.future);
      expect(notifications, 1);
      recovery.dispose();
      gate.complete(const Right(2));
      expect(await write, isNull);
      expect(notifications, 1);
    },
  );
  test(
    'late failed read after disposal cannot notify a removed editor',
    () async {
      final gate = Completer<Either<String, int?>>();
      final recovery = MerchantEditRecovery<int>(read: () => gate.future);
      var notifications = 0;
      recovery.addListener(() => notifications++);
      final read = recovery.reload();
      recovery.dispose();
      gate.complete(const Left('late'));
      await read;
      expect(notifications, 1);
      expect(recovery.loaded, false);
    },
  );
  test('thrown save is uncertain and cannot be blindly retried', () async {
    final recovery = MerchantEditRecovery<int>(
      read: () async => const Right(null),
    );
    await recovery.save(() async => throw StateError('synthetic'));
    expect(recovery.needsReview, true);
    expect(recovery.error, isNot(contains('synthetic')));
    await recovery.reload();
    expect(recovery.loaded, true);
    expect(recovery.current, isNull);
    recovery.dispose();
  });
  test('read deadline is explicit and ignores late response', () async {
    final gate = Completer<Either<String, int>>();
    final result = await merchantRead(
      () => gate.future,
      timeout: const Duration(milliseconds: 10),
    );
    expect(result, const Left<String, int>(merchantReadTimeout));
    gate.complete(const Right(99));
    await Future<void>.delayed(Duration.zero);
    expect(result.isLeft(), true);
  });
  test('read exception is sanitized including synchronous throws', () async {
    final result = await merchantRead<int>(() => throw StateError('private'));
    expect(result.isLeft(), true);
    expect(result.fold((e) => e, (_) => ''), isNot(contains('private')));
  });
  test(
    'profile comparison preserves nested existing hours without order sensitivity',
    () {
      expect(
        merchantValuesEqual(
          {
            'b': [
              1,
              {'x': true},
            ],
            'a': 's',
          },
          {
            'a': 's',
            'b': [
              1,
              {'x': true},
            ],
          },
        ),
        true,
      );
      expect(merchantValuesEqual({'a': null}, {}), false);
      expect(merchantValuesEqual([1, 2], [2, 1]), false);
    },
  );
}
